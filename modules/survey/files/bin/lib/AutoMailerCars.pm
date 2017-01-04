#
# $Log: AutoMailerCars.pm,v $
# Revision 1.3  2003/12/12 00:52:17  maxim
# Numerous changes
#
# Revision 1.2  2003/12/10 22:26:02  maxim
# Overrode get_data_dir()
#
# Revision 1.1.1.1  2003/12/01 21:24:15  maxim
# Automailer files check-in
#
#

=head1 NAME

AUTOMAILERCARS - Derived form base class for Automailers

=head1 SYNOPSIS

use AutoMailerCars;
my $amc = AutoMailerCars->create(\%options);

=head1 DESCRIPTION

AutoMailer implements methods to handle automailing tasks.

=head1 CONSTRUCTOR

The object inherits a constructor from the parent class.

=begin testing

=end testing

=cut

package AutoMailerCars;

# version
our $VERSION = 1.000;

# pragmas
use strict;
use warnings;
use FindBin;
use AutoMailer;
use base qw( AutoMailer );


1;

__END__

=head1 AUTHOR

Maxim Maltchevski, appname05 Site
E<lt>maxim.maltchevski@appname05site.comE<gt>

=head1 BUGS

=head1 COPYRIGHT

Copyright (c) 2003, appname05 Site.  All Rights Reserved.

=cut
