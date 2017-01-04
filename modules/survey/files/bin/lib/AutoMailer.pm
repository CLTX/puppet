#
# $Log: AutoMailer.pm,v $
# Revision 1.2  2004/05/28 17:47:01  maxim
# Added multiple image attachment
#
# Revision 1.1  2004/03/29 14:45:20  maxim
# Added AUTOMAILER files
#
# Revision 1.7  2003/12/12 00:52:17  maxim
# Numerous changes
#
# Revision 1.6  2003/12/09 23:45:29  maxim
# Added UTF-8 charset
#
# Revision 1.4  2003/12/05 15:11:58  maxim
# One DB file for all locales. Test if the locale log exists
#
# Revision 1.3  2003/12/04 21:57:21  maxim
# Changed scripts to run from 'bin' instead of 'data'
#
# Revision 1.1.1.1  2003/12/01 21:24:15  maxim
# Automailer files check-in
#
#

=head1 NAME

AUTOMAILER - Base class for Automailers

=head1 SYNOPSIS

use AutoMailer;
my $am = AutoMailer->create(\%options);

=head1 DESCRIPTION

AutoMailer implements methods to handle automailing tasks.
It is derived from B<Class::Base>.
See a man page for B<Class::Base> for the implementation details.

=head1 CONSTRUCTOR

The object inherits a constructor from the parent class.

=begin testing

use_ok('Class::Base');
use_ok('AutoMailer');
use_ok('Data::Dumper');
use_ok('File::Basename');
use_ok('File::Spec::Functions');
use_ok('Log::Dispatch::File');
use_ok('Log::Log4perl');
use_ok('XML::Simple');
use_ok('Sys::Hostname');
use_ok('File::Path');
use_ok('IO::File');

=end testing

=cut

package AutoMailer;

# version
our $VERSION = 1.000;

# pragmas
use strict;
use warnings;
use base qw( Class::Base );

# Extension Modules
use FileHandle;
use File::Temp;
use Net::SMTP;
use Date::Parse;
use Tie::DB_Lock;
use DB_File::Lock;
use Fcntl qw(:flock O_RDWR O_CREAT O_RDONLY); 

use FindBin;
use lib "$FindBin::Bin/lib";
use Date::Parse;
use XML::Simple;
use Sys::Hostname;
use IO::File; 
use File::Slurp; 
use File::Basename; 
use File::Spec::Functions; 
use Log::Dispatch::File;
use Log::Log4perl qw(:easy); 
use Email::Valid;
use CGI::Enurl;
use CGI::Deurl qw(NOCGI);
use MIME::Entity;
use HTML::Template;
use Data::Dumper; 
$Data::Dumper::Indent = 3;

# return codes
sub SUCCESS () {   1   }
sub FAILED  () { undef }

# set some environment vars
$ENV{'HOME'}        = "C" unless $ENV{'HOME'};
$ENV{'LOCALDOMAIN'} = "appname05-poll.com" unless $ENV{'LOCALDOMAIN'};
$ENV{'DOMAIN'}      = "appname05-poll.com" unless $ENV{'DOMAIN'};

=head1 METHODS

=head2 B<init($config)>

A method to store configuration parameters in a newly created object.
It is defined in the parent Class::Base. The method accept a reference to 
HASH of optional arguments. 

=begin testing

=end testing

=cut

# set all the keys passed to new
sub init
{
    my ($self, $conf) = @_;
    
    if ($conf and ref($conf) eq "HASH") {
        # copy parameters into $self
        foreach my $key (keys %{ $conf }) {
            $self->{$key} = $conf->{$key};
        }
    }
    
    return $self;
}

=head2 B<create(\%options)>

A method to create an object.

=over 4

=item *

basename: e.g. $config->{'basename'} = 'myfile'. This name will be used to look up
the application config file: e.g. myfile.xml. The '.xml' extension will be added
to the bas file name. Hence, DO NOT supply any extension to the bas name. Default is
a script name without the extension

=item *

basedir: e.g. $config->{'basedir'} = 'mydir'. This is used to located the application
config and log files. The config file must be located under 'mydir/cfg' and the log
file under 'mydir/logs'. Default is a script appname03ory

=back

It can accept a config from a different object. When passed { 'config' => $config }, it doesn't
look for 'logs' and 'cfg' appname03ories. It assumes all the info it needs is in the supplied $config.
This is convenient for testing: you don't have to create the mandatory appname03ories and config files:
just pass { 'config' => 1 } and do your testing by calling the object methods.
Otherwise, it will try to load 'logs/basename.conf' and 'cfg/basename.xml'. If the above files can't
be found, the script dies. When created properly, the object install two signal handlers to capture
the output of WARNINGS and FATALS to the log file.

=begin testing

=end testing

=cut

# method to create an AutoMailer object
sub create
{
    my $class = shift || __PACKAGE__; # class name
    my $conf  = shift;                # config HASH
    
    # check, if $conf is a ref to HASH
    if ($conf and ref($conf) ne "HASH") {
        die "Method accepts an optional reference to a HASH";
    } elsif (!$conf) {
        # initialize it
        $conf = {};
    }
    
    # open LOG and read the config
    unless (exists $conf->{'config'}) {
        
        # store the config in $self later
        $conf->{'config'} = _init_config($conf);
        
    } # unless exists $conf->{'config'}
    
    # use the parent method to create an object
    my $self = AutoMailer->new
        (
         %{ $conf }
        );
    
    # bless itself into $class
    bless $self, $class;
}

=head2 B<_init_config($hashref)>

Initializes log, reads XML cfg, installs signal handlers etc.

=cut

sub _init_config
{
    my $conf = shift;   # input HASH ref of {key => val}
    
    # config to return
    my $config;
    
    # base file name and appname03ory
    my $basename;
    my $basedir;
    $basename = $conf->{'basename'} || basename($0);
    $basedir  = $conf->{'basedir'}  || dirname($0);
    
    # strip the extension
    $basename =~ s|\.\w+$||;
    
    # append ".xml" to the app config
    my $appcfgfile = $basename . ".xml";
    
    # append ".conf" to the log config
    my $logcfgfile = $basename . ".conf";
    $logcfgfile = catfile($basedir, "logs", $logcfgfile);
    
    # initialize $log and check the config every 5 min for possible changes
    Log::Log4perl->init_and_watch($logcfgfile, 300);
    
    # host name
    my $hostname = hostname();
    my $ip = $ENV{'HTTP_HOST'} || $hostname || "LocalHost";
    
    # create a starting entry
    Log::Log4perl::MDC->put("IP", $ip);
    
    # catch fatals to the log
    local $SIG{__DIE__} = sub {
        $Log::Log4perl::caller_depth++;
        # get the logger
        my $log = get_logger();
        $log->fatal(@_);
        
        exit 1;
    };
    
    # catch warnings to the log
    local $SIG{__WARN__} = sub {
        $Log::Log4perl::caller_depth++;
        # get the logger
        my $log = get_logger();
        $log->warn(@_);
    };
    
    # read the app config now
    # ------------------------
    my $log = get_logger();
    $appcfgfile = catfile($basedir, "cfg", $appcfgfile);
    if ($log->is_debug()) {
        $log->debug("XML Config file name: '$appcfgfile'");
    }
    
    $config = XMLin($appcfgfile);
    if ($log->is_debug()) {
        $log->debug("XML Config: ", sub { Dumper($config) });
    }
    
    unless ($config) {
        die "Couldn't load the application config file '$appcfgfile': $!";
    }
    
    # store logger into $config
    $config->{'logger'} = $log;
    
    return $config;
}

=head2 B<get_log()>

Gets log4perl logger from $self

=cut

sub get_log
{
    my $self = shift;
    return $self->{'config'}->{'logger'};
}

###################################################################################################
# AutoMailer Utility Methods
###################################################################################################

=head2 B<get_skip(%args)>

This method is used to determine the number of records to skip in a text log file. It must get
a logfile name as an agrument. The method stores the number of lines to skip in a Berkeley DB.
This is a temporary solution. The method will not be used once the data is appname03ly written to
MS SQL database

=begin testing

=end testing

=cut

sub get_skip
{
    my $self = shift;
    my %args = @_;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # log file name
    my $logfile  = $args{'logfile'};
    my $data_dir = $args{'data_dir'};
    
    # number of lines to skip
    my $skip = 0;
    
    # sanity check
    unless ($logfile) {
        $log->error("No LOG file name specified !!! Setting Skip = 0");
        return $skip;
    }
    
    unless ($data_dir) {
        $log->error("No DATA appname03ory specified !!! Setting Skip = 0");
        return $skip;
    }
    
    # re-define $skip
    my $log_file = catfile($data_dir, $logfile);
    $skip = $self->bdb_val(
                           'key' => $log_file,
                          );
    
    unless (defined($skip)) {
        $log->error("Skip undefined !!! Setting Skip = 0");
        $skip = 0;
    }
    
    if ($log->is_debug()) { 
        $log->debug("Log file: '$logfile'. Skip: $skip"); 
    } 
    
    return $skip;

} # get_skip


=head2 B<check_log(%args)>

The method scans the LOG file for new records and inserts them into MS SQL database.
This is a temporary solution. The method will not be used once the data is appname03ly written to
MS SQL database

=begin testing

=end testing

=cut

sub check_log
{
    my $self       = shift;
    my %args       = @_;
    my $skip_lines = $args{'skip_lines'};
    my $position   = $args{'position'};
    my $data_dir   = $args{'data_dir'};
    my $logfile    = $args{'logfile'};
    my $appname05     = $args{'appname05'};
    my $sql        = $args{'sql'};
    
    my $log = get_logger();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    } 
    
    # sanity check
    unless ($logfile) {
        $log->error("No LOG file name specified !!!");
        return FAILED;
    }
    
    unless ($data_dir and -e $data_dir) {
        $log->error("DATA appname03ory not specified  or doesn't exists: '",$data_dir ? $data_dir : 'undef',"' !!!");
        return FAILED;
    }
    
    unless ($appname05) {
        $log->error("No appname05 name specified !!!");
        return FAILED;
    }
    
    unless ($sql) {
        $log->error("No SQL object specified !!!");
        return FAILED;
    }
  
    my $fh = new FileHandle;
    my $count = 0;
  
    my $xs = new XML::Simple();
  
    if (defined $position) {
        $count = $skip_lines;
    }
    
    # log with absolute path
    my $log_file = catfile($data_dir, $logfile);
    
    if( $fh->open("< " . $log_file)) {
        
        if(  defined $position ) {
            $fh->setpos( $position );
        }
        
        # go through line by line
        while (my $line = $fh->getline()) {
            
            chomp($line);
            $count++;
            
            if ( ( defined $position ) || $count > $skip_lines ) {
                
                # set position
                $position = $fh->getpos();
                
                if ( length ( $line ) > 20 ) {
                    
                    if ($log->is_debug()) { 
                        $log->debug("Log file '$logfile'. Processing line # $count"); 
                    } 
                    
                    my ( $time_str, $xml_str ) = split( /\t/, $line );
                    my $ref;
                    
                    if ($xml_str) {
                        
                        $xml_str =~ s/\&/\&amp;/g;
                        eval {
                            local $SIG{__DIE__} = 'DEFAULT';
                            $ref = $xs->XMLin( $xml_str,  forcearray => 1 );
                        };
                        if( $@ ) {
                            $log->error("Log file '$logfile'. Error Parsing Line # $count '$xml_str': $@");
                            next ;
                        }
                        
                    } else {
                        
                        $log->error("Log file '$logfile'. Error Parsing Line # $count: \$xml_str undefined !");
                        next ;
                    
                    } # if $xml_str
                    
                    # update MS SQL tables
                    $self->insert_log_rec(
                                          'appname05'    => $appname05,
                                          'file_name' => $logfile,
                                          'ref'       => $ref,
                                          'sql'       => $sql,
                                          'date'      => $time_str,
                                         );
                    
                    $fh->setpos( $position );
                
                } else {
                    
                    $log->warn("Log file '$logfile'. Line # $count '$line' < 20 chars. Skipping...");
                
                } # length of line
            
            } else {
                
                if ($log->is_debug()) { 
                    $log->debug("Log file '$logfile'. Skipped line # $count"); 
                } 
            } # of skip lines
        
        } # end while line
        
        # save the current position
        my $rc = $self->bdb_val(
                                'key' => $log_file,
                                'val' => $count,
                               );
        
        unless (defined($rc)) {
            $log->error("Couldn't save the current position '$count' in the log file '$logfile'");
        }
        
        if ($log->is_debug()) { 
            $log->debug("Log file: '$logfile'. Count: $count"); 
        } 
        
    } else {
        
        $log->error("Unable to open file: '$log_file'");
    
    } # endif open $logfile

} # check_log


=head2 B<bdb_val(%args)>

The method gets/sets/inintializes the value passed as a parameter in the Berkeley DB.
If $args{'val'} is present, then the method sets/initializes $key to $val. Otherwise
returns the value of $key. Returns UNDEF on failure

=begin testing

=end testing

=cut

sub bdb_val
{
    my $self = shift;
    my %args = @_;
     
    my $log = get_logger();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # input params
    my $key = $args{'key'};
    my $val = exists $args{'val'} ? $args{'val'} : undef;
    
    # sanity check
    unless ($key) {
        $log->error("No 'key' specified !!!");
        return FAILED;
    }
    
    if (exists $args{'val'} and not defined($val)) {
        $log->error("Can't set key '$key' to undefined value !!!");
        return FAILED;
    }
    
    # open/create database
    my $dbdir  = dirname($key);
    my $dbfile = catfile($dbdir,($self->{'config'}->{'database'}->{'dbfile'} ? $self->{'config'}->{'database'}->{'dbfile'} : "skip.db"));
    my %database;
    my $db;
    
    # '$key' is a full path to log file, get the base name only
    $key = basename($key);
    
    $db = tie ( %database, 'DB_File::Lock', $dbfile, O_CREAT | O_RDWR, 0666 , $DB_HASH, 'write');
    
    if ($db) {
        if (exists $args{'val'}) {
            # set
            if (exists $database{$key}) {
                $log->info("Key '$key' has value of '$database{$key}'. Setting it to '$val'");
            } else {
                $log->info("No entry for key '$key'. Initializing it with '$val'");
            }
            $database{$key} = $val;
        } else {
            # get
            if (exists $database{$key}) {
                $val = $database{$key};
            } else {
                $val = 0;
                $log->info("No entry for key '$key'. Initializing it with '$val'");
                $database{$key} = $val;
            }
        }
    } else {
        # error
        $log->error("Can't open/create database '$dbfile'");
        $val = undef;
    }
    
    undef $db;
    untie %database; 
    
    # result
    return $val;
    
} # bdb_val


=head2 B<insert_log_rec(%args)>

The method writes LOG records into MS SQL database.
This is a temporary solution. The method will not be used once the data is appname03ly written to
MS SQL database

=begin testing

=end testing

=cut

sub insert_log_rec
{
    my $self = shift;
    my %args = @_;
     
    my $log = get_logger();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # input args
    my $appname05    = $args{'appname05'};
    my $file_name = $args{'file_name'};
    my $ref       = $args{'ref'};
    my $sql       = $args{'sql'};
    my $date      = $args{'date'};
    
    # sanity check
    unless ($file_name) {
        $log->error("No LOG file name specified !!!");
        return FAILED;
    }
    
    unless ($appname05) {
        $log->error("No appname05 name specified !!!");
        return FAILED;
    }
    
    unless ($sql) {
        $log->error("No SQL object specified !!!");
        return FAILED;
    }
    
    my %log = ();
    if ( ! defined( $ref )) {
        
        # assign defaults
        $log{'REFERER'}      = "No Referrer"; 
        $log{'TIMESECOND'}   = str2time( $date ); 
        $log{'SESSIONID'}    = undef; 
        $log{'LOG'}          = $file_name; 
        $log{'appname05'}       = $appname05; 
        $log{'CLIENT_IP'}    = undef; 
        $log{'CGI_PARAMS'}   = undef; 
        
    }  else {
        
        # assign values
        $log{'REFERER'}      =  $ref->{REFERER}->[0]{'value'};
        $log{'TIMESECOND'}   =  $ref->{TIMESECOND}->[0]{'value'};
        $log{'SESSIONID'}    =  $ref->{SESSIONID}->[0]{'value'};
        $log{'LOG'}          =  $file_name;
        $log{'appname05'}       =  $appname05;
        $log{'CLIENT_IP'}    =  $ref->{CLIENT_IP}->[0]{'value'};
        my %form = ();
        foreach my $key ( keys %{$ref->{VARIABLES}->[0]{VARIABLE} }) {
           $form{ $key } =$ref->{VARIABLES}->[0]{VARIABLE}->{ $key }->{'value'};
        }
        $log{'CGI_PARAMS'}   =  \%form;
    
    } # endif ! defined $ref
    
    # run update
    $sql->addLine( 'log' => \%log ) ;

} # insert_log_rec


=head2 B<que_mail(%args)>

The method queues and sends e-mails

=begin testing

=end testing

=cut

sub que_mail
{
    my $self = shift;
    my %args = @_;
    
    my $log = get_logger();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # input params
    my $data = $args{'data'};
    my $sql  = $args{'sql'};
    
    # sanity check
    unless ($sql) {
        $log->error("No SQL object specified !!!");
        $log->error("Input args: ", sub {Dumper(\%args)}); 
        return FAILED;
    }
  
    unless ($data and ref($data) eq "HASH") {
        $log->error("No correct \$data structure specified !!!");
        return FAILED;
    }
    
    if ($log->is_debug()) { 
        $log->debug("DATA: ", sub {Dumper($data)}); 
    }
  
    #
    # Max sent check ???
    #
    
    #
    # 'data' structure from Peter:
    # $data->{
    #         'message_id' => $message_id,
    #         'to_address' => 'SomeAddress@to.send',
    #         'text_template_ref' => $text_template_ref,
    #         'html_template_ref' => $html_template_ref,
    #        }
    #
    
    # connect to any SMTP server
    my $smtp;
    foreach my $svr (@{ $data->{'smtp_servers'} }) {
        $smtp = Net::SMTP->new($svr);
        last if $smtp;
    }
    
    unless ($smtp) {
        $log->error("Couldn't connect to any of the following SMTP servers: ", sub{Dumper($data->{'smtp_servers'})});
        return FAILED;
    }
  
    # message object. Modufy the header to identfy undeliverables
    my $msg = MIME::Entity->build( 
                                   'To'          => $data->{'to_address'},
                                   'From'        => $data->{'from_address'}, 
                                   'Bcc'         => $data->{'bcc_address'},
                                   'Reply-To'    => $data->{'reply_address'},
                                   'Subject'     => $data->{'subject'},
                                   'X-MessageID' => $data->{'message_id'},
                                   'X-appname05ID'  => $data->{'appname05_id'},
                                   'Encoding'    => '8bit',
                                   'Type'        => 'multipart/alternative',
                                 );
  
    # TEXT attachment processing
    my $textfile;
    
    # make sure TEXT temlate exists
    my $text_template = $data->{'text_template'};
    unless (-e $text_template) {
        # en-us as default
        $text_template = catfile(dirname($text_template),$self->{'config'}->{'template'}->{'text'});
    }
    
    eval
    {
        $textfile = HTML::Template->new(
                                        'filename'          => $text_template,
                                        'die_on_bad_params' => 0,
                                       );
    };
    
    if ( $@ ) {
        $log->error("HTML::Template 'text' error: $@");
        return FAILED;
    }
    
    # run it
    eval
    {
        $textfile->param( $data->{'text_template_ref'} );
    };
    
    if ( $@ ) {
        $log->error("HTML::Template 'text' error: $@");
        return FAILED;
    }
    
    # HTML attachment processing
    my $htmlfile;
    
    # make sure HTML temlate exists
    my $html_template = $data->{'html_template'};
    unless (-e $html_template) {
        # en-us as default
        $html_template = catfile(dirname($html_template),$self->{'config'}->{'template'}->{'html'});
    }
    
    eval
    {
        $htmlfile = HTML::Template->new(
                                        'filename'          => $html_template,
                                        'die_on_bad_params' => 0,
                                       );
    };
    
    # run it
    eval
    {
        $htmlfile->param( $data->{'html_template_ref'} );
    };
    
    if ( $@ ) {
        $log->error("HTML::Template 'html' error: $@");
        return FAILED;
    }
    
    # attach processed templates
    # TEXT
    my $plain = $msg->attach( 'Type'     => 'text/plain; charset=UTF-8',
                              'Encoding' => '8bit',
                              'Data'     => [ $textfile->output() ],
                            );
    # HTML
    my $fancy = $msg->attach('Type' => 'multipart/related');  
    $fancy->attach( 'Type'     => 'text/html; charset=UTF-8',
                    'Encoding' => '8bit',
                    'Data'     => [ $htmlfile->output() ],
                  );
    
    # check for images to attach
    my %images = $self->get_images(
                                   'sql'       => $sql,
                                   'appname05_id' => $data->{'appname05_id'},
                                  );
    
    if (keys %images) {
        
        # attach them here
        foreach my $img (sort keys %images) {
            my $real_name = $images{$img};
            $real_name =~ s|\\|/|g;
            $real_name =~ s|//|/|g;
            unless (-e $real_name) {
                $log->error("Image file '$real_name' doesn't exist !");
                next;
            }
            my $id = basename($real_name);
            $fancy->attach(
                           Path => $real_name,
                           Type => "image/gif",
                           Encoding => "base64",
                           "Content-ID" => "<$img>",
                           ID => $id,
                          );
        } # end of foreach $img
        
    } # endif %images
    
    # run update on SQL tables beforehand
    my $rc = $sql->update_automail_message(
                                           'message_id'     => $data->{'message_id'},
                                           'message_status' => 2,
                                          );
    if ($rc == SUCCESS) {
        # Actually, send e-mail
        $smtp->mail($data->{'from_address'});
        $smtp->to($data->{'to_address'}, $data->{'bcc_address'});
        $smtp->data();
        $smtp->datasend( $msg->as_string );
        $smtp->dataend();
        $smtp->quit;
        return SUCCESS;
    
    } else {
        # inform of failure
        $log->error("E-mail '",$data->{'to_address'},"' is NOT sent because the table update failed !");
        return FAILED;
    }

} # que_mail


=head2 B<get_images(%args)>

The method returns a HASH of images to attach. In order not to break
the existing functionality there is some redundant code inside the method

=begin testing

=end testing

=cut

sub get_images
{
    my $self = shift;
    my %args = @_;
    
    my $log = get_logger();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # HASH of images
    my %images;
    
    # sql object
    my $sql = $args{'sql'};
    
    # appname05 ID
    my $appname05_id = $args{'appname05_id'};
    
    # sanity check
    unless ($sql) {
        $log->error("No SQL object specified !!!");
        return FAILED;
    }
  
    unless ($appname05_id) {
        $log->error("No \$appname05_id specified !!!");
        return FAILED;
    }
    
    # get the appname05_file from appname05_id
    my $appname05_file = "";
    my $dbh = $sql->{DBH};
    my $stmt = "SELECT appname05_file FROM appname05 WHERE appname05_id = $appname05_id";
    my $array_ref = undef;
    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        $array_ref = $dbh->selectall_arrayref($stmt);
    };
    
    if ( $@ ) {
        $log->error("Error in '$stmt' selecting appname05 file: $@");
        return FAILED;
    } else {
        # get the results
        $appname05_file = $array_ref->[0]->[0];
        unless ($appname05_file) {
            $log->error("No appname05 file selected: '$stmt'");
            return FAILED;
        }
    }
    
    # get the array of appname05s
    my @appname05s = $self->get_logfile_array('logfile' => $self->{'config'}->{'appname05'});
    foreach my $appname05_hash (@appname05s) {
        
        # skip, if no <images>
        next unless exists $appname05_hash->{'images'};
        
        # get the list of logs
        my @logs = $self->get_logfile_array('logfile' => $appname05_hash->{'log'});
        
        # appname05 appname03ory
        my $appname05_dir = $appname05_hash->{'appname05_dir'};
        
        # check, if any of the logs match appname05_file
        my $matched = 0;
        foreach my $logfile (@logs) {
            $logfile = $appname05_dir . "/" . $logfile;
            if ($logfile eq $appname05_file) {
                $matched++;
                last;
            }
        }
        
        if ($matched) {
            
            # DATA appname03ory
            my $script_dir = dirname($FindBin::Bin);
            my $data_dir   = $self->get_data_dir(
                                                 'script_dir' => $script_dir,
                                                 'appname05_dir' => $appname05_dir,
                                                );
            # image dir
            my $image_dir = $data_dir;
            $image_dir =~ s|data|appname05|i;
            
            # get the images
            foreach my $image (keys %{ $appname05_hash->{'images'} }) {
                $images{$image} = $image_dir . "/" . $appname05_hash->{'images'}->{$image};
            }
        } # endif $matched
    
    } # end of foreach $appname05
    
    wantarray ? %images : \%images;
    
} # get_images


=head2 B<get_data_dir(%args)>

The method returns the absolute path to the data appname03ory

=begin testing

=end testing

=cut

sub get_data_dir
{
    my $self = shift;
    my %args = @_;
    
    my $log = get_logger();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    my $script_dir = $args{'script_dir'};
    my $appname05_dir = $args{'appname05_dir'};
    
    # sanity check
    unless ($script_dir) {
        $log->error("No script appname03ory specified !!!");
        return FAILED;
    }
    
    unless ($appname05_dir) {
        $log->error("No appname05 appname03ory specified !!!");
        return FAILED;
    }
    
    # convert to the full path
    my $fullpath = catfile($script_dir,"data",$appname05_dir);
    
    # check, if the path exists
    unless (-e $fullpath) {
        # we are called from the DATA
        $fullpath = $FindBin::Bin;
    }
    
    if ($log->is_debug()) { 
        $log->debug("Full path: '$fullpath'"); 
    }
    
    return $fullpath;
    
} # get_logfile_with_path


=head2 B<get_logfile_array(%args)>

The method returns the array of log files to work with: en_us, de_de, etc.

=begin testing

=end testing

=cut

sub get_logfile_array
{
    my $self = shift;
    my %args = @_;
    
    my $log = get_logger();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    my $logfile = $args{'logfile'};
    
    # error flag
    my $error;
    
    # sanity check
    unless ($logfile) {
        $log->error("No logfile specified !!!");
        $error++;
    }
    
    # return array
    my @logfiles = ();
    
    unless ($error) {
        if (ref($logfile) eq "ARRAY") {
            # ref to ARRAY
            @logfiles = @{ $logfile };
        } elsif (ref($logfile) eq "SCALAR") {
            # ref to SCALAR
            push @logfiles, $$logfile;
        } elsif (ref($logfile) eq "HASH" or ref($logfile) eq "CODE") {
            # ref to HASH
            push @logfiles, $logfile;
        } elsif (ref($logfile) eq "CODE") {
            # ref to CODE
            $log->error("Input must be a SCALAR, a ref to ARRAY, HASH or SCALAR !!!");
        } else {
            # a SCALAR
            push @logfiles, $logfile;
        }
    } # unless $error
    
    wantarray ? @logfiles : \@logfiles;

} # get_logfile_array

1;

__END__


=head2 B<get_config(%args)>

The method gets automailer config from MS SQL database.

=begin testing

=end testing

=cut

sub get_config
{
    my $self = shift;
    my %args = @_;
    
    my $log = get_logger();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # input args
    my $sql     = $args{'sql'};
    my $logfile = $args{'logfile'};
    
    # sanity check
    unless ($sql) {
        $log->error("No SQL object specified !!!");
        return FAILED;
    }
    
    unless ($logfile) {
        $log->error("No LOG file name specified !!!");
        return FAILED;
    }
    
    my $hashref;
    my $dbh = $sql->{DBH};
    my $stmt = "SELECT a.\*, s.appname05_file AS appname05_file, m.name AS method_name FROM automail_config a, appname05 s, automail_method m WHERE a.logfile LIKE '$logfile' AND a.appname05_id = s.appname05_id AND a.method_id = m.method_id";
    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        $dbh->{'FetchHashKeyName'} = 'NAME_lc';
        $hashref = $dbh->selectall_hashref($stmt, 'automail_config_id');
    };
    
    if ( $@ ) {
        $log->error("Error selecting config: $@");
    }
    
    if ($log->is_debug()) { 
        $log->debug("Results: ", sub {Dumper($hashref)}); 
    }
    
    if (keys %{ $hashref } > 1) {
        $log->error("Query '$stmt' returned more than one row ! ", sub {Dumper($hashref)});
    }
    
    # we should return one row only
    my ($key, $val) = each %{ $hashref };
    
    # get the list of SMTP servers to connect to
    $stmt = "SELECT smtp_server FROM automail_smtp_servers ORDER BY preference";
    my $array_ref;
    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        $array_ref = $dbh->selectall_arrayref($stmt);
    };
    
    if ( $@ ) {
        $log->error("Error in '$stmt' selecting SMTP servers: $@");
        # assign default SMTP server
        $val->{'smtp_servers'} = [ "smtp.appname05-poll.com" ];
    } else {
        # get the results
        foreach my $aryref (@{ $array_ref }) {
            push @{ $val->{'smtp_servers'} }, $aryref->[0];
        }
    }
    
    # get the list of alert recipients
    $stmt = "SELECT email FROM automail_recipients WHERE active = 1";
    $array_ref = undef;
    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        $array_ref = $dbh->selectall_arrayref($stmt);
    };
    
    if ( $@ ) {
        $log->error("Error in '$stmt' selecting alert recipients: $@");
        # assign default recipient
        $val->{'alert_recipients'} = [ "maxim.maltchevski\@appname05site.com","peter.hircock\@appname05site.com" ];
    } else {
        # get the results
        foreach my $aryref (@{ $array_ref }) {
            push @{ $val->{'alert_recipients'} }, $aryref->[0];
        }
    }
    
    wantarray ? %{ $val } : $val;

} # get_config


=head2 B<update_automail_message(%args)>

The method updates the automail_message table

=begin testing

=end testing

=cut

sub update_automail_message
{
    my $self = shift;
    my %args = @_;
    
    my $log = get_logger();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # input args
    my $sql        = $args{'sql'};
    my $message_id = $args{'message_id'};
    
    # sanity check
    unless ($sql) {
        $log->error("No SQL object specified !!!");
        $log->error("Input args: ", sub {Dumper(\%args)}); 
        return FAILED;
    }
  
    unless ($message_id) {
        $log->error("No \$message_id specified !!!");
        return FAILED;
    }
    
    my $dbh = $sql->{DBH};
    my $stmt = "UPDATE automail_message SET sent_timestamp = getdate(), message_status_id = 2 WHERE automail_message_id = $message_id";
    
    # start transaction
    eval
    {
        local $SIG{__DIE__} = 'DEFAULT';
        my $sth = $dbh->prepare($stmt);
        $sth->execute();
        $sth->finish();
    };
    
    if ( $@ ) {
        $log->error("Error executing '$stmt': $@");
        # undo changes
        $dbh->rollback();
        return FAILED;
    } else {
        # OK
        if ($log->is_debug()) { 
            $log->debug("Successfully updated message ID '$message_id'"); 
        }
        $dbh->commit();
        return SUCCESS;
    }
}

=head1 AUTHOR

Maxim Maltchevski, appname05 Site
E<lt>maxim.maltchevski@appname05site.comE<gt>

=head1 BUGS

=head1 COPYRIGHT

Copyright (c) 2003, appname05 Site.  All Rights Reserved.

=cut
