use lib "../bin";
#use knoxSave;		# nasty hack to get us into appname05XML's namespace
package knoxSave;

##############################################################################

=head1 NAME

C<cleanSave.pm>

=head1 VERSION

	$Id: cleanSave.pm,v 1.9 2003/02/14 19:02:35 drew Exp $

=head1 SYNOPSIS

What do you think about that data?

	<!-- checkData: <PRINT output="in_english(checkData())" /> -->

Save with the data the "appropriate" way.

	<SET export="false" show="false" name="cs_result" value="cleanSave()" />

Having saved the data line, put debugging comment into the appname05 source.

	<IF cond="$debug_output">
		<!-- cleanSave: <PRINT output="in_english($cs_result)" /> -->
	</IF>

=head1 DETAILS

Exports two methods: C<cleanSave()> and C<checkData()> both of which
will return one of the following values:  

=cut


##############################################################################
use strict;				# use diagnostics;
## use warnings FATAL => 'all';

##############################################################################
use Carp;
use blTools;
use dbTools;
use knoxTools;
use fTools;

use Exporter;
our @ISA	= qw(Exporter);
our @EXPORT	= qw(cleanSave checkData in_english cs_good
		CS_FAIL CS_OK CS_BORING CS_BLACKLIST CS_DUPLICATE CS_FIRST);
our @EXPORT_OK	= qw(cleanSave checkData in_english cs_good
		CS_FAIL CS_OK CS_BORING CS_BLACKLIST CS_DUPLICATE CS_FIRST);
our $VERSION	= '$Revision: 1.9 $';
$VERSION =~ s/^\D*(\S*).*$/$1/o;
sub VERSION () { $VERSION; }

##############################################################################

=head2 Result Codes

=head3 Constants

The following is a list of result codes returned by cleanSave and checkData.
They are all non-zero values, except C<CS_FAIL>.

C<CS_FAIL>, 
C<CS_OK>, 
C<CS_BORING>,
C<CS_BLACKLIST>,
C<CS_DUPLICATE>,
C<CS_FIRST>

=cut

sub CS_FAIL		() { 0 }
sub CS_OK		() { 1 }
sub CS_BORING		() { 2 }
sub CS_BLACKLIST	() { 3 }
sub CS_DUPLICATE	() { 4 }
sub CS_FIRST		() { 5 }

our %dispatch = (
	CS_FIRST,	\&handle_first,
	CS_OK,		\&handle_ok,
	CS_BORING,	\&handle_boring,
	CS_BLACKLIST,	\&handle_blacklist,
	CS_DUPLICATE,	\&handle_duplicate
);

our @good = (CS_OK, CS_FIRST);

=head3 C<cs_good($result_code)>

Given a numeric result code, return true if the result code indicates 
a "good" save and false if it indicates a "junk" save. Currently 
C<CS_OK> and C<CS_FIRST> are considered "good" saves.

=cut

sub cs_good ($) {
	our @good;
	my $rc = shift;

	return scalar grep { $rc == $_ } @good;		# result in @good?
}


=head3 C<in_english($result_code)>

Given a numeric result code, return an english language string describing
the result.  Obviously for debugging purposes...

	<IF cond="$debug_output">
		<!-- cleanSave: <PRINT output="in_english($cs_result)" /> -->
	</IF>

=cut


our %english = (
	CS_FAIL,	'Failed.',
	CS_FIRST,	'First.',
	CS_OK,		'Ok.',
	CS_BORING,	'Boring.',
	CS_BLACKLIST,	'Blacklisted.',
	CS_DUPLICATE,	'Duplicate.'
);

sub in_english ($) {
	our %english;
	my $rc = shift;
	return $english{$rc};
}

##############################################################################

=head2 State Tests

=head3 C<test_duplicate()>

Assume default filenames, return true if session_id is in db file.

=cut

sub test_duplicate () {
	return dbExists(get_session_id_db_file(), 
			appname05BIN::get_sessionID());
}

##############################################################################

=head3 C<test_blacklist()>

Assume default filenames, return true if respondent's IP address is in the
blacklist.  B<NOTE>: if they're coming in via a proxy, then the proxy's 
IP address will be tested against the blacklist, not the actual user's.

=cut

sub test_blacklist () {
	my $ip = $appname05BIN::form{'env_REMOTE_ADDR'};
	return checkIpBl (get_blacklist_file(), $ip);
}

##############################################################################

=head3 C<test_boring()>

Check to see if the data is "boring" (contains nothing but "not seen" and 
"no answer").

=cut

sub test_boring () { 
	return boring_data(get_data_array_ref()); 
}

##############################################################################

=head3 C<test_first()>

Assume normal filenames, return true if the regular dat file does not exist
or is empty.

=cut

sub test_first () {
	my $dat_file = appname05BIN::get_data_file();
	return (not -e $dat_file) or -z $dat_file;
}

##############################################################################

=head2 Handlers

The handlers are called to do the appropriate thing depending on the 
nature of the data.  Over-riding these handlers would be an appropriate
way to obtain special behaviour for a particular appname05.

=head3 C<handle_duplicate()>

=head3 C<handle_blacklist()>

=head3 C<handle_boring()>

=head3 C<handle_first()>

=head3 C<handle_ok()>

=cut

sub handle_duplicate () {
	write_appname05('_duplicates');
	return CS_DUPLICATE;
}

sub handle_blacklist () {
	write_appname05('_blacklisted');
	return CS_BLACKLIST;
}

sub handle_boring () {
	write_appname05('_boring');
	return CS_BORING;
}

sub handle_ok () {
	my $r = write_appname05();

	return CS_FAIL if appname05BIN::SE_FAILED() == $r;
	
	add_session_id_db();

	return CS_OK if appname05BIN::SE_SUCCESS() == $r;
	return CS_FIRST if appname05BIN::SE_CREATED() == $r;
	croak "This should never happen!!!\n";
}

sub handle_first () { 
	handle_ok; 
}

##############################################################################

=head2 External Methods

=head3 C<checkData()>

Checks in the following order:

=over 4

=item blacklist 

Requires no locks and is computationally cheap, so check it first.

=item duplicates 

Requires lock, does a fastish db lookup.

=item boring

This must happen _AFTER_ above two filters.

=item first

Lastly, decide if this is a "first" entry, indicating a appname05 which has
gone live.

=item ok

Otherwise it's presumed to be a normal entry.

=back

=cut

sub checkData () {
	return CS_BLACKLIST	if test_blacklist();
#	return CS_DUPLICATE 	if test_duplicate();
#	return CS_BORING	if test_boring();	# lies!
	return CS_FIRST		if test_first();
	return CS_OK;		# normal
}


##############################################################################

=head3 C<cleanSave(E<lt>%named_paramE<gt>)>

Takes any of the following named parameters:

=over 4

=item C<-dipsatch>

C<CS_OK>, C<CS_FIRST>, C<CS_BORING>, C<CS_DUPLICATE> or C<CS_BLACKLIST>

=item C<-notify_to>

Comma seperated list of people to email the standard go-live message to.
IE: 

	-notify_to => 'drew@appname05site.com,peter@appname05site.com'

Currently should work for up to 2 email addresses.

=back

=cut

sub cleanSave {				# allow optional named params.
	our (%dispatch);		# import dispatch table
	my %p = scalar @_ ? @_ : ();	# parameter list

	# allow the -dispatch parameter to override default handling
	my $h = exists ($p{'-dispatch'}) ? $p{'-dispatch'} : checkData();

	# send go-live message? 
	if (CS_FIRST == $h and exists ($p{'-notify_to'})) {
		# send message...
	}
	
	return &{$dispatch{$h}}();
} # end cleanSave()

##############################################################################

=head2 Utility Methods

=head3 C<add_session_id_db()>

Assume default filenames, put session_id in db file.

=cut

sub add_session_id_db () {
	return dbAdd(get_session_id_db_file(), 
			appname05BIN::get_sessionID(), 1);
}

1;

__END__

=head1 NOTES

Several ugly assumptions necessary to interoperate with the
C<appname05-xml> engine are encapsulated here.  C<L<dataTools>> also
contains some ugly engine dependant stuff.

Since the appname05 engine rudely ignores the exporter stuff, cleanSave
rudely import's it's functions dirrectly into the appname05 engine's
namespace.  Yes, this is filthy coding practice.  Show me a better
alternative.  Please!

=head1 LOG

	$Log: cleanSave.pm,v $
	Revision 1.9  2003/02/14 19:02:35  drew
	added cs_good function to differentiate between 'good' and 'bad' result codes
	
	Revision 1.8  2003/02/14 16:08:51  drew
	added CS_FIRST to export list
	
	Revision 1.7  2003/02/14 15:21:36  drew
	Corrected spelling.  Oops.
	
	Revision 1.6  2003/02/04 18:26:49  drew
	commented out boring test as it's not working correctly yet.
	
	Revision 1.5  2002/12/06 17:38:03  drew
	changed synopsis documentation to be more appname05-engine oriented
	added the in_english($cs_result) call to provide english language versions
	of result codes.
	
	Revision 1.4  2002/11/18 16:49:59  drew
	added capacity for named paramaters to cleanSave
	added check for notify_to, no-op currently
	
	Revision 1.3  2002/11/12 15:10:16  drew
	Further documentation changes.
	
	Revision 1.2  2002/11/08 20:23:12  drew
	Documentation updates and upgrades
	added CS_FAIL result code
	modified other result codes to make sure they're non-zero
	
	Revision 1.1  2002/09/30 14:09:07  drew
	renamed revision to VERSION for mod_perl happiness
	
	Revision 1.0  2002/09/26 18:11:44  drew
	official release version 1.0
	
	Revision 0.15  2002/09/26 18:06:42  drew
	returned to nasty use hack method:
	apache/mod_perl supports the slightly cleaner way to do this, but
	iis/activestate does not.
	
	Revision 0.14  2002/09/26 15:27:28  drew
	removed internal call to use cleanSave (hack to get module really loaded)
	
	Revision 0.13  2002/09/26 14:34:41  drew
	documentation corrections
	changed dispatch table to use , instead of => (avoids autoquoting)
	
	Revision 0.12  2002/09/26 13:53:52  drew
	pod touchups
	
	Revision 0.11  2002/09/16 17:55:24  drew
	touched up POD docs.
	
	Revision 0.10  2002/09/13 19:01:58  drew
	initial hack

	Revision 0.9  2002/09/11 21:18:14  drew
	added some documentation

	Revision 0.8  2002/09/11 20:20:03  drew
	testing release...
	
	Revision 0.7  2002/09/10 21:00:00  drew
	*** empty log message ***
	
	Revision 0.6  2002/09/10 20:51:04  drew
	fool appname05 engine into keeping our code.
	
	Revision 0.5  2002/09/10 16:10:04  drew
	minor format cleanups.
	tweaked VERSION extraction stuff to work correctly.  dho.
	
	Revision 0.4  2002/09/10 14:17:47  drew
	fixed VERSION to reflect CVS revision number.
	
	Revision 0.3  2002/09/10 14:13:59  drew
	*** empty log message ***
	
	Revision 0.2  2002/09/09 20:38:29  drew
	exported checkData.  oops.
	
	Revision 0.1  2002/09/09 19:58:21  drew
	factored checkData out of cleanSave.
	moved cleanSave to a dispatch table design to facilitate adding further checks on data and ways to handle states.
	
	Revision 0.0.1.1  2002/09/09 15:36:18  drew
	Initial import.

=head1 AUTHOR

Andrew G. Hammond E<lt>F<mailto:andrew.hammond@appname05site.com>E<gt>

=head1 SEE ALSO

F<blTools.pm> F<dbTools.pm> F<dataTools.pm>

=head1 COPYRIGHT

Copyright (C) 2002, appname05Site Inc.  All rights reserved.

=cut
