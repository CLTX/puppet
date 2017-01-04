#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Data::Dumper;
$Data::Dumper::Indent = 3;

# load the module
use dataQuery;

# create the object
my $sql = dataQuery->new(
                      #'db'     => "mssql",
                      #'dbname' => "gud",
                     );
die "Can't create an dataQuery object !" unless ($sql);

print "SQL: ", Dumper($sql), "\n";
