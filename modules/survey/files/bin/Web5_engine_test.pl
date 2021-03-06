#!/usr/bin/perl
#
# $Id$
#
# Initial version of a appname05 Engine ping script.
#
# Copyright 2003 appname05Site. All rights reserved.

use strict;
use warnings;

use LWP::Simple qw(get);
use CGI qw(:standard);

use vars qw($TARGET_ADDRESS $TARGET_CONTENT $PING_SUCCESSFUL $PING_FAILURE);

$PING_SUCCESSFUL = "WEBSITE UP";
$PING_FAILURE = "WEBSITE DOWN";

$TARGET_ADDRESS = 'http://www5.appname05-poll.com/bin/appname05.asp?appname05=samples&page=sample_appname05-1.xml&log=test.log';
$TARGET_CONTENT = 'Welcome to the XYZ YadaYada appname05';

# Runs the show.
sub main()
{
    my $query = new CGI();
    
    # Attempt to grab the target page content.
    my $content = get($TARGET_ADDRESS);
    
    # Check the result for the content we are looking for.
    my $result = $PING_FAILURE;
    if ($content =~ /$TARGET_CONTENT/)
    {
        $result = $PING_SUCCESSFUL;
    }

    # Write out the response page.
    print header;
    print start_html("Engine Test");
    print $result;
    print end_html();    
}

main();
