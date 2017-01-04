use DB_File;
use CGI;

$q = new CGI;

$X = tie %hash, 'DB_File', $q->param('file');

print $q->header();
print $q->start_html() . "\n";
print "<pre>\n";
foreach $key ( keys %hash ) {
print  $hash{ $key } . "\n";
}
print "</pre>\n";
print $q->end_html() . "\n";
