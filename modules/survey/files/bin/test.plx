#!/usr/local/bin/perl

use CGI;
# use CGI qw/:cgi-lib/;   
# use CGI qw(remote_addr); 
use Cwd;
# use strict;

BEGIN {
  $start = localtime();
  $count = 1;
};
my $time = localtime();

my    $q = new CGI;
my $str = "";
my $key ;
my @rows ;
$str .= $q->header;
$str .= $q->start_html( 'A Simple test');

@rows = ();
push( @rows, $q->td( [ 'Start Time' , $start  ]));
push( @rows, $q->td( [ 'Curr Time'  , $time   ]));
push( @rows, $q->td( [ 'Server'  , $$   ]));
push( @rows, $q->td( [ 'Count'  , $count++   ]));
$str .= $q->table({-border=>undef},
        $q->caption($q->strong('Time Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

@rows = ();
push( @rows, $q->td( [ "auth_type", $q->auth_type()  ]));
push( @rows, $q->td( [ "path_info", $q->path_info()  ]));
push( @rows, $q->td( [ "path_translated", $q->path_translated()  ]));
push( @rows, $q->td( [ "query_string", $q->query_string()  ]));
push( @rows, $q->td( [ "raw_cookie", $q->raw_cookie()  ]));
push( @rows, $q->td( [ "referer", $q->referer()  ]));
push( @rows, $q->td( [ "remote_addr", $q->remote_addr()  ]));
push( @rows, $q->td( [ "remote_ident", $q->remote_ident()  ]));
push( @rows, $q->td( [ "remote_host", $q->remote_host()  ]));
push( @rows, $q->td( [ "remote_user", $q->remote_user()  ]));
push( @rows, $q->td( [ "request_method", $q->request_method()  ]));
push( @rows, $q->td( [ "script_name", $q->script_name()  ]));
push( @rows, $q->td( [ "server_name", $q->server_name()  ]));
push( @rows, $q->td( [ "server_port", $q->server_port()  ]));
push( @rows, $q->td( [ "server_software", $q->server_software()  ]));
push( @rows, $q->td( [ "user_agent", $q->user_agent()  ]));
push( @rows, $q->td( [ "user_name", $q->user_name()  ]));
push( @rows, $q->td( [ "virtual host", $q->virtual_host()  ]));
$str .= $q->table({-border=>undef,
                   -width=>'600'},
        $q->caption($q->strong('CGI Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

@rows = ();
foreach $key (  $q->http()) {
  push( @rows, $q->td( [ $key, $q->http($key)  ]));
}
$str .= $q->table({-border=>undef},
        $q->caption($q->strong('HTTP Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

@rows = ();
foreach $key (  $q->https()) {
  push( @rows, $q->td( [ $key, $q->https($key)  ]));
}
$str .= $q->table({-border=>undef},
        $q->caption($q->strong('HTTPS Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

@rows = ();
foreach $key (  $q->Accept()) {
  push( @rows, $q->td( [ $key]));
}
$str .= $q->table({-border=>undef},
        $q->caption($q->strong('Accept Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

@rows = ();
foreach $key (  $q->cookie()) {
  push( @rows, $q->td( [ $q->cookie( $key)]));
}
$str .= $q->table({-border=>undef},
        $q->caption($q->strong('Cookie Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

@rows = ();
foreach $key ( sort keys %ENV ) {
  push( @rows, $q->td( [ $key, $ENV{$key}  ]));
}
$str .= $q->table({-border=>undef,
                   -width=>'600'},
        $q->caption($q->strong('ENV Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

$str .= "\n";
@rows = ();
for( $i = 0; $i < $#ARGV + 1 ; $i++ ) {
  push( @rows, $q->td( [ $i, $ARGV[$i]  ]));
}
$str .= $q->table({-border=>undef,
                   -width=>'600'},
        $q->caption($q->strong('ARGV Stuff' )),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );
$str .= "\n";

@rows = ();
foreach $key (  $q->param()) {
  push( @rows, $q->td( [ $key, $q->param($key)  ]));
}
$str .= $q->table({-border=>undef},
        $q->caption($q->strong('Parameter Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

@rows = ();
foreach $key (  $q->url_param()) {
  push( @rows, $q->td( [ $key, $q->url_param($key)  ]));
}
$str .= $q->table({-border=>undef},
        $q->caption($q->strong('URL Parameter Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

@rows = ();
foreach $key ( @INC ) {
  push( @rows, $q->td( [ 'INC' , $key  ]));
}
$str .= $q->table({-border=>undef},
        $q->caption($q->strong('INC Stuff')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );

$str .=  "<p>Cwd: " . getcwd();
$str .=  "<p>QUERY_STRING " . $ENV{'QUERY_STRING'} . "</p>\n";

use File::Find;
my (@mod, %done, $dir);
find (\&get_module, grep { -r and -d } @INC);
@mod = grep (!$done{$_}++, @mod);
foreach $dir (sort { length $b <=> length $a } @INC) {
        foreach (@mod) { next if s,^\Q$dir,,; }
        }
# foreach (@mod) { s,^/(.*)\.pm$,$1,; s,/,::,g; $str .= "$_<BR>\n"; }
foreach (@mod) { s,^/(.*)\.pm$,$1,; s,/,::,g; }
@rows = ();
foreach $mod (@mod) { push( @rows , $q->td( $mod )) }
$str .= $q->table({-border=>'1'},
        $q->caption($q->strong('Perl Modules')),
        $q->Tr({-align=>'CENTER',-valign=>'TOP'},
          \@rows)
      );
$str .= "\nNumber Modules Installed: $#mod";

########################################################
# Get Module
########################################################
sub get_module {

/^.*\.pm$/ && /$ARGV[0]/i && push @mod,  $File::Find::name;
}


print $str;
exit(0);
