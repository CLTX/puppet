package blTools;

##############################################################################

=head1 NAME

C<blTools>

=head1 VERSION

	$Id: blTools.pm,v 1.5 2002/11/18 16:46:42 drew Exp $

=head1 SYNOPSIS

	use blTools;
	my ($blfile, $ip) = ('/foo/blacklist.txt', '1.2.3.4');
	
	print "$ip is blacklisted.\n"
		if checkIpBl $blfile, $ip == BL_IN_LIST;

=head1 DETAILS

Simplified ip blacklist testing.  The blacklist file format is as
follows:

Comments begin with a C<#> and proceed to the end of the line.
Blank lines and comments are ignored.
Blacklist entries are either IPs or netblocks.  Examples:

	127.0.0.1		# single IP
	127.0.0.0/8		# loop back class A
	127.0.0.0/255.0.0.0	# as above, with dotted quad netmask
	127.0.0.0 - 127.255.255.255 	# as above, range notation

Syntax errors in the input file will be reported and ignored on a line
by line basis.

=cut

##############################################################################
use strict;
## use warnings FATAL => 'all';

##############################################################################
use Carp;
use File::Basename;
use fTools;
use NetAddr::IP;

use Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw(checkIpBl BL_IN_LIST BL_NOT_IN_LIST);
our @EXPORT_OK  = qw(checkIpBl BL_IN_LIST BL_NOT_IN_LIST);
our $VERSION 	= '$Revision: 1.5 $';
$VERSION =~ s/^\D*(\S*).*$/$1/o;
sub VERSION { $VERSION }

##############################################################################

=head2 Constants

C<BL_NOT_IN_LIST> C<BL_IN_LIST>

=cut

sub BL_NOT_IN_LIST 	() { 0 }
sub BL_IN_LIST 		() { 1 }

##############################################################################
# global private vars
#my $ip = qr/\d+\.\d+\.\d+\.\d+/o;

##############################################################################

=head2 Methods

=head3 C<checkIpBl($blfile, $ip_str)>

Given the file name of a blacklist file and an IP address in string form,
return true if the IP is in any of the net blocks listed in the blacklist.

Blacklist file is a flat file.
Empty lines and comments (# to end of line) are ignored.
Entries can be any reasonable form of IP address with or without netmask
See doc's for C<NetAddr::IP> for details.

	127.0.0.0/8				# loopback adds
	24.0.0.0/255.0.0.0			# those cable isp's
	192.168.0.0-192.168.255.255		# "unroutable" C class

=cut

sub checkIpBl ($$) {
	my ($blfile, $ip_str) = @_;

	touch_dir ($blfile);
	return 0 unless (-e $blfile);           # no blacklist -> not in.

	my $ip = new NetAddr::IP ($ip_str)
		or carp "Can't parse $ip_str: \n";
	return BL_NOT_IN_LIST 
		unless $ip;			# can't go any further.

	open BL, '<', $blfile or do {
		carp "Can't read $blfile: $!\n";
		return BL_NOT_IN_LIST;
	};

	my $st = 0;				# assume not in blacklist
	my $ln = 0;				# track debug output
        while (<BL>) {
		$ln++;				# increment line counter
		chomp;				# strip trailing newline(s)
 		s/\s*//og;			# strip all whitespace
		s/^([^#]*)#.*$/$1/o;		# strip comments
		next if /^$/;			# skip empty lines
		my $block;
		eval { $block = new NetAddr::IP($_); };
		do { 	carp "blTools: can't parse $blfile (line $ln): $_\n";
			next; } unless $block;
		last if $st = $ip->within($block);
	} # end while (read line from file)
	close BL;
	return $st ? BL_IN_LIST
		   : BL_NOT_IN_LIST;
}

##############################################################################

=head2 Command Line Invocation

When called dirrectly from the command line,  take a file name and an IP as
parameters and check if the IP is "in" the blacklist.

=cut

if (basename($0) eq __PACKAGE__ . '.pm') {
        die 'Usage: ' . basename($0) . " <blfile> <ip>\n"
                unless scalar @ARGV == 2;

	if (checkIpBl $ARGV[0], $ARGV[1] == BL_IN_LIST) {
        	print $ARGV[1], ' is in ', $ARGV[0], "\n";
	} else {
        	print $ARGV[1], ' is NOT in ', $ARGV[0], "\n";
	}
}

# successfull exit on load
1;

__END__

=head1 NOTES

Implement some kind of caching for blacklists?  Or better still, put them
into a database???
Implement user interface for modifying blacklist?

=head1 LOG

	$Log: blTools.pm,v $
	Revision 1.5  2002/11/18 16:46:42  drew
	added call to touch_dir
	
	Revision 1.4  2002/11/14 19:55:27  drew
	commented out dead code
	renamed  to
	further documentation work
	removed #! from head of module (stupid ActiveState barfs on this)
	
	Revision 1.3  2002/11/14 16:41:50  drew
	more documentation work,
	cleaned up eval method of detecting un-parsable input,
	cleaned up execution detection code
	
	Revision 1.2  2002/11/14 14:40:55  drew
	documentation layout changes
	
	Revision 1.1  2002/09/30 14:09:07  drew
	renamed revision to VERSION for mod_perl happiness
	
	Revision 1.0  2002/09/26 18:11:44  drew
	official release version 1.0
	
	Revision 0.9  2002/09/26 14:33:15  drew
	commented out some debugging code
	
	Revision 0.8  2002/09/26 13:53:11  drew
	pod docs cleanup
	
	Revision 0.7  2002/09/16 17:37:21  drew
	Added executable mode.
	cleaned up parsing
	formalized result codes
	
	Revision 0.6  2002/09/13 19:01:58  drew
	initial hack
	
	Revision 0.5  2002/09/11 20:24:08  drew
	darn missing semi-colons...
	
	Revision 0.4  2002/09/11 20:20:03  drew
	testing release...
	
	Revision 0.3  2002/09/10 16:10:04  drew
	minor format cleanups.
	tweaked VERSION extraction stuff to work correctly.  dho.
	'
	
	Revision 0.2  2002/09/10 14:47:44  drew
	tweaked blacklist loop for efficiency, and predeclared the $st variable.
	
	Revision 0.1  2002/09/10 14:17:47  drew
	fixed VERSION to reflect CVS revision number.
	
	Revision 0.0.1.1  2002/09/09 15:36:18  drew
	Initial import.
	
=head1 AUTHOR

Andrew G. Hammond E<lt>F<drew@appname05site.com>E<gt>

=head1 SEE ALSO

L<NetAddr::IP>

=head1 COPYRIGHT

Copyright (C) 2002, appname05Site Inc.  All rights reserved.

=cut
