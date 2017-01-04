#
# $Log: AutoMailerDLC.pm,v $
# Revision 1.1  2004/02/06 19:31:31  maxim
# Added DLC files
#
#

=head1 NAME

AUTOMAILERDLC - Derived form base class for Automailers

=head1 SYNOPSIS

use AutoMailerDLC;
my $amc = AutoMailerDLC->create(\%options);

=head1 DESCRIPTION

AutoMailer implements methods to handle automailing tasks.

=head1 CONSTRUCTOR

The object inherits a constructor from the parent class.

=begin testing

=end testing

=cut

package AutoMailerDLC;

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
    my $uniq_id     = $args{'uniq_id'};
    my $email       = $args{'email'};
    my $params      = $args{'params'};
    my $data_dir    = $args{'data_dir'};
    my $uniqid_db   = $args{'uniqid_db'};
    my $uniqid_txt  = $args{'uniqid_txt'};
    my $uniqid_bak  = $args{'uniqid_bak'};
    my $created     = $args{'created'};
    
    my $location = ($params->{'LOCATION'} ? $params->{'LOCATION'} : ($params->{'location'} ? $params->{'location'} : ''));
    my $time = localtime();
    my $str  = "Mail Sent: " . $uniq_id . "\t" . $count . "\t" . time() . "\t" . $email . "\t" . $time . "\n";
    
    # output to the text file first
    my $out = IO::File->new(catfile($data_dir, $uniqid_txt), "a");
    if ($out) {
        print $out "$str\n";
        close $out;
    } else {
        $log->error("Couldn't open file '",catfile($data_dir, $uniqid_txt),"' for append: $!");
    }
    
    # uniqid.db
    $str = "&ts=" . time() . "&location=" . url_encode($location);
    my $rc = $self->bdb_val(
                            'key'    => $uniq_id,
                            'val'    => $str,
                            'dbdir'  => $data_dir,
                            'dbfile' => $uniqid_db,
                           );
    unless ($rc) {
        $log->error("Error updating '", catfile($data_dir, $uniqid_db),"'");
    }
    
    # output to the BAK file last
    my $bak = IO::File->new(catfile($data_dir, $uniqid_bak), "a");
    $str = $uniq_id . "\t" . $str;
    if ($bak) {
        print $bak "$str\n";
        close $bak;
    } else {
        $log->error("Couldn't open file '",catfile($data_dir, $uniqid_bak),"' for append: $!");
    }
    
} # update_databases


=head2 B<url_encode($txt)>

A home grown URL encoding

=begin testing

=end testing

=cut

sub url_encode
{
  my $txt = shift;
  $txt =~ s/([^a-z0-9_.!~*'() -])/sprintf "%%%02X", ord($1)/gei ;
  $txt =~ tr / /+/;
  return $txt ;
}

1;

__END__

=head1 AUTHOR

Maxim Maltchevski, appname05 Site
E<lt>maxim.maltchevski@appname05site.comE<gt>

=head1 BUGS

=head1 COPYRIGHT

Copyright (c) 2003, appname05 Site.  All Rights Reserved.

=cut
