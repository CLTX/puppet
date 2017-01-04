#
# $Log: AutoMailerWebpanel.pm,v $
# Revision 1.1  2004/04/08 15:00:03  maxim
# Added webpanel automailer
#
#

=head1 NAME

AUTOMAILERWEBPANEL - Derived form base class for Automailers

=head1 SYNOPSIS

use AutoMailerWebpanel;
my $amc = AutoMailerWebpanel->create(\%options);

=head1 DESCRIPTION

AutoMailer implements methods to handle automailing tasks.

=head1 CONSTRUCTOR

The object inherits a constructor from the parent class.

=begin testing

=end testing

=cut

package AutoMailerWebpanel;

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
use base qw( AutoMailerSearch );

# return codes
sub SUCCESS () {   1   }
sub FAILED  () { undef }


=head2 B<update_databases(%args)>

The method checks, if the e-mail address is blacklisted in one or more database(s).
DEFAULT is NOT blacklisted, same is true in case of ANY error !!!

=begin testing

=end testing

=cut
sub is_blacklisted
{
    my $self = shift;
    my %args = @_;
     
    my $log = $self->get_log();
    if ($log->is_debug()) { 
        $log->debug("Entered"); 
    }
    
    my $email = $args{'email'};
    my $list  = $args{'list'};   # list of databases to check against
    my $sql   = $args{'sql'};
    my $appname05= $args{'appname05'};
    
    # sanity check
    unless ($email) {
        $log->error("No email given");
        return FAILED;
    }
    
    unless ($list and ref($list) eq "ARRAY") {
        $log->error("List of blacklisted must be a REF to array");
        return FAILED;
    }
    
    unless ($sql) {
        $log->error("No SQL object specified");
        return FAILED;
    }
    
    # get the handle
    my $dbh  = $sql->{DBH};
    my $stmt;
    
    my $is_blacklisted = 0;
    foreach my $table (@{ $list }) {
        # check, if the email exists
        $stmt = "SELECT COUNT(\*) FROM $table WHERE email = '" . $email . "'";
        
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
            next;
        }
        
        # inform, if blacklisted anywhere
        if ($array_ref->[0]->[0]) {
            $log->info("E-mail '$email' for appname05 '$appname05' is blacklisted in table '$table'");
            $is_blacklisted++;
        }
    } # end of foreach $table
    
    return $is_blacklisted;

} # is_blacklisted

1;

__END__

=head1 AUTHOR

Maxim Maltchevski, appname05 Site
E<lt>maxim.maltchevski@appname05site.comE<gt>

=head1 BUGS

=head1 COPYRIGHT

Copyright (c) 2003, appname05 Site.  All Rights Reserved.

=cut
