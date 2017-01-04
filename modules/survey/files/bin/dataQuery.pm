#
# $Log: dataQuery.pm,v $
# Revision 1.4  2004/09/01 20:13:04  maxim
# Added methods to get the parameters from the database instead of BDB
#
# Revision 1.3  2004/08/24 18:45:28  maxim
# Expanded capabilities to work with TEXT fields. Refreshing the SQL when CACHE is updated
#
# Revision 1.2  2004/04/14 16:13:27  maxim
# updateCompletes code added
#
# Revision 1.2  2004/03/05 17:45:40  maxim
# Added checkPasscode function
#
# Revision 1.1  2003/10/27 20:42:17  maxim
# Added dataQuery.pm
#
#

=head1 NAME

dataQuery - Class to handle various DB query related tasks

=head1 SYNOPSIS

use dataQuery;
my $dq = dataQuery->new();

=head1 DESCRIPTION

dataQuery implements methods to handle data retrieval from MS SQL database
to drive the appname05 logic, i.e., fininsh the appname05, if the number of respondents
reached the certain limit.

=head1 CONSTRUCTOR

The object inherits a constructor from the parent class.

=begin testing

use_ok('DBI');
use_ok('Date::Parse');
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

package dataQuery;

# version
our $VERSION = 1.000;

# pragmas
use strict;
use warnings;

# Extension Modules
use DBI;
use Date::Parse;
use Data::Dumper;
$Data::Dumper::Indent = 3;
use File::Basename;
use File::Spec::Functions;
use Log::Dispatch::File;
use Log::Log4perl qw(:easy);
use XML::Simple;
use Sys::Hostname;
use File::Path;
use IO::File;

# return codes
sub SUCCESS () {   1   }
sub FAILED  () { undef }

=head1 METHODS

=head2 B<new()>

=begin testing

=end testing

=cut

# cached query object
my $query;

# cached CGI object
#my $cgi;

# method to create a dataQuery object
$dataQuery::defaultclass = __PACKAGE__;
sub new
{
    my $class = shift || $dataQuery::defaultclass; # class name
    my $conf  = shift;                             # optional config HASH
    
    # do we have the query object?
    if ($query and ref($query) eq $class) {
        
        # check, if the connection to MS SQL exists
        if (exists $query->{'dbh'} and not $query->{'dbh'}) {
            # connection is broken
            $query->reconnect();
        } elsif (not exists $query->{'dbh'}) {
            # connection doesn't exist
            $query->connect();
        }
        return $query;
    }
    
    # check, if $conf is a ref to HASH
    if ($conf and ref($conf) ne "HASH") {
        die "Method accepts an optional reference to a HASH";
    } elsif (!$conf) {
        # initialize it
        $conf = {};
    }
    
    # initialize the query object
    $query = {};
    
    # bless $query into $class
    bless $query, $class;
    
    # open LOG and read the config
    unless (exists $conf->{'config'}) {
        
        # store the config in $self later
        $query->{'config'} = _init_config($conf);
        
    } # unless exists $conf->{'config'}
    
    # open a connection
    $query->connect();
    
    my $log = get_logger("dataQuery");
    
    # stash the logger away
    $query->{'logger'} = $log;
    
    if ($log->is_debug()) {
        $log->debug("Query: ", sub {Dumper($query)});
    }
    
    # return the object
    return $query;
}

=head2 B<get_log(>

Gets the loggger

=cut

sub get_log
{
    shift->{'logger'};
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
    $basename = $conf->{'basename'} || $dataQuery::defaultclass;
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
        my $log = get_logger("dataQuery");
        $log->fatal(@_);
        
        exit 1;
    };
    
    # catch warnings to the log
    local $SIG{__WARN__} = sub {
        $Log::Log4perl::caller_depth++;
        # get the logger
        my $log = get_logger("dataQuery");
        $log->warn(@_);
    };
    
    # read the app config now
    # ------------------------
    my $log = get_logger("dataQuery");
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

=head2 B<connect()>

Connects to MS SQL via ODBC

=cut

sub connect
{
    my $self = shift;
    my $dbh;
    
    my $log = get_logger("dataQuery");
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # config values
    my $host        = $self->{'config'}->{'db'}->{'host'};
    my $database    = $self->{'config'}->{'db'}->{'database'};
    my $user        = $self->{'config'}->{'db'}->{'user'};
    my $pass        = $self->{'config'}->{'db'}->{'pass'};
    my $autocommit  = $self->{'config'}->{'db'}->{'autocommit'};
    my $raise_error = $self->{'config'}->{'db'}->{'raise_error'};
    
    # get logger
    if ($log->is_debug()) {
        $log->debug("Host: '$host' Database: '$database' User: '$user' Pass: '$pass' AutoCommit: '$autocommit' RaiseError: $raise_error");
    }
    
    # DSN
    my $dsn = "driver={SQL Server};Server=$host;database=$database;uid=$user;pwd=$pass;"; 
    if ($log->is_debug()) {
        $log->debug("DSN: '$dsn'");
    }
    
    $dbh = DBI->connect(
                        "dbi:ODBC:$dsn",
                        "$user",
                        "$pass",
                        { AutoCommit => $autocommit , RaiseError => $raise_error} )
        or die "$DBI::errstr\n";
    $dbh->{LongReadLen} = 65536;
    $self->{'dbh'} = $dbh;
}

=head2 B<reconnect()>

Re-connects to MS SQL via ODBC

=cut

sub reconnect
{
    my $self = shift;
    
    my $log = get_logger("dataQuery");
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    my $dbh = $self->{'dbh'};
    if ($dbh) {
        $dbh->disconnect();
    }
    $self->connect();
}

=head2 B<getCount($query_string, $start_time)>

Runs a user specified query

=cut

sub getCount
{
    # get the args
    my $input = shift; # input string to parse
    my $start = shift; # start time to check the record count
    
    # does the query object exist ???
    my $log;
    unless ($query) {
        $query = dataQuery->new();
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Creating query object...");
        }
    } else {
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Using existing query object...");
        }
    }
    
    if ($log->is_debug()) {
        $log->debug("Input: '$input' Start: '$start'");
    }
    
    # sanity check
    unless ($input) {
        $log->error("No input query string specified !");
        return -1;
    }
    unless ($start) {
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
        $start = $year+1900 . "-" . $mon+1 . "-" . $mday . " 00:00:00";
        $log->info("Defaulting start time to '$start'");
    }
    
    # get the FORM vars
    my %form = get_form_data();
    
    # Use $form{'data'} as filename if defined otherwise 
    # strip off trailing '.*' extension from $form{'page'} and tack on '.dat' extension.
    my $base = "";
    if (defined($form{'data'}) && $form{'data'} ne ''){
        $base = $form{'data'};
    } else {
        $base = $form{'page'};
        # strip off the extension, if any
        $base =~ s/\..*$//;
        $base .= '.dat';
    } # if ... data file name defined in form
    
    # appname05 file name
    my $appname05_dir  = defined($form{'appname05data'}) ? $form{'appname05data'} : $form{'appname05'};
    my $appname05_file = $appname05_dir . "/" . $base;
    
    # sanity check
    unless ($appname05_file) {
        $log->error("No appname05 file specified. CGI params: ", sub{Dumper(\%form)});
        return -1;
    }
    
    if ($log->is_debug()) {
        $log->debug("appname05 file: $appname05_file");
    }
    
    # check, if we have the $appname05_file and $input in cache
    my $result = $query->check_cache(
                                     {
                                         'input'       => $input,
                                         'appname05_file' => $appname05_file,
                                         'start'       => $start,
                                         'form'        => \%form,
                                     }
                                    );
    # what's in the $result ?
    if (not defined $result) {
        # error
        return -1;
    } else {
        # return the findings
        return $result;
    }
}

=head2 B<checkPasscode($passcode, $automailerlog)>

Checks, if the passcode is valid.

=cut

sub checkPasscode
{
    # get the args
    my $passcode      = shift; # passcode to check
    my $automailerlog = shift; # name of the log file the automaler is using
    
    # does the query object exist ???
    my $log;
    unless ($query) {
        $query = dataQuery->new();
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Creating query object...");
        }
    } else {
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Using existing query object...");
        }
    }
    
    # sanity check
    unless ($passcode) {
        $log->error("No passcode specified !");
        return -1;
    }
    unless ($automailerlog) {
        $log->error("No automailer log specified !");
        return -1;
    }
    
    if ($log->is_debug()) {
        $log->debug("Passcode: '$passcode' Automailer log: '$automailerlog'");
    }
    
    # get the message ID out of the passcode
    my $msg_id = get_passcode_msg_id($passcode);
    
    # build a SQL statement
    my $sql = "select s.appname05_file "
        . "from appname05 s, automail_message m, automail_config c "
        . "where m.automail_message_id = $msg_id "
        . "AND m.automail_config_id = c.automail_config_id "
        . "AND c.appname05_id = s.appname05_id";
    
    # run a query
    my $appname05_file = $query->run_query($sql);
    
    # compare it with the automailer log
    return ($appname05_file eq $automailerlog ? 1 : 0);
}

=head2 B<get_passcode_msg_id($passcode)>

Returns the message ID encrypted in the passcode
Otherwise, returns undef

=cut

sub get_passcode_msg_id
{
    my $passcode = shift;
    
    # convert it to INT and subtract the constant
    my $msg_id = hex($passcode) - 100023;
    return $msg_id;
}

=head2 B<get_msg_id($passcode)>

Returns the message ID encrypted in the passcode
Otherwise, returns undef

=cut

sub get_msg_id
{
    my $passcode = shift;
    
    # convert it to INT and subtract the constant
    my $msg_id = hex($passcode) - 17;
    return $msg_id;
}

=head2 B<updateCompletes($appname05,$passcode>

Creates a record in the webpanel_completes table
to keep track of webpanel members activity

=cut

sub updateCompletes
{
    # get the args
    my $appname05   = shift; # name of the appname05 appname03ory
    my $passcode = shift; # participant passcode
    
    # does the query object exist ???
    my $log;
    unless ($query) {
        $query = dataQuery->new();
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Creating query object...");
        }
    } else {
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Using existing query object...");
        }
    }
    
    # sanity check
    unless ($passcode) {
        $log->error("No passcode specified !");
        return -1;
    }
    unless ($appname05) {
        $log->error("No appname05 appname03ory specified !");
        return -1;
    }
    
    if ($log->is_debug()) {
        $log->debug("Passcode: '$passcode' appname05: '$appname05'");
    }
    
    # get the project ID
    my $project_id = $appname05;
    $project_id =~ s|.*/(.*?)$|$1|;
    
    # does this project ID and passcode exist in the webpanel_completes table?
    my $data_exists;
    my $sql = "SELECT COUNT(\*) FROM webpanel_completes WHERE project_id='$project_id' and passcode='$passcode'";
    
    # run a query
    $data_exists = $query->run_query($sql);
    
    unless ($data_exists) {
        
        # build the INSERT statement
        $sql = "INSERT INTO webpanel_completes(project_id,passcode,completed_timestamp) VALUES('$project_id','$passcode',getdate())";
        
        # run it
        my $rc = $query->db_insert($sql);
        
        if ($log->is_debug()) {
            if ($rc) {
                $log->debug("Successfully inserted a record for project ID '$project_id', passcode '$passcode'");
            } else {
                $log->debug("Failed to insert a record for project ID '$project_id', passcode '$passcode'");
            }
        }
    } else {
        if ($log->is_debug()) {
            $log->debug("The record exists for project ID '$project_id', passcode '$passcode'");
        }
    } # unless record exists

} # updateCompletes

=head2 B<check_cache($options_hash_ref)>

Returns the query result, if it's in cache and still valid.
Otherwise, returns undef

=cut

sub check_cache
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger("dataQuery");
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if (($options and ref($options) ne "HASH") or !$options) {
        $log->error("Must have a reference to HASH as input");
        return undef;
    }
    
    # need $input and $appname05_file and $start
    my $input       = $options->{'input'};
    my $appname05_file = $options->{'appname05_file'};
    my $start       = $options->{'start'};
    
    # sanity check
    unless ($input and $appname05_file and $start) {
        $log->error("Must have 'input', 'appname05_file' and 'start' variables as input");
        return undef;
    }
    
    # cache parameters
    my $time_checked;
    my $count;
    my $old_count;
    my $sql;
    my $current_time;                                       # default is 1 min
    my $refresh = $self->{'config'}->{'db'}->{'refresh'} || 60;
    # input/start key
    my $inputstart = $input . $start;
    
    # check $appname05_file cache first
    if (exists $self->{'cache'}->{$appname05_file}) {
        
        # check for $input in $appname05_file cache
        if (exists $self->{'cache'}->{$appname05_file}->{$inputstart}) {
            
            # get the cached results
            $time_checked = $self->{'cache'}->{$appname05_file}->{$inputstart}->{'time_checked'};
            $count        = $self->{'cache'}->{$appname05_file}->{$inputstart}->{'count'};
            $old_count    = $count;
            $current_time = time();
            
            if ($current_time < ($time_checked + $refresh)) {
                # cache is still valid
                if ($log->is_debug()) {
                    $log->debug("Using cached result '$count'...");
                }
            
            } else {
                
                # it's time to re-run the query and refresh the cache
                # get the SQL to run
                $sql = $self->generate_sql($options);
                $count  = $self->run_query($sql);
                
                # refresh cache
                $self->{'cache'}->{$appname05_file}->{$inputstart}->{'time_checked'} = $current_time;
                $self->{'cache'}->{$appname05_file}->{$inputstart}->{'count'}        = $count;
                $self->{'cache'}->{$appname05_file}->{$inputstart}->{'sql'} = $sql;
                
                if ($log->is_debug()) {
                    $log->debug("Refreshing cached result from '$old_count' to '$count'...");
                }
            }
        
        } else {
            
            # set the new $input cache
            $self->{'cache'}->{$appname05_file}->{$inputstart} = {};
            
            # get the SQL to run
            $sql = $self->generate_sql($options);
            
            # get the count
            $count = $self->run_query($sql);
            
            # setting the SQL for future use
            $self->{'cache'}->{$appname05_file}->{$inputstart}->{'sql'} = $sql;
            
            # setting the count for future use
            $self->{'cache'}->{$appname05_file}->{$inputstart}->{'count'} = $count;
            
            # setting time checked
            $self->{'cache'}->{$appname05_file}->{$inputstart}->{'time_checked'} = time();
            
            if ($log->is_debug()) {
                $log->debug("Setting appname05_file '$appname05_file' input/start '$input/$start' cache to: ", sub{Dumper($self->{'cache'}->{$appname05_file}->{$inputstart})});
            }
    
        } # endif exists {$appname05_file}->{$inputstart}
        
    } else {
        
        # set $appname05_file and $input cache for the first time
        $self->{'cache'}->{$appname05_file}->{$inputstart} = {};
        
        # get the SQL to run
        $sql = $self->generate_sql($options);
        
        # get the count
        $count = $self->run_query($sql);
        
        # setting the SQL for future use
        $self->{'cache'}->{$appname05_file}->{$inputstart}->{'sql'} = $sql;
        
        # setting the count for future use
        $self->{'cache'}->{$appname05_file}->{$inputstart}->{'count'} = $count;
        
        # setting time checked
        $self->{'cache'}->{$appname05_file}->{$inputstart}->{'time_checked'} = time();
        
        if ($log->is_debug()) {
            $log->debug("Initial setting of appname05_file '$appname05_file' and input/start '$input/$start' cache to: ", sub{Dumper($self->{'cache'}->{$appname05_file}->{$inputstart})});
        }
        
    } # endif exists $appname05_file
    
    # return the result
    return $count;

} # check_cache

sub generate_sql
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger("dataQuery");
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if (($options and ref($options) ne "HASH") or !$options) {
        $log->error("Must have a reference to HASH as input");
        return undef;
    }
    
    # need $input and $appname05_file and $start
    my $input       = $options->{'input'};
    my $appname05_file = $options->{'appname05_file'};
    my $start       = $options->{'start'};
    my %form        = %{ $options->{'form'} };
    
    # sanity check
    unless ($input and $appname05_file and $start) {
        $log->error("Must have 'input', 'appname05_file' and 'start' variables as input");
        return undef;
    }
    
    # generated SQL
    my $sql = "";
    
    # static part 1
    my $stmt1 = "SELECT COUNT(*) FROM appname05 s,response r,";
    
    # static part 2
    my $stmt2 = " WHERE s.appname05_file='$appname05_file' AND s.appname05_id=r.appname05_id AND r.status_flag=9 AND r.updated > '$start' ";
    
    # replace -lt, -gt, etc.
    my $old_input = $input;
    $input = replace_str($input);
    
    # parse $input
    my @from  = ();
    my @where = ();
    
    my $field = "";
    my $table = "";
    # determine the type of input
    if ($input =~ /appname05(\d+)/i) {
        # answer_integer
        $field = "appname05";
        $table = "answer_integer";
    } elsif ($input =~ /textincludeboth(\d+)/i) {
        # answer_text
        $field = "textincludeboth";
        $table = "answer_text";
    } else {
        # shouldn't be here
        $log->error("Input string '$input' must refer to 'appname05' or 'textincludeboth'");
        return undef;
    }
    
    while ($input =~ /$field(\d+)/ig) {
        push @from,  "$table $field$1";
        push @where, "AND r.response_id = $field$1.response_id AND $field$1.field_number = $1";
    }
    
    # add '.content'
    $input =~ s/$field(\d+)/$field$1.content/ig;
    
    # substitute the FORM variable with value
    $input =~ s/form\{(\w+)\}/$form{$1}/ig;
    if ($field eq "textincludeboth") {
        # can't have " = " on text fields
        $input =~ s/[=]/LIKE/g;
        # replace "|" with single quotes
        $input =~ s/[|]/'/g;
    }
    
    # construct SQL statement
    $sql = $stmt1 . join(",", @from) . $stmt2 . join(" ", @where) . " AND $input";
    
    if ($log->is_debug()) {
        $log->debug("SQL: $sql");
    }
    
    # return what we've got
    return $sql;

} # generate_sql

sub replace_str
{
    my $expr = shift;
    
    my $log = get_logger("dataQuery");
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    return "" unless $expr;

    # Relational operators, -ne etc. -> != etc.
    # Note that string relational operators (ne, eq) remain unchanged.
    $expr =~ s/\s-le\s/ <= /oig;
    $expr =~ s/\s-lt\s/ < /oig;
    $expr =~ s/\s-eq\s/ = /oig;
    $expr =~ s/\s-ne\s/ <> /oig;
    $expr =~ s/\s-gt\s/ > /oig;
    $expr =~ s/\s-ge\s/ >= /oig;
    $expr =~ s/\s==\s/ = /oig;
    $expr =~ s/\s\!=\s/ <> /oig;
    $expr =~ s/\s\|\|\s/ OR /oig;
    $expr =~ s/\s\&\&\s/ AND /oig;

    # Logical operators, -and etc. -> && etc.
    $expr =~ s/\s-and\s/ AND /oig;
    $expr =~ s/\s-or\s/ OR /oig;

    return $expr;

} # replace_str

sub run_query
{
    my $self = shift;
    my $sql  = shift;
    
    my $log = get_logger("dataQuery");
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    unless ($sql) {
        $log->error("No SQL statement to run");
        return undef;
    }
    
    # check out the database connection just in case
    if (exists $self->{'dbh'} and not $self->{'dbh'}) {
        # connection is broken
        $self->reconnect();
    } elsif (not exists $self->{'dbh'}) {
        # connection doesn't exist
        $self->connect();
    }
    
    # DBI stuff follows
    my $dbh = $self->{'dbh'};
    my $sth = $dbh->prepare($sql);
    
    # check for DB errors
    if (!$sth) {
        # specify the $error
        $log->error("DBI ERROR prepare: ", $dbh->errstr());
        return undef;
    } # endif !$sth
    
    if (!$sth->execute()) {
        # specify the $error
        $log->error("DBI ERROR execute: ", $sth->errstr());
        return undef;
    } # endif !$sth->execute
    
    # if we made it here, we're more or less OK
    # how many records did we find?
    my @row = $sth->fetchrow_array();
    
    # the final error check
    if ($sth->err) {
        # shucks !!!
        $log->error("DBI ERROR fetchrow_array: ", $sth->err());
        return undef;
    }
    
    if ($log->is_debug()) {
        $log->debug("Result: ", sub{Dumper(\@row)});
    }
    
    # expecting just one number
    return $row[0];

} # run_query

sub get_form_data
{
    
    my $log = get_logger("dataQuery");
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # initialize FORM 
    my %form = ();
    
    # who called us ?
    my $pkg  = _called_by();
    
    # break into the appname05 engine name space
    # populate %form
    my $hashstr = "$pkg"."::form";
    eval "\%form = \%$hashstr";
    
    if ( $@ ) {
        $log->error("Eval error: $@");
    } else {
        #if ($log->is_debug()) {
        #    $log->debug("Form: ", sub{Dumper(\%form)});
        #}
    }
    
    wantarray ? %form : \%form;
    
} # get_form_data

sub _called_by
{
    my $log = get_logger("dataQuery");
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # who called us ???
    my $called;
    my $i = 0;
    while (my ($pack, $file, $line, $subname, $hasargs, $wantarray) = caller($i++)) {
        #if ($log->is_debug()) {
        #    $log->debug("\$i: '$i',\$pack: '$pack',\$file: '$file',\$line: '$line',\$subname: '$subname',\$hasargs: '$hasargs',\$wantarray: '$wantarray'");
        #}
        # get out at the first package above us
        if ($pack ne $dataQuery::defaultclass) {
            $called = $pack;
            last;
        }
    }
    return $called;

} # _called_by

# Runs INSERT command with $stmt passed onto it. Returns undef on $error
sub db_insert
{
    my $self = shift;
    my $stmt = shift;
    
    my $log = get_logger("dataQuery");
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    unless ($stmt) {
        $log->error("No INSERT statement to run");
        return undef;
    }
    
    # check out the database connection just in case
    if (exists $self->{'dbh'} and not $self->{'dbh'}) {
        # connection is broken
        $self->reconnect();
    } elsif (not exists $self->{'dbh'}) {
        # connection doesn't exist
        $self->connect();
    }
    
    # DBI stuff follows
    my $dbh = $self->{'dbh'};
    
    # error string
    my $error;
    
    # start transaction
    eval
    {
        # need to reset $SIG{__DIE__} here
        local $SIG{__DIE__} = 'DEFAULT';
        # prepare $sth
        my $sth = $dbh->prepare($stmt);
        
        # run update
        $sth->execute();
        
        # commit
        $dbh->commit();
    };
    
    if ( $@ ) {
        # error
        $log->error("DBI INSERT '$stmt' error: ", $dbh->errstr());
        $dbh->rollback();
        return undef;
    } else {
        return 1;
    }

} # db_insert

=head2 B<get_data_id_sent_timestamp(%args)>

Returns the message data_id and sent_timestamp

=cut

sub get_data_id_sent_timestamp
{
    my %args = @_;
    my $msg_id = $args{'msg_id'};
    
    # does the query object exist ???
    my $log;
    unless ($query) {
        $query = dataQuery->new();
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Creating query object...");
        }
    } else {
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Using existing query object...");
        }
    }
    
    # sanity check
    unless ($msg_id) {
        $log->error("No Msg ID specified");
        return (undef,undef);
    }
    
    my $dbh  = $query->{'dbh'};
    my $stmt = "SELECT data_id,sent_timestamp FROM automail_message WHERE automail_message_id=$msg_id";
    my $array_ref;
    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        $array_ref = $dbh->selectall_arrayref($stmt);
    };
    
    if ( $@ ) {
        $log->error("DBI ERRROR: $@");
        return (undef,undef);
    } else {
        if ($log->is_debug()) {
            $log->debug("Results: ",sub{Dumper($array_ref)});
        }
        # get the results
        return ($array_ref->[0]->[0],int(str2time($array_ref->[0]->[1])));
    }
} # get_data_id_sent_timestamp

=head2 B<get_msg_params(%args)>

Returns the PARAMS associated with the message

=cut

sub get_msg_params
{
    my %args = @_;
    my $data_id    = $args{'data_id'};
    my $table_name = $args{'table_name'};
    
    # does the query object exist ???
    my $log;
    unless ($query) {
        $query = dataQuery->new();
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Creating query object...");
        }
    } else {
        $log = get_logger("dataQuery");
        if ($log->is_debug()) {
            $log->debug("Using existing query object...");
        }
    }
    
    # sanity check
    unless ($data_id and $table_name) {
        $log->error("No data ID and table name specified");
        return undef;
    }
    
    my $dbh  = $query->{'dbh'};
    my $sql  = "SELECT name, content ";
       $sql .= "  FROM $table_name ";
       $sql .= " WHERE entrance_log_id = " . $data_id ;
       
    my $parm_ref;
    eval
    {
        local $SIG{__DIE__} = 'DEFAULT';
        $parm_ref = $dbh->selectall_arrayref( $sql, { Columns => {} } );
    };
    
    if ( $@ ) {
        $log->error("DBI ERRROR: $@");
        return undef;
    }
    my %tmpl_hash;
    foreach my $param ( @{$parm_ref} ) { 
        $tmpl_hash{$param->{'name'}} = $param->{'content'};
    }
    return \%tmpl_hash;

} # get_msg_params

=head2 B<DESTROY()>

destroys connection to MS SQL via ODBC

=cut

sub DESTROY
{
    my $self = shift;
    my $dbh = $self->{'dbh'};
    if ($dbh) {
        $dbh->disconnect();
    }
}

# leave this line alone
1;
