#!/usr/bin/perl 
#
# $Log$
# Revision 1.6  2006/02/15 16:54:37  mmaltchevski
# Numerous changed to find and verify the location record plus IVR logic
#
# Revision 1.5  2006/01/30 19:44:55  mmaltchevski
# Modified code for IVR/Web PIN check
#
# Revision 1.4  2005/12/15 20:01:22  mmaltchevski
# Added store logic
#
# Revision 1.3  2005/08/10 16:27:39  mmaltchevski
# Added disable_location_check flag
#
# Revision 1.2  2005/08/09 18:37:43  mmaltchevski
# Added DYNAMIC PIN validation
#
# Revision 1.1  2005/07/13 20:50:11  mmaltchevski
# Initial check-in
#
#

=head1 NAME

verifyPIN.pl

=head1 SYNOPSIS

The script gets a request with the following variables
http://verifyPIN.pl?pin_id=123456&appname05_id=123[&status_id=10,90]

=head1 DETAILS

pin_id and appname05_id are mandatory. The script checks the master list
for the appname05_id and finds the appropriate location of password file.
If status_id is provided, the completed file record is created with it.

=cut

# a hack to make accessCode work without the real appname05 engine
package appname05BIN;
    our $base_data_dir;
1;

package main;
use strict;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
$CGI::DISABLE_UPLOADS = 1;	   # please don't DOS us...
$CGI::POST_MAX = 1024;		   # support posts at all?
 
use Fcntl;
use FindBin;
use XML::Simple;
use HTML::Template;
use File::Basename; 
use File::Spec::Functions; 
use Log::Dispatch::File;
use Log::Log4perl qw(:easy); 
use Data::Dumper; 
$Data::Dumper::Indent = 3;
use Sys::Hostname;
use lib "$FindBin::Bin";

use accessCode;
use simpleWrite;
use dbTools;

################################################################################################
# ERROR and return code(s)
################################################################################################
sub SUCCESS                      () {  1  }  # general OK
sub FAILED                       () { -1  }  # general FAILURE
sub appname05_ID_NOT_VALID          () { -2  }  # appname05 ID doesn't exist in the master file
sub PIN_NOT_VALID                () { -3  }  # PIN doesn't exist in the password file
sub WEB_appname05_STARTED           () { -4  }  # WEB appname05 is started
sub WEB_appname05_COMPLETED         () { -5  }  # WEB appname05 is completed
sub MASTER_LIST_DOES_NOT_EXIST   () { -6  }  # appname05 master list doesn't exist
sub NO_PIN_ON_URL                () { -7  }  # No PIN on the URL
sub NO_appname05_ID_ON_URL          () { -8  }  # No appname05_id on the URL
sub PASSWORD_FILE_DOES_NOT_EXIST () { -9  }  # appname05 password file doesn't exist
sub IVR_appname05_STARTED           () { -10 }  # IVR appname05 is started
sub IVR_appname05_COMPLETED         () { -11 }  # IVR appname05 is completed
sub PASSWORD_DIR_DOES_NOT_EXIST  () { -12 }  # appname05 password dir doesn't exist
################################################################################################

################################################################################################
# Status flag(s)
################################################################################################
sub WEB_DEFAULT                 () {  0   }  # Web appname05 default value for status
sub WEB_STARTED                 () {  1   }  # Web appname05 incomplete record
sub WEB_COMPLETED               () {  9   }  # Web appname05 complete record
sub IVR_STARTED                 () {  10  }  # IVR appname05 incomplete record
sub IVR_DROPPED                 () {  80  }  # IVR appname05 dropped
sub IVR_COMPLETED               () {  90  }  # IVR appname05 complete record
# text returned to the IVR application
sub IVR_STATUS_VALID           () { "VALID"     }  # PIN is NOT in completed file
sub IVR_STATUS_STARTED         () { "STARTED"   }  # PIN is IN completed file, Web appname05 started
sub IVR_STATUS_COMPLETED       () { "COMPLETED" }  # PIN is IN completed file, Web appname05 completed
sub IVR_STATUS_UNKNOWN         () { "UNKNOWN"   }  # error checking the IVR PIN
################################################################################################

# init config 
my $cfg = _init_config();

# get the logger 
my $log = $cfg->{'logger'}; 

# error message
my $error_message = "";

# HTML template to use
my $tmpl = $cfg->{'tmpl'};
unless (-e $tmpl) {
    # log an errror
    $log->error("Can't find HTML template '$tmpl': $!");
    exit -1;
}

# IVR template to use
my $tmplivr = $cfg->{'tmplivr'};
unless (-e $tmplivr) {
    # log an errror
    $log->error("Can't find IVR template '$tmplivr': $!");
    exit -1;
}

# get CGI object
my $q = new CGI;

# get PIN
my $pin = $q->param("pin_id") || shift @ARGV;

# sanity check
unless ($pin) {
    # log an error
    $error_message = "No PIN passed on the URL: " . $q->url();
    $log->error($error_message);
    # exit with the status
    my_exit(
            'cgi'   => $q,
            'title' => "ERROR",
            'tmpl'  => $tmpl,
            'log'   => $log,
            'msg'   => $error_message,
            'rc'    => NO_PIN_ON_URL,
            'color' => "red",
           );
}

# get appname05_id
my $appname05_id = $q->param("appname05_id") || shift @ARGV;

# sanity check
unless ($appname05_id) {
    # log an error
    $error_message = "No appname05_id passed on the URL: " . $q->url();
    $log->error($error_message);
    # exit with the status
    my_exit(
            'cgi'   => $q,
            'title' => "ERROR",
            'tmpl'  => $tmpl,
            'log'   => $log,
            'msg'   => $error_message,
            'rc'    => NO_appname05_ID_ON_URL,
            'color' => "red",
           );
}

# optional status_id
my $status_id = $q->param("status_id") || IVR_STARTED;

# drive letter
my $drive = $cfg->{'drive'};

# set appname05BIN::basedir to drive
$appname05BIN::base_data_dir = $drive;

# check the master file
my $master_list     =  $cfg->{'db'}->{'master_list'};
my $master_list_abs =  $drive .'/'.$master_list;
unless (-e  $master_list_abs) {
    # can't open master list
    $error_message = "Can't open appname05 master list '$master_list_abs': $!";
    $log->error($error_message);
    # exit with the status
    my_exit(
            'cgi'   => $q,
            'title' => "ERROR",
            'tmpl'  => $tmpl,
            'log'   => $log,
            'msg'   => $error_message,
            'rc'    => MASTER_LIST_DOES_NOT_EXIST,
            'color' => "red",
           );
}

# initialze the password file var
my $passfile;
my $passfile_abs;

# initialze the completed file var
my $compfile;
my $compfile_abs;

# initialze the completed DB var
my $compdb;

# delimeter
my $delim = $cfg->{'delim'} || '\|';

# type of validation
my $dynamic = $q->param("dynamic") || shift @ARGV;

if ($dynamic) {
    # use the binary files to validate PIN
    # initialize accessCode
    my $acc_ml = new accessCode($master_list, $appname05_id, 0, $delim);
    if ($acc_ml) {
        # access list object created
        if ($log->is_debug()) {
            $log->debug("Created master list access object for master list '$master_list'");
        }
        
        # does the appname05_id exists in the list ?
        if ($acc_ml->isAccessCode()) {
            # appname05_id found
            $passfile     = $acc_ml->getAccessField(1);
            $passfile_abs = $drive .'/'. $passfile;
            # appname03ory to look for binary file(s)
            my $bindir    = dirname($passfile_abs);
            unless (-d $bindir) {
                $error_message = "appname03ory '$bindir' doesn't exist: $!";
                $log->error($error_message);
                # exit with the status
                my_exit(
                        'cgi'   => $q,
                        'title' => "ERROR",
                        'tmpl'  => $tmpl,
                        'log'   => $log,
                        'msg'   => "Password dir doesn't exist for appname05_id '$appname05_id' !",
                        'rc'    => PASSWORD_DIR_DOES_NOT_EXIST,
                        'color' => "red",
                       );
            } else {
                # dir is valid
                # load all binary files with extension $binext
                my $binext   = $cfg->{'binext'} || "FIL";
                my $found    = 0;
                my $success  = 0;
                my $rc       = undef;
                my $msg      = "";
                my $store    = 0;
                my $chain    = 0;
                my $progr    = 0;
                my $expiry   = "01/01/2000";
                my $min      = 0;
                my $location = 0;
                my $sPIN     = 0;
                my $PINc     = 0;
                while (my $binfile = glob(catfile($bindir, "*.$binext"))) {
                    $found++;
                    (
                     $rc,
                     $msg,
                     $store,
                     $chain,
                     $progr,
                     $expiry,
                     $min,
                     $location,
                     $sPIN,
                     $PINc
                    ) = check_bin(
                                  'log'                    => $log,
                                  'pin'                    => $pin,
                                  'binfile'                => $binfile,
                                  'disable_location_check' => $cfg->{'disable_location_check'},
                                  'quick_location_check'   => $cfg->{'quick_location_check'},
                                 );
                    if ($rc == SUCCESS) {
                        # PIN verified
                        # get out
                        last;
                    } # endif SUCCESS
                } # while $binfile
                
                unless ($found) {
                    $error_message = "No password files with extension '$binext' found in '$bindir' !";
                    $log->error($error_message);
                    # exit with the status
                    my_exit(
                            'cgi'   => $q,
                            'title' => "ERROR",
                            'tmpl'  => $tmpl,
                            'log'   => $log,
                            'msg'   => "Password file doesn't exist for appname05_id '$appname05_id' !",
                            'rc'    => PASSWORD_FILE_DOES_NOT_EXIST,
                            'color' => "red",
                           );
                } # unless found password file
                
                # final step: return the findings
                if ($rc == SUCCESS) {
                    # log SUCCESS
                    $log->info($msg);
                    # exit with the status
                    my_exit(
                            'cgi'      => $q,
                            'title'    => "SUCCESS",
                            'tmpl'     => $tmpl,
                            'log'      => $log,
                            'msg'      => $msg,
                            'rc'       => SUCCESS,
                            'store'    => $store,
                            'chain'    => $chain,
                            'progr'    => $progr,
                            'expiry'   => $expiry,
                            'min'      => $min,
                            'location' => $location,
                            'sPIN'     => $sPIN,
                            'PINc'     => $PINc,
                           );
                } else {
                    # log ERROR
                    $log->error($msg);
                    # exit with the status
                    my_exit(
                            'cgi'   => $q,
                            'title' => "ERROR",
                            'tmpl'  => $tmpl,
                            'log'   => $log,
                            'msg'   => $msg,
                            'rc'    => $rc,
                            'color' => "red",
                           );
                } # endif SUCCESS
            } # endif exists $bindir
        } else {
            # appname05_id is NOT found
            $error_message = "appname05 ID '$appname05_id' is NOT found in master file '$master_list_abs' !";
            $log->error($error_message);
            # exit with the status
            my_exit(
                    'cgi'   => $q,
                    'title' => "ERROR",
                    'tmpl'  => $tmpl,
                    'log'   => $log,
                    'msg'   => "appname05 ID '$appname05_id' is invalid",
                    'rc'    => appname05_ID_NOT_VALID,
                    'color' => "red",
                   );
        } # endif found appname05_id
    } else {
        # couldn't create accessCode object
        # can't open master list
        $error_message = "Can't create appname05 master list access object !";
        $log->error($error_message);
        # exit with the status
        my_exit(
                'cgi'   => $q,
                'title' => "ERROR",
                'tmpl'  => $tmpl,
                'log'   => $log,
                'msg'   => $error_message,
                'rc'    => MASTER_LIST_DOES_NOT_EXIST,
                'color' => "red",
               );
    } # endif created accessCode object

} else {
    # IVR app will request to check the PIN, if it's in completed file
    # use traditional accessCode validation
    # initialize accessCode
    my $return_status = IVR_STATUS_UNKNOWN;
    my $acc_ml = new accessCode($master_list, $appname05_id, 0, $delim);
    if ($acc_ml) {
        # access list object created
        if ($log->is_debug()) {
            $log->debug("Created master list access object for master list '$master_list'");
        }
        
        # does the appname05_id exists in the list ?
        if ($acc_ml->isAccessCode()) {
            # appname05_id found
            $compfile     = $acc_ml->getAccessField(2);
            $compfile_abs = $drive .'/'. $compfile;
            $compdb       = $compfile_abs;
            # change extension
            $compdb =~ s|\.(.*?)$||;
            $compdb .= ".db";
            
            my $success = 0;
            if (-e $compfile_abs) {
                # completed file exists
                if ($log->is_debug()) {
                    $log->debug("appname05 completed file '$compfile_abs' exists");
                }
                
                # does it exist in completed file ?
                my $acc_cm = new accessCode($compfile, $pin, 0, $delim);
                if ($acc_cm) {
                    # can create completed access code
                    if ($log->is_debug()) {
                        $log->debug("Created completed access object for completed file '$compfile_abs'");
                    }
                    
                    # is PIN in there ?
                    if ($acc_cm->isAccessCode()) {
                        # PIN found
                        my $status = $acc_cm->getAccessField(1);
                        
                        $error_message = "PIN '$pin' is found in completed file '$compfile_abs' with status '$status' !";
                        
                        if ($log->is_debug()) {
                            $log->debug($error_message);
                        }
                        
                        # check the status in completed
                        if ($status == IVR_STARTED) {
                            # what's the requestor status?
                            if (  $status_id == IVR_COMPLETED
                               || $status_id == IVR_DROPPED
                               ) {
                                # update the status in completed
                                my $rc = update_completed(
                                                          'compfile_abs' => $compfile_abs,
                                                          'del'          => $delim,
                                                          'pin'          => $pin,
                                                          'status_id'    => $status_id,
                                                          'compdb'       => $compdb,
                                                          'log'          => $log,
                                                         );
                                if ($rc == SUCCESS) {
                                    # IVR appname05 can proceed
                                    $return_status = IVR_STATUS_VALID;
                                } # endif updated
                            } else {
                                # IVR appname05 can proceed
                                $return_status = IVR_STATUS_STARTED;
                            } # endif $status_id
                        } elsif ($status == IVR_COMPLETED) {
                            # IVR appname05 should not proceed
                            $return_status = IVR_STATUS_COMPLETED;
                        } elsif ($status == IVR_DROPPED) {
                            # what's the requestor status?
                            if ($status_id == IVR_COMPLETED) {
                                # update the status in completed
                                my $rc = update_completed(
                                                          'compfile_abs' => $compfile_abs,
                                                          'del'          => $delim,
                                                          'pin'          => $pin,
                                                          'status_id'    => $status_id,
                                                          'compdb'       => $compdb,
                                                          'log'          => $log,
                                                         );
                                if ($rc == SUCCESS) {
                                    # IVR appname05 can proceed
                                    $return_status = IVR_STATUS_VALID;
                                } # endif updated
                            } elsif ($status_id == IVR_STARTED) {
                                # update the status in completed
                                my $rc = update_completed(
                                                          'compfile_abs' => $compfile_abs,
                                                          'del'          => $delim,
                                                          'pin'          => $pin,
                                                          'status_id'    => $status_id,
                                                          'compdb'       => $compdb,
                                                          'log'          => $log,
                                                         );
                                if ($rc == SUCCESS) {
                                    # IVR appname05 can proceed
                                    $return_status = IVR_STATUS_STARTED;
                                } # endif updated
                            } else {
                                # IVR appname05 can proceed
                                $return_status = IVR_STATUS_VALID;
                            } # endif $status_id
                        } elsif ($status == WEB_STARTED) {
                            # what's the requestor status?
                            if ($status_id == IVR_COMPLETED) {
                                # update the status in completed
                                my $rc = update_completed(
                                                          'compfile_abs' => $compfile_abs,
                                                          'del'          => $delim,
                                                          'pin'          => $pin,
                                                          'status_id'    => $status_id,
                                                          'compdb'       => $compdb,
                                                          'log'          => $log,
                                                         );
                                if ($rc == SUCCESS) {
                                    # IVR appname05 can proceed
                                    $return_status = IVR_STATUS_VALID;
                                } # endif updated
                            } elsif ($status_id == WEB_COMPLETED) {
                                # update the status in completed
                                my $rc = update_completed(
                                                          'compfile_abs' => $compfile_abs,
                                                          'del'          => $delim,
                                                          'pin'          => $pin,
                                                          'status_id'    => $status_id,
                                                          'compdb'       => $compdb,
                                                          'log'          => $log,
                                                         );
                                if ($rc == SUCCESS) {
                                    # IVR appname05 can't proceed
                                    $return_status = IVR_STATUS_COMPLETED;
                                } # endif updated
                            } else {
                                # IVR appname05 can proceed
                                $return_status = IVR_STATUS_STARTED;
                            } # endif $status_id
                        } elsif ($status == WEB_COMPLETED) {
                            # IVR appname05 should not proceed
                            $return_status = IVR_STATUS_COMPLETED;
                        } else {
                            # unknown status here, replace it with the one
                            # on the URL
                            $error_message = "Unknown status '$status' for PIN '$pin' in completed file '$compfile_abs' !";
                            $log->error($error_message);
                            # update the status in completed
                            my $rc = update_completed(
                                                      'compfile_abs' => $compfile_abs,
                                                      'del'          => $delim,
                                                      'pin'          => $pin,
                                                      'status_id'    => $status_id,
                                                      'compdb'       => $compdb,
                                                      'log'          => $log,
                                                     );
                            if ($rc == SUCCESS) {
                                # IVR appname05 can proceed
                                $return_status = IVR_STATUS_VALID;
                            } else {
                                # IVR appname05 can proceed
                                $return_status = IVR_STATUS_STARTED;
                            } # endif updated
                        } # endif $status in completed
                        
                        # exit with the status
                        my_exit_ivr(
                                'cgi'    => $q,
                                'tmpl'   => $tmplivr,
                                'log'    => $log,
                                'pin'    => $pin,
                                'status' => $return_status,
                               );
                    } else {
                        # no PIN in completed
                        if ($log->is_debug()) {
                            $log->debug("No PIN '$pin' in completed file '$compfile_abs'");
                        }
                        
                        # IVR appname05 can proceed
                        $success++;
                        
                    } # endif PIN is in completed
                    
                } else {
                    
                    # failed to create completed access code
                    $error_message = "Failed to create completed access object for completed file '$compfile_abs'";
                    $log->error($error_message);
                    
                    # IVR app should handle this as an error condition
                    
                    # exit with the status
                    my_exit_ivr(
                            'cgi'    => $q,
                            'tmpl'   => $tmplivr,
                            'log'    => $log,
                            'pin'    => $pin,
                            'status' => $return_status,
                           );
                    
                } # endif completed access code
            } else {
                # not yet created
                if ($log->is_debug()) {
                    $log->debug("Creating appname05 completed file '$compfile_abs'");
                }
                
                # IVR appname05 can proceed
                $success++;
                
            } # endif completed exists
            
            # if we're here, check for success
            if ($success) {
                my $rc = update_completed(
                                          'compfile_abs' => $compfile_abs,
                                          'del'          => $delim,
                                          'pin'          => $pin,
                                          'status_id'    => $status_id,
                                          'compdb'       => $compdb,
                                          'log'          => $log,
                                         );
                if ($rc == SUCCESS) {
                    # IVR appname05 can proceed
                    $return_status = IVR_STATUS_VALID;
                }
                
                # exit with the status
                my_exit_ivr(
                        'cgi'    => $q,
                        'tmpl'   => $tmplivr,
                        'log'    => $log,
                        'pin'    => $pin,
                        'status' => $return_status,
                       );
            } else {
                # no SUCCESS ??? It shouldn't happen
                $error_message = "Failed to check PIN '$pin' in completed file '$compfile_abs' for UNKNOWN reason !";
                $log->error($error_message);
                
                # exit with the status
                my_exit_ivr(
                        'cgi'    => $q,
                        'tmpl'   => $tmplivr,
                        'log'    => $log,
                        'pin'    => $pin,
                        'status' => $return_status,
                       );
            } # endif SUCCESS
                        
            
        } else {
            # appname05_id is NOT found
            $error_message = "appname05 ID '$appname05_id' is NOT found in master file '$master_list_abs' !";
            $log->error($error_message);
            
            # exit with the status
            my_exit_ivr(
                    'cgi'    => $q,
                    'tmpl'   => $tmplivr,
                    'log'    => $log,
                    'pin'    => $pin,
                    'status' => $return_status,
                   );
        } # endif appname05_id exists
        
    } else {
        # can't open master list
        $error_message = "Can't create appname05 master list access object !";
        $log->error($error_message);
        
        # exit with the status
        my_exit_ivr(
                'cgi'    => $q,
                'tmpl'   => $tmplivr,
                'log'    => $log,
                'pin'    => $pin,
                'status' => $return_status,
               );
    } # endif $master_list access created
} # endif dynamic validation

########################################################################################
# SUBS
########################################################################################

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
    my $logger = get_logger();
    $appcfgfile = catfile($basedir, "cfg", $appcfgfile);
    if ($logger->is_debug()) {
        $logger->debug("XML Config file name: '$appcfgfile'");
    }
    
    $config = XMLin($appcfgfile);
    if ($logger->is_debug()) {
        $logger->debug("XML Config: ", sub { Dumper($config) });
    }
    
    unless ($config) {
        die "Couldn't load the application config file '$appcfgfile': $!";
    }
    
    # store logger into $config
    $config->{'logger'} = $logger;
    
    return $config;
} # _init_config

=head2 B<my_exit(%args)>

Outputs HTML to the browser

=cut

sub my_exit
{
    my %args = @_; # args list
    my $cgi   = $args{'cgi'};
    my $log   = $args{'log'};
    my $msg   = $args{'msg'};
    my $title = $args{'title'};
    my $tmpl  = $args{'tmpl'};
    my $rc    = $args{'rc'};
    my $color = $args{'color'} || "black";
    my $store = $args{'store'} || 0;
    my $chain = $args{'chain'} || 0;
    my $progr = $args{'progr'} || 0;
    my $expiry = $args{'expiry'} || "01/01/2000";
    my $min    = $args{'min'} || 0;
    my $location = $args{'location'} || 0;
    my $sPIN     = $args{'sPIN'} || 0;
    my $PINc     = $args{'PINc'} || 0;
    
    # create HTML template
    my $t = new HTML::Template('filename' => $tmpl);
    $t->param('title' => $title);
    $t->param('msg'   => $msg);
    $t->param('rc'    => $rc);
    $t->param('color' => $color);
    $t->param('store' => $store);
    $t->param('chain' => $chain);
    $t->param('progr' => $progr);
    $t->param('expiry' => $expiry);
    $t->param('min' => $min);
    $t->param('location' => $location);
    $t->param('sPIN' => $sPIN);
    $t->param('PINc' => $PINc);
    
    # output it
    print $cgi->header(-type => 'text/html'), $t->output();
    
    # exit here
    exit;
} # my_exit

=head2 B<my_exit_ivr(%args)>

Outputs a plain text to the IVR application

=cut

sub my_exit_ivr
{
    my %args = @_; # args list
    my $cgi    = $args{'cgi'};
    my $log    = $args{'log'};
    my $pin    = $args{'pin'};
    my $status = $args{'status'};
    my $tmpl   = $args{'tmpl'};
    
    # create HTML template
    my $t = new HTML::Template('filename' => $tmpl);
    $t->param('pin'    => $pin);
    $t->param('status' => $status);
    
    # output it
    print $cgi->header(-type => 'text/plain'), $t->output();
    
    # exit here
    exit;
} # my_exit_ivr

=head2 B<bin2dec($binary_string)>

Converts binary to decimal

=cut

sub bin2dec {
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

=head2 B<dec2bin($decimal)>

Converts decimal to binary

=cut

sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}

=head2 B<check_bin(%args)>

Checks the PIN using binary input files

=cut

sub check_bin
{
    my %args = @_; # args list
    my $log  = $args{'log'};

    # PIN
    my $PIN                    = $args{'pin'};
    my $binfile                = $args{'binfile'};
    my $disable_location_check = $args{'disable_location_check'};
    my $quick_location_check   = $args{'quick_location_check'};
    
    # return values
    my $rc;
    my $msg;
    
    # open it in a binary mode
    unless (sysopen BIN, $binfile, O_RDONLY) {
        $msg = "Can't open password file '$binfile' !";
        $log->error("Can't open binary file '$binfile': $!");
        $rc = PASSWORD_FILE_DOES_NOT_EXIST;
        # bail out
        return ($rc, $msg);
    }
    # read the file in binary mode
    binmode(BIN);
    
    if ($log->is_debug()) {
        $log->debug("Encoded PIN: $PIN");
    }
    
    # header record length
    my $header = 115;
    
    # buffer var
    my $buf;
    
    # read the header
    my $readlen = sysread BIN, $buf, $header;
    if ($log->is_debug()) {
        $log->debug("$readlen byte(s) have been read.");
    }
    
    # unpack the content
    my (
        $formind,
        $version,
        $last_loc00,
        $last_loc01,
        $last_loc02,
        $last_loc03,
        $last_loc04,
        $key_1,
        $key_2,
        $key_3,
        $key_4,
        $key_5,
                       #FF VR  L0 L1 L2 L3 L4 K1 K2 K3 K4 K5 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
        @seq) = unpack "B8 B32 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8", $buf;
    
    if ($log->is_debug()) {
        $log->debug("Binary representataion:");
        $log->debug("Format Ind: ", $formind);
        $log->debug("Version: ", $version);
        $log->debug("Last location 00: ", $last_loc00);
        $log->debug("Last location 01: ", $last_loc01);
        $log->debug("Last location 02: ", $last_loc02);
        $log->debug("Last location 03: ", $last_loc03);
        $log->debug("Last location 04: ", $last_loc04);
    }
    # Last location
    my $last_location = bin2dec($last_loc00) . bin2dec($last_loc01) . bin2dec($last_loc02) . bin2dec($last_loc03) . bin2dec($last_loc04);
    if ($log->is_debug()) {
        $log->debug("Assembled last location: ", $last_location);
    }
    
    if ($log->is_debug()) {
        # preliminary keys
        $log->debug("Key 1: ", $key_1);
        $log->debug("Key 2: ", $key_2);
        $log->debug("Key 3: ", $key_3);
        $log->debug("Key 4: ", $key_4);
        $log->debug("Key 5: ", $key_5);
    }
    
    # re-assign keys
    my $key_00 = bin2dec(substr($key_1,0,4));
    my $key_01 = bin2dec(substr($key_1,4,4));
    my $key_02 = bin2dec(substr($key_2,0,4));
    my $key_03 = bin2dec(substr($key_2,4,4));
    my $key_04 = bin2dec(substr($key_3,0,4));
    my $key_05 = bin2dec(substr($key_3,4,4));
    my $key_06 = bin2dec(substr($key_4,0,4));
    my $key_07 = bin2dec(substr($key_4,4,4));
    my $key_08 = bin2dec(substr($key_5,0,4));
    my $key_09 = bin2dec(substr($key_5,4,4));
    
    if ($log->is_debug()) {
        $log->debug("Key 00: ", $key_00);
        $log->debug("Key 01: ", $key_01);
        $log->debug("Key 02: ", $key_02);
        $log->debug("Key 03: ", $key_03);
        $log->debug("Key 04: ", $key_04);
        $log->debug("Key 05: ", $key_05);
        $log->debug("Key 06: ", $key_06);
        $log->debug("Key 07: ", $key_07);
        $log->debug("Key 08: ", $key_08);
        $log->debug("Key 09: ", $key_09);
    }
    # assemble the key
    my $key = $key_00 . $key_01 . $key_02 . $key_03 . $key_04 . $key_05 . $key_06 . $key_07 . $key_08 . $key_09;
    if ($log->is_debug()) {
        $log->debug("Assembled key $key");
        $log->debug("Seq has ", scalar @seq, " elements");
    }
    # re-assign sequence
    my @sequence;
    my $seqcnt = 0;
    my @tmpseq = ();
    my $cnt    = 0;
    for (my $i = 0; $i <= $#seq; $i++) {
        $cnt++;
        if ($cnt > 9 and $cnt % 10 == 0) {
            push @tmpseq, bin2dec($seq[$i]);
            push @sequence, [ @tmpseq ];
            # re-set it
            @tmpseq = ();
        } else {
            push @tmpseq, bin2dec($seq[$i]);
        }
    }
    if ($log->is_debug()) {
        $log->debug("Sequence has ", scalar @sequence, " elements");
    }
    
    # start decoding and validation
    my @decodedPIN = ();
    
    # encoded PIN array
    my @encodedPIN = split /|/, $PIN;
    
    # get the index into encoded PIN from the last digit in the 1st sequence array
    # all the sequence numbers end in the same digit
    my $seq_num = $encodedPIN[${ $sequence[0] }[9]];
    
    # sequence array
    my @seq_arr = @{ $sequence[$seq_num] };
    
    # key array
    my @key_arr = split /|/, $key;
    
    # apply the rearrangement sequence
    for (my $i = 0; $i < length($PIN); $i++) {
        $decodedPIN[$i] = $encodedPIN[$seq_arr[$i]];
    }
    if ($log->is_debug()) {
        $log->debug("Re-arranged decoded PIN ",join("",@decodedPIN));
    }
    
    # subtract without the carry the key value
    for (my $i = 0; $i < length($PIN); $i++) {
        if ($decodedPIN[$i] >= $key_arr[$i]) {
            $decodedPIN[$i] = $decodedPIN[$i] - $key_arr[$i];
        } else {
            $decodedPIN[$i] = ($decodedPIN[$i] + 10) - $key_arr[$i];
        }
    }
    if ($log->is_debug()) {
        $log->debug("Key subtracted from decoded PIN ",join("",@decodedPIN));
    }
    
    # compute the checksum
    my $checksum = 0;
    for (my $i = 0; $i < 9; $i++) {
        if ($i % 2 != 0) {
            $checksum += $decodedPIN[$i];
        } else {
            if ($decodedPIN[$i] < 5) {
                $checksum += $decodedPIN[$i] * 2;
            } else {
                # this line is the same as doubling the number and adding the digits together
                $checksum += $decodedPIN[$i] - (9 - $decodedPIN[$i]);
            }
        }
    }
    
    # see, if the checksum and the last digit of the decoded PIN match
    $checksum %= 10;
    
    if ($checksum != $decodedPIN[9]) {
        $msg = "$PIN - Invalid PIN (Bad CheckSum)";
        $log->error($msg);
        $rc = PIN_NOT_VALID;
        # bail out
        
        # close the file
        close BIN;
        return ($rc, $msg);
    } else {
        # log it
        $msg = "$PIN - Valid PIN (CheckSum passed)";
        $log->info($msg);
        if ($disable_location_check) {
            # bypass the location check
            $rc  = SUCCESS;
            
            # close the file
            close BIN;
            return ($rc, $msg);
        }
    }
    
    # loop through the location records. Match each 5 BCD digit location
    # with the first 5 digit of the decoded PIN
    my $foundLoc   =  0;
    my $chain      =  0;
    my $store      =  0;
    my $progr      =  0;
    my $expiry     = "01/01/2000";
    my $min        =  0;
    my $location   =  0;
    my $sPIN       =  0;
    my $PINc       =  0;
    my $recordsize = 31;
    my $decodedPIN = join("",@decodedPIN);
    
    # calculate the offset
    my $loc = substr($decodedPIN,0,5);
    my $off = $header + ($loc - 1) * $recordsize;
    
    if ($log->is_debug()) {
        $log->debug("PIN $PIN, target location $loc, offset $off");
    }
    
    # set the record pointer to the $loc
    my $res = seek BIN, $off, 0;
    if ($res) {
        # OK
        my $len = sysread(BIN, $buf, $recordsize);
        
        # check for errors
        if (not defined($len)) {
            goto FINISHED if $! =~ /^Interrupted/;
            $msg = "PIN $PIN. System read error: $!";
            $log->error($msg);
            $rc  = FAILED;
            # bail out
            
            # close the file
            close BIN;
            return ($rc, $msg);
        }
        
        # get the stuff out of $buf
        my (
            $chain0,
            $chain1,
            $store0,
            $store1,
            $prg0,
            $prg1,
            $prg2,
            $prg3,
            $exp0,
            $exp1,
            $exp2,
            $exp3,
            $exp4,
            $exp5,
            $exp6,
            $exp7,
            $exp8,
            $exp9,
            $min0,
            $min1,
            $loc0,
            $loc1,
            $loc2,
            $loc3,
            $loc4,
            $str0,
            $str1,
            $str2,
            $str3,
            $inc0,
            $inc1
            #          C0 C1 T0 T1 P0 P1 P2 P3 E0 E1 E2 E3 E4 E5 E6 E7 E8 E9 M0 M1 L0 L1 L2 L3 L4 S0 S1 S2 S3 I0 I1
           ) = unpack "B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8 B8", $buf;
        
        # combine the results
        $chain        = bin2dec($chain1 . $chain0);
        $store        = bin2dec($store1 . $store0);
        $progr        = bin2dec($prg3 . $prg2 . $prg1 . $prg0);
        $expiry       = pack("B8",$exp0) . pack("B8",$exp1) . pack("B8",$exp2) . pack("B8",$exp3) . pack("B8",$exp4) . pack("B8",$exp5) . pack("B8",$exp6) . pack("B8",$exp7) . pack("B8",$exp8) . pack("B8",$exp9);
        $min          = bin2dec($min1 . $min0);
        $location     = bin2dec($loc0) . bin2dec($loc1) . bin2dec($loc2) . bin2dec($loc3) . bin2dec($loc4);
        # arrange them in big endian order
        $sPIN = bin2dec($str3 . $str2 . $str1 . $str0);
        # arrange them in big endian order
        $PINc = bin2dec($inc1 . $inc0);
        
        if ($log->is_debug()) {
            $log->debug("Chain $chain");
            $log->debug("Store $store");
            $log->debug("Program $progr");
            $log->debug("Expiry $expiry");
            $log->debug("Minutes $min");
            $log->debug("Location $location");
            $log->debug("Start PIN $sPIN");
            $log->debug("PIN Increment $PINc");
        }
        
        # check, if the location matches the first 5 digit in the decoded PIN
        if ($location eq substr($decodedPIN, 0, 5)) {
            # got it
            $foundLoc = 1;
            
            # convert 4 BCD digits starting at 5 to unsigned binary
            my $uPIN = dec2bin(substr($decodedPIN,5,4));
            if ($log->is_debug()) {
                $log->debug("uPIN $uPIN");
            }
            # make sure the PIN counter value is at least as large as the starting PIN
            if ($uPIN < $sPIN) {
                $msg = "$PIN - Invalid PIN (Less Than the Starting PIN)";
                # report an ERROR
                $log->error($msg);
                $rc = PIN_NOT_VALID;
                last;
            }
            # make sure the PIN counter is a legal increment from the starting PIN
            if (($uPIN - $sPIN) % $PINc != 0) {
                $msg = "$PIN - Invalid PIN (Bad PIN counter increment)";
                # report an ERROR
                $log->error($msg);
                $rc = PIN_NOT_VALID;
                last;
            }
            
            # good PIN overall
            $msg = "$PIN - Valid PIN (All checks are successful)";
            $rc  = SUCCESS;
            
        } # endif $location found
    } else {
        # failed to find a location record
        $log->error("SEEK failed to find a location for $PIN at record $loc, offset $off");
    } # endif seek failed
    
    FINISHED: # in case of an INTERRUPT
    
    
    unless ($foundLoc) {
        $msg = "$PIN - Invalid PIN (Bad location Number)";
        # report an ERROR
        $log->error($msg);
        $rc = PIN_NOT_VALID;
    }
    
    # close the file
    close BIN;
    
    return (
            $rc,
            $msg,
            $store,
            $chain,
            $progr,
            $expiry,
            $min,
            $location,
            $sPIN,
            $PINc
           );
} # check_bin

=head2 B<update_completed(%args)>

Updates the completed file

=cut

sub update_completed
{
    my %args = @_; # args list

    # PIN
    my $compfile_abs = $args{'compfile_abs'};
    my $del          = $args{'del'};
    my $pin          = $args{'pin'};
    my $status_id    = $args{'status_id'};
    my $compdb       = $args{'compdb'};
    my $log          = $args{'log'};
    
    # add PIN to the completed file
    my $output_file = new SimpleWrite($compfile_abs, 'append');
    
    # being paranoid ?
    if ($output_file) {
        # remove the leading '\' from delimiter
        $del = '|' if ($del eq '\|');
        
        # write a new entry with the status
        $output_file->printf("%s%s%s\n", $pin, $del, $status_id);
        
        # add PIN to DB
        dbTools::dbAdd($compdb, $pin, $pin.$del.$status_id);
        
        if ($log->is_debug()) {
            $log->debug("Added PIN '$pin' with status '$status_id' to completed file '$compfile_abs'");
        }
        
        # exit with the status
        return SUCCESS;
        
    } else {
        # failed to open completed file
        $error_message = "Failed to open completed file '$compfile_abs' in append mode !";
        $log->error($error_message);
        
        # exit with the status
        return FAILED;
    } # endif opened completed file
} # update_completed
