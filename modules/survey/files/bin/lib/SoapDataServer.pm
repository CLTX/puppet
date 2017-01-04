#
# $Log: SoapDataServer.pm,v $
# Revision 1.2  2004/06/24 18:59:25  maxim
# Put call to Storable into eval
#
# Revision 1.1  2004/03/31 21:09:40  maxim
# Added BDB/SOAP stuff to new repository
#
# Revision 0.12  2003/12/08 23:09:21  maxim
# sql obj doesn't need params
#
# Revision 0.11  2003/08/11 15:51:51  maxim
# Added LOCAL to SIGs. Created a DESTROY
#
# Revision 0.10  2003/06/26 16:04:18  maxim
# Added INFO message to keep track of deleted recs
#
# Revision 0.9  2003/06/17 20:13:05  maxim
# Sender is an NT service
#
# Revision 0.8  2003/06/12 21:11:20  maxim
# New apiSQL interface used
#
# Revision 0.7  2003/06/10 15:33:58  maxim
# A few debug statements commented out
#
# Revision 0.6  2003/06/05 16:31:55  maxim
# send_remote, send_local return whatever they got from SOAP instead of SUCCESS
#
# Revision 0.5  2003/06/03 19:19:18  maxim
# to_sql re-written
#
# Revision 0.4  2003/05/30 20:25:51  maxim
# Tweaked SOAP error handling
#
# Revision 0.3  2003/05/29 13:52:24  maxim
# Added fallback to LOG for remote send
#
# Revision 0.2  2003/05/29 13:38:09  maxim
# Init LOG, CFG separated into a function
#
# Revision 0.1  2003/05/28 20:33:14  maxim
# Reset SIGDIE inside eval
#
# Revision 0.0.0.1  2003/05/28 14:30:56  maxim
# Initial import to CVS
#
#

=head1 NAME

SOAPDATASERVER - SOAP Data Server Implementation

=head1 SYNOPSIS

use SoapDataServer;

=head1 DESCRIPTION

Implements a SOAP::Lite based server for a data exchange between different clients

=cut

package SoapDataServer;

# pragmas
use strict;
use warnings;

# version
our $VERSION = 1.000;

# Extension Modules
use SOAP::Lite;
use IO::File;
use Cwd;
use Carp;
use Data::Dumper;
$Data::Dumper::Indent = 3;
use Log::Log4perl qw(:easy);
use XML::Simple;
use File::Basename;
use File::Spec::Functions;
use Sys::Hostname;
use Storable;

# the application config
use vars qw( $config );

# wrapper around BerkeleyDB
use BDB;

# return codes
sub SUCCESS {   1   }
sub FAILED  { undef }

################################################################################################
# constructor
################################################################################################
=head1 CONSTRUCTOR

=head2 B<new()>

Accepts no arguments. Stores a newly read XML config file in self. The default
location for the config file ./cfg

=cut

$SoapDataServer::DefaultClass = 'SoapDataServer' unless defined $SoapDataServer::DefaultClass;
sub new
{
    my ($class, $conf) = @_;
    my $self = {};
    
    # check, if $conf is a ref to HASH
    if ($conf and ref($conf) ne "HASH") {
        die "Method accepts an optional reference to a HASH";
    }
    
    # open LOG and read the config
    unless (exists $conf->{'config'}) {
        
        # store the config in $self later
        $config = _init_config($conf);
        
    } else {
        
        # get it from $conf
        $config = $conf->{'config'};
        
    } # unless exists $conf->{'config'}
    
    # bless itself
    bless $self, ref $class || $class || $SoapDataServer::DefaultClass;
    
    # store the config in $self
    $self->{'config'} = $config;
    
    # return the object
    return $self;
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
    
    return $config;
}

###################################################################################################
# Data Access Methods
###################################################################################################

=head1 METHODS

=head2 B<get_config()>

Returns the config HASH in the list context or HASH ref otherwise

=cut

sub get_config
{
    wantarray ? %{ shift->{'config'} } : shift->{'config'};
}

=head2 B<get_data_line($value[,$type])>

Gets the data line out of the "frozen" $value. Returns the ".dat" line by default, 
'log' line, if specified as $type, or an empty string

=cut

sub get_data_line
{
    my $self  = shift;
    my $value = shift;
    my $type  = lc shift;
    
    $type = "dat" unless $type;
    
    # get the log
    my $log = get_logger();
    #$log->debug("Type: '$type'");
    
    # sanity check
    return "" unless $value;
    
    # thaw the $value
    my $thawed = Storable::thaw($value);
    
    unless (ref($thawed) eq "HASH") {
        $log->error("Thawed value is NOT a HASH ref: ",ref($thawed));
        return "";
    }
    
    #if ($log->is_debug()) {
    #    $log->debug("Thawed: ", sub{Dumper($thawed)});
    #}
    
    # get the dat-line
    my $dat_line;
    if ($type eq 'dat') {
        $dat_line = defined($thawed->{'dat'}->{'line'}) ? $thawed->{'dat'}->{'line'} : "";
    } elsif ($type eq 'log') {
        $dat_line = defined($thawed->{'log'}) ? $thawed->{'log'} : "";
    } else {
        $log->error("Invalid record type '$type'");
        return "";
    }
    
    # return it
    return $dat_line;

} # get_data_line

=head2 B<get_appname05_name($value)>

Gets the data line out of the "frozen" $value. Returns the appname05 name or an empty string

=cut

sub get_appname05_name
{
    my $self  = shift;
    my $value = shift;
    
    # get the log
    my $log = get_logger();
    
    # sanity check
    return "" unless $value;
    
    # thaw the $value
    my $thawed = Storable::thaw($value);
    
    unless (ref($thawed) eq "HASH") {
        $log->error("Thawed value is NOT a HASH ref: ",ref($thawed));
        return "";
    }
    
    # get the appname05 name
    my $name = "";
    if (exists $thawed->{'dat'}) {
        $name = defined($thawed->{'dat'}->{'cgi_params'}->{'appname05'}) ? $thawed->{'dat'}->{'cgi_params'}->{'appname05'} : "";
    }
    
    # return it
    return $name;

} # get_appname05_name

###################################################################################################
# Interface Methods
###################################################################################################

=head2 B<process_queue(%ARGUMENTS)>

Accepts a HASH of arguments. Main script to run as a SENDER. Dispatches and handles the calls
appropriately.
This method provides a fallback to Perl Service. See SoapDataSenderSvc.pl

=cut

sub process_queue
{
    my $self = shift;
    my %args = @_;
    
    # get the LOG
    my $log = get_logger();
    
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # BDB config
    my $bdb_config = $config->{'input'};
    
    # create a BDB object
    my $bdb = BDB->create(
                          {
                              'config' => $bdb_config,
                          },
                         );
    
    # sleep for at least 1 s
    my $interval = $bdb_config->{'interval'} || 1;
    $interval = 1 if $interval < 1;
    
    # role type
    my $role_type = $config->{'role'}->{'type'};
    my $data_sep  = $config->{'data'}->{'separator'}->{'dat'};
    
    # get the recs from the queue
    while (1) {
        
        # get the first rec
        my ($key, $value) = $bdb->get_first();
        
        # must have a meaningful $key
        unless ($key) {
            
            # sleep interval
            sleep($interval);
            next;
        }
        
        # success flag
        my $success;
        
        # order of processing
        my @order = @{ $config->{'output'}->{'target'} };
        
        # go through the loop by order
        foreach my $hash (sort {by_order($a,$b)} @order) {
            
            if ($log->is_debug()) {
                $log->debug("Order HASH: ", sub {Dumper($hash)});
            }
            
            # what method to use to send/process the data ?
            my @methods = split m!\s*\Q|\E\s*!, $hash->{'type'};
            
            # go through the methods one by one
            foreach my $method (@methods) {
                
                # lower case it
                $method = lc $method;
                
                $log->debug("Method: $method");
                
                # should this be processed remotedly ?
                if ($method =~ /^(\w+)\s*\(remote\)\s*$/i) {
                    
                    # process remotedly
                    $log->debug("Calling remote method 'to_",$1,"'");
                    my $rc = $self->send_remote(
                                                'method' => "to_" . $1,
                                                'line'   => $value,
                                                'dir'    => $config->{'data'}->{'location'},
                                               );
                    # indicate success
                    $success++ if $rc;
                    
                } elsif ($method =~ /^(\w+)\s*\(local\)\s*$/i) {
                    
                    # process locally
                    $log->debug("Calling local method 'to_",$1,"'");
                    my $rc = $self->send_local(
                                               'method' => "to_" . $1,
                                               'line'   => $value,
                                               'dir'    => $config->{'data'}->{'location'},
                                              );
                    # indicate success
                    $success++ if $rc;
                
                } else {
                    
                    # what is the sender type?
                    if ($role_type eq "local") {
                        
                        # process locally
                        $log->debug("Calling local method 'to_",$method,"'");
                        my $rc = $self->send_local(
                                                   'method' => "to_" . $method,
                                                   'line'   => $value,
                                                   'dir'    => $config->{'data'}->{'location'},
                                                  );
                        # indicate success
                        $success++ if $rc;
                    
                    } elsif ($role_type eq "remote") {
                        
                        # process remotely
                        $log->debug("Calling remote method 'to_",$method,"'");
                        my $rc = $self->send_remote(
                                                    'method' => "to_" . $method,
                                                    'line'   => $value,
                                                    'dir'    => $config->{'data'}->{'location'},
                                                   );
                        # indicate success
                        $success++ if $rc;
                        
                    } else {
                        
                        # unknown role type
                        $log->error("Unknown role type '$role_type'. Defaulting to 'local'");
                        $role_type = "local";
                    
                    } # endif $role_type
                    
                } # endif remote/local method
                
            } # foreach $method

            # continue to the next order only, if none of methods succeeded
            last if $success;

        } # foreach order $hash
        
        if ($success) {
            
            # delete the processed record from the queue
            my $rc;
            eval
            {
                # need to reset $SIG{__DIE__} here
                local $SIG{__DIE__} = 'DEFAULT';
                $rc = $bdb->del_rec(
                                     {
                                         'key' => $key,
                                     }
                                   );
            };
            
            # error ???
            if ( $@ ) {
                $log->error("Failed to delete key '$key': $@");
            } else {
                if ($rc) {
                    $log->info("Successfully deleted key '$key'");
                } else {
                    $log->error("Failed to delete key '$key'");
                }
            } # endif error
        
        } else {
            
            # none of the methods succeeded: discreetly fall back to LOG, if DAT-line
            #my $data_line = $self->get_data_line($value);
            #if ($data_line) {
            #    $log->error("Failed to process record key '$key', $data_sep:", $data_line);
            #}
        
        } # endif $success
    
    } # while (1)

} # process_queue

=head2 B<by_order()>

Sorts the array elements by order specified in the CFG XML-file
This is in process_queue fallback method to Perl Service. See SoapDataSenderSvc.pl

=cut

sub by_order
{
    my $a = shift;
    my $b = shift;
    
    return $a->{'order'} <=> $b->{'order'} || $a->{'order'} cmp $b->{'order'};

} # by_order

###################################################################################################
# Various SEND Methods
###################################################################################################

=head2 B<send(%ARGUMENTS)>

Accepts a HASH of arguments including the string to send and a send method to use

=cut

sub send
{
    my $self = shift;
    my %args = @_;
    
    # get the LOG
    my $log = get_logger();
    
    # a method to use
    my $meth = $args{'method'};
    
    # sanity check
    unless ($self->can($meth)) {
        
        # unknown method call
        $log->error("Unknown method call '$meth'");
        
        # no OK acknowledgement, do nothing
        return FAILED;
    }
    
    # remove 'method' key
    delete $args{'method'};
    
    # send the data
    my $rc = $self->$meth(%args);
    
    # return status code
    return $rc;
    
} # send

=head2 B<send_local(%ARGUMENTS)>

Accepts a HASH of arguments including the string to send and a send method to use.
It's a wrapper for 'send' locally

=cut

sub send_local
{
    my $self = shift;
    my %args = @_;
    
    # get the args
    my $method = $args{'method'};
    my $line   = $args{'line'};
    my $dir    = $args{'dir'};
    
    # get the LOG
    my $log = get_logger();
    
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # run actual 'send'
    my $rc = $self->send(
                         'method' => $method,
                         'line'   => $line,
                         'dir'    => $dir,
                        );
    unless ($rc) {
        
        # log error
        $log->error("Failed to send data using local method '$method'");
        return FAILED;
    
    } else {
        
        # return $rc on success
        return $rc;
    }
    
} # send_local

=head2 B<send_remote(%ARGUMENTS)>

Accepts a HASH of arguments including the string to send and a send method to use.
It's a wrapper for 'send' remotely

=cut

sub send_remote
{
    my $self = shift;
    my %args = @_;
    
    # get the args
    my $method = $args{'method'};
    my $line   = $args{'line'};
    my $dir    = $args{'dir'};
    
    # get the LOG
    my $log = get_logger();
    
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # success flag
    my $success;
    
    # list of servers to try to connect to
    my @servers = @{ $config->{'server'} };
    
    if ($log->is_debug()) {
        $log->debug("Servers:", sub{Dumper(\@servers)});
    }
    
    # return value from SOAP: it could be an object
    my $rc;
    foreach my $hash (@servers) {
        # get params
        my $host = $hash->{'host'};
        my $port = $hash->{'port'};
        
        # check, if the host is alive
        my $r = undef;
        eval
        {
            # need to reset $SIG{__DIE__} here
            local $SIG{__DIE__} = 'DEFAULT';
            $r = SOAP::Lite
            -> uri('urn:'.__PACKAGE__)
            -> proxy('http://'.$host.':'.$port.'/')
            #-> on_debug(sub { $log->debug(@_) })
            -> call('check_alive')
            #-> result()
            ;
        };
        
        # check the return
        if ( $@ or (ref($r) and $r->faultstring())) {
            
            my $mess = "";
            $mess .= ": " . $@ if $@;
            if (ref($r)) {
                if ($mess) {
                    $mess .= ", " . $r->faultstring();
                } else {
                    $mess .= ": " . $r->faultstring();
                }
            }
            
            $log->error("Failed to send data using remote method '$method'. Server '$host:$port' is down",$mess,". Trying next...");
            # try next
            next;
        
        } else {
            
            # server is available, unfreeze $line before sending
            
            # arguments to pass
            my %args = (
                        'line'   => $line,
                        'method' => $method,
                        'dir'    => $dir,
                       );
            
            # build args as a list
            my @args;
            foreach my $k (keys %args) {
                push @args, $k, $args{$k};
            }
            my $r = undef;
            eval
            {
                # need to reset $SIG{__DIE__} here
                local $SIG{__DIE__} = 'DEFAULT';
                $r = SOAP::Lite
                -> uri('urn:'.__PACKAGE__)
                -> proxy('http://'.$host.':'.$port.'/')
                #-> on_debug(sub { $log->debug(@_) })
                -> call('send' => @args)
                #-> result()
                ;
            };
            
            # check the return
            if ( $@ or (ref($r) and $r->faultstring())) {
                
                my $mess = "";
                $mess .= ": " . $@ if $@;
                if (ref($r)) {
                    if ($mess) {
                        $mess .= ", " . $r->faultstring();
                    } else {
                        $mess .= ": " . $r->faultstring();
                    }
                }
                
                # log error
                $log->error("Failed to send data using remote method '$method'", $mess);
            
            } else {
                # increment $success only, if the method succeded
                $rc = $r->result();
                if ($log->is_debug()) {
                    $log->debug("SOAP method '$method' returned: '",(defined($rc) ? $rc : "undef"),"'");
                }
                $success++ if $rc;
            }
        } # endif $@ or !$rc
        
        # done here
        last if $success;
        
    } # foreach my $hash
    
    if ($success) {
        return $rc;
    } else {
        return FAILED;
    }
    
} # send_remote

=head2 B<to_log(%ARGUMENTS)>

Accepts a HASH of arguments including the string to send. Saves the data into the log file

=cut

sub to_log
{
    my $self = shift;
    my %args = @_;
    
    # get the LOG
    my $log = get_logger();
    
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # a "frozen" line
    my $line = $args{'line'};
    
    # get it
    my $dataline = $self->get_data_line($line);
    
    # if it's empty, it's probably LOG record
    my $logline;
    unless ($dataline) {
        $logline = $self->get_data_line($line, 'log');
    }
    # separator for the data line
    my $sep_dat = $config->{'data'}->{'separator'}->{'dat'};
    my $sep_log = $config->{'data'}->{'separator'}->{'log'};
    
    # sending it straight to LOG
    if ($dataline) {
        $log->info("$sep_dat:$dataline");
        return SUCCESS;
    } elsif ($logline) {
        # stop from blocking forever on the first LOG record in the BDB
        # silently ignore it
        return SUCCESS;
    } else {
        # shouldn't happen
        $log->error("Unknown data line");
        return FAILED;
    } # if DAT-line

} # to_log

=head2 B<to_dat(%ARGUMENTS)>

Accepts a HASH of arguments including the string to send. Sends the data to the DAT-file.
appname05 name delimited by "!" precedes the actual data: !appname05_name!1|2|3| ...
DAT-file name is the appname05 name with the extension ".dat". it's located in the config file
specified location under 'data' section: $config->{'data'}->{'location'}

=cut

sub to_dat
{
    my $self = shift;
    my %args = @_;
    
    # get the LOG
    my $log = get_logger();
    
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # DAT-line
    my $line = $args{'line'};
    
    # DAT-file appname03ory
    my $dir = $args{'dir'};
    
    # unfreeze it from $line
    my $dataline = $self->get_data_line($line);
    
    # if it's empty, it's probably LOG record, return SUCCESS
    return SUCCESS unless $dataline;
    
    # DAT file name
    my $filename = $self->get_appname05_name($line) || "sample_appname05";
    
    # DAT file name = appname05 name . "dat"
    my $datfile = catfile($dir, $filename . ".dat");
    
    # open DAT-file in append mode
    my $dat = IO::File->new($datfile, "a");
    
    unless ($dat) {
        $log->error("Couldn't open file '$datfile' for append: $!");
        return FAILED;
    }
    
    if ($log->is_debug()) {
        $log->debug("DAT-line '$dataline', DAT-file '$datfile'");
    }
    
    # writing it straight to DAT
    print $dat "$dataline\n";
    close $dat;
    
    # nothing much really can happen here
    return SUCCESS;

} # to_dat

=head2 B<to_sql(%ARGUMENTS)>

Accepts a HASH of arguments including the string to send. Sends the data to the SQL server

=cut

# store the DB handle to MSSQL
my $cache_sql;
sub to_sql
{
    my $self = shift;
    my %args = @_;
    
    # get the LOG
    my $log = get_logger();
    
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # a 'frozen' value
    my $line = $args{'line'};
    
    # complete HASH
    my %output;
    eval
    {
        %output = %{ Storable::thaw($line) };
    };
    
    if ($@) {
        $log->error("Failed to thaw line '$line': $@");
        return SUCCESS;
    }
    
    # check, if we need to initialize apiSQL object
    my $sql;
    unless ($cache_sql) {
        if ($log->is_debug()) {
            $log->debug("Creating an  SQL object");
        }
        eval
        {
            # need to reset $SIG{__DIE__} here
            local $SIG{__DIE__} = 'DEFAULT';
            require apiSQL;
        };
        
        # errors ???
        if ( $@ ) {
            # bad luck
            $log->error("Can't load apiSQL: $@");
            return FAILED;
        } else {
            # continue
            eval
            {
                # need to reset $SIG{__DIE__} here
                local $SIG{__DIE__} = 'DEFAULT';
                
                # try to create SQL
                $sql = apiSQL->new();
            };
            
            # errors ???
            if ( $@ ) {
                # bad luck
                $log->error("Error creating apiSQL object: $@");
                return FAILED;
            } else {
                # check the results
                unless ($sql) {
                    $log->error("Couldn't create apiSQL object with the following params: ", sub {Dumper($config->{'data'}->{'sql'})});
                    return FAILED;
                } else {
                    # we're OK, store it
                    $cache_sql = $sql;
                } # unless $sql
            } # endif errors
        } # endif errors
    } else {
        if ($log->is_debug()) {
            $log->debug("Using cached SQL object");
        }
        # get the object
        $sql = $cache_sql;
    } # unless $cache_sql
    
    # add data to SQL
    eval
    {
        # need to reset $SIG{__DIE__} here
        local $SIG{__DIE__} = 'DEFAULT';
        
        # do it here
        $sql->addLine(%output);
    };
    
    # errors ???
    if ( $@ ) {
        $log->error("addLine failed: $@");
        return FAILED;
    } else {
        # nothing much really can happen here
        return SUCCESS;
    }

} # to_sql

=head2 B<check_alive(>

Returns 1, if connection is up and running. It's used to test remote HTTP connections

=cut

sub check_alive
{
    my $self = shift;
    
    # nothing much really can happen here
    return SUCCESS;

} # check_alive

=head2 B<to_stderr(%ARGUMENTS)>

Accepts a HASH of arguments including the string to send. Sends the data to STDERR
This method is used for debugging only

=cut

sub to_stderr
{
    my $self = shift;
    my %args = @_;
    
    # get the LOG
    my $log = get_logger();
    
    # a 'frozen' value
    my $line = $args{'line'};
    
    # data-line
    my $dataline = $self->get_data_line($line);
    
    # sending it straight to LOG
    print STDERR "Sending to STDERR: '$dataline'\n";
    
    # nothing much really can happen here
    return SUCCESS;

} # to_stderr

=head2 B<DESTROY>

Destructor

=cut

sub DESTROY
{
    my $self = shift;
    
    # undef it
    undef $self;
}

##################################################################################################

1;
