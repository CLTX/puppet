package fTools;

##############################################################################

=head1 NAME

C<fTools>

=head1 VERSION

	$Id: fTools.pm,v 1.5 2002/11/12 21:07:18 drew Exp $

=head1 SYNOPSIS

	use fTools;
	
	# dirs with .. in their path are not allowed by default.
	# You'll have to RTFC to find out how to enable them.
	
	my $limit = 5;
	my $long_relative_path = 'a/r/e/a/l/l/y/l/o/n/g/p/a/t/h/';
	my $un_reducable_path = '/a/../../b/';
	
	rmkdir $long_relative_path, $limit;	# will fail due to limit
	rmkdir $long_relative_path;		# will work
	rmkdir $un_reducable_path;		# will fail (can't .. past root)

=head1 DETAILS

=cut

##############################################################################
use strict;
use integer;

use Carp;
use File::Spec::Functions ':ALL';
use Exporter;
our @ISA	= qw(Exporter);
our @EXPORT	= qw(rmkdir touch_dir); 
our @EXPORT_OK	= qw(rmkdir touch_dir);
our $VERSION	= '$Revision: 1.5 $';
$VERSION =~ s/^\D*(\S*).*$/$1/o; 
sub VERSION () { $VERSION };


##############################################################################

=head2 C<rmkdir ($path, E<lt>$limitE<gt>)>

Recursively make a bunch of sub-dirs, as necessary.

=cut

sub rmkdir {
	my @in_path = splitdir rel2abs shift;
        my $limit = shift;
        my @out_path;

        while (scalar @in_path) {
                push @out_path, shift @in_path;
                my $path = catdir (@out_path);
		next if -d $path;		# dir already there?
		do {	carp 'rmkdir namespace collision: "' . $path .
				'" exists and is not a dir.' . "\n";
			return 0; } if -e $path;
		unshift @in_path, pop @out_path;
		last;
	} # end while dir's exist and no namespace collisions

	if (defined ($limit)) {			# check limits
		if ($limit < scalar @in_path) {
			carp "rmkdir failed: depth exceeds limit: $limit\n";
			return 0;
		}
	} # end if check limit

	while (scalar @in_path) {
		push @out_path, shift @in_path;
		my $path = catdir(@out_path);
		mkdir $path or do {		# make the dir
			carp "Can't mkdir $path: $!\n";
			return 0;
		};
	} # end while 
	return 1;				# success if we get here.
}


##############################################################################

=head2 C<touch_dir ($dir_file)>

Given a file name with path information, make sure that the path in which 
the file resides exists, recursively creating it if necessary.

=cut

sub touch_dir ($) {
        my $dir_file = shift;
        my $dir = (splitpath($dir_file))[1];
        return rmkdir $dir;
}

1;

__END__

##############################################################################

=head1 NOTES

Need to add MASK stuff (right now just using default).

=head1 LOG

	$Log: fTools.pm,v $
	Revision 1.5  2002/11/12 21:07:18  drew
	purged documentation of cruft
	removed the reduce_path function (use File:Spec::Functions::rel2abs instead)
	rewrote rmkdir for platform independance
	
	Revision 1.4  2002/11/04 20:11:43  drew
	changed some stuff from UNIXy assumptions to the more portable File::Spec
	modules.
	
	Revision 1.3  2002/10/17 18:12:31  drew
	removed prototype from rmkdir, since it is polymorphic.
	
	Revision 1.2  2002/09/30 14:05:37  drew
	renamed revision to VERSION
	
	Revision 1.1  2002/09/27 20:17:16  drew
	darn pod's whitespace sensitivities...
	
	Revision 1.0  2002/09/26 18:11:44  drew
	official release version 1.0
	
	Revision 0.2  2002/09/26 14:37:07  drew
	documentation touchups
	
	Revision 0.1  2002/09/17 19:10:33  drew
	added reduce_path function and moved rmkdir to this file.

=head1 AUTHOR

Andrew G. Hammond E<lt>F<mailto:andrew.hammond@appname05site.com>E<gt>

=head1 SEE ALSO

=head1 COPYRIGHT

Copyright (C) 2002, appname05Site Inc. All rights reserved.

=cut
