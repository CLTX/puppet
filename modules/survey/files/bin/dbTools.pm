package dbTools;

##############################################################################

=head1 NAME

C<dbTools>

=head1 VERSION

	$Id: dbTools.pm,v 1.6 2003/04/25 14:59:01 drew Exp $

=head1 SYNOPSIS

	# simple, safe db access
	use dbTools;
	my ($file, $key, $val) = ('/foo/sid.db', 'bar', '1');
	
	my $result_code = dbAdd $file, $key, $val;
	if ($result_code == $DB_OK) {
		print "dbAdd successful.\n";
	} elsif ($result_code == $DB_FAIL) {
		print "dbAdd failed.\n";
	}
	
	print "$key is in $file\n"
		if dbExists $file, $key;

	print "$key is ", dbGet($file, $key), "\n";

	# dump contents of $file to STDOUT
	print dbToString $file;

=head1 DETAILS

If you only need to do a single operation on a DB file, this module is a
reasonable way to get it done.  However if you need to do multiple 
operations on the same DB file, it would be better to use C<DB_File::Lock>
dirrectly.

=cut


##############################################################################
use Carp;
use DB_File::Lock;
use Fcntl qw(:flock O_RDONLY O_RDWR O_CREAT);
use File::Basename;
use File::Spec::Functions ':ALL';
use fTools;

use Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw(dbExists dbAdd dbGet dbDel dbToString DB_OK DB_FAIL);
our @EXPORT_OK  = qw(dbExists dbAdd dbGet dbDel dbToString DB_OK DB_FAIL);
our $VERSION	= '$Revision: 1.6 $';
$VERSION	=~ s/^\D*(\S*).*$/$1/o;
sub VERSION { $VERSION; }

##############################################################################

=head2 Constants

C<DB_OK>, C<DB_FAIL>

=cut

sub DB_OK ()	{ 1 }
sub DB_FAIL ()	{ 0 }


##############################################################################

=head2 C<dbExists($dbfile, $key)>

Given a key and a dbfile to test against, return true if that 
key already appears in the dbfile. Currently this does _NOT_ 
do any form of db connection caching.

=cut

sub dbExists ($$) {
        my ($df, $key) = @_;

	return DB_FAIL unless (-r $df);		# no file -> not in file.

        my %db;
        # note: default lockfile name is ${df}.lock
        tie (%db, 'DB_File::Lock', $df, O_RDONLY, 0600, $DB_HASH, 'read')
                or carp "Can't tie to $df: $!\n";
        my $status = exists $db{$key};
        untie %db;

        return $status;
}

##############################################################################

=head2 C<dbGet($dbfile, $key)>

Given a key and a dbfile, return the value referenced by the key.
If the key is not in the database, return NULL.

=cut

sub dbGet ($$) {
        my ($df, $key) = @_;

	return DB_FAIL unless (-r $df);		# no file -> not in file.

        my %db;
        # note: default lockfile name is ${df}.lock
        tie (%db, 'DB_File::Lock', $df, O_RDONLY, 0600, $DB_HASH, 'read')
                or carp "Can't tie to $df: $!\n";
        my $value = $db{$key};
        untie %db;

        return $value;
}

##############################################################################

=head2 C<dbAdd($dbfile, $key, $val)>

Given a db filename, a key and a value, insert a key->value mapping into 
the database file and return a boolean indicating success or failure.

=cut

sub dbAdd ($$$) {
	my ($df, $key, $val) = @_;
	our ($DB_OK, $DB_FAIL);

	do {	carp "Couldn't create dirrectory for db to live in: $!\n";
		return DB_FAIL;
	}	unless touch_dir($df);


	do {	carp "Can't write to $df\n";
		return DB_FAIL;
	}	if (-e $df and not -w $df);

	my %db;
		# notes: default lockfile name is ${dbfile}.lock
		# 	default db type is hash.
	tie (%db, 'DB_File::Lock', $df, O_CREAT|O_RDWR, 
	     0600, $DB_HASH, 'write') 
		or do { carp "Can't tie to $df: $!\n";
			undef %db;
			return DB_FAIL; };
	$db{$key} = $val;			# insert key
	untie %db;

	return DB_OK;
}

##############################################################################

=head 2 C<dbDel ($dbfile, $key)>

Given a db filename and a key, remove the key from the database
and return a boolean indicating success or failure.

=cut

sub dbDel ($$) {
        my ($df, $key) = @_;

	do {	carp "Couldn't create dirrectory for db to live in: $!\n";
		return DB_FAIL;
	}	unless touch_dir($df);

	return DB_FAIL unless (-r $df);		# no file -> not in file.

	my %db;
		# notes: default lockfile name is ${dbfile}.lock
		# 	default db type is hash.
	tie (%db, 'DB_File::Lock', $df, O_CREAT|O_RDWR, 
	     0600, $DB_HASH, 'write') 
		or do { carp "Can't tie to $df: $!\n";
			undef %db;
			return DB_FAIL; };
	delete $db{$key};			# delete key
	untie %db;

	return DB_OK;
}

##############################################################################

=head2 C<dbToString($dbfile)>

For debugging.  Dump entire contents of $dbfile into a string.

=cut

sub dbToString ($) {
	my $df = shift;
	our ($DB_OK, $DB_FAIL);

	do {	carp "Can't read file: $df\n";
		return '' 
	} unless (-r $df);

	my %db;
	my ($result, $count) = ('', 0);
        tie (%db, 'DB_File::Lock', $df, O_RDONLY, 0600, $DB_HASH, 'read')
                or carp "Can't tie to $df: $!\n";
	foreach my $k (sort keys %db) {
		my $v = $db{$k};		
		$result .= $count++ . ":\t$k\t-> $v\n";
	}
	untie %db;
	return $result;
}

##############################################################################

=head2 Command Line DB Dumping

When executed dirrectly from command line, expects name of db file as 
argument and dumps file to stdout.  Will eventually autodetect when 
running in a CGI environment and grab a parameter for a file to dump.
Maybe v2.

=cut

if (basename($0) eq __PACKAGE__ . '.pm') {
	die 'Usage: ' . basename($0) . " <dbfile>\n"
		unless scalar @ARGV == 1;
	print dbToString $ARGV[0];
}
1;

__END__

=head1 NOTES

Implement persistant db file ties?  Locking issues?
I doubt this can be done on a forking webserver.  Possibly on a
threading server.  We really should be using a proper database.

=head1 LOG

	$Log: dbTools.pm,v $
	Revision 1.6  2003/04/25 14:59:01  drew
	added dbGet (tested and documented)
	
	Revision 1.5  2002/11/18 16:50:45  drew
	documentation work and some minor code cleaning
	
	Revision 1.4  2002/11/14 19:55:07  drew
	commented out dead code
	renamed  to
	further documentation work
	removed #! from head of module (stupid ActiveState barfs on this)
	
	Revision 1.3  2002/11/04 20:15:14  drew
	- Podified some of the internal documentation.
	- Added calls to touch_dir (from fTools) to make sure that dirs are created
	when they're needed.  This is ugly, but not as ugly as having the appname05
	engine barf because a necessary control dir doesn't exist.
	
	Revision 1.2  2002/09/30 14:09:07  drew
	renamed revision to VERSION for mod_perl happiness
	
	Revision 1.1  2002/09/27 18:00:27  drew
	added a dbDel function
	changed return values from variables to inline functions
	minor cleanups of comments
	
	Revision 1.0  2002/09/26 18:11:44  drew
	official release version 1.0
	
	Revision 0.6  2002/09/26 14:36:35  drew
	documentation touchups
	
	Revision 0.5  2002/09/16 15:27:47  drew
	Made some stuff verbatim.

=head1 AUTHOR

Andrew G. Hammond E<lt>F<drew@appname05site.com>E<gt>

=head1 SEE ALSO

L<DB_File::Lock>

=head1 COPYRIGHT

Copyright (C) 2002, appname05Site Inc.  All rights reserved.

=cut
