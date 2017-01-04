#
# $Log: BDB.pm,v $
# Revision 1.2  2004/06/24 18:59:25  maxim
# Put call to Storable into eval
#
# Revision 1.1  2004/03/31 21:09:40  maxim
# Added BDB/SOAP stuff to new repository
#
# Revision 0.8  2003/08/29 12:46:28  maxim
# DB_RECOVER,DESTROY removed. Added logic to handle duplicates in add_rec
#
# Revision 0.7  2003/08/20 19:05:54  maxim
# DB_RECOVER added to TXNs
#
# Revision 0.6  2003/06/19 12:27:17  maxim
# use Log::Dispatch::File
#
# Revision 0.5  2003/06/10 15:04:25  maxim
# Sorting order switched to avoid warnings
#
# Revision 0.4  2003/06/10 14:40:15  maxim
# Two new params added to show_recs
#
# Revision 0.3  2003/05/30 20:26:40  maxim
# Removed excessive error messages
#
# Revision 0.2  2003/05/29 13:37:38  maxim
# Init LOG, CFG separated into a function
#
# Revision 0.1  2003/05/28 20:50:47  maxim
# Reset SIGDIE inside eval
#
# Revision 0.0.0.1  2003/05/28 14:30:56  maxim
# Initial import to CVS
#
#

=head1 NAME

BDB - Class to handle various BerkeleyDB related tasks

=head1 SYNOPSIS

use BDB;
my $bdb = BDB->create(\%options);

=head1 DESCRIPTION

BDB implements methods to handle data interchange between the appname05 Engine
and DATA servers. It is derived from B<Class::Base>.
See a man page for B<Class::Base> for the implementation details.

=head1 CONSTRUCTOR

The object inherits a constructor from the parent class.

=begin testing

use_ok('Class::Base');
use_ok('BerkeleyDB');
use_ok('Data::Dumper');
use_ok('File::Basename');
use_ok('File::Spec::Functions');
use_ok('Log::Dispatch::File');
use_ok('Log::Log4perl');
use_ok('XML::Simple');
use_ok('Sys::Hostname');
use_ok('File::Path');
use_ok('IO::File');
use_ok('Storable');

# initialize default object
use BDB;

# set the tests
rmtree("testdir") if -d "testdir";
ok(! -e "testdir", "testdir removed");

mkpath("testdir") unless (-d "testdir");
mkpath(catdir("testdir","logs")) unless (-d catdir("testdir","logs"));
mkpath(catdir("testdir","cfg")) unless (-d catdir("testdir","cfg"));
mkpath(catdir("testdir","data")) unless (-d catdir("testdir","data"));

ok(-e "testdir", "testdir created");
ok(-e catdir("testdir","logs"), catdir("testdir","logs") . " created");
ok(-e catdir("testdir","cfg"), catdir("testdir","cfg") . " created");
ok(-e catdir("testdir","data"), catdir("testdir","data") . " created");

our $log_conf =
q{log4perl.logger = DEBUG, Logfile
#log4perl.logger = INFO, Logfile

# appender
log4perl.appender.Logfile = Log::Dispatch::File
log4perl.appender.Logfile.filename = testdir/logs/BDB.log
log4perl.appender.Logfile.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Logfile.layout.ConversionPattern = %d %X{IP} %p %F{1}:%L (%M) => %m%n
};

our $bdb_conf_txn_nosync_cache =
q{<?xml version="1.0" encoding="ISO-8859-1" ?>
<config>

<db>
    <!-- name of the data store -->
    <database>appname05.db</database>

    <!-- name of the Next ID database -->
    <next_id>next_id.db</next_id>

    <!-- database location relative tio the calling script -->
    <location>data</location>

    <!-- use transactions -->
    <txn>1</txn>

    <!-- use transactions with DB_TXN_NOSYNC to speed it up -->
    <nosync>1</nosync>

    <!-- retry transactions up to this number of times before giving up -->
    <retry>10</retry>

    <!-- use cache -->
    <cache>1</cache>
    
    <!-- To achive the fastest operation, set txn=0 and cache=1 -->
</db>

</config>
};

our $bdb_conf_txn_cache =
q{<?xml version="1.0" encoding="ISO-8859-1" ?>
<config>

<db>
    <!-- name of the data store -->
    <database>appname05.db</database>

    <!-- name of the Next ID database -->
    <next_id>next_id.db</next_id>

    <!-- database location relative tio the calling script -->
    <location>data</location>

    <!-- use transactions -->
    <txn>1</txn>

    <!-- use transactions with DB_TXN_NOSYNC to speed it up -->
    <nosync>0</nosync>

    <!-- retry transactions up to this number of times before giving up -->
    <retry>10</retry>

    <!-- use cache -->
    <cache>1</cache>
    
    <!-- To achive the fastest operation, set txn=0 and cache=1 -->
</db>

</config>
};

our $bdb_conf_txn_nocache =
q{<?xml version="1.0" encoding="ISO-8859-1" ?>
<config>

<db>
    <!-- name of the data store -->
    <database>appname05.db</database>

    <!-- name of the Next ID database -->
    <next_id>next_id.db</next_id>

    <!-- database location relative tio the calling script -->
    <location>data</location>

    <!-- use transactions -->
    <txn>1</txn>

    <!-- use transactions with DB_TXN_NOSYNC to speed it up -->
    <nosync>0</nosync>

    <!-- retry transactions up to this number of times before giving up -->
    <retry>10</retry>

    <!-- use cache -->
    <cache>0</cache>
    
    <!-- To achive the fastest operation, set txn=0 and cache=1 -->
</db>

</config>
};

our $bdb_conf_notxn_cache =
q{<?xml version="1.0" encoding="ISO-8859-1" ?>
<config>

<db>
    <!-- name of the data store -->
    <database>appname05.db</database>

    <!-- name of the Next ID database -->
    <next_id>next_id.db</next_id>

    <!-- database location relative tio the calling script -->
    <location>data</location>

    <!-- use transactions -->
    <txn>0</txn>

    <!-- use transactions with DB_TXN_NOSYNC to speed it up -->
    <nosync>0</nosync>

    <!-- retry transactions up to this number of times before giving up -->
    <retry>10</retry>

    <!-- use cache -->
    <cache>1</cache>
    
    <!-- To achive the fastest operation, set txn=0 and cache=1 -->
</db>

</config>
};

our $bdb_conf_notxn_nocache =
q{<?xml version="1.0" encoding="ISO-8859-1" ?>
<config>

<db>
    <!-- name of the data store -->
    <database>appname05.db</database>

    <!-- name of the Next ID database -->
    <next_id>next_id.db</next_id>

    <!-- database location relative tio the calling script -->
    <location>data</location>

    <!-- use transactions -->
    <txn>0</txn>

    <!-- use transactions with DB_TXN_NOSYNC to speed it up -->
    <nosync>0</nosync>

    <!-- retry transactions up to this number of times before giving up -->
    <retry>10</retry>

    <!-- use cache -->
    <cache>0</cache>
    
    <!-- To achive the fastest operation, set txn=0 and cache=1 -->
</db>

</config>
};

# open a log config
my $logconffile = catfile("testdir", "logs", "BDB.conf");
unlink $logconffile if -e $logconffile;
ok(! -e $logconffile, "LOG config '$logconffile' doesn't exist");
my $logfh = IO::File->new("$logconffile", "w");
ok(defined $logfh, "LOG config '$logconffile' created");
print $logfh $log_conf;
close $logfh;
ok(-s $logconffile, "LOG config '$logconffile' has non-zero size");

# open BDB config with txns
my $bdbconffile = catfile("testdir", "cfg", "BDB.xml");
unlink $bdbconffile if -e $bdbconffile;
ok(! -e $bdbconffile, "BDB config '$bdbconffile' doesn't exist");
my $bdbfh = IO::File->new("$bdbconffile", "w");
ok(defined $bdbfh, "BDB config '$bdbconffile' created");
print $bdbfh $bdb_conf_txn_nosync_cache;
close $bdbfh;
ok(-s $bdbconffile, "BDB config '$bdbconffile' has non-zero size");

our $bdb = BDB->create({
'basename' => 'bdb',
'basedir'  => 'testdir',
});

isa_ok($bdb, 'BDB', "it's the right class");

# config to use in some tests
our $config = $bdb->get_config();
ok(ref($config) eq "HASH", "Got config from the created object");

=end testing

=cut

package BDB;

# version
our $VERSION = 1.000;

# pragmas
use strict;
use warnings;
use base qw( Class::Base );

# Extension Modules
use BerkeleyDB;
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
use Storable;

# return codes
sub SUCCESS () {   1   }
sub FAILED  () { undef }

=head1 METHODS

=head2 B<init($config)>

A method to store configuration parameters in a newly created object.
It is defined in the parent Class::Base. The method accept a reference to 
HASH of optional arguments. 

=begin testing

# make sure every method/function call works
my @methods = qw
(
init
_init_config
create
add_rec
get_val
set_val
get_first
get_last
get_count
get_stats
del_rec
show_recs
get_next_id
get_config
check_cache
check_cache_param
get_home
get_retry
get_dbfile
use_txn
use_nosync
use_cache
);
can_ok('BDB', @methods);

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

A method to create an object. It will initialize connections to the following
databases: appname05.db, next_id. By default it will open them as a
concurrent data store enabling multiple reads and a single write. 
Use {'txn' => 1} in the %options or in the main config.xml to enable transactions

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

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key1' => 'value1' );
my $hashref = \%hash;
my $coderef = sub { "die, piggy, die" };

my $bdb1;

eval
{
    local $SIG{__DIE__} = 'DEFAULT';
    eval { $bdb1 = BDB->create($scalar) };
    ok($@, "Create dies when passed a scalar");
    eval { $bdb1 = BDB->create($scalarref) };
    ok($@, "Create dies when passed a REF to scalar");
    eval { $bdb1 = BDB->create(@array) };
    ok($@, "Create dies when passed an array");
    eval { $bdb1 = BDB->create($arrayref) };
    ok($@, "Create dies when passed a REF to array");
    eval { $bdb1 = BDB->create(%hash) };
    ok($@, "Create dies when passed a HASH");
    eval { $bdb1 = BDB->create($coderef) };
    ok($@, "Create dies when passed a REF to code");

    # checking defaults
    eval { $bdb1 = BDB->create() };
    ok($@, "Create dies when NOT passed any params: no 'logs' appname03ory and log/BDB.conf");
    mkpath("logs");
    mkpath("cfg");
    
    # open a log config
    my $logconffile = catfile("logs", "BDB.conf");
    unlink $logconffile if -e $logconffile;
    ok(! -e $logconffile, "LOG config '$logconffile' doesn't exist");
    my $logfh = IO::File->new("$logconffile", "w");
    ok(defined $logfh, "LOG config '$logconffile' created");
    print $logfh $log_conf;
    close $logfh;
    ok(-s $logconffile, "LOG config '$logconffile' has non-zero size");
    
    # open BDB config with txns
    my $bdbconffile = catfile("cfg", "BDB.xml");
    unlink $bdbconffile if -e $bdbconffile;
    ok(! -e $bdbconffile, "BDB config '$bdbconffile' doesn't exist");
    my $bdbfh = IO::File->new("$bdbconffile", "w");
    ok(defined $bdbfh, "BDB config '$bdbconffile' created");
    print $bdbfh $bdb_conf_txn_nosync_cache;
    close $bdbfh;
    ok(-s $bdbconffile, "BDB config '$bdbconffile' has non-zero size");
    eval { $bdb1 = BDB->create() };
    ok(!$@, "Create lives when NOT passed any params using ALL defaults");
    undef $bdb1;
    eval { $bdb1 = BDB->create($hashref) };
    ok(!$@, "Create lives when passed a HASH ref using ALL defaults");
    ok($bdb1->{'key1'} eq 'value1', "Init worked: Self 'key1' eq 'value1'");
    undef $bdb1;
    rmtree("logs");
    rmtree("cfg");
    ok(! -d "logs", "'logs' dir deleted");
    ok(! -d "cfg", "'cfg' dir deleted");
    eval { $bdb1 = BDB->create({'config' => $config}) };
    ok(!$@, "Create lives when passed a valid \$config using ALL defaults");
    undef $bdb1;
    eval { $bdb1 = BDB->create({'config' => 1}) };
    ok(!$@, "Create lives when passed \{ 'config' => 1 \} using ALL defaults");
};

=end testing

=cut

# method to create a BDB object
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
    
    # create cache
    unless (exists $conf->{'cache'}) {
        $conf->{'cache'} = {};
    }
    
    # use the parent method to create an object
    my $self = BDB->new
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
    
    return $config;
}

###################################################################################################
# BerkeleyDB Utility Methods
###################################################################################################

=head2 B<add_rec($hashref)>

This method is used to add a record to a DB. It expects a reference to a HASH of named
arguments. It must have at least the following key/value pairs: {'key' => $key, 'value' => $value}. Returns 1 on success,
'undef' on failure.

=begin testing

our $num_tests = 10;
our $line = "M" x 8;
our $location = catfile("testdir", "data");

# 1) add 10 recs using transactions and cache using default name

# default DB appname05.db at testdir/data

my $database = catfile($location, "appname05.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                                'location' => $location,
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location}) == 10, "Database '$database' has 10 recs");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

# 2) add 10 recs to a DB called test.db

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
'database' => 'test.db',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location}) == 10, "Database '$database' has 10 recs");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

# 3) add 10 recs to a default DB at the new location 'db'
$location = catfile("testdir", "db");

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
});

$database = catfile($location, "appname05.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location}) == 10, "Database '$database' has 10 recs");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

# 4) add 10 recs to a DB called test.db at the location 'db'
$location = catfile("testdir", "db");

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                                'location' => $location,
                                'database' => 'test.db',
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location, 'database' => 'test.db'}) == 10, "Database '$database' has 10 recs");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my %hashval = ( 'value' => 'value1');
my %hashkey = ( 'key' => 'key1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->add_rec($scalar), "add_rec dies when passed a scalar");
ok(! $bdb1->add_rec($scalarref), "add_rec dies when passed a REF to scalar");
ok(! $bdb1->add_rec(@array), "add_rec dies when passed an array");
ok(! $bdb1->add_rec($arrayref), "add_rec dies when passed a REF to array");
ok(! $bdb1->add_rec(%hash), "add_rec dies when passed a HASH");
ok(! $bdb1->add_rec($coderef), "add_rec dies when passed a REF to code");

# checking defaults
ok(! $bdb1->add_rec(), "add_rec dies when NOT passed any params");
ok(! $bdb1->add_rec(\%hashkey), "add_rec dies: no 'value'");
ok(! $bdb1->add_rec(\%hashval), "add_rec dies: no 'key'");

=end testing

=cut

sub add_rec
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    unless ($options and (ref($options) eq "HASH") and exists $options->{'key'} and exists $options->{'value'}) {
        $log->error("Must have a HASH reference with \{'key' => \$key, 'value' => \$value\} parameter as input");
        return FAILED;
    }
    
    # rec to add
    my $key   = $options->{'key'};
    my $value = $options->{'value'};
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options);
    
    # enable transactions ?
    my $use_txn = $self->use_txn($options);
    
    # enable cache ?
    my $use_cache = $self->use_cache($options);
    
    # initialize vars
    my $env;
    my $db1;
    my $cursor;
    my ($k, $v);
    
    if ($log->is_debug()) {
        $log->debug("Self: ", sub {Dumper($self)});
    }
    
    # check cache ?
    if ($use_cache) {
        
        # check cache
        ($env, $db1) = $self->check_cache(
                                          {
                                              'home'    => $home,
                                              'dbfile'  => $dbfile,
                                              'use_txn' => $use_txn,
                                          }
                                         );
    } # endif $use_cache
    
    if ($use_txn) {
        
        if ($log->is_debug()) {
            $log->debug("Using transactions...");
        }
        
        # enable DB_TXN_NOSYNC with transactions ?
        my $use_nosync = $self->use_nosync($options);
        
        # number of times to retry the transaction
        my $retry = $self->get_retry($options);
        
        # DB environment
        if (!$env or !$use_cache) {
            $env = new BerkeleyDB::Env(
                                       '-Home'  => $home,
                                       '-Flags' => DB_CREATE|DB_INIT_TXN|DB_INIT_MPOOL|DB_INIT_LOCK,
                                       '-LockDetect' => DB_LOCK_DEFAULT,
                                      );
            if ($env && $use_nosync) {
                # speed up the txns
                $env->set_flags(DB_TXN_NOSYNC, 1);
            }
        } # unless $env
        
        unless ($env) {
            $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'env_txn',
                                             'value'  => $env,
                                         }
                                        );
            } # endif $use_cache
        } # unless $env
        
        # It's very important to open a database in a transaction
        my $txn = $env->txn_begin();
        
        # open the DB
        if (!$db1 or !$use_cache) {
            $db1 = new BerkeleyDB::Hash (
                                         '-Filename' => $dbfile,
                                         '-Flags'    => DB_CREATE,
                                         '-Env'      => $env,
                                         '-Txn'      => $txn,
                                        );
        } # unless $db1
        
        unless ($db1) {
            $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
            undef $env;
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'dbh_txn',
                                             'value'  => $db1,
                                         }
                                        );
            } # endif $use_cache
        } # unless $db1
        
        # complete the transaction opening the database
        $txn->txn_commit();
        
        # error flag
        my $error;
        for (my $i = 0; $i < $retry; $i++) {
            # start a new transaction
            my $txn = $env->txn_begin();
            
            # initialize transactions
            $db1->Txn($txn);
            ($k, $v) = ($key, "") ;
            
            # return code
            my $rc;
            
            # does the $key exist?
            if ($db1->db_get($k, $v) == 0) {
                my $newkey = $self->get_next_id();
                # shouldn't happen
                $log->error("Key '$key' exists in database '$dbfile'. Overwriting '", $key, "' with '$newkey'");
                $key = $newkey;
            }
            
            # store it in the DB
            $rc = $db1->db_put($key, $value);
            
            if ( $rc ) {
                # abort the transaction
                if ((my $ret = $txn->txn_abort()) != 0) {
                    # double failure
                    # log an error
                    $log->error("Couldn't abort adding key/value '$key/$value' to database '$dbfile': $BerkeleyDB::Error $rc $ret");
                } else {
                    # log an error, if not a deadlock
                    unless ($rc =~ /DB_LOCK_DEADLOCK/) {
                        $log->error("Aborted adding key/value '$key/$value' to database '$dbfile': $BerkeleyDB::Error $rc");
                    }
                }
                # increment $error
                $error++;
                
            } else {
                # complete the transaction
                if ((my $ret = $txn->txn_commit()) != 0) {
                    $log->error("Couldn't commit adding key/value '$key/$value' to database '$dbfile'. Aborted transaction: $BerkeleyDB::Error $ret");
                    $error++;
                } else {
                    # we're fine
                    $error = 0;
                    last;
                } # endif commit
            } # endif $rc
        } # endfor $retry
        
        # RELEASE all the locks immediately, cleanup after yourself
        undef $txn;
        undef $db1;
        undef $env;
        
        if ($error) {
            $log->error("Couldn't complete transaction adding key/value '$key/$value' to database '$dbfile' after $retry attempts");
            return FAILED;
        } else {
            return SUCCESS;
        }
    
    } else {
        
        if ($log->is_debug()) {
            $log->debug("NOT Using transactions...");
        }
        
        # use default: the concurrent data store
        
        # DB environment: Concurrent Data Store, no transactions
        if (!$env or !$use_cache) {
            $env = new BerkeleyDB::Env(
                                       '-Home'  => $home,
                                       '-Flags' => DB_CREATE|DB_INIT_MPOOL|DB_INIT_CDB,
                                       '-LockDetect' => DB_LOCK_DEFAULT,
                                      );
        } # unless $env
        
        unless ($env) {
            $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'env_cdb',
                                             'value'  => $env,
                                         }
                                        );
            } # endif $use_cache
        } # unless $env
        
        # open the DB
        if (!$db1 or !$use_cache) {
            $db1 = new BerkeleyDB::Hash (
                                         '-Filename' => $dbfile,
                                         '-Flags'    => DB_CREATE,
                                         '-Env'      => $env,
                                        );
        } # unless $db1
        
        unless ($db1) {
            $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
            undef $env;
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'dbh_cdb',
                                             'value'  => $db1,
                                         }
                                        );
            } # endif $use_cache
        } # unless $db1
        
        # error flag
        my $error;
        
        # open a write cursor
        my $cursor = $db1->db_cursor(DB_WRITECURSOR);
        my ($k, $v) = ($key, "") ;
        
        # wrap it in eval
        my $rc;
        eval
        {
            # need to reset $SIG{__DIE__} here
            local $SIG{__DIE__} = 'DEFAULT';
            
            # get the next ID
            if ($cursor->c_get($k, $v, DB_SET) == 0) {
                my $newkey = $self->get_next_id();
                # shouldn't happen
                $log->error("Key '$key' exists in database '$dbfile'. Overwriting '", $key, "' with '$newkey'");
                $key = $newkey;
            } # unless $k is found
            
            # append it
            $rc = $cursor->c_put($key, $value, DB_KEYLAST);
        };
        
        # RELEASE all the locks immediately, cleanup after yourself
        undef $cursor;
        undef $db1;
        undef $env;
        
        if ( $@ or $rc ) {
            # log an error
            $log->error("Couldn't add key/value '$key/$value' to database '$dbfile': $@ $BerkeleyDB::Error $rc");
            $error++;
        } # endif error
        
        if ($error) {
            return FAILED;
        } else {
            return SUCCESS;
        } # endif error
        
    
    } # endif use transactions
    
} # add_rec

=head2 B<get_val($hashref)>

This method is used to get a value from a DB where the key equals $key. It expects a reference to a HASH of named
arguments. It must have at least the following key/value pair: {'key' => $key}. Returns value on success,
'undef' on failure.

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my %hashval = ( 'value' => 'value1');
my %hashkey = ( 'key' => 'key1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->get_val($scalar), "get_val dies when passed a scalar");
ok(! $bdb1->get_val($scalarref), "get_val dies when passed a REF to scalar");
ok(! $bdb1->get_val(@array), "get_val dies when passed an array");
ok(! $bdb1->get_val($arrayref), "get_val dies when passed a REF to array");
ok(! $bdb1->get_val(%hash), "get_val dies when passed a HASH");
ok(! $bdb1->get_val($coderef), "get_val dies when passed a REF to code");

# checking defaults
ok(! $bdb1->get_val(), "get_val dies when NOT passed any params");
ok(! $bdb1->get_val(\%hashval), "get_val dies: no 'key'");

# add 10 recs to a DB called test.db at the location 'db'
$location = catfile("testdir", "db");

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
'database' => 'test.db',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location, 'database' => 'test.db'}) == 10, "Database '$database' has 10 recs");
ok($bdb->get_val({'key' => '5',}) eq "MMMMMMMM_0005", "Value of key '5' eq 'MMMMMMMM_0005'");
ok(! $bdb->get_val({'key'=>'15'}), "Key '15' doesn't exist");
# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

=end testing

=cut

sub get_val
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    unless ($options and (ref($options) eq "HASH") and exists $options->{'key'}) {
        $log->error("Must have a HASH reference with \{'key' => \$key} parameter as input");
        return FAILED;
    }
    
    # rec to get
    my $key = $options->{'key'};
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options);
    
    # enable transactions ?
    my $use_txn = $self->use_txn($options);
    
    # enable cache ?
    my $use_cache = $self->use_cache($options);
    
    # some DB variables
    my $env;
    my $db1;
    my $val;
    
    # check cache ?
    if ($use_cache) {
        
        # check cache
        ($env, $db1) = $self->check_cache(
                                          {
                                              'home'    => $home,
                                              'dbfile'  => $dbfile,
                                              'use_txn' => $use_txn,
                                          }
                                         );
    } # endif $use_cache
    
    # DB environment: Concurrent Data Store, no transactions
    if (!$env or !$use_cache) {
        $env = new BerkeleyDB::Env(
                                   '-Home'  => $home,
                                   '-Flags' => DB_CREATE|DB_INIT_MPOOL|DB_INIT_CDB,
                                   '-LockDetect' => DB_LOCK_DEFAULT,
                                  );
    } # unless $env
    
    unless ($env) {
        $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'env_cdb',
                                         'value'  => $env,
                                     }
                                    );
        } # endif $use_cache
    } # unless $env
    
    # open the DB
    if (!$db1 or !$use_cache) {
        $db1 = new BerkeleyDB::Hash (
                                     '-Filename' => $dbfile,
                                     '-Flags'    => DB_CREATE,
                                     '-Env'      => $env,
                                    );
    } # unless $db1
    
    unless ($db1) {
        $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
        undef $env;
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'dbh_cdb',
                                         'value'  => $db1,
                                     }
                                    );
        } # endif $use_cache
    } # unless $db1
    
    # does the $key exist?
    unless ($db1->db_get($key, $val) == 0) {
        $log->error("Couldn't get value for key '$key'");
        return FAILED;
    }
    
    # cleanup after yourself
    undef $db1;
    undef $env;
    
    # return what we've found
    return $val;
    
} # get_val

=head2 B<set_val($hashref)>

This method is used to set a value of a key in a DB. It expects a reference to a HASH of named
arguments. It must have at least the following key/value pairs: {'key' => $key, 'value' => $value}. Returns 1 on success,
'undef' on failure.

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my %hashval = ( 'value' => 'value1');
my %hashkey = ( 'key' => 'key1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->set_val($scalar), "set_val dies when passed a scalar");
ok(! $bdb1->set_val($scalarref), "set_val dies when passed a REF to scalar");
ok(! $bdb1->set_val(@array), "set_val dies when passed an array");
ok(! $bdb1->set_val($arrayref), "set_val dies when passed a REF to array");
ok(! $bdb1->set_val(%hash), "set_val dies when passed a HASH");
ok(! $bdb1->set_val($coderef), "set_val dies when passed a REF to code");

# checking defaults
ok(! $bdb1->set_val(), "set_val dies when NOT passed any params");
ok(! $bdb1->set_val(\%hashkey), "set_val dies: no 'value'");
ok(! $bdb1->set_val(\%hashval), "set_val dies: no 'key'");

# add 10 recs to a DB called test.db at the location 'db'
$location = catfile("testdir", "db");

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
'database' => 'test.db',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location, 'database' => 'test.db'}) == 10, "Database '$database' has 10 recs");
ok($bdb->get_val({'key' => '5'}) eq "MMMMMMMM_0005", "Value of key '5' eq 'MMMMMMMM_0005'");
ok($bdb->set_val({'key' => '5', 'value' => '5555'}), "The value of key '5' updated");
ok($bdb->get_val({'key' => '5'}) eq "5555", "Value of key '5' eq '5555'");
ok(! $bdb->get_val({'key'=>'15'}), "Key '15' doesn't exist");
ok($bdb->set_val({'key' => '15', 'value'=> 'Key_15'}), "Key '15' created");
ok($bdb->get_val({'key' => '15'}) eq 'Key_15', "Value of key '15' eq 'Key_15'");
# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

=end testing

=cut

sub set_val
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    unless ($options and (ref($options) eq "HASH") and exists $options->{'key'} and exists $options->{'value'}) {
        $log->error("Must have a HASH reference with \{'key' => \$key, 'value' => \$value\} parameter as input");
        return FAILED;
    }
    
    # rec to add
    my $key   = $options->{'key'};
    my $value = $options->{'value'};
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options);
    
    # enable transactions ?
    my $use_txn = $self->use_txn($options);
    
    # enable cache ?
    my $use_cache = $self->use_cache($options);
    
    # initialize vars
    my $env;
    my $db1;
    my $cursor;
    my ($k, $v);
    
    # check cache ?
    if ($use_cache) {
        
        # check cache
        ($env, $db1) = $self->check_cache(
                                          {
                                              'home'    => $home,
                                              'dbfile'  => $dbfile,
                                              'use_txn' => $use_txn,
                                          }
                                         );
    } # endif $use_cache
    
    if ($use_txn) {
        
        if ($log->is_debug()) {
            $log->debug("Using transactions...");
        }
        
        # enable DB_TXN_NOSYNC with transactions ?
        my $use_nosync = $self->use_nosync($options);
        
        # number of times to retry the transaction
        my $retry = $self->get_retry($options);
        
        # DB environment
        if (!$env or !$use_cache) {
            $env = new BerkeleyDB::Env(
                                       '-Home'  => $home,
                                       '-Flags' => DB_CREATE|DB_INIT_TXN|DB_INIT_MPOOL|DB_INIT_LOCK,
                                       '-LockDetect' => DB_LOCK_DEFAULT,
                                      );
            if ($env && $use_nosync) {
                # speed up the txns
                $env->set_flags(DB_TXN_NOSYNC, 1);
            }
        } # unless $env
        
        unless ($env) {
            $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'env_txn',
                                             'value'  => $env,
                                         }
                                        );
            } # endif $use_cache
        } # unless $env
        
        # It's very important to open a database in a transaction
        my $txn = $env->txn_begin();
        
        # open the DB
        if (!$db1 or !$use_cache) {
            $db1 = new BerkeleyDB::Hash (
                                         '-Filename' => $dbfile,
                                         '-Flags'    => DB_CREATE,
                                         '-Env'      => $env,
                                         '-Txn'      => $txn,
                                        );
        } # unless $db1
        
        unless ($db1) {
            $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
            undef $env;
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'dbh_txn',
                                             'value'  => $db1,
                                         }
                                        );
            } # endif $use_cache
        } # unless $db1
        
        # complete the transaction opening the database
        $txn->txn_commit();
        
        # error flag
        my $error;
        for (my $i = 0; $i < $retry; $i++) {
            # start a new transaction
            my $txn = $env->txn_begin();
            
            # initialize transactions
            $db1->Txn($txn);
            ($k, $v) = ($key, "") ;
            
            # wrap it in eval
            my $rc;
            
            # does the $key exist?
            if ($db1->db_get($k, $v) != 0) {
                # shouldn't happen
                $log->info("Key '$key' doesn't exist in database '$dbfile'. Creating a key '$key' with value '$value'");
            }
            
            # store it in the DB
            $rc = $db1->db_put($key, $value);
            
            if ( $rc ) {
                # abort the transaction
                if ((my $ret = $txn->txn_abort()) != 0) {
                    # double failure
                    # log an error
                    $log->error("Couldn't abort setting key/value '$key/$value' in database '$dbfile': $BerkeleyDB::Error $rc $ret");
                } else {
                    # log an error, if not a deadlock
                    unless ($rc =~ /DB_LOCK_DEADLOCK/) {
                        $log->error("Aborted setting key/value '$key/$value' in database '$dbfile': $BerkeleyDB::Error $rc");
                    }
                }
                # increment $error
                $error++;
                
            } else {
                # complete the transaction
                if ((my $ret = $txn->txn_commit()) != 0) {
                    $log->error("Couldn't commit setting key/value '$key/$value' in database '$dbfile'. Aborted transaction: $BerkeleyDB::Error $ret");
                    $error++;
                } else {
                    # we're fine
                    $error = 0;
                    last;
                } # endif commit
            } # endif $rc
        } # endfor $retry
        
        # RELEASE all the locks immediately, cleanup after yourself
        undef $txn;
        undef $db1;
        undef $env;
        
        if ($error) {
            $log->error("Couldn't complete transaction setting key/value '$key/$value' in database '$dbfile' after $retry attempts");
            return FAILED;
        } else {
            return SUCCESS;
        }
    
    } else {
        
        if ($log->is_debug()) {
            $log->debug("NOT Using transactions...");
        }
        
        # use default: the concurrent data store
        
        # DB environment: Concurrent Data Store, no transactions
        if (!$env or !$use_cache) {
            $env = new BerkeleyDB::Env(
                                       '-Home'  => $home,
                                       '-Flags' => DB_CREATE|DB_INIT_MPOOL|DB_INIT_CDB,
                                       '-LockDetect' => DB_LOCK_DEFAULT,
                                      );
        } # unless $env
        
        unless ($env) {
            $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'env_cdb',
                                             'value'  => $env,
                                         }
                                        );
            } # endif $use_cache
        } # unless $env
        
        # open the DB
        if (!$db1 or !$use_cache) {
            $db1 = new BerkeleyDB::Hash (
                                         '-Filename' => $dbfile,
                                         '-Flags'    => DB_CREATE,
                                         '-Env'      => $env,
                                        );
        } # unless $db1
        
        unless ($db1) {
            $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
            undef $env;
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'dbh_cdb',
                                             'value'  => $db1,
                                         }
                                        );
            } # endif $use_cache
        } # unless $db1
        
        # error flag
        my $error;
        
        # open a write cursor
        my $cursor = $db1->db_cursor(DB_WRITECURSOR);
        my ($k, $v) = ($key, "") ;
        
        # return code
        my $rc;
        
        # get the key
        unless ($cursor->c_get($k, $v, DB_SET) == 0) {
            
            # no matching records in the database
            # shouldn't happen
            $log->info("Key '$key' doesn't exist in database '$dbfile'. Creating key '$key' with value '$value'");
            $rc = $cursor->c_put($key, $value, DB_KEYLAST);
        
        } else {
            
            # store it in the DB
            $rc = $cursor->c_put($key, $value, DB_CURRENT);
        
        } # unless $k is found
        
        # RELEASE all the locks immediately, cleanup after yourself
        undef $cursor;
        undef $db1;
        undef $env;
        
        if ( $rc ) {
            # log an error
            $log->error("Couldn't set key/value '$key/$value' in database '$dbfile': $BerkeleyDB::Error $rc");
            $error++;
        } # endif error
        
        if ($error) {
            return FAILED;
        } else {
            return SUCCESS;
        } # endif error
    
    } # endif use transactions
    
} # set_val

=head2 B<get_first([$hashref])>

This method is used to get the first key/value pair from a DB. It expects an optional reference to a HASH of named
arguments. Returns ($key, $value) on success, 'undef, undef' on failure.

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->get_first($scalar), "get_first dies when passed a scalar");
ok(! $bdb1->get_first($scalarref), "get_first dies when passed a REF to scalar");
ok(! $bdb1->get_first(@array), "get_first dies when passed an array");
ok(! $bdb1->get_first($arrayref), "get_first dies when passed a REF to array");
ok(! $bdb1->get_first(%hash), "get_first dies when passed a HASH");
ok(! $bdb1->get_first($coderef), "get_first dies when passed a REF to code");

# add 10 recs to a DB called test.db at the location 'db'
$location = catfile("testdir", "db");

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
'database' => 'test.db',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location, 'database' => 'test.db'}) == 10, "Database '$database' has 10 recs");
my ($k, $v) = $bdb->get_first();
ok($k && $v, "Key '$k', value '$v'");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

=end testing

=cut

sub get_first
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and (ref($options) ne "HASH")) {
        $log->error("Must have a HASH reference as input");
        return FAILED;
    }
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options);
    
    # enable transactions ?
    my $use_txn = $self->use_txn($options);
    
    # enable cache ?
    my $use_cache = $self->use_cache($options);
    
    my $env;
    my $db1;
    
    # check cache ?
    if ($use_cache) {
        
        # check cache
        ($env, $db1) = $self->check_cache(
                                          {
                                              'home'    => $home,
                                              'dbfile'  => $dbfile,
                                              'use_txn' => $use_txn,
                                          }
                                         );
    } # endif $use_cache
    
    # DB environment: Concurrent Data Store, no transactions
    if (!$env or !$use_cache) {
        $env = new BerkeleyDB::Env(
                                   '-Home'  => $home,
                                   '-Flags' => DB_CREATE|DB_INIT_MPOOL|DB_INIT_CDB,
                                   '-LockDetect' => DB_LOCK_DEFAULT,
                                  );
    } # unless $env
    
    unless ($env) {
        $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'env_cdb',
                                         'value'  => $env,
                                     }
                                    );
        } # endif $use_cache
    } # unless $env
    
    # open the DB
    if (!$db1 or !$use_cache) {
        $db1 = new BerkeleyDB::Hash (
                                     '-Filename' => $dbfile,
                                     '-Flags'    => DB_CREATE,
                                     '-Env'      => $env,
                                    );
    } # unless $db1
    
    unless ($db1) {
        $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
        undef $env;
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'dbh_cdb',
                                         'value'  => $db1,
                                     }
                                    );
        } # endif $use_cache
    } # unless $db1
    
    # error flag
    my $error;
    
    # open a cursor
    my $cursor = $db1->db_cursor();
    my ($key, $value) = ("", "") ;
    
    # return code
    my $rc;
    
    # get $key/$value
    $rc = $cursor->c_get($key, $value, DB_FIRST);
    
    # RELEASE all the locks immediately, cleanup after yourself
    undef $cursor;
    undef $db1;
    undef $env;
    
    if ( $rc and $rc !~ /DB_NOTFOUND/) {
        # log an error
        $log->error("Couldn't get the first key/value from database '$dbfile': $BerkeleyDB::Error $rc");
        $error++;
    } # endif error
    
    if ($error) {
        return (undef, undef);
    } else {
        return ($key, $value);
    } # endif error
    
} # get_first

=head2 B<get_last([$hashref])>

This method is used to get the last key/value pair from a DB. It expects an optional reference to a HASH of named
arguments. Returns ($key, $value) on success, 'undef, undef' on failure.

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->get_last($scalar), "get_last dies when passed a scalar");
ok(! $bdb1->get_last($scalarref), "get_last dies when passed a REF to scalar");
ok(! $bdb1->get_last(@array), "get_last dies when passed an array");
ok(! $bdb1->get_last($arrayref), "get_last dies when passed a REF to array");
ok(! $bdb1->get_last(%hash), "get_last dies when passed a HASH");
ok(! $bdb1->get_last($coderef), "get_last dies when passed a REF to code");

# add 10 recs to a DB called test.db at the location 'db'
$location = catfile("testdir", "db");

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
'database' => 'test.db',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location, 'database' => 'test.db'}) == 10, "Database '$database' has 10 recs");
my ($k, $v) = $bdb->get_last();
ok($k && $v, "Key '$k', value '$v'");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

=end testing

=cut

sub get_last
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and (ref($options) ne "HASH")) {
        $log->error("Must have a HASH reference as input");
        return FAILED;
    }
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options);
    
    # enable transactions ?
    my $use_txn = $self->use_txn($options);
    
    # enable cache ?
    my $use_cache = $self->use_cache($options);
    
    my $env;
    my $db1;
    
    # check cache ?
    if ($use_cache) {
        
        # check cache
        ($env, $db1) = $self->check_cache(
                                          {
                                              'home'    => $home,
                                              'dbfile'  => $dbfile,
                                              'use_txn' => $use_txn,
                                          }
                                         );
    } # endif $use_cache
    
    # DB environment: Concurrent Data Store, no transactions
    if (!$env or !$use_cache) {
        $env = new BerkeleyDB::Env(
                                   '-Home'  => $home,
                                   '-Flags' => DB_CREATE|DB_INIT_MPOOL|DB_INIT_CDB,
                                   '-LockDetect' => DB_LOCK_DEFAULT,
                                  );
    } # unless $env
    
    unless ($env) {
        $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'env_cdb',
                                         'value'  => $env,
                                     }
                                    );
        } # endif $use_cache
    } # unless $env
    
    # open the DB
    if (!$db1 or !$use_cache) {
        $db1 = new BerkeleyDB::Hash (
                                     '-Filename' => $dbfile,
                                     '-Flags'    => DB_CREATE,
                                     '-Env'      => $env,
                                    );
    } # unless $db1
    
    unless ($db1) {
        $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
        undef $env;
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'dbh_cdb',
                                         'value'  => $db1,
                                     }
                                    );
        } # endif $use_cache
    } # unless $db1
    
    # error flag
    my $error;
    
    # open a cursor
    my $cursor = $db1->db_cursor();
    my ($key, $value) = ("", "") ;
    
    # get $key/$value
    my $rc = $cursor->c_get($key, $value, DB_LAST);
    
    # RELEASE all the locks immediately, cleanup after yourself
    undef $cursor;
    undef $db1;
    undef $env;
    
    if ( $rc and $rc !~ /DB_NOTFOUND/ ) {
        # log an error
        $log->error("Couldn't get the last key/value from database '$dbfile': $BerkeleyDB::Error $rc");
        $error++;
    } # endif error
    
    if ($error) {
        return (undef, undef);
    } else {
        return ($key, $value);
    } # endif error
    
} # get_last

=head2 B<get_count([$hashref])>

This method is used to get the number of key/value pairs in a DB. It expects an optional reference to a HASH of named
arguments. Returns the count on success, 'undef' on failure.

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->get_count($scalar), "get_count dies when passed a scalar");
ok(! $bdb1->get_count($scalarref), "get_count dies when passed a REF to scalar");
ok(! $bdb1->get_count(@array), "get_count dies when passed an array");
ok(! $bdb1->get_count($arrayref), "get_count dies when passed a REF to array");
ok(! $bdb1->get_count(%hash), "get_count dies when passed a HASH");
ok(! $bdb1->get_count($coderef), "get_count dies when passed a REF to code");

# add 5 recs to a DB called test.db at the location 'db'
$location = catfile("testdir", "db");

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
'database' => 'test.db',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= 5; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location, 'database' => 'test.db'}) == 5, "Database '$database' has 5 recs");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

=end testing

=cut

sub get_count
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and (ref($options) ne "HASH")) {
        $log->error("Must have a HASH reference as input");
        return FAILED;
    }
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options);
    
    # enable transactions ?
    my $use_txn = $self->use_txn($options);
    
    # enable cache ?
    my $use_cache = $self->use_cache($options);
    
    my $env;
    my $db1;
    
    # check cache ?
    if ($use_cache) {
        
        # check cache
        ($env, $db1) = $self->check_cache(
                                          {
                                              'home'    => $home,
                                              'dbfile'  => $dbfile,
                                              'use_txn' => $use_txn,
                                          }
                                         );
    } # endif $use_cache
    
    # DB environment: Concurrent Data Store, no transactions
    if (!$env or !$use_cache) {
        $env = new BerkeleyDB::Env(
                                   '-Home'  => $home,
                                   '-Flags' => DB_CREATE|DB_INIT_MPOOL|DB_INIT_CDB,
                                   '-LockDetect' => DB_LOCK_DEFAULT,
                                  );
    } # unless $env
    
    unless ($env) {
        $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'env_cdb',
                                         'value'  => $env,
                                     }
                                    );
        } # endif $use_cache
    } # unless $env
    
    # open the DB
    if (!$db1 or !$use_cache) {
        $db1 = new BerkeleyDB::Hash (
                                     '-Filename' => $dbfile,
                                     '-Flags'    => DB_CREATE,
                                     '-Env'      => $env,
                                    );
    } # unless $db1
    
    unless ($db1) {
        $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
        undef $env;
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'dbh_cdb',
                                         'value'  => $db1,
                                     }
                                    );
        } # endif $use_cache
    } # unless $db1
    
    # error flag
    my $error;
    
    # get the stats
    my $hashref = $db1->db_stat();
    
    # RELEASE all the locks immediately, cleanup after yourself
    undef $db1;
    undef $env;
    
    if ($log->is_debug()) {
        $log->debug("DB Stats: ", sub { Dumper($hashref) });
    }
    
    if ( $BerkeleyDB::Error ) {
        # log an error
        $log->error("Couldn't get stats from database '$dbfile': $BerkeleyDB::Error");
        $error++;
    } # endif error
    
    if ($error) {
        return FAILED;
    } else {
        return ($hashref and exists $hashref->{'hash_nkeys'} ? $hashref->{'hash_nkeys'} : 0);
    } # endif error
    
} # get_count

=head2 B<get_stats([$hashref])>

This method is used to return statistics about a DB. It expects an optional reference to a HASH of named
arguments. Returns the HASH reference on success, 'undef' on failure.

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->get_stats($scalar), "get_stats dies when passed a scalar");
ok(! $bdb1->get_stats($scalarref), "get_stats dies when passed a REF to scalar");
ok(! $bdb1->get_stats(@array), "get_stats dies when passed an array");
ok(! $bdb1->get_stats($arrayref), "get_stats dies when passed a REF to array");
ok(! $bdb1->get_stats(%hash), "get_stats dies when passed a HASH");
ok(! $bdb1->get_stats($coderef), "get_stats dies when passed a REF to code");

# add 5 recs to a DB called test.db at the location 'db'
$location = catfile("testdir", "db");

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
'database' => 'test.db',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= 5; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
my $hashref = $bdb->get_stats({'location' => $location, 'database' => 'test.db'});
ok(ref($hashref) eq "HASH", "get_stats returned a HASH");
ok($hashref->{hash_nkeys} == 5,"Database '$database' has 5 recs");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

=end testing

=cut

sub get_stats
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and (ref($options) ne "HASH")) {
        $log->error("Must have a HASH reference as input");
        return FAILED;
    }
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options);
    
    my $env;
    my $db1;
    
    # enable transactions ?
    my $use_txn = $self->use_txn($options);
    
    # enable cache ?
    my $use_cache = $self->use_cache($options);
    
    # check cache ?
    if ($use_cache) {
        
        # check cache
        ($env, $db1) = $self->check_cache(
                                          {
                                              'home'    => $home,
                                              'dbfile'  => $dbfile,
                                              'use_txn' => $use_txn,
                                          }
                                         );
    } # endif $use_cache
    
    # DB environment: Concurrent Data Store, no transactions
    if (!$env or !$use_cache) {
        $env = new BerkeleyDB::Env(
                                   '-Home'  => $home,
                                   '-Flags' => DB_CREATE|DB_INIT_MPOOL|DB_INIT_CDB,
                                   '-LockDetect' => DB_LOCK_DEFAULT,
                                  );
    } # unless $env
    
    unless ($env) {
        $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'env_cdb',
                                         'value'  => $env,
                                     }
                                    );
        } # endif $use_cache
    } # unless $env
    
    # open the DB
    if (!$db1 or !$use_cache) {
        $db1 = new BerkeleyDB::Hash (
                                     '-Filename' => $dbfile,
                                     '-Flags'    => DB_CREATE,
                                     '-Env'      => $env,
                                    );
    } # unless $db1
    
    unless ($db1) {
        $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
        undef $env;
        return FAILED;
    } else {
        if ($use_cache) {
            # check cache param
            $self->check_cache_param(
                                     {
                                         'home'   => $home,
                                         'dbfile' => $dbfile,
                                         'param'  => 'dbh_cdb',
                                         'value'  => $db1,
                                     }
                                    );
        } # endif $use_cache
    } # unless $db1
    
    # error flag
    my $error;
    
    # get the stats
    my $hashref = $db1->db_stat();
    
    # RELEASE all the locks immediately, cleanup after yourself
    undef $db1;
    undef $env;
    
    if ($log->is_debug()) {
        $log->debug("DB Stats: ", sub { Dumper($hashref) });
    }
    
    if ( $BerkeleyDB::Error ) {
        # log an error
        $log->error("Couldn't get stats from database '$dbfile': $BerkeleyDB::Error");
        $error++;
    } # endif error
    
    if ($error) {
        return FAILED;
    } else {
        return ($hashref and ref($hashref) eq "HASH" ? $hashref : undef);
    } # endif error
    
} # get_stats

=head2 B<del_rec($hashref)>

This method is used to delete a record from a DB where key equals '$key'. It expects a reference to a HASH of named
arguments. It must have at least the following key/value pair: {'key' => $key}. Returns 1 on success,
'undef' on failure.

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my %hashval = ( 'value' => 'value1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->del_rec($scalar), "del_rec dies when passed a scalar");
ok(! $bdb1->del_rec($scalarref), "del_rec dies when passed a REF to scalar");
ok(! $bdb1->del_rec(@array), "del_rec dies when passed an array");
ok(! $bdb1->del_rec($arrayref), "del_rec dies when passed a REF to array");
ok(! $bdb1->del_rec(%hash), "del_rec dies when passed a HASH");
ok(! $bdb1->del_rec($coderef), "del_rec dies when passed a REF to code");

# checking defaults
ok(! $bdb1->del_rec(), "del_rec dies when NOT passed any params");
ok(! $bdb1->del_rec(\%hashval), "del_rec dies: no 'key'");

# add 10 recs to a DB called test.db at the location 'db'
$location = catfile("testdir", "db");

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->add_rec(
                            {
                                'key'      => $cnt,
                                'value'    => $line . "_" . sprintf("%04d", $cnt),
                                'location' => $location,
                                'database' => 'test.db',
                            }
                          );
}

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location, 'database' => 'test.db'}) == 10, "Database '$database' has 10 recs");

for (my $cnt = 1; $cnt <= $num_tests; $cnt++) {
    my $rc = $bdb->del_rec(
                            {
                                'key'      => $cnt,
                                'location' => $location,
                                'database' => 'test.db',
                            }
                          );
    ok($rc == 1, "Key '$cnt' deleted");
}
ok($bdb->get_count({'location' => $location, 'database' => 'test.db'}) == 0, "Database '$database' empty");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

=end testing

=cut

sub del_rec
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    unless ($options and (ref($options) eq "HASH") and exists $options->{'key'}) {
        $log->error("Must have a HASH reference with \{'key' => \$key\} parameter as input");
        return FAILED;
    }
    
    # key to delete
    my $key = $options->{'key'};
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options);
    
    # enable transactions ?
    my $use_txn = $self->use_txn($options);
    
    # enable cache ?
    my $use_cache = $self->use_cache($options);
    
    # initialize vars
    my $env;
    my $db1;
    my $cursor;
    my ($k, $v);
    
    # check cache ?
    if ($use_cache) {
        
        # check cache
        ($env, $db1) = $self->check_cache(
                                          {
                                              'home'    => $home,
                                              'dbfile'  => $dbfile,
                                              'use_txn' => $use_txn,
                                          }
                                         );
    } # endif $use_cache
    
    if ($use_txn) {
        
        if ($log->is_debug()) {
            $log->debug("Using transactions...");
        }
        
        # enable DB_TXN_NOSYNC with transactions ?
        my $use_nosync = $self->use_nosync($options);
        
        # number of times to retry the transaction
        my $retry = $self->get_retry($options);
        
        # DB environment
        if (!$env or !$use_cache) {
            $env = new BerkeleyDB::Env(
                                       '-Home'  => $home,
                                       '-Flags' => DB_CREATE|DB_INIT_TXN|DB_INIT_MPOOL|DB_INIT_LOCK,
                                       '-LockDetect' => DB_LOCK_DEFAULT,
                                      );
            if ($env && $use_nosync) {
                # speed up the txns
                $env->set_flags(DB_TXN_NOSYNC, 1);
            }
        } # unless $env
        
        unless ($env) {
            $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'env_txn',
                                             'value'  => $env,
                                         }
                                        );
            } # endif $use_cache
        } # unless $env
        
        # It's very important to open a database in a transaction
        my $txn = $env->txn_begin();
        
        # open the DB
        if (!$db1 or !$use_cache) {
            $db1 = new BerkeleyDB::Hash (
                                         '-Filename' => $dbfile,
                                         '-Flags'    => DB_CREATE,
                                         '-Env'      => $env,
                                         '-Txn'      => $txn,
                                        );
        } # unless $db1
        
        unless ($db1) {
            $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
            undef $env;
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'dbh_txn',
                                             'value'  => $db1,
                                         }
                                        );
            } # endif $use_cache
        } # unless $db1
        
        # complete the transaction opening the database
        $txn->txn_commit();
        
        # start a new transaction
        $txn = $env->txn_begin();
        
        # initialize transactions
        $db1->Txn($txn);
        ($k, $v) = ($key, "") ;
        
        # error flag
        my $error;
        for (my $i = 0; $i < $retry; $i++) {
            
            # return code
            my $rc;
            
            # does the $key exist?
            if ($db1->db_get($k, $v) == 0) {
                
                # delete it
                $rc = $db1->db_del($key);
            
            } else {
                
                # shouldn't happen
                $log->info("Key '$key' doesn't exist in database '$dbfile'. Can't delete it");
                # abort the transaction
                $txn->txn_abort();
                last;
                
            } # endif $key exists
            
            if ( $rc ) {
                if ((my $ret = $txn->txn_abort()) != 0) {
                    # double failure
                    # log an error
                    $log->error("Couldn't abort deleting key '$key' from database '$dbfile': $BerkeleyDB::Error $rc $ret");
                } else {
                    # log an error, if not a deadlock
                    unless ($rc =~ /DB_LOCK_DEADLOCK/) {
                        $log->error("Aborted deleting key '$key' from database '$dbfile': $BerkeleyDB::Error $rc");
                    }
                }
                # increment $error
                $error++;
            
            } else {
                
                # complete the transaction
                if ((my $ret = $txn->txn_commit()) != 0) {
                    $log->error("Couldn't commit deleting key '$key' from database '$dbfile'. Aborted transaction: $BerkeleyDB::Error $ret");
                    $error++;
                } else {
                    # we're fine
                    $error = 0;
                    last;
                } # endif commit
            } # endif error
        } # endfor $retry
        
        # RELEASE all the locks immediately, cleanup after yourself
        undef $txn;
        undef $db1;
        undef $env;
        
        if ($error) {
            return FAILED;
        } else {
            return SUCCESS;
        }
    
    } else {
        
        if ($log->is_debug()) {
            $log->debug("NOT Using transactions...");
        }
        
        # use default: the concurrent data store
        
        # DB environment: Concurrent Data Store, no transactions
        if (!$env or !$use_cache) {
            $env = new BerkeleyDB::Env(
                                       '-Home'  => $home,
                                       '-Flags' => DB_CREATE|DB_INIT_MPOOL|DB_INIT_CDB,
                                       '-LockDetect' => DB_LOCK_DEFAULT,
                                      );
        } # unless $env
        
        unless ($env) {
            $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'env_cdb',
                                             'value'  => $env,
                                         }
                                        );
            } # endif $use_cache
        } # unless $env
        
        # open the DB
        if (!$db1 or !$use_cache) {
            $db1 = new BerkeleyDB::Hash (
                                         '-Filename' => $dbfile,
                                         '-Flags'    => DB_CREATE,
                                         '-Env'      => $env,
                                        );
        } # unless $db1
        
        unless ($db1) {
            $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
            undef $env;
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'dbh_cdb',
                                             'value'  => $db1,
                                         }
                                        );
            } # endif $use_cache
        } # unless $db1
        
        # error flag
        my $error;
        
        # open a write cursor
        $cursor = $db1->db_cursor(DB_WRITECURSOR);
        ($k, $v) = ("$key", "") ;
        
        # wrap it in eval
        eval
        {
            # need to reset $SIG{__DIE__} here
            local $SIG{__DIE__} = 'DEFAULT';
            
            # get the next ID
            unless ($cursor->c_get($k, $v, DB_SET) == 0) {
                # no matching records in the database
                # shouldn't happen
                $log->error("Key '$key' doesn't exists in database '$dbfile'! Can't delete it");
                $error++;
            } else {
                
                # delete it from DB using the current cursor position
                $cursor->c_del();
            } # unless $k is found
        };
        
        # RELEASE all the locks immediately, cleanup after yourself
        undef $cursor;
        undef $db1;
        undef $env;
        
        if ( $@ ) {
            # log an error
            $log->error("Couldn't delete key '$key' from database '$dbfile': $@ $BerkeleyDB::Error");
            $error++;
        } # endif error
        
        if ($error) {
            return FAILED;
        } else {
            return SUCCESS;
        } # endif error
        
    
    } # endif use transactions
    
} # del_rec

=head2 B<show_recs([{'num' => $number}])>

Shows records from a database as key/value pairs to STDOUT. Default is all records. It can be
limited to {'num' => $number} of records. To output using sort, enter {'sort' => 1}. Optionally,
to thaw "frozen" key or value, use {'thaw_key' => 1} or {'thaw_val' => 1}.

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->show_recs($scalar), "show_recs dies when passed a scalar");
ok(! $bdb1->show_recs($scalarref), "show_recs dies when passed a REF to scalar");
ok(! $bdb1->show_recs(@array), "show_recs dies when passed an array");
ok(! $bdb1->show_recs($arrayref), "show_recs dies when passed a REF to array");
ok(! $bdb1->show_recs(%hash), "show_recs dies when passed a HASH");
ok(! $bdb1->show_recs($coderef), "show_recs dies when passed a REF to code");

=end testing

=cut

sub show_recs
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return FAILED;
    }
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options);
    
    my $env;
    my $db1;
    
    # some DB variables
    my %hash ;
    
    # DB environment
    $env = new BerkeleyDB::Env(
                               '-Home'  => $home,
                               '-Flags' => DB_CREATE|DB_INIT_MPOOL,
                              );
    unless ($env) {
        $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
        return FAILED;
    }
    
    # open the DB
    $db1 = tie %hash, 'BerkeleyDB::Hash',(
                                          '-Filename' => $dbfile,
                                          '-Flags'    => DB_CREATE,
                                          '-Env'      => $env,
                                         );
    unless ($db1) {
        $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
        undef $env;
        return FAILED;
    }
    
    # to sort keys
    my $sort;
    if ($options and $options->{'sort'}) {
        $sort++;
    }
    
    # limit show to 'num' keys
    my $num = 0;
    if ($options and $options->{'num'}) {
        $num = $options->{'num'};
    }
    
    # to thaw a 'frozen' key
    my $thaw_key = 0;
    if ($options and $options->{'thaw_key'}) {
        $thaw_key = $options->{'thaw_key'};
    }
    
    # to thaw a 'frozen' val
    my $thaw_val = 0;
    if ($options and $options->{'thaw_val'}) {
        $thaw_val = $options->{'thaw_val'};
    }
    
    my $cnt = 0;
    if ($sort) {
        foreach my $key (sort {($a cmp $b) || ($a <=> $b)} keys %hash) {
            my $val = $hash{$key};
            $cnt++;
            if ($num) {
                last if ($cnt > $num);
            }
            my $thawed_key;
            my $thawed_val;
            if ($thaw_key) {
                eval
                {
                    $thawed_key = Storable::thaw($key);
                };
                if ($@) {
                    $log->error("Key: '$key' can't be thawed: $@");
                    $thawed_key = "UNKNOWN";
                }
            }
            if ($thaw_val) {
                eval
                {
                    $thawed_val = Storable::thaw($val);
                };
                if ($@) {
                    $log->error("Key: '$key'. Val: '$val' can't be thawed: $@");
                    $thawed_val = "UNKNOWN";
                }
            }
            print "Key: ",($thawed_key ? Dumper($thawed_key) : "'$key'"),"\tValue: ",($thawed_val ? Dumper($thawed_val) : "'$val'"),"\n";
        }
    } else {
        foreach my $key (keys %hash) {
            my $val = $hash{$key};
            $cnt++;
            if ($num) {
                last if ($cnt > $num);
            }
            my $thawed_key;
            my $thawed_val;
            if ($thaw_key) {
                $thawed_key = Storable::thaw($key);
            }
            if ($thaw_val) {
                $thawed_val = Storable::thaw($val);
            }
            print "Key: ",($thawed_key ? Dumper($thawed_key) : "'$key'"),"\tValue: ",($thawed_val ? Dumper($thawed_val) : "'$val'"),"\n";
        }
    }
    
    # cleanup after yourself
    undef $db1;
    undef $env;
    untie %hash;

} # show_recs

=head2 B<get_next_id([{'txn' => 1}])>

Returns the next ID used as a key in a database. If the user supplies {'txn' => 1} to
the method or to "create()", then the transactions are used. Returns next ID on success,
'undef' - on failure

=begin testing

$location = catfile("testdir", "data");
mkpath($location);

# 1) get next ID using transactions and cache using default name

# default DB get_next_id.db at testdir/data

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
});

my $database = catfile($location, "next_id.db");
ok(! -e $database, "Database '$database' doesn't exist");
my $rc = $bdb->get_next_id(
                           {
                               'location' => $location,
                           }
                          );

ok($rc == 1, "Got next ID: '$rc'");

$rc = $bdb->get_next_id(
                        {
                            'location' => $location,
                        }
                       );

ok($rc == 2, "Got next ID: '$rc'");

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location, 'database' => "next_id.db"}) == 1, "Database '$database' has 1 rec");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

# 2) get next ID using a DB called test.db, no txns

# create 'data'-dir
mkpath($location);

$bdb = BDB->create({
'basename' => 'BDB',
'basedir'  => 'testdir',
'location' => $location,
'next_id'  => 'test.db',
});

$database = catfile($location, "test.db");
ok(! -e $database, "Database '$database' doesn't exist");
$rc = $bdb->get_next_id(
                        {
                            'txn' => 0,
                        }
                       );

ok($rc == 1, "Got next ID: '$rc'. No txns");

$rc = $bdb->get_next_id(
                        {
                            'txn' => 0,
                        }
                       );

ok($rc == 2, "Got next ID: '$rc'. No txns");

# DB must be created
ok(-e $database, "Database '$database' created");
ok($bdb->get_count({'location' => $location, 'database' => "test.db"}) == 1, "Database '$database' has 1 rec");

# delete the object
undef $bdb;

# delete DB
rmtree($location);

# confirm deletion
ok(! -d $location, "appname03ory '$location' doesn't exist");
ok(! -e $database, "Database '$database' doesn't exist");

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'key' => 'key1', 'value' => 'value1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(! $bdb1->get_next_id($scalar), "get_next_id dies when passed a scalar");
ok(! $bdb1->get_next_id($scalarref), "get_next_id dies when passed a REF to scalar");
ok(! $bdb1->get_next_id(@array), "get_next_id dies when passed an array");
ok(! $bdb1->get_next_id($arrayref), "get_next_id dies when passed a REF to array");
ok(! $bdb1->get_next_id(%hash), "get_next_id dies when passed a HASH");
ok(! $bdb1->get_next_id($coderef), "get_next_id dies when passed a REF to code");

=end testing

=cut

sub get_next_id
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return FAILED;
    }
    
    # initialize the next ID
    my $next_id;
    
    # home appname03ory for the databases
    my $home   = $self->get_home($options);
    my $dbfile = $self->get_dbfile($options, "next_id");
    
    # enable transactions ?
    my $use_txn = $self->use_txn($options);
    
    # enable cache ?
    my $use_cache = $self->use_cache($options);
    
    # some DB vars
    my $env;
    my $db1;
    my $cursor;
    my ($k,$v);
    
    # check cache ?
    if ($use_cache) {
        
        # check cache
        ($env, $db1) = $self->check_cache(
                                          {
                                              'home'    => $home,
                                              'dbfile'  => $dbfile,
                                              'use_txn' => $use_txn,
                                          }
                                         );
    } # endif $use_cache
    
    if ($use_txn) {
        
        if ($log->is_debug()) {
            $log->debug("Using transactions...");
        }
        
        # enable DB_TXN_NOSYNC with transactions ?
        my $use_nosync = $self->use_nosync($options);
        
        # number of times to retry the transaction
        my $retry = $self->get_retry($options);
        
        # DB environment
        if (!$env or !$use_cache) {
            $env = new BerkeleyDB::Env(
                                       '-Home'  => $home,
                                       '-Flags' => DB_CREATE|DB_INIT_TXN|DB_INIT_MPOOL|DB_INIT_LOCK,
                                       '-LockDetect' => DB_LOCK_DEFAULT,
                                      );
            if ($env && $use_nosync) {
                # speed up the txns
                $env->set_flags(DB_TXN_NOSYNC, 1);
            }
        } # unless $env
        
        unless ($env) {
            $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'env_txn',
                                             'value'  => $env,
                                         }
                                        );
            } # endif $use_cache
        } # unless $env
        
        # It's very important to open a database in a transaction
        my $txn = $env->txn_begin();
        
        # open the DB
        if (!$db1 or !$use_cache) {
            $db1 = new BerkeleyDB::Hash (
                                         '-Filename' => $dbfile,
                                         '-Flags'    => DB_CREATE,
                                         '-Env'      => $env,
                                         '-Txn'      => $txn,
                                        );
        } # unless $db1
        
        unless ($db1) {
            $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
            undef $env;
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'dbh_txn',
                                             'value'  => $db1,
                                         }
                                        );
            } # endif $use_cache
        } # unless $db1
        
        # complete the transaction opening the database
        $txn->txn_commit();
        
        
        # error flag
        my $error;
        for (my $i = 0; $i < $retry; $i++) {
            # start a new transaction
            $txn = $env->txn_begin();
            
            # initialize transactions
            $db1->Txn($txn);
            ($k, $v) = ("id", "") ;
            
            # wrap it in eval
            my $rc;
            # get the next ID
            unless ($db1->db_get($k, $v) == 0) {
                # no records in the database yet
                # initialize it
                $db1->db_put('id', 1);
                $next_id = 1;
            } else {
                
                # increment the ID
                $next_id = ++$v;
                
                # store it in the DB
                $rc = $db1->db_put('id', $v);
            }
            
            if ( $rc ) {
                # abort the transaction
                if ((my $ret = $txn->txn_abort()) != 0) {
                    # log a double error
                    $log->error("Couldn't abort transaction: $BerkeleyDB::Error $rc $ret");
                } else {
                    # log an error unless deadlock
                    unless ($rc =~ /DB_LOCK_DEADLOCK/) {
                        $log->error("Aborted transaction: $BerkeleyDB::Error $rc");
                    }
                }
                $error++;
                
            } else {
                # complete the transaction
                if ((my $ret = $txn->txn_commit()) != 0) {
                    # log an error
                    $log->error("Couldn't commit transaction: $BerkeleyDB::Error $ret");
                    $error++;
                } else {
                    # we're fine
                    $error = 0;
                    last;
                } # endif commit
            } # endif $rc
        } # endfor $retry
        
        # RELEASE all the locks immediately, cleanup after yourself
        undef $txn;
        undef $db1;
        undef $env;
        
        if ($error) {
            $log->error("Couldn't get next ID after $retry attempts");
            return FAILED;
        }
    
    } else {
        
        if ($log->is_debug()) {
            $log->debug("NOT Using transactions...");
        }
        
        # use default: the concurrent data store
        
        # DB environment: Concurrent Data Store, no transactions
        if (!$env or !$use_cache) {
            $env = new BerkeleyDB::Env(
                                       '-Home'  => $home,
                                       '-Flags' => DB_CREATE|DB_INIT_MPOOL|DB_INIT_CDB,
                                       '-LockDetect' => DB_LOCK_DEFAULT,
                                      );
        } # unless $env
        
        unless ($env) {
            $log->error("Can't create DB environment at '$home': $BerkeleyDB::Error");
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'env_cdb',
                                             'value'  => $env,
                                         }
                                        );
            } # endif $use_cache
        } # unless $env
        
        # open the DB
        if (!$db1 or !$use_cache) {
            $db1 = new BerkeleyDB::Hash (
                                         '-Filename' => $dbfile,
                                         '-Flags'    => DB_CREATE,
                                         '-Env'      => $env,
                                        );
        } # unless $db1
        
        unless ($db1) {
            $log->error("Can't open DB file '$dbfile': $BerkeleyDB::Error");
            undef $env;
            return FAILED;
        } else {
            if ($use_cache) {
                # check cache param
                $self->check_cache_param(
                                         {
                                             'home'   => $home,
                                             'dbfile' => $dbfile,
                                             'param'  => 'dbh_cdb',
                                             'value'  => $db1,
                                         }
                                        );
            } # endif $use_cache
        } # unless $db1
        
        # open a write cursor
        $cursor = $db1->db_cursor(DB_WRITECURSOR);
        ($k, $v) = ("", "") ;
        
        # wrap it in eval
        my $rc;
        
        # get the next ID
        unless ($cursor->c_get($k, $v, DB_FIRST) == 0) {
            # no records in the database yet
            # initialize it
            $cursor->c_put('id', 1, DB_KEYFIRST);
            $next_id = 1;
        } else {
            
            # increment the ID
            $next_id = ++$v;
            
            # store it in the DB
            $rc = $cursor->c_put('id', $v, DB_CURRENT);
        }
        
        # RELEASE all the locks immediately, cleanup after yourself
        undef $cursor;
        undef $db1;
        undef $env;
        
        if ( $rc ) {
            # log an error
            $log->error("Error writing to cursor: $@ $BerkeleyDB::Error $rc");
        }
    
    } # endif use transactions
    
    if ($log->is_debug()) {
        $log->debug("Next ID: ", $next_id);
    }
    
    # return the next ID
    return $next_id;

} # get_next_id


###################################################################################################
# Data Access Methods
###################################################################################################

=head2 B<get_config()>

Returns the config HASH in the list context or HASH ref otherwise

=cut

sub get_config
{
    wantarray ? %{ shift->{'config'} } : shift->{'config'};
}

=head2 B<check_cache($hashref)>

Checks and sets cache HASH to use with DB and ENV handles. It expects a ref to HASH as
input. Returns ENV and DB handles, if available

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'hom' => 'home1', 'dbfil' => 'dbfile1');
my %hashhome = ( 'home' => 'home1' );
my %hashdbfile = ( 'dbfile' => 'dbfile1' );
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
my ($e, $d);
($e,$d) = $bdb1->check_cache($scalar);
ok(! ($e && $d), "check_cache dies when passed a scalar");
($e,$d) = $bdb1->check_cache($scalarref);
ok(! ($e && $d), "check_cache dies when passed a REF to scalar");
($e,$d) = $bdb1->check_cache(@array);
ok(! ($e && $d), "check_cache dies when passed an array");
($e,$d) = $bdb1->check_cache($arrayref);
ok(! ($e && $d), "check_cache dies when passed a REF to array");
($e,$d) = $bdb1->check_cache(%hash);
ok(! ($e && $d), "check_cache dies when passed a HASH");
($e,$d) = $bdb1->check_cache($coderef);
ok(! ($e && $d), "check_cache dies when passed a REF to code");

# mandatory params
($e,$d) = $bdb1->check_cache(\%hashhome);
ok(! ($e && $d), "check_cache dies when passed a only HOME");
($e,$d) = $bdb1->check_cache(\%hashdbfile);
ok(! ($e && $d), "check_cache dies when passed a only DBFILE");

# cache set
my %hash1 = ( 'home' => 'home1', 'dbfile' => 'dbfile1');
ok(!exists $bdb1->{'cache'}->{'home1'}, "home1 doesn't exist");
ok(!exists $bdb1->{'cache'}->{'home1'}->{'dbfile1'}, "home1->dbfile1 doesn't exists");
($e,$d) = $bdb1->check_cache(\%hash1);
ok(! ($e && $d), "check_cache not set (\%hash1)");
ok(exists $bdb1->{'cache'}->{'home1'}, "home1 now exists");
ok(exists $bdb1->{'cache'}->{'home1'}->{'dbfile1'}, "home1->dbfile1 now exists");

# set txns
my %hash1_txn = ( 'home' => 'home1', 'dbfile' => 'dbfile1', 'use_txn' => 1);
($e,$d) = $bdb1->check_cache(\%hash1_txn);
ok(! ($e && $d), "check_cache txns not set (\%hash1_txn)");
ok(exists $bdb1->{'cache'}->{'home1'}, "home1 still exists");
ok(exists $bdb1->{'cache'}->{'home1'}->{'dbfile1'}, "home1->dbfile1 still exists");
my %hash1_txn_env = ( 'home' => 'home1', 'dbfile' => 'dbfile1', 'param' => 'env_txn', 'value' => 1);
my %hash1_txn_dbh = ( 'home' => 'home1', 'dbfile' => 'dbfile1', 'param' => 'dbh_txn', 'value' => 1);
ok($bdb1->check_cache_param(\%hash1_txn_env), "Setting Txn env");
ok($bdb1->check_cache_param(\%hash1_txn_dbh), "Setting Txn dbh");
($e,$d) = $bdb1->check_cache(\%hash1_txn);
ok($e && $d, "check_cache txns set (\%hash1)");

# another dbfile
my %hash2_txn = ( 'home' => 'home1', 'dbfile' => 'dbfile2', 'use_txn' => 1);
ok(!exists $bdb1->{'cache'}->{'home1'}->{'dbfile2'}, "home1->dbfile2 doesn't exist");
($e,$d) = $bdb1->check_cache(\%hash2_txn);
ok(! ($e && $d), "check_cache txns not set (\%hash2_txn)");
ok(exists $bdb1->{'cache'}->{'home1'}->{'dbfile2'}, "home1->dbfile2 now exists");
my %hash2_txn_env = ( 'home' => 'home1', 'dbfile' => 'dbfile2', 'param' => 'env_txn', 'value' => 1);
my %hash2_txn_dbh = ( 'home' => 'home1', 'dbfile' => 'dbfile2', 'param' => 'dbh_txn', 'value' => 1);
ok($bdb1->check_cache_param(\%hash2_txn_env), "Setting Txn env");
ok($bdb1->check_cache_param(\%hash2_txn_dbh), "Setting Txn dbh");
($e,$d) = $bdb1->check_cache(\%hash2_txn);
ok($e && $d, "check_cache txns set (\%hash2)");

# set cdb
my %hash2_cdb = ( 'home' => 'home1', 'dbfile' => 'dbfile2', 'use_txn' => 0);
ok(exists $bdb1->{'cache'}->{'home1'}->{'dbfile2'}, "home1->dbfile2 exists");
($e,$d) = $bdb1->check_cache(\%hash2_cdb);
ok(! ($e && $d), "check_cache cdb not set (\%hash2_cdb)");
ok(exists $bdb1->{'cache'}->{'home1'}->{'dbfile2'}, "home1->dbfile2 still exists");
my %hash2_cdb_env = ( 'home' => 'home1', 'dbfile' => 'dbfile2', 'param' => 'env_cdb', 'value' => 1);
my %hash2_cdb_dbh = ( 'home' => 'home1', 'dbfile' => 'dbfile2', 'param' => 'dbh_cdb', 'value' => 1);
ok($bdb1->check_cache_param(\%hash2_cdb_env), "Setting CDB env");
ok($bdb1->check_cache_param(\%hash2_cdb_dbh), "Setting CDB dbh");
($e,$d) = $bdb1->check_cache(\%hash2_cdb);
ok($e && $d, "check_cache cdb set (\%hash2)");
($e,$d) = $bdb1->check_cache(\%hash2_txn);
ok($e && $d, "check_cache txn still set (\%hash2)");

# different home
my %hash3 = ( 'home' => 'home2', 'dbfile' => 'dbfile1');
ok(!exists $bdb1->{'cache'}->{'home2'}, "home2 doesn't exist");
ok(!exists $bdb1->{'cache'}->{'home2'}->{'dbfile1'}, "home2->dbfile1 doesn't exists");
($e,$d) = $bdb1->check_cache(\%hash3);
ok(! ($e && $d), "check_cache not set (\%hash3)");
ok(exists $bdb1->{'cache'}->{'home2'}, "home2 now exists");
ok(exists $bdb1->{'cache'}->{'home2'}->{'dbfile1'}, "home2->dbfile1 now exists");
($e,$d) = $bdb1->check_cache(\%hash2_cdb);
ok($e && $d, "check_cache cdb still set (\%hash2)");
($e,$d) = $bdb1->check_cache(\%hash2_txn);
ok($e && $d, "check_cache txn still set (\%hash2)");

=end testing

=cut

sub check_cache
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return undef, undef;
    }
    
    # need $home and $dbfile
    my $home    = $options->{'home'};
    my $dbfile  = $options->{'dbfile'};
    
    # sanity check
    unless ($home and $dbfile) {
        $log->error("Must have 'home', 'dbfile' variables as input");
        return undef, undef;
    }
    
    # this one is optional
    my $use_txn = $options->{'use_txn'};
    
    # ENV and DB handles
    my $env;
    my $db1;
    my $hash;
    
    # check $home cache
    if (exists $self->{'cache'}->{$home}) {
        
        # check $dbfile cache
        if (exists $self->{'cache'}->{$home}->{$dbfile}) {
            
            # check for ENV and DBH
            if ($use_txn) {
                if (exists $self->{'cache'}->{$home}->{$dbfile}->{'env_txn'}) {
                    # environment exists in cache
                    $env = $self->{'cache'}->{$home}->{$dbfile}->{'env_txn'};
                    if ($log->is_debug()) {
                        $log->debug("Using cached env_txn...");
                    }
                } # endif exists env_txn
                if (exists $self->{'cache'}->{$home}->{$dbfile}->{'dbh_txn'}) {
                    # environment exists in cache
                    $db1 = $self->{'cache'}->{$home}->{$dbfile}->{'dbh_txn'};
                    if ($log->is_debug()) {
                        $log->debug("Using cached dbh_txn...");
                    }
                } # endif exists dbh_txn
            
            } else {
                
                # don't use transactions
                if (exists $self->{'cache'}->{$home}->{$dbfile}->{'env_cdb'}) {
                    # environment exists in cache
                    $env = $self->{'cache'}->{$home}->{$dbfile}->{'env_cdb'};
                    if ($log->is_debug()) {
                        $log->debug("Using cached env_cdb...");
                    }
                } # endif exists env_cdb
                if (exists $self->{'cache'}->{$home}->{$dbfile}->{'dbh_cdb'}) {
                    # environment exists in cache
                    $db1 = $self->{'cache'}->{$home}->{$dbfile}->{'dbh_cdb'};
                    if ($log->is_debug()) {
                        $log->debug("Using cached dbh_cdb...");
                    }
                } # endif exists dbh_cdb
            
            } # endif $use_txn
        
        } else {
            
            # set $dbfile cache
            $self->{'cache'}->{$home}->{$dbfile} = {};
            if ($log->is_debug()) {
                $log->debug("Setting dbfile '$dbfile' cache...");
            }
    
        } # endif exists $dbfile
        
    } else {
        
        # set $home cache
        $self->{'cache'}->{$home} = {};
        if ($log->is_debug()) {
            $log->debug("Setting home '$home' cache...");
        }
        
        # set $dbfile cache
        $self->{'cache'}->{$home}->{$dbfile} = {};
        if ($log->is_debug()) {
            $log->debug("Setting dbfile '$dbfile' cache...");
        }
        
    } # endif exists $home
    
    return $env, $db1;

} # check_cache

=head2 B<check_cache_param($hashref)>

Checks and sets cache HASH parameter to use with DB and ENV handles. It expects a ref to HASH as
input. Returns 1 on success, undef on failure

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'home' => 'home1', 'dbfile' => 'dbfile1', 'param' => 'bart', 'value' => 'simpson');
my %hashhome = ( 'home' => 'home1' );
my %hashdbfile = ( 'dbfile' => 'dbfile1' );
my %hashdbfileparam = ( 'dbfile' => 'dbfile1', 'param' => 'param1' );
my %hashhomedbfile = ( 'home' => 'home1', 'dbfile' => 'dbfile1' );
my %hashhomeparam = ( 'home' => 'home1', 'param' => 'dbfile1' );
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => 1});
ok(!$bdb1->check_cache_param($scalar), "check_cache_param dies when passed SCALAR");
ok(!$bdb1->check_cache_param($scalarref), "check_cache_param dies when passed ref to SCALAR");
ok(!$bdb1->check_cache_param(@array), "check_cache_param dies when passed ARRAY");
ok(!$bdb1->check_cache_param($arrayref), "check_cache_param dies when passed ref to ARRAY");
ok(!$bdb1->check_cache_param($coderef), "check_cache_param dies when passed ref to CODE");
ok(!$bdb1->check_cache_param(%hash), "check_cache_param dies when passed HASH");

# mandatory args
ok(!$bdb1->check_cache_param(\%hashhome), "check_cache_param dies when NOT passed dbfile and param");
ok(!$bdb1->check_cache_param(\%hashdbfile), "check_cache_param dies when NOT passed home and param");
ok(!$bdb1->check_cache_param(\%hashdbfileparam), "check_cache_param dies when NOT passed home");
ok(!$bdb1->check_cache_param(\%hashhomedbfile), "check_cache_param dies when NOT passed param");
ok(!$bdb1->check_cache_param(\%hashhomeparam), "check_cache_param dies when NOT passed dbfile");

# set params
ok(!exists $bdb1->{'cache'}->{'home1'}->{'dbfile1'}->{'bart'}, "Bart not set");
ok($bdb1->check_cache_param(\%hash), "Bart is set");
ok($bdb1->{'cache'}->{'home1'}->{'dbfile1'}->{'bart'} eq "simpson", "Bart's last name is Simpson");
my %hash1 = ( 'home' => 'home1', 'dbfile' => 'dbfile1', 'param' => 'bart', 'value' => 'skinner');
ok($bdb1->check_cache_param(\%hash1), "Bart is still set");
ok($bdb1->{'cache'}->{'home1'}->{'dbfile1'}->{'bart'} eq "simpson", "Bart's last name is still Simpson");
my %hash2 = ( 'home' => 'home1', 'dbfile' => 'dbfile1', 'param' => 'bart', 'value' => 'skinner', 'set_cache' => 1);
ok($bdb1->check_cache_param(\%hash2), "Bart is still Bart");
ok($bdb1->{'cache'}->{'home1'}->{'dbfile1'}->{'bart'} eq "skinner", "Bart's last name is now Skinner");

=end testing

=cut

sub check_cache_param
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return FAILED;
    }
    
    # need $home and $dbfile and $param
    my $home   = $options->{'home'};
    my $dbfile = $options->{'dbfile'};
    my $param  = $options->{'param'};
    
    # sanity check
    unless ($home and $dbfile and $param) {
        $log->error("Must have 'home', 'dbfile' and 'param' variables as input");
        return FAILED;
    }
    
    # this is optional
    my $value     = $options->{'value'};
    my $set_cache = $options->{'set_cache'};
    
    # set cache param
    if (!exists $self->{'cache'}->{$home}->{$dbfile}->{$param} or $set_cache) {
        $self->{'cache'}->{$home}->{$dbfile}->{$param} = $value;
        if ($log->is_debug()) {
            $log->debug("Setting '$param' cache...");
        }
    } # unless exists env_txn
    
    return SUCCESS;
    
} # check_cache_param

=head2 B<get_home($hashref)>

Returns the location of a BerkeleyDB database relative to the script. Checks the script
config file and input parameters. Default is "data"

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'location' => 'home1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => {}});
ok(!$bdb1->get_home($scalar), "get_home dies when passed SCALAR");
ok(!$bdb1->get_home($scalarref), "get_home dies when passed ref to SCALAR");
ok(!$bdb1->get_home(@array), "get_home dies when passed ARRAY");
ok(!$bdb1->get_home($arrayref), "get_home dies when passed ref to ARRAY");
ok(!$bdb1->get_home($coderef), "get_home dies when passed ref to CODE");
ok(!$bdb1->get_home(%hash), "get_home dies when passed HASH");

# default
is($bdb1->get_home(), catdir(dirname($0),"data"), "Defaulting to 'data'");

# supplied via options
is($bdb1->get_home(\%hash), catdir(dirname($0),"home1"), "Home is 'home1'");

# via self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'location' => 'home2'});
is($bdb1->get_home(), catdir(dirname($0),"home2"), "Home is 'home2'");

# via config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'location' => 'home3'}}});
is($bdb1->get_home(), catdir(dirname($0),"home3"), "Home is 'home3'");

# options override self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'location' => 'home2'});
is($bdb1->get_home(\%hash), catdir(dirname($0),"home1"), "Home is 'home1'");

# options override config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'location' => 'home3'}}});
is($bdb1->get_home(\%hash), catdir(dirname($0),"home1"), "Home is 'home1'");

# options override config and self
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'location' => 'home3'}}, 'location' => 'home2'});
is($bdb1->get_home(\%hash), catdir(dirname($0),"home1"), "Home is 'home1'");

=end testing

=cut

sub get_home
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return FAILED;
    }
    
    my $home = ($options and $options->{'location'} ? catdir(dirname($0),$options->{'location'}) : undef)
           || ($self->{'location'} ? catdir(dirname($0),$self->{'location'}) : undef)
           || ($self->{'config'}->{'db'}->{'location'} ? catdir(dirname($0),$self->{'config'}->{'db'}->{'location'}) : undef)
           || catdir(dirname($0),"data");
    
    return $home;

} # get_home

=head2 B<get_retry($hashref)>

Returns the number of times to retry the transsaction before giving up.
It uses config file and/or input parameters. Default is 3.

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'retry' => '10');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => {}});
ok(!$bdb1->get_retry($scalar), "get_retry dies when passed SCALAR");
ok(!$bdb1->get_retry($scalarref), "get_retry dies when passed ref to SCALAR");
ok(!$bdb1->get_retry(@array), "get_retry dies when passed ARRAY");
ok(!$bdb1->get_retry($arrayref), "get_retry dies when passed ref to ARRAY");
ok(!$bdb1->get_retry($coderef), "get_retry dies when passed ref to CODE");
ok(!$bdb1->get_retry(%hash), "get_retry dies when passed HASH");

# default
is($bdb1->get_retry(), 3, "Defaulting to '3'");

# supplied via options
is($bdb1->get_retry(\%hash), 10, "Retry is '10'");

# via self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'retry' => '20'});
is($bdb1->get_retry(), 20, "Retry is '20'");

# via config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'retry' => '30'}}});
is($bdb1->get_retry(), 30, "Retry is '30'");

# options override self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'retry' => '20'});
is($bdb1->get_retry(\%hash), 10, "Retry is '10'");

# options override config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'retry' => '30'}}});
is($bdb1->get_retry(\%hash), 10, "Retry is '10'");

# options override config and self
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'retry' => '30'}}, 'retry' => '20'});
is($bdb1->get_retry(\%hash), 10, "Retry is '10'");

=end testing

=cut

sub get_retry
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return FAILED;
    }
    
    my $retry = ($options and $options->{'retry'} ? $options->{'retry'} : undef)
           || ($self->{'retry'} ? $self->{'retry'} : undef)
           || ($self->{'config'}->{'db'}->{'retry'} ? $self->{'config'}->{'db'}->{'retry'} : undef)
           || 3;
    
    return $retry;

} # get_retry

=head2 B<get_dbfile($hashref)>

Returns the name of a BerkeleyDB database file. Default is "appname05.db" for appname05
and "next_id.db" for next ID

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'database' => 'file1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => {}});
ok(!$bdb1->get_dbfile($scalar), "get_dbfile dies when passed SCALAR");
ok(!$bdb1->get_dbfile($scalarref), "get_dbfile dies when passed ref to SCALAR");
ok(!$bdb1->get_dbfile(@array), "get_dbfile dies when passed ARRAY");
ok(!$bdb1->get_dbfile($arrayref), "get_dbfile dies when passed ref to ARRAY");
ok(!$bdb1->get_dbfile($coderef), "get_dbfile dies when passed ref to CODE");
ok(!$bdb1->get_dbfile(%hash), "get_dbfile dies when passed HASH");

# default
is($bdb1->get_dbfile(), 'appname05.db', "Defaulting to 'appname05.db'");

# supplied via options
is($bdb1->get_dbfile(\%hash), 'file1', "DB file is 'file1'");

# via self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'database' => 'file2'});
is($bdb1->get_dbfile(), 'file2', "DB file is 'file2'");

# via config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'database' => 'file3'}}});
is($bdb1->get_dbfile(), 'file3', "DB file is 'file3'");

# options override self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'database' => 'file2'});
is($bdb1->get_dbfile(\%hash), 'file1', "DB file is 'file1'");

# options override config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'database' => 'file3'}}});
is($bdb1->get_dbfile(\%hash), 'file1', "DB file is 'file1'");

# options override config and self
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'database' => 'file3'}}, 'database' => 'file2'});
is($bdb1->get_dbfile(\%hash), 'file1', "DB file is 'file1'");

# next_id
my %hash1 = ( 'next_id' => 'next_file1');
undef $bdb1;
$bdb1 = BDB->create({'config' => {}});

# default
is($bdb1->get_dbfile({},'next_id'), 'next_id.db', "Defaulting to 'next_id.db'");

# supplied via options
is($bdb1->get_dbfile(\%hash1,'next_id'), 'next_file1', "DB file is 'next_file1'");

# via self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'next_id' => 'next_file2'});
is($bdb1->get_dbfile({},'next_id'), 'next_file2', "DB file is 'next_file2'");

# via config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'next_id' => 'next_file3'}}});
is($bdb1->get_dbfile({},'next_id'), 'next_file3', "DB file is 'next_file3'");

# options override self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'next_id' => 'next_file2'});
is($bdb1->get_dbfile(\%hash1,'next_id'), 'next_file1', "DB file is 'next_file1'");

# options override config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'next_id' => 'next_file3'}}});
is($bdb1->get_dbfile(\%hash1,'next_id'), 'next_file1', "DB file is 'next_file1'");

# options override config and self
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'next_id' => 'next_file3'}}, 'next_id' => 'next_file2'});
is($bdb1->get_dbfile(\%hash1,'next_id'), 'next_file1', "DB file is 'next_file1'");

=end testing

=cut

sub get_dbfile
{
    my $self    = shift;
    my $options = shift;
    my $type    = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return FAILED;
    }
    
    my $dbfile;
    
    if ($type and $type eq "next_id") {
        # next ID
        $dbfile = ($options and $options->{'next_id'})
               || $self->{'next_id'}
               || $self->{'config'}->{'db'}->{'next_id'}
               || "next_id.db";
    } else {
        # default
        $dbfile = ($options and $options->{'database'})
               || $self->{'database'}
               || $self->{'config'}->{'db'}->{'database'}
               || "appname05.db";
    }
    
    return $dbfile;
    
} # get_dbfile

=head2 B<use_txn($hashref)>

Sets $use_txn flag as per $options, $self or $config

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'txn' => '1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => {}});
ok(!$bdb1->use_txn($scalar), "use_txn dies when passed SCALAR");
ok(!$bdb1->use_txn($scalarref), "use_txn dies when passed ref to SCALAR");
ok(!$bdb1->use_txn(@array), "use_txn dies when passed ARRAY");
ok(!$bdb1->use_txn($arrayref), "use_txn dies when passed ref to ARRAY");
ok(!$bdb1->use_txn($coderef), "use_txn dies when passed ref to CODE");
ok(!$bdb1->use_txn(%hash), "use_txn dies when passed HASH");

# default
ok(!defined($bdb1->use_txn()), "Defaulting to 'undef'");

# supplied via options
is($bdb1->use_txn(\%hash), 1, "USE_TXN is '1'");

# via self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'txn' => '1'});
is($bdb1->use_txn(), 1, "USE_TXN is '1'");

# via config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'txn' => '1'}}});
is($bdb1->use_txn(), 1, "USE_TXN is '1'");

# options override self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'txn' => '0'});
is($bdb1->use_txn(\%hash), 1, "USE_TXN is '1'");

# options override config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'txn' => '0'}}});
is($bdb1->use_txn(\%hash), 1, "USE_TXN is '1'");

# options override config and self
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'txn' => '0'}}, 'txn' => '0'});
is($bdb1->use_txn(\%hash), 1, "USE_TXN is '1'");

# options override config and self
my %hash1 = ( 'txn' => '0');
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'txn' => '1'}}, 'txn' => '1'});
is($bdb1->use_txn(\%hash1), 0, "USE_TXN is '0'");

=end testing

=cut

sub use_txn
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return FAILED;
    }
    
    my $use_txn;
    if ($options and $options->{'txn'}) {
        # yes, we want transactions
        $use_txn++;
    } elsif (($self->{'txn'} or $self->{'config'}->{'db'}->{'txn'})) {
        if ($options and exists $options->{'txn'} and !$options->{'txn'}) {
            # no, we don't want transactions
            $use_txn = 0;
        } else {
            # yes, we want transactions
            $use_txn++;
        }
    } # endif use transactions
    
    return $use_txn;

} # use_txn

=head2 B<use_nosync($hashref)>

Sets $use_nosync flag as per $options to speed up the transaction throughput

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'nosync' => '1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => {}});
ok(!$bdb1->use_nosync($scalar), "use_nosync dies when passed SCALAR");
ok(!$bdb1->use_nosync($scalarref), "use_nosync dies when passed ref to SCALAR");
ok(!$bdb1->use_nosync(@array), "use_nosync dies when passed ARRAY");
ok(!$bdb1->use_nosync($arrayref), "use_nosync dies when passed ref to ARRAY");
ok(!$bdb1->use_nosync($coderef), "use_nosync dies when passed ref to CODE");
ok(!$bdb1->use_nosync(%hash), "use_nosync dies when passed HASH");

# default
ok(!defined($bdb1->use_nosync()), "Defaulting to 'undef'");

# supplied via options
is($bdb1->use_nosync(\%hash), 1, "USE_NOSYNC is '1'");

# via self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'nosync' => '1'});
is($bdb1->use_nosync(), 1, "USE_NOSYNC is '1'");

# via config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'nosync' => '1'}}});
is($bdb1->use_nosync(), 1, "USE_NOSYNC is '1'");

# options override self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'nosync' => '0'});
is($bdb1->use_nosync(\%hash), 1, "USE_NOSYNC is '1'");

# options override config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'nosync' => '0'}}});
is($bdb1->use_nosync(\%hash), 1, "USE_NOSYNC is '1'");

# options override config and self
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'nosync' => '0'}}, 'nosync' => '0'});
is($bdb1->use_nosync(\%hash), 1, "USE_NOSYNC is '1'");

# options override config and self
my %hash1 = ( 'nosync' => '0');
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'nosync' => '1'}}, 'nosync' => '1'});
is($bdb1->use_nosync(\%hash1), 0, "USE_NOSYNC is '0'");

=end testing

=cut

sub use_nosync
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return FAILED;
    }
    
    my $use_nosync;
    if ($options and $options->{'nosync'}) {
        # yes, we want to use NOSYNC with transactions
        $use_nosync++;
    } elsif (($self->{'nosync'} or $self->{'config'}->{'db'}->{'nosync'})) {
        if ($options and exists $options->{'nosync'} and !$options->{'nosync'}) {
            # no, we don't want to use NOSYNC with transactions
            $use_nosync = 0;
        } else {
            # yes, we want to use NOSYNC with transactions
            $use_nosync++;
        }
    } # endif use NOSYNC
    
    return $use_nosync;

} # use_nosync

=head2 B<use_cache($hashref)>

Sets $use_cache flag as per $options, $self or $config

=begin testing

# these all should die
my $scalar = "abc";
my $scalarref = \$scalar;
my @array = qw(1 2 3);
my $arrayref = \@array;
my %hash = ( 'cache' => '1');
my $coderef = sub { "die, piggy, die" };

my $bdb1 = BDB->create({'config' => {}});
ok(!$bdb1->use_cache($scalar), "use_cache dies when passed SCALAR");
ok(!$bdb1->use_cache($scalarref), "use_cache dies when passed ref to SCALAR");
ok(!$bdb1->use_cache(@array), "use_cache dies when passed ARRAY");
ok(!$bdb1->use_cache($arrayref), "use_cache dies when passed ref to ARRAY");
ok(!$bdb1->use_cache($coderef), "use_cache dies when passed ref to CODE");
ok(!$bdb1->use_cache(%hash), "use_cache dies when passed HASH");

# default
ok(!defined($bdb1->use_cache()), "Defaulting to 'undef'");

# supplied via options
is($bdb1->use_cache(\%hash), 1, "USE_CACHE is '1'");

# via config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'cache' => '1'}}});
is($bdb1->use_cache(), 1, "USE_CACHE is '1'");

# options override self
undef $bdb1;
$bdb1 = BDB->create({'config' => {}, 'cache' => '0'});
is($bdb1->use_cache(\%hash), 1, "USE_CACHE is '1'");

# options override config
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'cache' => '0'}}});
is($bdb1->use_cache(\%hash), 1, "USE_CACHE is '1'");

# options override config and self
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'cache' => '0'}}, 'cache' => '0'});
is($bdb1->use_cache(\%hash), 1, "USE_CACHE is '1'");

# options override config and self
my %hash1 = ( 'cache' => '0');
undef $bdb1;
$bdb1 = BDB->create({'config' => {'db' => {'cache' => '1'}}, 'cache' => '1'});
is($bdb1->use_cache(\%hash1), 0, "USE_CACHE is '0'");

=end testing

=cut

sub use_cache
{
    my $self    = shift;
    my $options = shift;
    
    my $log = get_logger();
    if ($log->is_debug()) {
        $log->debug("Entered");
    }
    
    # sanity check
    if ($options and ref($options) ne "HASH") {
        $log->error("Must have a reference to HASH as input");
        return FAILED;
    }
    
    my $use_cache;
    if ($options and $options->{'cache'}) {
        # yes, we want to use cache
        $use_cache++;
    } elsif ($self->{'config'}->{'db'}->{'cache'}) {
        if ($options and exists $options->{'cache'} and !$options->{'cache'}) {
            # no, we don't want to use cache
            $use_cache = 0;
        } else {
            # yes, we want to use cache
            $use_cache++;
        }
    } # endif use cache
    
    return $use_cache;

} # use_cache

1;

__END__

=head1 AUTHOR

Maxim Maltchevski, appname05 Site
E<lt>maxim.maltchevski@appname05site.comE<gt>

=head1 BUGS

=head1 COPYRIGHT

Copyright (c) 2003, appname05 Site.  All Rights Reserved.

=cut
