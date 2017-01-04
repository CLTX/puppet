#!/usr/bin/perl
#
# $Log: $
#
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use File::Basename; 
use File::Spec::Functions; 
use Date::Parse;
use apiSQL;
use AutoMailerSearch;
use Data::Dumper; 
$Data::Dumper::Indent = 3;

# create an AutoMailerSearch object, use cfg/automailer_cars.xml, logs/automailer_cars.conf
my $amc = AutoMailerSearch->create();

# get the logger
my $log = $amc->get_log();
$log->info("Program started");

if ($log->is_debug()) { 
    scalar @ARGV ? $log->debug("Input args: ", join(",",@ARGV)) : $log->debug("No input args"); 
}

# create an apiSQL object
my $sql;

if ($log->is_debug()) {
    $log->debug("Creating an SQL object");
}

eval
{
    # need to reset $SIG{__DIE__} here
    local $SIG{__DIE__} = 'DEFAULT';
    $sql = apiSQL->new();
};

# errors ???
if ( $@ ) {
    # bad luck
    $log->error("Error creating apiSQL object: $@");
    exit -1;
} else {
    # check the results
    unless ($sql) {
        $log->error("Couldn't create apiSQL object !");
        exit -1;
    } else {
        if ($log->is_debug()) {
            $log->debug("Successfully created an SQL object");
        }
    }
} # endif $@

# Automailer SMTP servers
my @smtp_servers = $sql->get_automailer_smtp();

if ($log->is_debug()) {
    $log->debug("SMTP servers: ", sub{Dumper(\@smtp_servers)});
}

# Automailer alert recipients
my @alert_recipients = $sql->get_automailer_alert_recipients();

if ($log->is_debug()) {
    $log->debug("Alert recipients: ", sub{Dumper(\@alert_recipients)});
}

# get the appname05(s) from config
my @appname05s = $amc->get_appname05_array(
                                     'appname05' => $amc->{'config'}->{'appname05'},
                                    );

if ($log->is_debug()) {
    $log->debug("appname05 array: ", sub{Dumper(\@appname05s)});
}

# run the appname05s loop
foreach my $appname05_hash (@appname05s) {
    
    # appname05 LOG file
    my $log_file = $appname05_hash->{'log'};
    
    # array of LOGs to check
    my @logfiles = $amc->get_logfile_array('logfile' => $log_file);
    
    # appname05
    my $appname05 = $appname05_hash->{'appname05_dir'};
    
    # DATA appname03ory
    my $script_dir = dirname($FindBin::Bin);
    my $data_dir   = $amc->get_data_dir(
                                        'script_dir' => $script_dir,
                                        'appname05_dir' => $appname05,
                                       );
    # appname05 appname03ory
    my $appname05_dir = $amc->get_appname05_dir(
                                          'script_dir' => $script_dir,
                                          'appname05_dir' => $appname05,
                                         );
    # control appname03ory
    my $control_dir = $amc->get_control_dir(
                                            'script_dir' => $script_dir,
                                            'appname05_dir' => $appname05,
                                           );
    # project ID
    my $project_id = $appname05_hash->{'appname05'};
    
    # project number
    my $project_num = $appname05_hash->{'project_num'};
    
    # duplicates check
    my %sent_email;
    
    # run all log files in a LOOP
    foreach my $logfile (@logfiles) {
        
        # check only locales that have a log file
        unless (-e catfile($data_dir, $logfile)) {
            if ($log->is_debug()) {
                $log->debug("Skipping file '$logfile'");
            }
            next;
        } else {
            # next unless $logfile eq "ko-kr";
            if ($log->is_debug()) {
                $log->debug("Processing file '$logfile'");
            }
        }
        
        # appname05 file
        my $appname05_file = $appname05 . "/" . $logfile;
        
        # Automail list
        my $array_ref = $sql->getAutomailList('log' => $appname05_file);
        
        if ($log->is_debug()) {
            $log->debug("Array Ref from getAutomailList(): ", sub{Dumper($array_ref)});
        }
        
        foreach my $config (@{$array_ref}) {
            
            # mail parameters for HTML template
            my $params = $sql->getAutomailMessage(
                                               'data_id'    => $config->{'data_id'},
                                               'table_name' => 'entrance_parameters'
                                              );
            # update HTML::Template HASH ref
            my $unique_id = 0;
            my $pass      = 0;
            my $rsp_id    = 0;
            my $tmp_code  = 0;
            if (exists $appname05_hash->{'id_len'}
               and $appname05_hash->{'id_len'} > 0) {
                # need unique ID
                $unique_id = $amc->get_unique_id(
                                                 'id' => $config->{'automail_message_id'},
                                                 'id_len' => $appname05_hash->{'id_len'},
                                                );
                # assign to rsp_id
                $rsp_id = $unique_id;
                
                # add project_num to unique_id
                $unique_id = $project_num . "." . $unique_id;
                
                # string like: 018.012ABCD.asp
                $params->{'id'} = $unique_id . ".asp";
                
                # store it
                $tmp_code = $unique_id;
            }
            
            if ($config->{'appname05_password'}) {
                # need to generate a password
                $pass = $amc->get_password(
                                           'id' => $config->{'automail_message_id'},
                                           'id_len' => $appname05_hash->{'pass_len'},
                                          );
                $params->{'pwd'} = $pass;
                $params->{'id'}  = $project_id . $appname05_hash->{'letter'} . $appname05_hash->{'htmlext'};
                
                # assign to rsp_id, tmp_code
                $rsp_id   = $pass;
                $tmp_code = $pass;
            }
            
            # add the project ID
            $params->{'pn'} = $project_id;
            
            if ($log->is_debug()) {
                $log->debug("E-mail params from getAutomailMessage(): ", sub{Dumper($params)});
            }
            
            # create $data structure for que_mail
            my $data =
            {
                'appname05_id'         => $config->{'appname05_id'},
                'message_id'        => $config->{'automail_message_id'},
                'text_template'     => catfile($appname05_dir, $config->{'text_template'}),
                'html_template'     => catfile($appname05_dir, $config->{'html_template'}),
                'text_template_ref' => $params,
                'html_template_ref' => $params,
                'smtp_servers'      => \@smtp_servers,
                'to_address'        => $config->{'email'},
                'from_address'      => $config->{'from_address'},
                'bcc_address'       => $config->{'bcc_address'},
                'reply_address'     => $config->{'reply_address'},
                'subject'           => $config->{'subject'},
            };
            
            # create $data_uniqs structure for update_databases
            my $data_uniqs =
            {
                'count'       => $config->{'automail_message_id'},                              
                'unique_id'   => $unique_id,                                                    
                'rsp_id'      => $rsp_id,                                                       
                'email'       => $config->{'email'},                                            
                'type'        => $appname05_hash->{'type'},                        
                'delim'       => $appname05_hash->{'delim'},                       
                'params'      => $params,                                                       
                'control_dir' => $control_dir,                                                  
                'uniqid_db'   => $amc->{'config'}->{'database'}->{'uniqid_db'},                 
                'uniqid_txt'  => $amc->{'config'}->{'database'}->{'uniqid_txt'},                
                'uniqs_db'    => $amc->{'config'}->{'database'}->{'uniqs_db'},                  
                'created'     => $config->{'created_timestamp'},                              
            };
            
            # check for duplicates ?
            if ($amc->{'config'}->{'database'}->{'duplicate_check'}) {
                
                if ($log->is_debug()) {
                    $log->debug("Duplicate check enabled");
                }
                
                # double check before sending
                unless (exists $sent_email{lc $config->{'email'}}) {
                    # call que_mail
                    $amc->que_mail(
                                   'sql'  => $sql,
                                   'data' => $data,
                                  );
                    
                    # keep a record
                    $log->info("E-mail sent: '",$config->{'email'},"'");
                    
                    # update duplicate control HASH
                    $sent_email{lc $config->{'email'}}++;
                    
                    # update BDB databases
                    my $rc = $amc->update_databases(
                                                    %{ $data_uniqs },
                                                   );
                    if ($rc) {
                        $log->info("Created record for E-mail: '",$config->{'email'},"', unique ID '$unique_id'");
                    } else {
                        $log->info("Failed to created record for E-mail: '",$config->{'email'},"', unique ID '$unique_id'");
                    }
                
                } else {
                    
                    # it's been sent already
                    my $rc = $sql->update_automail_message(
                                                           'message_id'     => $data->{'message_id'},
                                                           'message_status' => 3,
                                                          );
                    if ($rc) {
                        $log->info("Duplicate E-mail: '",$config->{'email'},"' status updated");
                    } else {
                        $log->info("Duplicate E-mail: '",$config->{'email'},"' status NOT updated");
                    }
                
                } # unless sent
            
            } else {
                
                if ($log->is_debug()) {
                    $log->debug("Duplicate check disabled");
                }
                
                # call que_mail
                $amc->que_mail(
                               'sql'  => $sql,
                               'data' => $data,
                              );
                
                # keep a record
                $log->info("E-mail sent: '",$config->{'email'},"'");
                
                # update databases
                my $rc = $amc->update_databases(
                                                %{ $data_uniqs },
                                               );
                if ($rc) {
                    $log->info("Created record for E-mail: '",$config->{'email'},"', unique ID '$unique_id'");
                } else {
                    $log->info("Failed to created record for E-mail: '",$config->{'email'},"', unique ID '$unique_id'");
                }
            
            } # endif check_duplicates
            
        } # end of foreach $config
        
    } # end of foreach $logfile
    
} # end of foreach $appname05_hash

$log->info("Program finished");
print "Program finished.\n";
