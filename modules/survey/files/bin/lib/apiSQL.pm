#!/usr/local/bin/perl -W

package apiSQL;

=head1 NAME

C<apiSQL> - Perl interface to Knox database

=head1 VERSION

	$Id: apiSQL.pm,v 1.3 2004/05/26 21:15:38 maxim Exp $

=head1 SYNOPSIS

	an example of how to use this module belongs here

=head1 DESCRIPTION

This would be the place to put in a nice long description of what it does. 

=head1 TODO

TBD:
Convert Line to %form ,  load %form.

=over 4

=item POD

Started by Drew

=item Consistent Args handling

=item my $var = $args{'var'} || '';

=item Inline tests

Suggestion: hide tests in transaction and then rollback?

=over 4

=item Connect To DB

=item Insert of bad record

=item Insert of old record 

=item Insert of new ( insert ) record.

=item Insert of newer ( update ) record.

=item Delete/Insert ( maybe on insertAnswer )

instead of selective update/insert

=back

=item Move config out of connect into params

=item Handle video trax  10.0  numbers ( x10)

=back


Done:

	Full Engine deconstruct of line
	appname05NN                  -- answer_integer
	statusFlag                -- Response  done
	Time ( Epoc in secs )     -- Discard have with updated
	textincludebothNN         -- answer_integer 
	DateString GMT            -- Respondent -- updated
	Local Time HH:MM          -- Discard/Dup with updated
	IP                        -- Response todo
	Session_ID                -- Response done

=cut

# use strict;
use Date::Parse;
use DBI;  
use Storable ;
use MIME::Base64 ();
use Benchmark::Timer;
use File::Basename;
use File::Spec::Functions qw/:ALL/;
use FindBin;
use Email::Valid;
use XML::Simple;
use Sys::Hostname;
use Log::Dispatch::File;
use Log::Log4perl qw(:easy); 

=head1 DETAILS

This is the place to describe how it does things that aren't obvious.

=head2 Constants

The following constants are defined for your pleasure. Using integer
literals instead of constant symbols, that's a night in the box.

	BAD_RECORD
	OLD_RECORD
	INSERT_RECORD
	UPDATE_RECORD

=cut

sub BAD_RECORD		() { 0 };  # Don't recognize format of form structure
sub OLD_RECORD		() { 1 };  # Record older than load don't do
sub INSERT_RECORD	() { 2 };  # Record Inserted
sub UPDATE_RECORD	() { 3 };  # Record Updated ( did exist )
sub STATUS_RECORD	() { 4 };  # Record newer but already have status 9

# return codes
sub SUCCESS () {   1   }
sub FAILED  () { undef }


=head2 Methods

=head3 new ( %args )

Required Arguments: WRITE ME

Optional Arguments: WRITE ME

=cut

sub new {
	my $proto = shift;
        my $conf  = shift; # optional CONFIG HASHREF
        
        # check, if $conf is a ref to HASH
        if ($conf and ref($conf) ne "HASH") {
            die "Method accepts an optional reference to a HASH";
        } elsif (!$conf) {
            # initialize it
            $conf = {};
        }
        
        # initialize $self
        my $self  = {} ;
	my $class = ref($proto) || $proto;
	bless( $self , $class );
        
        # read config
        my $config = _init_config($conf);
        
        # Config XML
        $self->{CONFIG}       = $config;
        
        # DB stuff
	$self->{DBTYPE}       = $config->{'dbtype'};
	$self->{CONNECT}      = $config->{'connect'};
	$self->{USERNAME}     = $config->{'username'};
	$self->{PASSWORD}     = $config->{'password'};
	$self->{PROCEDURE}    = $config->{'procedure'};
	$self->{LOADLOGPARAM} = $config->{'loadlogparam'};
	$self->{AUTOMAILER}   = $config->{'automailer'};

	$self->connect();
	$self->prepare();
        $self->{TIMER} = Benchmark::Timer->new();

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
    $basename = $conf->{'basename'} || __PACKAGE__;
    $basedir  = $conf->{'basedir'}  || $FindBin::Bin;
    
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
    return $self->{CONFIG}->{'logger'};
}


sub DESTROY {
        my $self = shift;
	my $dbh = $self->{DBH};
	$dbh->disconnect();
        $self->{TIMER}->report() ;
}
#
# Connect to the database using the config parametersA
#
sub connect {
        my $self = shift;
	my $dbh;
      
# die $self->{USERNAME}; 
	$dbh = DBI->connect( $self->{CONNECT}, 
		             $self->{USERNAME}, 
			     $self->{PASSWORD},
                             { AutoCommit => 0 } );
                             # { RaiseError => 1, AutoCommit => 0 } );

	if( $dbh && $self->{DBTYPE} eq "mssql" ) { 
            $dbh->{LongReadLen} = 65536;
        }
	$self->{DBH} = $dbh;
}
#
#  Try to disconnect
#
sub reconnect {
        my $self = shift;
	my $dbh  = undef;

	eval {
	  $dbh = $self->{DBH};
	  $dbh->disconnect();
	  $dbh = $self->connect();
	  $self->prepare() if $dbh;
        };
	return $dbh;
}
#
## prepare cached db statements
#
sub prepare {
        my $self = shift;
	my $dbh = $self->{DBH};

	#
	# appname05 Table
	#
	my $sth = {} ;
        $sth->{appname05}->{select} = $dbh->prepare( "SELECT appname05_id FROM appname05 WHERE appname05_file LIKE ? ");
        $sth->{appname05}->{insert} = $dbh->prepare( "INSERT INTO appname05 (appname05_file) VALUES ( ? )");
	#
	# Response Table
	#
        $sth->{response}->{select} = $dbh->prepare( "SELECT updated, response_id,status_flag FROM response WHERE appname05_id = ? AND  session_id LIKE ? ");
        $sth->{response}->{insert} = $dbh->prepare( "INSERT INTO response ( appname05_id, session_id, server_id, remote_address, updated, status_flag) VALUES ( ?, ? , ?, ? , ? , ? )");
        $sth->{response}->{update} = $dbh->prepare( "UPDATE response SET server_id = ?, remote_address = ?, updated = ?, status_flag = ? WHERE response_id = ?");
	# Note:  RI will delete the answer_integer && answer_text
        $sth->{response}->{delete} = $dbh->prepare( "DELETE FROM response WHERE appname05_id = ? AND  session_id LIKE ? ");
       
	# Answer_integer table
	# Singleton Version
	# $sth->{answer_integer}->{select} = $dbh->prepare( "SELECT content  FROM answer_integer WHERE response_id = ? AND field_number = ?");
        $sth->{answer_integer}->{insert} = $dbh->prepare( "INSERT INTO answer_integer  (response_id, field_number, content ) VALUES ( ? ,  ? , ?)");
        $sth->{answer_integer}->{update} = $dbh->prepare( "UPDATE answer_integer SET content = ? WHERE response_id = ? AND field_number = ?");
	# $sth->{answer_integer}->{delete} = $dbh->prepare( "DELETE FROM answer_integer  WHERE response_id = ? AND field_number = ?");
	# Set Version
        $sth->{answer_integer}->{select} = $dbh->prepare( "SELECT field_number, content  FROM answer_integer WHERE response_id = ?");
        $sth->{answer_integer}->{delete} = $dbh->prepare( "DELETE FROM answer_integer  WHERE response_id = ? AND field_number IN ( ? )");
       
	# Answer_text table
	# Single row version
	$sth->{answer_text}->{select} = $dbh->prepare( "SELECT content  FROM answer_text WHERE response_id = ? AND field_number = ?");
        $sth->{answer_text}->{insert} = $dbh->prepare( "INSERT INTO answer_text  (response_id, field_number, content ) VALUES ( ? ,  ? , ?)");
        $sth->{answer_text}->{update} = $dbh->prepare( "UPDATE answer_text SET content = ? WHERE response_id = ? AND field_number = ?");
	$sth->{answer_text}->{delete} = $dbh->prepare( "DELETE FROM answer_text WHERE response_id = ? AND field_number = ?");
	# Set Version
	# $sth->{answer_text}->{select} = $dbh->prepare( "SELECT field_number, content  FROM answer_text WHERE response_id = ?");
	# $sth->{answer_text}->{delete} = $dbh->prepare( "DELETE FROM answer_text WHERE response_id = ? AND field_number IN ( ? )");
       
	# Entrance Table
	#
	# $sth->{entrance_log}->{select} = $dbh->prepare( "SELECT entrance_log_id FROM entrance_log WHERE appname05_id = ? AND  server_id = ? AND remote_address LIKE ? and created = ? ");
	#
	# Use IDENT_CURRENT ,  ( CURRVAL in postgreSQL )
	# Should use NEXTVAL before insert, but don't see IDENT_NEXT
	#
	$sth->{entrance_log}->{select} = $dbh->prepare( "SELECT IDENT_CURRENT ( 'entrance_log' ) AS entrance_log_id");
        $sth->{entrance_log}->{insert} = $dbh->prepare( "INSERT INTO entrance_log ( appname05_id, session_id, server_id, remote_address, created, referrer ) VALUES ( ?, ? , ?, ? , ? , ?)");
	$sth->{entrance_log}->{delete} = $dbh->prepare( "DELETE  FROM entrance_log WHERE appname05_id = ?" );
	#
	# automail_message
	#
	$sth->{automail_config}->{select}  = $dbh->prepare( "SELECT active, automail_config_id, email_parameter, min_delay, max_delay, min_delay_parameter FROM automail_config WHERE appname05_id = ?") || die "Can not Prepare @_";
        $sth->{automail_message}->{insert} = $dbh->prepare( "INSERT INTO automail_message ( automail_config_id, data_id, send_min_timestamp, send_max_timestamp, email, message_status_id) VALUES ( ?, ?, ?, ?, ?, ?)");
	#
	# Note:  RI will delete the answer_integer && answer_text
	# N/A  $sth->{response}->{delete} = $dbh->prepare( "DELETE FROM response WHERE appname05_id = ? AND  session_id LIKE ? ");
	#
	# Entrance Normalized Table
	#
        # $sth->{entrance_normalized}->{select} = $dbh->prepare( "SELECT entrance_normlized_id FROM entrance_normalized WHERE content LIKE ? ");
        # $sth->{entrance_normalized}->{insert} = $dbh->prepare( "INSERT INTO entrance_normalized (content) VALUES ( ? )");
	#
	# Session Information
	#
        $sth->{session_information}->{select} = $dbh->prepare( "SELECT session_information_id FROM session_information WHERE response_id = ? ");
        $sth->{session_information}->{insert} = $dbh->prepare( "INSERT INTO session_information ( response_id, expires, content ) VALUES ( ?, ?, ?)");
        $sth->{session_information}->{update} = $dbh->prepare( "UPDATE session_information SET expires = ? , content = ? WHERE response_id = ? ");
	# 
	# Entrance Parameters
	#
        $sth->{entrance_parameters}->{insert} = $dbh->prepare( "INSERT INTO entrance_parameters ( entrance_log_id, name, content ) VALUES ( ?, ? , ?  )");
       
	# get appname05 count
	#

		$sth->{count}->{select} = $dbh->prepare(" SELECT count(*) from response where appname05_id = ?");
		#
	# get SessionState
	#
		$sth->{session_state}->{select} = $dbh->prepare(" SELECT content from session_information where response_id = ?");

		#
	
	# End of prepared statements
	$self->{STH} = $sth;
	return $sth;
}

=head3 getappname05ID ( %args )

Translate appname05 name into id,  add it if it does not exist

=cut

my %appname05;
sub getappname05ID {
  my $self = shift;
  my ( %args ) = @_ ;
  my $file = $args{ 'file' } ? $args{ 'file' } : 'default'; 

  if( ! ( exists ( $appname05{ $file } ) ) ) {
    my $dbh = $self->{DBH}; 
    my $sth = $self->{STH}->{appname05};
    my @row ;
    my $rv  = $sth->{select}->execute( $file);
    if ( ! ( @row = $sth->{select}->fetchrow_array  ) ) {
      $rv  = $sth->{insert}->execute( $file);
      $rv  = $sth->{select}->execute( $file);
      @row = $sth->{select}->fetchrow_array ; 
      $dbh->commit();
    }
    $sth->{select}->finish( );
    $appname05{ $file } = $row[0];
  } # End of if not already in hash
  return $appname05{ $file };
} # End of getappname05ID

=head3 isAutomailStudy ( %args )

Get if Study is an autoMailer.  Cache results.   Which means if we change it we have to 
restart senderLogLine.

Returns hash of  ( active,  unique_only , email_parameter, min_delay_parameter, min_delay, max_delay )

=cut

my %isAutomailStudy;
sub isAutomailStudy {
  my $self = shift;
  my ( %args ) = @_;
  my $appname05_id = $args{ 'appname05_id' } ? $args{ 'appname05_id' } : '0'; 

  my %empty = ( 'active' => 0,
	        'automail_config_id' => undef,
		'email_parameter' => undef,
		'min_delay_parameter' => undef,
		'min_delay' => undef,
		'max_delay' => undef
	);
  my $hash_ref;

  if( ! ( exists ( $isAutomailStudy{"$appname05_id"} ) ) ) {
    my $dbh = $self->{DBH}; 
    my $sth = $self->{STH}->{automail_config};
    my $rv  = $sth->{select}->execute($appname05_id);
    if ( $hash_ref = $sth->{select}->fetchrow_hashref() ) {
# TBD Should map  map { $new {$_} = $hash}, keys ( %hash ) 
      $isAutomailStudy{ $appname05_id } = $hash_ref;
    } else {
      $isAutomailStudy{ $appname05_id } = \%empty;
    }
    $sth->{select}->finish( );
  } # End of if not already in hash
  return $isAutomailStudy{$appname05_id};
} # End of getappname05ID


#  =head3 getEntraceNormalizedID ( %args )

#  Translate common values into ID,  great candidate to be moved into procedure.

#  =cut

#  sub getEntranceNormalizedID {
#    my $self = shift;
 #   my ( %args ) = @_ ;
#    my $dbh = $self->{DBH}; 
#    my $sth = $self->{STH}->{entrance_normailized};

#    my $content = $args{ 'content' } ? $args{ 'content' } : undef; 
  #  my @row ;
#    my $rv  = $sth->{select}->execute( $content);
#    if( ! ( @row = $sth->{select}->fetchrow_array  ) ) {
#      $rv  = $sth->{insert}->execute( $content);
#      $rv  = $sth->{select}->execute( $content);
#      @row = $sth->{select}->fetchrow_array ; 
#      $dbh->commit();
#    }
#    $sth->{select}->finish( );
#    # print "appname05ID " . $row[0] . "\n";
#    return $row[0];
#  }


=head3 addLine ( %args )

Generic Add Line,  will call addLogLine ( if log_file ) defined 
or addDatLine

=cut

sub addLine {
  my $self = shift;
  my ( %args ) = @_ ;
  my $rc;
  my $max_attempts = 10;
  my $dbh = $self->{DBH};
  my $attempts = 0;

  while( ! $dbh || ! $dbh->ping ) {
       if (++$attempts > $max_attempts) {
           # give up
	   die "Couldn't connect to the database $self->{DBNAME} after $max_attempts times";
	   # return undef;
       }
       $self->reconnect();
       sleep( 5); # No sleep in alarm
  }
 
  if( exists $args{ 'log' } ) {
    $rc = $self->addLogLine( 'log' => $args{'log'}, 
                             'force' => $args{'force'} );
  } 
  if( exists $args{ 'dat' } ) {
    $rc = $self->addDatLine( 'dat' => $args{'dat'}, 
                             'force' => $args{'force'} );
  }
  return $rc;
}


=head3 purgeLog ( %args ) 

WRITE ME

=cut

sub existLog {
  my $self = shift;
  my ( %args ) = @_ ;
  my $rc = 0;

  my $dbh = $self->{DBH};
  my $sth = $self->{STH}->{entrance_log};

  my $logfile = $args{ 'log' };

  my $appname05 = $self->getappname05ID( 'file' => $logfile );
  return $appname05;
}
sub purgeLog {
  my $self = shift;
  my ( %args ) = @_ ;
  my $rc = 0;

  my $dbh = $self->{DBH};
  my $sth = $self->{STH}->{entrance_log};

  my $logfile = $args{ 'log' };

  my $appname05 = $self->getappname05ID( 'file' => $logfile );
  $rc = $sth->{delete}->execute( $appname05) ;
  $dbh->commit();
  return $rc;
}

=head3 addLogLine ( %args )

add a Dat Structure 

Only load if incoming line is newer than the old one.

=cut

sub addLogLine {
  my $self = shift;
  my ( %args ) = @_ ;
  my $rc = 0;
  my $return_code = $self->BAD_RECORD();

  $self->{'TIMER'}->start( 'SubEntranceLog');
  my $dbh = $self->{DBH};
  my $sth = $self->{STH}->{entrance_log};

  my $log = $args{ 'log' };
  my $modified_rows = 0;
 
  if(0) {
    use Data::Dumper;
    my $dumper = new Data::Dumper( [ $log ], [qw( log ) ] );
    warn $dumper->Dump();
  } 

  my $referer      = $log->{ 'REFERER' } ? $log->{ 'REFERER' } : undef;
  if( $referer eq "No Referer" ) {
	 $referer = undef ;
  }
  my $date = SqlDate ( 'date' => $log->{TIMESECOND}
                             , 'format' => $self->{DBTYPE} );
  my $logfile = $log->{appname05} .  "/" .  
	        $log->{LOG};
  my $appname05 = $self->getappname05ID( 'file' => $logfile );
  my $automail_ref ; 
  my $client_ip      = $log->{ 'CLIENT_IP' } ? $log->{ 'CLIENT_IP' } : undef;
  my $sessionid      = $log->{ 'SESSIONID' } ? $log->{ 'SESSIONID' } : undef;
  my $server         = $log->{ 'SERVER_ID' } ? $log->{ 'SERVER_ID' } : '1';
  my $entrance_log_id ;

  # Active Email appname05's MUST load the parameters
  if( $self->{AUTOMAILER} ) {
     $automail_ref = $self->isAutomailStudy( 'appname05_id' => $appname05 ); 
     # use Data::Dumper;
     # die Dumper( $automail_ref );
     if( $automail_ref->{active} ) {
	 $self->{LOADLOGPARAM} = 1;
     }
  }

  my $ip_saved = undef;
  if( $client_ip ) {
    my @octect = split( /\./ , $client_ip );
    $ip_saved = $octect[0] . '.' . $octect[1] . '.' . $octect[2] . '.0';
  }
  $self->{'TIMER'}->start( 'InsEntranceLog');
  $rc = $sth->{insert}->execute( $appname05, 
                $sessionid,
                $server,
	        $ip_saved,
	        $date, 
		$referer ) ;

 $return_code = $self->INSERT_RECORD() if ( $rc );

 $self->{'TIMER'}->stop( 'InsEntranceLog');
 if( $self->{LOADLOGPARAM} && defined $log->{'CGI_PARAMS'} ) {
    $rc = $sth->{select}->execute();
    if( my @row = $sth->{select}->fetchrow_array  ) {
      $sth->{select}->finish( );
      $self->{'TIMER'}->start( 'PrepParameters');
      $entrance_log_id = $row[0];

      my $insert_string = "";
      PARAM: foreach my $key ( keys %{$log->{'CGI_PARAMS'} }) {
	next PARAM if $key eq '';
	next PARAM if $key eq 'log';
	next PARAM if $key eq 'page';
	next PARAM if $key eq 'appname05';
        $insert_string .= ' UNION ALL ' if length( $insert_string );
        $insert_string .= 'SELECT ' . $entrance_log_id . ',';
        $insert_string .= '\'' . $key . '\',';
        my $val = $log->{'CGI_PARAMS'}{ $key };
        $val =~ s|'|''|g;
        $insert_string .= '\'' . $val . '\''
      }
      $sth->{select}->finish;
      $self->{'TIMER'}->stop( 'PrepParameters');
      $self->{'TIMER'}->start( 'InsParameters');
      if( length( $insert_string ) ) {
	      # warn "<SQL>" . $insert_string . "</SQL>";
	 $modified_rows += $dbh->do( 'INSERT INTO entrance_parameters ( entrance_log_id, name, content ) ' . $insert_string );
	     # die 'INSERT INTO answer_integer ( response_id, field_number, content ) ' . $insert_string ;
       }
      $self->{'TIMER'}->stop( 'InsParameters');
    } # get entrance_log_id
  } # Have Parameters
  if( $self->{AUTOMAILER} && $automail_ref->{active} ) {
    my $sth = $self->{STH}->{automail_message};
    $self->{'TIMER'}->start( 'InsAutomail');
    #
    # TBD TimeDelay Ins here
    #
    #$log->{'CGI_PARAMS'}{ $key }
    my $min_delay ;
    if( $automail_ref->{min_delay_parameter} ) {
      $min_delay = $log->{'CGI_PARAMS'}{ $automail_ref->{min_delay_parameter} } * 3600 ;
    } else {
	    $min_delay = $automail_ref->{min_delay} ; 
    }
    my $max_delay = $min_delay + $automail_ref->{max_delay} ; 
    my $status = 0;

    my $rv  = $sth->{insert}->execute( 
	      $automail_ref->{automail_config_id},
	      $entrance_log_id,
              SqlDate ( 'date' => time() + $min_delay , 
		        'format' => $self->{DBTYPE} ),
              SqlDate ( 'date' => time() + $max_delay ,
                        'format' => $self->{DBTYPE} ),
              $log->{'CGI_PARAMS'}{ $automail_ref->{email_parameter} } ,
	      Email::Valid->address(  $log->{'CGI_PARAMS'}{ $automail_ref->{email_parameter} } ) ? 1 : 4 
           );
    $self->{'TIMER'}->stop( 'InsAutomail');
  }
  $dbh->commit();
  $self->{'TIMER'}->stop( 'SubEntranceLog');
  return $return_code;
}

=head3 addDatLine ( %args )

add a Dat Structure

Only load if incoming line is newer than the old one.

This function is too big to understand easily.

=cut

sub addDatLine {
  my $self = shift;
  my ( %args ) = @_ ;
  my $rc = 0;

  my $dat = $args{ 'dat' };
  my $force = $args{ 'force' } ||= 0;
  my $procedure = $self->{PROCEDURE};

  #use Data::Dumper;
  # my $dumper = new Data::Dumper( [ $dat ], [qw( dat ) ] );
  # die $dumper->Dump();


  my $dbh = $self->{DBH};
  my $sth = $self->{STH}->{response};

  my $delimitor   = $dat->{ 'cgi_params' }{'delimitor'} ;
  my $status      = $dat->{ 'cgi_params' }{'status_flag'} ? $dat->{ 'cgi_params' }{'status_flag'} : '9';
  my $server      = $dat->{ 'server_id' } ? $dat->{ 'server_id' } : '1';
  my $datfile        = $dat->{ 'cgi_params' }{ 'appname05' } . '/' . $dat->{ 'cgi_params' }{ 'data' } ;
  my $appname05 = $self->getappname05ID( 'file' => $datfile );

  my $id = $dat->{ 'session_id' }; 

  
  my $ip_saved;
  if( $dat->{ 'cgi_params'}{ 'ip_not_saved' } ) {
          $ip_saved = '0.0.0.0';
  } elsif ( $dat->{ 'cgi_params' }{ 'ip_saved' } ) {
          $ip_saved = $dat->{ 'remote_addr' };
  } else {
          my @octect = split( /\./ , $dat->{ 'remote_addr' });
          $ip_saved = $octect[0] . '.' . $octect[1] . '.' . $octect[2] . '.0';
  }

  my $date = SqlDate ( 'date' => $dat->{ 'created' }, 'format' => $self->{DBTYPE} );
  #
  # First method selectively inserts/updates method
  #
    #
    #  Change exists $dat->{ 'cgi_params' }{ $field_name } to use
    #  varseen instead.
    #
    #  Strait from engine
    #
    my %variableIsSeen;
    if(defined($dat->{'cgi_params'}{'varseen'})){
       my @varseen = split( /,/, $dat->{'cgi_params'}{'varseen'});
       for my $var (@varseen){
          $variableIsSeen{$var} = 1;
       } # for
    } # if
  my $response_id = undef;

  if( $procedure ) {
      $response_id =  $self->insertProcedure( 
                'appname05ID' => $appname05, 
                'sessionID' => $id,
                'updated' => $date, 
                'remote' => $ip_saved, 
                'serverID' => $server, 
                'status_flag'   =>  $status ); 

  } else {
  my $rv  = $sth->{select}->execute( $appname05, $id  );
  my @row;

  if( @row = $sth->{select}->fetchrow_array  ) {
        $response_id = $row[1];
        # print STDERR "Duplicate $row[0]\n";
        # if incoming data not newer
	# print STDERR "Time: " . str2time( $row[0] ) . " " . str2time( $date) . "\n"; 
	if( $force || ( $row[2] != 9 && $status == 9  )) {
         
          # Always load if getting status 9 even if not most current date
         
        } elsif( $row[2] == 9 && $status != 9  ) {
         
          # Don't overwrite a nine even if date is newer.
         
            $sth->{select}->finish( );
            $dbh->commit(); # Nothing done
	    return $self->STATUS_RECORD();
	} elsif( str2time( $row[0] ) >  str2time( $date)  ) {
         
          # Don't overwrite if older
         
            $sth->{select}->finish( );
            $dbh->commit(); # Nothing done
	    return $self->OLD_RECORD();
        }
        $rv  = $sth->{update}->execute( $server, $ip_saved, $date, $status, $row[1] );
        $rc =  $self->UPDATE_RECORD();
  } else {
  $self->{'TIMER'}->start( 'Response');
          $rv  = $sth->{insert}->execute( $appname05, $id, $server, $ip_saved, $date, $status);
          $rc =  $self->INSERT_RECORD();
          $sth->{select}->finish( );
          $rv  = $sth->{select}->execute( $appname05, $id  );
          if( @row = $sth->{select}->fetchrow_array  ) {
            $response_id = $row[1];
          }
  $self->{'TIMER'}->stop( 'Response');
  }
  $sth->{select}->finish( );
    #
    # Add in Integers
    #
  $self->{'TIMER'}->start( 'Integer');
    $self->addIntegerAnswer( 'response_id'  => $response_id, 
	                     'form'         => $dat->{ 'cgi_params' } ,
                             'numappname05'    => $dat->{ 'cgi_params' }{ 'numappname05' },
                             'varseen'      => \%variableIsSeen  
    );
  $self->{'TIMER'}->stop( 'Integer');
  }
  $self->{'TIMER'}->start( 'Session');

  $self->addSession( 'response_id'  => $response_id, 
	               'form'         => $dat->{ 'cgi_params' } );

  $self->{'TIMER'}->stop( 'Session');
    #
    # Add Text
    #
    # From EndRec + 2 to skip endrec && time in seconds
    #
  $self->{'TIMER'}->start( 'Text');

    for ( my $i = 1; $i <= $dat->{ 'cgi_params' }{ 'numtext' }; $i++ ) {
	 my $field_name = "textincludeboth" . $i ;
	 my $content = $dat->{ 'cgi_params' }{ $field_name };
         if( ( length( $content ) == 0 ) || ( $content eq "no answer" ) ) {       # textinclude
	   $content = undef ;
	 }
         $self->addAnswer( 'response_id' => $response_id, 
			       'field_number' => $i, 
		               'table' => 'answer_text', 
			       'content'      => $content,
			       'exists'        => exists $dat->{ 'cgi_params' }{ $field_name } || $variableIsSeen{$field_name }
			  );
    }  # End of for loop to step through the data 
  $self->{'TIMER'}->stop( 'Text');
  $dbh->commit();
  return $rc;
}

=head3 addIntegerAnswer ( %args )

Add the answer subtables (  _integer )( appname05NN)  

=cut

sub addIntegerAnswer {
  my $self = shift;
  my ( %args ) = @_ ;
  my $modified_rows = 0;
  
  my $log           = $self->get_log();
  my $insert_string = "";
  my $delete_string = "";
  
  if ($log->is_debug()) {
      $log->debug("Input args: ", sub{Dumper(\%args)});
  }

  my $response_id =  $args{ 'response_id' }  ? $args{ 'response_id' } : '1'; 
  my $form        =  $args{ 'form' } ; 
  my $numappname05   =  $args{ 'numappname05' } ? $args{ 'numappname05' } : '0' ; 
  my $varseen     =  $args{ 'varseen' }  ? $args{ 'varseen' } : '1'; 
  my $dbh = $self->{DBH};
  my $sth = $self->{STH}->{  'answer_integer' };
  my $insert_number = 0;

  my $rc       = $sth->{select}->execute( $response_id ); 
  my $data_ref = $sth->{select}->fetchall_hashref( 'field_number'); 
  
  if ($log->is_debug()) {
      $log->debug("\$data_ref: ", sub{Dumper($data_ref)});
  }

  for ( my $i = 1; $i <= $numappname05 ; $i++ ) {
    my $field_name = "appname05" . $i ;
    my $content = $form->{ $field_name } ;
    
    if ($log->is_debug()) {
      $log->debug("\$field_name '$field_name', \$content '$content'");
    }

# use Data::Dumper;
# die Dumper( $form );

    my $not_seen = 0;
    if( !exists $form->{ $field_name} ) {
      $not_seen = 1;
    }

    my $no_answer = 0;
#
# Bulk loader modified to create not seen
#
#              $content eq '.'                          || 
#              ( ( length( $content) > 1 ) # Multi Digit appname05NN 
#		&& $content == ( ( 10 ** length( $content ) ) - 1  ) )
if( ( exists $varseen->{ $field_name } &&
      ( !exists $form->{ $field_name }   
	    || !defined $content       
            || length( $content ) == 0 || $content eq '.' ) ) ) {
	   $not_seen  = 0;
	   $no_answer = 1;
    } elsif ((length($content) > 1 ) && $content == ((10 ** length($content)) - 1)) {
        # Multi Digit appname05NN: 99,999,9999,...
        # make sure the field length is correct, i.e.,
        # the field is listed under n_digits where n is the field length
        my $n_digits = length($content) . "_digits";
        my $n_str    = $form->{$n_digits};
        if ($log->is_debug()) {
            $log->debug("Field: '$field_name' n_digits: '$n_digits' n_str: $n_str");
        }
        if (defined($n_str)) {
            my @n_list = split /,/, $n_str;
            if (grep /^$i$/, @n_list) {
                # the field name is in the list
                # it's an unanswered field.
                $not_seen  = 0;
                $no_answer = 1;
                if ($log->is_debug()) {
                    $log->debug("Field: '$field_name' is 'not answered'. Content: '",(defined($content) ? $content : 'NOT DEFINED'),"'");
                }
            } else {
                # it's a legitimate 99,999,9999,...
                if ($log->is_debug()) {
                    $log->debug("Field: '$field_name' is '",(defined($content) ? $content : 'NOT DEFINED'),"'");
                }
            } # endif grep field
        } else {
            # shouldn't be here
            $log->error("Field: '$field_name', '",(defined($content) ? $content : 'NOT DEFINED'),"' is not in the '$n_digits'");
        } # endif defined($n_str)
    } # endif no_answer
    
    if ($log->is_debug()) {
      $log->debug("\$not_seen '$not_seen', \$no_answer '$no_answer'");
    }
# print STDERR "$not_seen;$no_answer;$content\n";

        
	 #  DELETE
	 #  TBD:  Only deletes for values less than numappname05 or numtext
	 #
	 #  Record exists in DB and not part of our varseen list
	 if( exists $data_ref->{ $i }  && $not_seen ) {    
           # If we don't have a variable or it is a not seen value 
              $delete_string .= ',' if length( $delete_string );
              $delete_string .= $i;
         } # End of if exists

        
	 # INSERT
	 #
	 if( !exists $data_ref->{ $i } && ! $not_seen ) {    
            $insert_string .= ' UNION ' if length( $insert_string );
	    # Just make sure
            $content = 'NULL' if( $no_answer ) ;
            $insert_string .= 'SELECT \'' . $response_id . '\',';
            $insert_string .= $i . ',';
            if( $no_answer ) { 
              $insert_string .= 'NULL' ;
            } else {
                if ($content eq '.') { # allow_zero = 1
                    # a drop down box slipped through the cracks
                    $insert_string .= 'NULL' ;
                } else {
                    # as intended
                    $insert_string .= sprintf( "%d", $content ) ;
                }
            }
            $insert_number++;
         } else {
	 #
	 # UPDATE ( if different from current )
	 #
           my $old_content = $data_ref->{ $i }->{'content'};
           # if user goes back and resubmits
	   if( $no_answer || $content eq '.') {
             $content = undef;
           }
           if( (   defined $old_content && ! defined $content )  ||
               ( ! defined $old_content &&   defined $content )  ||
               (   defined $old_content &&   defined $content && ( $old_content != $content ) ) ) {
              $modified_rows += $sth->{update}->execute( $content, $response_id, $i);
# print STDERR "Update  $field_name:$no_answer:$old_content:$content\n";
           } # Changed
         }  # UPDATE
       } # FOREACH field
  $self->{'TIMER'}->start( 'InsInteger');
    
       if( length( $insert_string ) ) {
# die "<SQL>" . $insert_string . "</SQL>";
             
             if ($log->is_debug()) {
               $log->debug("\$insert_string '$insert_string'");
             }
             
	     $modified_rows += $dbh->do( 'INSERT INTO answer_integer ( response_id, field_number, content ) ' . $insert_string );
	     # die 'INSERT INTO answer_integer ( response_id, field_number, content ) ' . $insert_string ;
       }
  $self->{'TIMER'}->stop( 'InsInteger');

       if( length( $delete_string )) {
	     $modified_rows += $dbh->do( 'DELETE FROM answer_integer WHERE response_id = \'' . $response_id . '\' AND field_number IN ( ' . $delete_string . ')' );
	     # $modified_rows += $sth->{delete}->execute( $response_id, $delete_string);
       }
  return $modified_rows;
}
sub insertProcedure{
  my $self = shift;
  my ( %args ) = @_ ;

  my $pageNumber     =  $args{ 'pageNumber' }  ? $args{ 'pageNumber' } : '0'; 
  my $numberOfFields =  $args{ 'numberOfFields' }  ? $args{ 'numberOfFields' } : '0'; 
  my $appname05ID =  $args{ 'appname05ID' }  ? $args{ 'appname05ID' } : '0'; 
  my $sessionID =  $args{ 'sessionID' }  ? $args{ 'sessionID' } : '0'; 
  my $updated =  $args{ 'updated' }  ? $args{ 'updated' } : '0'; 
  my $remote =  $args{ 'remote' }  ? $args{ 'remote' } : '0.0.0.0'; 
  my $serverID =  $args{ 'serverID' }  ? $args{ 'serverID' } : '0'; 
  my $status_flag =  $args{ 'status_flag' }  ? $args{ 'status_flag' } : '0'; 
  my $insert_string =  $args{ 'insert_string' }  ? $args{ 'insert_string' } : ''; 

  my $modified_rows = 0;


  my $session_id  =  $args{ 'session_id' }  ? $args{ 'session_id' } : '1'; 
  my $form        =  $args{ 'form' } ; 
  my $numappname05   =  $args{ 'numappname05' } ? $args{ 'numappname05' } : '0' ; 
  my $varseen     =  $args{ 'varseen' }  ? $args{ 'varseen' } : '1'; 
  my $dbh = $self->{DBH};
  my $sth = $self->{STH}->{  'answer_integer' };
  my $insert_number = 0;
  my $page = 1;

  for ( my $i = 1; $i <= $numappname05 ; $i++ ) {
    my $field_name = "appname05" . $i ;
    my $content = $form->{ $field_name } ;

# use Data::Dumper;
# die Dumper( $form );

    my $not_seen = 0;
    if( !exists $form->{ $field_name} ) {
      $not_seen = 1;
    }

    my $no_answer = 0;
    if( ( exists $varseen->{ $field_name } &&
          ( !exists $form->{ $field_name }   
	    || !defined $content       
            || length( $content ) == 0  ) )            ||   
              $content eq '.'                          ||   
              ( ( length( $content) > 1 ) # Multi Digit appname05NN  
		&& $content == ( ( 10 ** length( $content ) ) - 1  ) ) 
     ) {
die "Over Rulling not_seen ($content) " if( $not_seen );

	   $not_seen  = 0;
	   $no_answer = 1;
     
     }
# print STDERR "$not_seen;$no_answer;$content\n";

        
	 # INSERT
	 #
	 if( ! $not_seen ) {    
            $insert_string .= ' UNION ' if length( $insert_string );
	    # Just make sure
            $content = 'NULL' if( $no_answer ) ;
            $insert_string .= 'SELECT @R,f=';
            $insert_string .= $i . ',c=';
            if( $no_answer ) { 
              $insert_string = 'NULL' ;
            } else {
              $insert_string .= sprintf( "%d", $content ) ;
            }
            $insert_number++;
            if( $insert_number == 70 ) {
              $self->callInsertProcedure( 
                'pageNumber' => $page++,
                'numberOfFields' => $insert_number, 
                'appname05ID' => $serverID, 
                'sessionID' => $sessionID,
                'updated' => $updated, 
                'remote' => $remote, 
                'serverID' => $serverID, 
                'status_flag'   =>  $status_flag, 
                'insert_string' =>  $insert_string ); 
              $insert_number = 0;
              $insert_string = '';
            }
         } 
       } # FOREACH field
  $self->{'TIMER'}->start( 'InsInteger');
            my $response_id =  $self->callInsertProcedure( 
                'pageNumber' => $page == 1 ? 0 : -99,
                'numberOfFields' => $insert_number, 
                'appname05ID' => $serverID, 
                'sessionID' => $sessionID,
                'updated' => $updated, 
                'remote' => $remote, 
                'serverID' => $serverID, 
                'status_flag'   =>  $status_flag, 
                'insert_string' =>  $insert_string ); 
  $self->{'TIMER'}->stop( 'InsInteger');

  return $response_id;
}
sub callInsertProcedure{
  my $self = shift;
  my ( %args ) = @_ ;
  my $dbh = $self->{DBH};
  my $pageNumber     =  $args{ 'pageNumber' }  ? $args{ 'pageNumber' } : '0'; 
  my $numberOfFields =  $args{ 'numberOfFields' }  ? $args{ 'numberOfFields' } : '0'; 
  my $appname05ID =  $args{ 'appname05ID' }  ? $args{ 'appname05ID' } : '0'; 
  my $sessionID =  $args{ 'sessionID' }  ? $args{ 'sessionID' } : '0'; 
  my $updated =  $args{ 'updated' }  ? $args{ 'updated' } : '0'; 
  my $remote =  $args{ 'remote' }  ? $args{ 'remote' } : '0.0.0.0'; 
  my $serverID =  $args{ 'serverID' }  ? $args{ 'serverID' } : '0'; 
  my $status_flag =  $args{ 'status_flag' }  ? $args{ 'status_flag' } : '0'; 
  my $insert_string =  $args{ 'insert_string' }  ? $args{ 'insert_string' } : ''; 
  my $response_id ;
  $self->{'TIMER'}->start( 'InsInteger');
	     my $str =  'INSERT INTO answer_integer ( response_id, field_number, content ) ' . $insert_string ;
	     $response_id = $dbh->do( "SELECT InsertUpdateString( $pageNumber, $numberOfFields, $appname05ID, $sessionID, $updated, $remote, $serverID, $status_flag, '', '', '$str' " );
  $self->{'TIMER'}->stop( 'InsInteger');

  return $response_id;
}

=head3 addAnswer ( %args )

Add the integer or text subtables ( appname05NN, textincludebothNN)

=cut

sub addAnswer  {
  my $self = shift;
  my ( %args ) = @_ ;
  my $rc = 0;
  my $rv;

  my $response_id =  $args{ 'response_id' }  ? $args{ 'response_id' } : '1'; 
  my $field_number = $args{ 'field_number' } ? $args{ 'field_number' } : '0'; 
  my $content =      $args{ 'content' }      ; 
  my $exists       = $args{ 'exists' }       ; 
  my $dbh = $self->{DBH}; 
  my $sth = $self->{STH}->{ $args{ 'table' } };
  
  # warn( "Response_id $response_id FN $field_number C $content E $exists " );
  
#  unless( $exists ) {
#      $rv  = $sth->{delete}->execute( $response_id, $field_number) ;
#      return ;
#  }
  $rv  = $sth->{select}->execute( $response_id, $field_number);
  my @row ;
  if( @row = $sth->{select}->fetchrow_array  ) {
    my $old_content = $row[0];
    $sth->{select}->finish();
    if( $exists ) {
    if( (   defined $old_content && ! defined $content )  ||
        ( ! defined $old_content &&   defined $content )  ||
        (   defined $old_content &&   defined $content && ( $old_content ne $content ) ) ) {
        $rv  = $sth->{update}->execute( $content, $response_id, $field_number);
      }
    } else {
        $rv  = $sth->{delete}->execute( $response_id, $field_number);
    }
  } else {
      # print STDERR "Insert R:(" . $response_id . ") F:(" . $field_number . ") V: (" . $content , ")\n";
      if( $exists ) {
        $rv  = $sth->{insert}->execute( $response_id, $field_number, $content);
        $sth->{select}->finish();
      }
  }
}
=head3 getCount ( %args )

Return number of responses for specified appname05.

Note that appname05 engine latency requirements may involve caching this
data at the SOAP interface level.

=cut

sub getCount {
	my $self = shift;
	my(%args) = @_;

	my $appname05_id = defined($args{appname05_id}) ? $args{appname05_id} : '1'; 

	my $rv;
	my $dbh = $self->{DBH}; 
	my $sth = $self->{STH}->{count};

	my $count;
	my @row;
	$rv  = $sth->{select}->execute($appname05_id);
	if( ! ( @row = $sth->{select}->fetchrow_array  ) ) {
		$count = $row[0];
	} # if
	$sth->{select}->finish( );

	return $count;

} # getCount()


=head3 getSessionState()

Return session state for specified response_id

=cut

sub getSessionState {
	my $self = shift;
	my(%args) = @_;

	my $response_id = defined($args{response_id}) ? $args{response_id} : '1'; 

	my $rv;
	my $dbh = $self->{DBH}; 
	my $sth = $self->{STH}->{session_state};

	my $session_state;
	my @row;
	$rv  = $sth->{select}->execute($response_id);
	if( ! ( @row = $sth->{select}->fetchrow_array  ) ) {
		$session_state = $row[0];
	} # if
	$sth->{select}->finish( );

	return $session_state;

} # getSessionState()


=head3 SqlDate ( %args )

Put date into appropriate for DB timestamp format;

=cut

sub SqlDate {
	# TBD sprintf for postgres

  my ( %args ) = @_ ;
  $args{ 'date' }   ||= 'Wed Jan  8 16:26:15 2003 GMT';
  $args{'format' } ||= "pgsql";
  # (my $ss,my $mm,my $hh,my $day,my $month,my $year,my $zone) = strptime($args{ date} );  
   
  # (my $ss,my $mm,my $hh,my $day,my $month,my $year,my $zone) = localtime( str2time($args{ date} ));  
  my ( $ss, $mm, $hh, $day, $month, $year, $zone) = localtime( $args{ 'date' } );  

  return undef if( ! defined $year );
  #  return undef if( ! defined $zone );  # At least zone gets used and the compiler will stop warning
 
  # print STDERR "Input: " . $args{ date } . "\n";
  # print STDERR "Date:  $year $month $day $hh $mm $ss $zone \n";
  return sprintf( "%4.4d%2.2d%2.2d%2.2d%2.2d%2.2d" , $year + 1900, $month + 1, $day, $hh, $mm, $ss ) 
    if ( $args{ format } eq "mysql");
  return sprintf( "%4.4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d" , $year + 1900, $month + 1, $day, $hh, $mm, $ss)
    if ( $args{ format } eq "mssql" );
  return sprintf( "%4.4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d" , $year + 1900, $month + 1, $day, $hh, $mm, $ss)
}

=head3 addEntranceParameters ( %args )

Add the entrance_parameter subtable

=cut

sub addEntranceParameters {
  my $self = shift;
  my ( %args ) = @_ ;
  my $dbh = $self->{DBH}; 
  my $sth = $self->{STH}->{entrance_parameters};

  my $entrance_log_id =  $args{'entrance_log_id'}  ? $args{'entrance_log_id'} : '1'; 
  # my $sequence = $args{ 'sequence' } ? $args{ 'sequence' } : '0'; 
  my $name = $args{ 'name' } ? $args{ 'name' } : undef; 
  my $content = $args{ 'content' } ? $args{ 'content' } : undef; 

  return my $rv  = $sth->{insert}->execute( $entrance_log_id, $name, $content);
}

sub addSession {
  my $self = shift;
  my ( %args ) = @_ ;
  my $rc = 0;

  my $response_id =  $args{ 'response_id' }  ? $args{ 'response_id' } : '1'; 
  my $form        =  $args{ 'form' }      ; 

  my $dbh = $self->{DBH}; 
  my $sth = $self->{STH}->{ 'session_information' };
 
  my $content = MIME::Base64::encode ( Storable::freeze( $form ));
  my $expires = "";
  my $expire_epoch = "";
  if( exists $form->{ 'sesson_expires' } ) {
     $expire_epoch = time() +  ( $form->{ 'sesson_expires' } * 3600  );
  } else {
     $expire_epoch = time() +  ( 21 * 24 * 3600  );
  }
  $expires = SqlDate ( 'date' => $expire_epoch, 
                             , 'format' => $self->{DBTYPE} );

  # warn( "Response_id $response_id FN $field_number C $content E $exists " );
  
  my $rv  = $sth->{select}->execute( $response_id);
  my @row ;
  if( @row = $sth->{select}->fetchrow_array  ) {
# warn "R($response_id)E($expires)C($content)";
     $rv  = $sth->{update}->execute( $expires, $content, $response_id);
  } else {
     $rv = $sth->{insert}->execute( $response_id, $expires, $content);
  }
  $sth->{select}->finish( );
}

sub getAutomailList  {
  my $self = shift;
  my ( %args ) = @_ ;
  my $rc = 0;
  
  my $log = $self->get_log();
  my $dbh = $self->{DBH};
  # my $sth = $self->{STH}->{entrance_log};

  my $logfile = $args{ 'log' };

  my $sql =  "SELECT * FROM automail_config c, automail_message m, appname05 s ";
     $sql .= "WHERE c.automail_config_id = m.automail_config_id ";
     $sql .= " AND send_min_timestamp <= getdate() ";
     $sql .= " AND send_max_timestamp >= getdate() ";
     $sql .= " AND message_status_id = 1 ";
     $sql .= " AND appname05_file = '" . $logfile . "' ";
     $sql .= " AND s.appname05_id = c.appname05_id ";
     $sql .= " ORDER BY send_min_timestamp ";
  
     my $array_ref = $dbh->selectall_arrayref( $sql, { Columns => { } } );
     
     if ($log->is_debug()) {
         $log->debug("Email array: ", sub{Dumper($array_ref)});
     }
#
  my @unique_array;
  my @update_list = ();
  foreach $config ( @{$array_ref} ) { 
   #
   #  TBD
   #    Select Against table to find if address is unique,
   #    if not update status and delete from array
   #
   # Get expire in days
     my $expire = $config->{'duplicate_expire'} / ( 24 * 60 * 60 );  # /
     
     # escape e-mail
     my $email = $config->{'email'};
     $email =~ s|'|''|g;
      
     $sql  = "SELECT count(*) AS count";
     $sql .= "  FROM automail_message m ";
     $sql .= " WHERE message_status_id = 2 ";
     $sql .= "   AND automail_config_id = " . $config->{'automail_config_id'};
     $sql .= "   AND email = '" . $email;
     $sql .= "'  AND sent_timestamp > ( GETDATE() - $expire )"; 

     my $count_ref = $dbh->selectall_arrayref( $sql, { Columns => {} } );
     
     if ($log->is_debug()) {
         $log->debug("SQL: '$sql'");
         $log->debug("Email Count array: ", sub{Dumper($count_ref)});
     }
     if ( $count_ref->[0]->{'count'} != 0 ) {
	     # Not unique so update status
       my $update = $dbh->do( 'UPDATE automail_message SET message_status_id = 3 WHERE automail_message_id = ' . $config->{'automail_message_id'} );
       if( $update ) {
	       $dbh->commit();
       } else {
	       $dbh->rollback();
       }

     } else {
       push ( @unique_array, $config ) ;
       push @update_list, $config->{'automail_message_id'};
     }
  }
  $dbh->commit();
  
  # mark selected messages with status = 6
  if (scalar @update_list > 0) {
      my $update = $dbh->do( 'UPDATE automail_message SET message_status_id = 6 WHERE automail_message_id IN(' . join(",", @update_list) . ')' );
      if( $update ) {
          $dbh->commit();
      } else {
          $dbh->rollback();
      }
  } # endif @update_list > 0
  
  if ($log->is_debug()) {
      $log->debug("Unique Email array: ", sub{Dumper(\@unique_array)});
  }
  return \@unique_array;
}

sub getAutomailMessage  {
	#
	# TBD  Make a little more generic to handle logs or dat
	#
  my $self = shift;
  my ( %args ) = @_ ;
  my $rc = 0;

  my $dbh = $self->{DBH};
  # my $sth = $self->{STH}->{entrance_log};

  my $data_id = $args{ 'data_id' };
  my $table_name = $args{ 'table_name' };
  my $automail_message_id = $args{ 'automail_message_id' };
  my $sql  = "SELECT name, content ";
     $sql .= "  FROM $table_name ";
     $sql .= " WHERE entrance_log_id = " . $data_id ;
# warn $sql;
  my $parm_ref = $dbh->selectall_arrayref( $sql, { Columns => {} } );
  ## Mail program Done in update_automail_message
  ## my $update = $dbh->do( 'UPDATE automail_message SET message_status_id = 2, sent_timestamp = GETDATE() WHERE automail_message_id = ' . $automail_message_id);
  my %tmpl_hash;
  foreach $param ( @{$parm_ref} ) { 
           $tmpl_hash{$param->{name}} =  $param->{content};
  }
  $dbh->commit();
  return \%tmpl_hash;
}

=head2 B<update_automail_message(%args)>

The method updates the automail_message table

=begin testing

=end testing

=cut

sub update_automail_message
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # input args
    my $message_id     = $args{'message_id'};
    my $message_status = $args{'message_status'};
  
    unless ($message_id) {
        $log->error("No \$message_id specified !!!");
        return FAILED;
    }
  
    unless ($message_status) {
        $log->error("No \$message_status specified !!!");
        return FAILED;
    }
    
    my $dbh = $self->{DBH};
    my $stmt;
    if ($message_status == 2) {
        # message sent
        $stmt = "UPDATE automail_message SET sent_timestamp = getdate(), message_status_id = 2 WHERE automail_message_id = $message_id";
    } elsif ($message_status == 3) {
        # duplicate message
        $stmt = "UPDATE automail_message SET message_status_id = 3 WHERE automail_message_id = $message_id";
    } else {
        # unknown status
        $log->error("Unknown message status: '$message_status'");
        return FAILED;
    }
    
    # start transaction
    eval
    {
        local $SIG{__DIE__} = 'DEFAULT';
        my $sth = $dbh->prepare($stmt);
        $sth->execute();
        $sth->finish();
        $dbh->commit();
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
        return SUCCESS;
    }
}


=head2 B<get_automailer_smtp()>

The method gets automailer SMTP servers

=begin testing

=end testing

=cut

sub get_automailer_smtp
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # initialize return list
    my @list;
    
    # get the list of SMTP servers to connect to
    my $dbh  = $self->{DBH};
    my $stmt = "SELECT smtp_server FROM automail_smtp_servers ORDER BY preference";
    my $array_ref;
    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        $array_ref = $dbh->selectall_arrayref($stmt);
    };
    
    if ( $@ ) {
        $log->error("Error in '$stmt' selecting SMTP servers: $@");
        # assign default SMTP server
        push @list, "smtp.appname05-poll.com", "127.0.0.1";
    } else {
        # get the results
        foreach my $aryref (@{ $array_ref }) {
            push @list, $aryref->[0];
        }
    }
    
    wantarray ? @list : \@list;

} # get_automailer_smtp


=head2 B<get_automailer_alert_recipients()>

The method gets automailer alert recipients

=begin testing

=end testing

=cut

sub get_automailer_alert_recipients
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # initialize return list
    my @list;
    
    # get the list of alert recipients
    my $dbh  = $self->{DBH};
    my $stmt = "SELECT email FROM automail_recipients WHERE active = 1";
    my $array_ref = undef;
    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        $array_ref = $dbh->selectall_arrayref($stmt);
    };
    
    if ( $@ ) {
        $log->error("Error in '$stmt' selecting alert recipients: $@");
        # assign default recipient
        push @list, "maxim.maltchevski\@appname05site.com", "peter.hircock\@appname05site.com";
    } else {
        # get the results
        foreach my $aryref (@{ $array_ref }) {
            push @list, $aryref->[0];
        }
    }
    
    wantarray ? @list : \@list;

} # get_automailer_alert_recipients


=head2 B<automail_insert_config()>

The method creates a record in automail_config

=begin testing

=end testing

=cut

sub automail_insert_config
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # config
    my $config = $args{'config'};
    
    # get the list of alert recipients
    my $dbh  = $self->{DBH};
    my $stmt = "INSERT INTO automail_config ("
        . join(",", sort keys %{ $config })
        . ") VALUES('"
        . join("','", map { $config->{$_} } sort keys %{ $config })
        . "')";
    
    if ($log->is_debug()) { 
        $log->debug("Stmt: '$stmt'"); 
    }
    
    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        my $sth = $dbh->prepare($stmt);
        $sth->execute();
        $sth->finish();
    };
    
    if ( $@ ) {
        $log->error("Error in '$stmt': $@");
        $dbh->rollback();
        return FAILED;
    } else {
        $dbh->commit();
    }
    
    return SUCCESS;

} # automail_insert_config


=head2 B<automail_config_exists()>

The method creates a record in automail_config

=begin testing

=end testing

=cut

sub automail_config_exists
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # config
    my $appname05_id = $args{'appname05_id'};
    my $logfile   = $args{'logfile'};
    
    # get the list of alert recipients
    my $dbh  = $self->{DBH};
    my $stmt = "SELECT COUNT(\*) FROM automail_config WHERE appname05_id = '$appname05_id' AND logfile = '$logfile'";
    
    if ($log->is_debug()) { 
        $log->debug("Stmt: '$stmt'"); 
    }
    
    my $array_ref = undef;
    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        $array_ref = $dbh->selectall_arrayref($stmt);
    };
    
    if ( $@ ) {
        $log->error("Error in '$stmt': $@");
        return FAILED;
    }
    
    return $array_ref->[0]->[0];

} # automail_config_exists

1;

__END__

=head1 LOG

	$Log: apiSQL.pm,v $
	Revision 1.3  2004/05/26 21:15:38  maxim
	Escaped e-mail in the automailer SELECT duplicates
	
	Revision 1.2  2004/05/18 15:22:10  maxim
	Replaced single quote with two single quotes in entrance_parameters
	
	Revision 1.1  2004/03/31 22:17:50  maxim
	Added gud stuff to new repository
	
	Revision 1.58  2004/02/06 15:46:12  maxim
	Message status changed to 6 while it's being processed
	
	Revision 1.57  2004/01/05 16:05:40  maxim
	Fixed broken v1.56 for drop down boxes
	
	Revision 1.55  2003/12/18 21:10:18  maxim
	If user goes back and resubmits, undef content
	
	Revision 1.54  2003/12/18 19:22:45  maxim
	allow_zero =1 sets not answered drop down box to 0
	
	Revision 1.53  2003/12/18 16:58:17  maxim
	Added $content eq '.' to addIntegerAnswer for single digit drop down boxes
	
	Revision 1.52  2003/12/12 00:53:43  maxim
	Numerous changes
	
	Revision 1.51  2003/12/10 22:24:38  maxim
	Parantheses added to the duplicate check
	
	Revision 1.50  2003/12/08 23:06:52  maxim
	Added Log4perl to apiSQL and some Automailer functions
	
	Revision 1.49  2003/12/05 17:09:42  peter
	More functionallity to apiSQL.pm for automailer,  includes updates and checks.
	
	Revision 1.45  2003/11/18 15:58:44  peter
	Updated to always load if we are getting a status 9 and don't have one.
	
	
	Current logic
	  IF force_flag  OR getting status 9 and don't have one
	    CONTINUE Load complete record over incomplete
	  ELSE IF   have status 9 and update is not 9
	    DON't Load incomplete record over complete
	  ELSE IF  getting date older then loaded date
	    Don't Load old record.
	
	Peter
	
	Revision 1.44  2003/11/11 20:37:02  peter
	Fixed,  saving all text not just seen.
	
	Revision 1.43  2003/11/10 15:38:35  peter
	Modified return values of addLogline to be more consistent
	
	Revision 1.39  2003/11/06 19:17:45  peter
	Updated to Read XML config file for connection Parameters
	
	Revision 1.38  2003/11/06 18:22:52  peter
	9999 from engine fix
	
	Revision 1.37  2003/09/22 04:33:56  peter
	First draft of procedure calls.
	
	Revision 1.36  2003/09/22 03:44:58  peter
	apiSQL.pm  Updated to use SET version of addInteger
	
	Revision 1.35  2003/09/09 16:25:25  peter
	Added feature to getappname05ID,  that caches the results in hash.
	
	Revision 1.34  2003/09/09 14:00:22  peter
	Commented out Log params.
	
	Revision 1.33  2003/08/18 14:31:57  peter
	Untested changes to use varseen.
	
	Revision 1.32  2003/08/18 13:50:58  peter
	Added empty string check to apiSQL.pm for answer_interger NULL's.
	
	Revision 1.31  2003/07/16 15:14:40  maxim
	RaiseError = 0
	
	Revision 1.30  2003/07/16 14:50:38  peter
	 Added int() call to content on integer type questions.
	
	Revision 1.29  2003/07/15 21:02:58  maxim
	Exit logic added, if connect fais in addLine
	
	Revision 1.28  2003/07/15 01:19:13  peter
	Took out alarm,  didn't seem to work in soap daemon
	
	Revision 1.27  2003/07/15 01:03:58  peter
	Check for status 9 before overwrite.
	
	Revision 1.25  2003/07/12 00:41:17  peter
	Added Check not to overwrite status 9 records with other status
	
	Revision 1.23  2003/06/18 15:56:34  peter
	Modified to use new subroutines:
	  connect  # connect logic
	  prepare  # prepare cached sql statements
	  reconnect # disconnect, connect, prepare
	
	Inspired by adding $dbh->ping to addLine to verify still connected
	
	Revision 1.12  2003/06/09 17:44:35  peter
	*** empty log message ***
	
	Revision 1.11  2003/06/09 12:38:57  drew
	package name got changed and I clobbered it....
	
	Revision 1.10  2003/06/09 12:35:55  drew
	podded (again)
	

=head1 AUTHORS

Peter Hircock E<lt>F<peter.hircock@appname05site.com>E<gt>

Andrew G. Hammond E<lt>F<andrew.hammond@appname05site.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 2002, 2003, appname05Site Inc.  All rights reserved.

=cut
