#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Data::Dumper;
$Data::Dumper::Indent = 3;

# load the module
use apiSQL;

# create the object
my $sql = apiSQL->new(
                      #'db'     => "mssql",
                      #'dbname' => "gud",
                     );
die "Can't create an apiSQL object !" unless ($sql);

print "SQL: ", Dumper($sql), "\n";
