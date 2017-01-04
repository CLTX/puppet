#
# $Log: AutoMailerSearch.pm,v $
# Revision 1.4  2004/02/10 22:23:39  maxim
# Date localtime
#
# Revision 1.3  2004/02/02 22:58:38  maxim
# Added time_created to output string
#
# Revision 1.2  2004/01/20 20:53:37  maxim
# Extra 'no answer' removed
#
# Revision 1.1  2004/01/05 15:24:22  maxim
# Added Search files
#
#

=head1 NAME

AUTOMAILERSEARCH - Derived form base class for Automailers

=head1 SYNOPSIS

use AutoMailerSearch;
my $amc = AutoMailerSearch->create(\%options);

=head1 DESCRIPTION

AutoMailer implements methods to handle automailing tasks.

=head1 CONSTRUCTOR

The object inherits a constructor from the parent class.

=begin testing

=end testing

=cut

package AutoMailerSearch;

# version
our $VERSION = 1.000;

# pragmas
use strict;
use warnings;
use FindBin;
use IO::File; 
use Date::Parse;
use Tie::DB_Lock;
use DB_File::Lock;
use Fcntl qw(:flock O_RDWR O_CREAT O_RDONLY); 
use File::Basename; 
use File::Spec::Functions; 
use apiSQL;
use AutoMailer;
use base qw( AutoMailer );

# return codes
sub SUCCESS () {   1   }
sub FAILED  () { undef }


=head2 B<get_appname05_array($config->{appname05})>

A method to get a list of appname05s from the configuration file
The method accept a reference to HASH. 

=begin testing

=end testing

=cut

sub get_appname05_array
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    my $appname05 = $args{'appname05'};
    
    # error flag
    my $error;
    
    # sanity check
    unless ($appname05) {
        $log->error("No appname05 specified !!!");
        $error++;
    }
    
    # return array
    my @appname05s = ();
    
    unless ($error) {
        if (ref($appname05) eq "ARRAY") {
            # ref to ARRAY
            @appname05s = @{ $appname05 };
        } elsif (ref($appname05) eq "HASH") {
            # ref to HASH
            push @appname05s, $appname05;
        } else {
            $log->error("Input must be a ref to ARRAY or HASH !!!");
        }
    } # unless $error
    
    wantarray ? @appname05s : \@appname05s;

} # get_appname05_array


=head2 B<get_unique_id(%args)>

A method to get a unique HEX id out of MESSAGE_ID

=begin testing

=end testing

=cut

sub get_unique_id
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    my $id     = $args{'id'};
    my $id_len = $args{'id_len'} || 7;
    
    # sanity check
    unless ($id) {
        $log->error("No Message ID is given !!! Setting it to '0'");
        $id = 0;
    }
    
    # garble ID with a number
    $id += 17;
    
    # hex
    my $hex_id = $self->get_hex_id(
                                   'id'     => $id,
                                   'id_len' => $id_len,
                                  );
    # add .asp extension
    return $hex_id;
    
} # get_unique_id


=head2 B<get_hex_id(%args)>

A method to get a HEX id given a number and length

=begin testing

=end testing

=cut

sub get_hex_id
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    my $id     = $args{'id'};
    my $id_len = $args{'id_len'} || 7;
    
    # sanity check
    unless ($id) {
        $log->error("No ID is given !!! Setting it to '0'");
        $id = 0;
    }
    
    return sprintf("%." . $id_len . "X", $id);
    
} # get_hex_id


=head2 B<get_password(%args)>

A method to get a unique HEX password out of MESSAGE_ID

=begin testing

=end testing

=cut

sub get_password
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    my $id     = $args{'id'};
    my $id_len = $args{'id_len'} || 6;
    
    # sanity check
    unless ($id) {
        $log->error("No Message ID is given !!! Setting it to '0'");
        $id = 0;
    }
    
    # garble ID with a number
    $id += 100023;
    
    # hex
    my $hex_id = $self->get_hex_id(
                                   'id'     => $id,
                                   'id_len' => $id_len,
                                  );
    return $hex_id;
    
} # get_password


=head2 B<get_appname05_dir(%args)>

The method returns the absolute path to the appname05 appname03ory

=begin testing

=end testing

=cut

sub get_appname05_dir
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
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
    my $fullpath = catfile($script_dir,"appname05",$appname05_dir);
    
    # check, if the path exists
    unless (-e $fullpath) {
        # we are called from the appname05
        $fullpath = $FindBin::Bin;
    }
    
    if ($log->is_debug()) { 
        $log->debug("Full path: '$fullpath'"); 
    }
    
    return $fullpath;
    
} # get_appname05_dir


=head2 B<get_control_dir(%args)>

The method returns the absolute path to the control appname03ory

=begin testing

=end testing

=cut

sub get_control_dir
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
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
    my $fullpath = catfile($script_dir,"control",$appname05_dir);
    
    # check, if the path exists
    unless (-e $fullpath) {
        # we are called from the appname05
        $fullpath = $FindBin::Bin;
    }
    
    if ($log->is_debug()) { 
        $log->debug("Full path: '$fullpath'"); 
    }
    
    return $fullpath;
    
} # get_control_dir


=head2 B<update_uniqs(%args)>

The method creates/update a record in automail_uniqs

=begin testing

=end testing

=cut

sub update_uniqs
{
    my $self = shift;
    my %args = @_;
    
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # data
    my $data = $args{'data'};
    my $sql  = $args{'sql'};
    
    # sanity check
    unless ($data and ref($data) eq "HASH") {
        $log->error("Must have a data HASH ref");
        return FAILED;
    }
    
    unless ($sql) {
        $log->error("No SQL object specified");
        return FAILED;
    }
    
    # get the handle
    my $dbh  = $sql->{DBH};
    my $stmt;
    
    # check, if the message ID exists
    $stmt = "SELECT COUNT(\*) FROM automail_uniqs WHERE automail_message_id = '" . $data->{'automail_message_id'} . "'";
    
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
    
    if ($array_ref->[0]->[0]) {
        # record exists, update it
        $data->{'updated_timestamp'} = apiSQL::SqlDate(
                                                       'date'   => time(), 
                                                       'format' => $sql->{DBTYPE},
                                                      );
        $stmt = "UPDATE automail_uniqs SET "
            . join(",", map { "$_ = '" . ($data->{$_} ? $data->{$_} : 'NULL') . "'" } sort keys %{ $data });
    } else {
        # record doesn't exist, create it
        $data->{'created_timestamp'} = apiSQL::SqlDate(
                                                       'date'   => time(), 
                                                       'format' => $sql->{DBTYPE},
                                                      );
        $stmt = "INSERT INTO automail_uniqs ("
            . join(",", sort keys %{ $data })
            . ") VALUES('"
            . join("','", map { ($data->{$_} ? $data->{$_} : 'NULL') } sort keys %{ $data })
            . "')";
    }
    
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

} # update_uniqs


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
     
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # input params
    my $key = $args{'key'};
    my $val = exists $args{'val'} ? $args{'val'} : undef;
    my $dbdir  = $args{'dbdir'};
    my $dbfile = $args{'dbfile'};
    
    # sanity check
    unless ($dbdir and -e $dbdir) {
        $log->error("'dbdir' not specified or doesn't exist !!!");
        return FAILED;
    }
    
    unless ($dbfile) {
        $log->error("'dbfile' not specified !!!");
        return FAILED;
    }
    
    # concatenate
    $dbfile = catfile($dbdir, $dbfile);
    
    unless ($key) {
        $log->error("No 'key' specified !!!");
        return FAILED;
    }
    
    if (exists $args{'val'} and not defined($val)) {
        $log->error("Can't set key '$key' to undefined value !!!");
        return FAILED;
    }
    
    # open/create database
    my %database;
    my $db;
    
    $db = tie ( %database, 'DB_File::Lock', $dbfile, O_CREAT | O_RDWR, 0666 , $DB_HASH, 'write');
    
    if ($db) {
        if (exists $args{'val'}) {
            # set
            if (exists $database{$key}) {
                $log->debug("Key '$key' has value of '$database{$key}'. Setting it to '$val'");
            } else {
                $log->debug("No entry for key '$key'. Initializing it with '$val'");
            }
            $database{$key} = $val;
        } else {
            # get
            if (exists $database{$key}) {
                $val = $database{$key};
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


=head2 B<update_databases(%args)>

The method creates a param string and updates the BDBs and a text file.
It preserves the existing record formats.

=begin testing

=end testing

=cut

sub update_databases
{
    my $self = shift;
    my %args = @_;
     
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # args
    my $count       = $args{'count'};
    my $unique_id   = $args{'unique_id'};
    my $rsp_id      = $args{'rsp_id'};
    my $email       = $args{'email'};
    my $type        = $args{'type'};
    my $delim       = $args{'delim'};
    my $params      = $args{'params'};
    my $control_dir = $args{'control_dir'};
    my $uniqid_db   = $args{'uniqid_db'};
    my $uniqid_txt  = $args{'uniqid_txt'};
    my $uniqs_db    = $args{'uniqs_db'};
    my $created     = $args{'created'};
    
    # get the output string
    my $str = $self->get_output_str(
                                    'params'    => $params,
                                    'type'      => $type,
                                    'unique_id' => $unique_id,
                                    'rsp_id'    => $rsp_id,
                                    'count'     => $count,
                                    'email'     => $email,
                                    'delim'     => $delim,
                                    'created'   => $created,
                                   );
    if ($log->is_debug()) { 
        $log->debug("Output string: '$str'"); 
    }
    
    # output to the text file first
    my $out = IO::File->new(catfile($control_dir, $uniqid_txt), "a");
    if ($out) {
        print $out "$str\n";
        close $out;
    } else {
        $log->error("Couldn't open file '",catfile($control_dir, $uniqid_txt),"' for append: $!");
    }
    
    # uniqid.db
    my $rc = $self->bdb_val(
                            'key'    => lc $rsp_id,  # lc here
                            'val'    => $str,
                            'dbdir'  => $control_dir,
                            'dbfile' => $uniqid_db,
                           );
    unless ($rc) {
        $log->error("Error updating '", catfile($control_dir, $uniqid_db),"'");
    }
    
    # uniqs.db
    $rc = $self->bdb_val(
                         'key'    => $rsp_id,        #  no lc here
                         'val'    => '&ts=' . time() . '&rs=' . $unique_id,
                         'dbdir'  => $control_dir,
                         'dbfile' => $uniqs_db,
                        );
    unless ($rc) {
        $log->error("Error updating '", catfile($control_dir, $uniqs_db),"'");
    }
    
} # update_databases


=head2 B<get_output_str(%args)>

The method creates an output string. It's a rip-off from the 2332mt/enter.xml
It preserves the existing record formats.

=begin testing

=end testing

=cut

sub get_output_str
{
    my $self = shift;
    my %args = @_;
     
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    # args
    my $params    = $args{'params'};
    my $type      = $args{'type'};
    my $delim     = $args{'delim'};
    my $count     = $args{'count'};
    my $unique_id = $args{'unique_id'};
    my $rsp_id    = $args{'rsp_id'};
    my $email     = $args{'email'};
    my $created   = $args{'created'};
    
    # sanity check
    unless ($params and ref($params) eq "HASH") {
        $log->error("'params' must be a reference to HASH !!!");
        return FAILED;
    }
        
    # two totally different formats: search and email
    my $site      = $params->{'site'} ? $params->{'site'} : ($params->{'SITE'} ? $params->{'SITE'} : '');
    my $location  = $params->{'location'} ? $params->{'location'} : ($params->{'LOCATION'} ? $params->{'LOCATION'} : '');
    my $param_str = "";
    
    if ($type eq "search") {
        
        # this is an ugly, non-generic part
        # instead of reading from the text file search.log,
        # we set everything here
        my $rq2   = "";
        my $query = "";
        my $q1    = "";
        my $q2    = "";
        my $q3    = "";
        my $q4    = "";
        
        # try both cases
        my $uq = $params->{'uq'} ? $params->{'uq'} : ($params->{'UQ'} ? $params->{'UQ'} : '');
        my $sg = $params->{'sg'} ? $params->{'sg'} : ($params->{'SG'} ? $params->{'SG'} : '');
        my $si = $params->{'si'} ? $params->{'si'} : ($params->{'SI'} ? $params->{'SI'} : '');
        my $qt = $params->{'qt'} ? $params->{'qt'} : ($params->{'QT'} ? $params->{'QT'} : '');
    
        if (defined($uq) and $uq ne '') {
            $query = '1';
            $q1    = $uq;
            $rq2   = $uq .'<BR/>';
        } else {
            $query = '0';
            $q1    = 'no answer';
        }
        
        if (defined($sg) and $sg ne '') {
            $query = $query . '1';
            $q2    = $sg;
            $rq2   = $rq2 . $sg .'<BR/>';
        } else {
            $query = $query . '0';
            $q2    = 'no answer';
        }
        
        if (defined($si) and $si ne '') {
            $query = $query .'1';
            $q3    = $si;
            $rq2   = $rq2 . $si .'<BR/>';
        } else {
            $query = $query . '0';
            $q3    = 'no answer';
        }
        
        if (defined($qt) and $qt ne '') {
            $query = $query . '1';
            $q4    = $qt;
            $rq2   = $rq2 . $qt .'<BR/>';
        } else {
            $query = $query . '0';
            $q4    = 'no answer';
        }
  
        $rq2 = substr($rq2,0,length($rq2)-5); # remove last <BR/>
        
        # param string
        $param_str = $rq2
            . $delim . "no answer"
            . $delim . "no answer"
            . $delim . "no answer"
            #. $delim . "no answer"
            . $delim . $location
            . $delim . $site
            . $delim . $q1
            . $delim . $q2
            . $delim . $q3
            . $delim . $q4
            . $delim . $query
            # added timestamp popup showed up
            . $delim . int(str2time($created))
            . $delim . scalar localtime(int(str2time($created)))
            ;
    
    } elsif ($type eq "email") {
        # e-mail is different
        
        # param string
        $param_str = $site
            . $delim . $location
            ;
    } else {
        # shouldn't be here
        $log->error("Invalid type: '$type'");
        return FAILED;
    }
    
    # output string
    my $str = $rsp_id
        . $delim . "Mail Sent: $unique_id"
        . $delim . $count
        . $delim . time()
        . $delim . $email
        . $delim . $param_str
        . $delim . scalar localtime()
        ;

} # get_output_str

1;

__END__

=head1 AUTHOR

Maxim Maltchevski, appname05 Site
E<lt>maxim.maltchevski@appname05site.comE<gt>

=head1 BUGS

=head1 COPYRIGHT

Copyright (c) 2003, appname05 Site.  All Rights Reserved.

=cut
