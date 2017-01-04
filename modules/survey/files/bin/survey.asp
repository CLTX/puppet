#!/usr/local/bin/perl 
#
# $Log: appname05-xml.pl,v $
# Revision 1.2  2004/09/07 14:26:03  maxim
# Modified error messages in the engine to remove PATH
#
# Revision 1.1  2004/03/31 21:24:49  maxim
# Added Engine stuff to new repository
#
# Revision 1.86  2003/09/16 15:33:42  maxim
# Added SERVER_ID to log record
#
# Revision 1.85  2003/09/10 15:10:53  maxim
# bdb_log and bdb_dat have their own config files and separate appname03ories
#
# Revision 1.84  2003/09/08 16:44:11  maxim
# DAT and LOG are written into separate files
#
# Revision 1.83  2003/08/29 12:59:10  maxim
# bdb->DESTROY removed as it doesn't work as intended
#
# Revision 1.81  2003/08/11 18:29:23  peter
# Checked in changes,   BDB write after if
#
# Revision 1.79  2003/07/25 15:21:36  maxim
# Changes made to outputappname05() not to save incremental stuff into DAT file. Needs testing
#
# Revision 1.78  2003/06/27 12:18:50  maxim
# Commented out INFO message
#
# Revision 1.77  2003/06/26 15:57:36  maxim
# Added INFO message to keep track of added recs
#
# Revision 1.76  2003/06/23 19:42:44  maxim
# June 2003 changes are merged into the old engine
#
# Revision 1.75  2003/05/28 19:57:16  maxim
# disable_cookies, server_id added to the list of config params. Output to BerkeleyDB enabled
#
# Revision 1.74  2003/05/02 22:02:19  maxim
# Display version allows to submit the appname05 results in a .dat file
#
# Revision 1.73  2003/05/01 15:36:49  maxim
# Replaced ACTION script for display version with no_content.pl
#
# Revision 1.72  2003/03/26 14:38:15  maxim
# sessionID redefinition problem fixed
#
# Revision 1.71  2003/03/24 21:19:20  maxim
# Corrected typo: $disable_is changed to $disable_if
#
# Revision 1.70  2003/03/24 20:19:21  maxim
# Numerous changes: 1) evaluteIf returns 0, if passed 'undef' 2) disable_if 3) disable_random to produce display version
#
#
package appname05BIN;
{

# appname05-xml.pl - appname05site XML based appname05 engine
# 
# Process special XML tags, pass others thru unchanged.
#
# 1) Random selection.
#
#    <RANDOM name="name" [ use="N" ] show="yes|no|0|1|true|false">
#     <R>...</R>
#     <R>...</R>
#     <R>...</R>
#    </RANDOM>
#
# 2) Conditional output.
#
#   <IF cond="$a < $b" show="yes|no|0|1|true|false">
#    Conditionally included if "a < b".
#   <ELSEIF cond="$d >= 7"/>
#    Conditionally included if "d >= 7".
#   <ELSE/>
#    Otherwise conditionally included.
#   </IF>
#
# 3) Assignment. 
#
#   <SET name="var1" value="expr1" export="yes|no" show="yes|no|0|1|true|false" />
#   <SET name="var2" value="$var1 + 7"/>
#
# 4) Export. Make variable visible when form submitted.
#    By default varibales created with <SET> are not.
#    By default CGI variables are exported.
#
#   <EXPORT name="var1"/> - to export
#   <EXPORT name="var1" value="no"/> - to unexport
#
# 5) Print. Output the expression. The value of the "output" attribute get substituted into a
#    perl "printf STDOUT ( ... )" statement.
#
#   <PRINT output="..." show="yes|no|0|1|true|false" />
#   <PRINT output="var1"/> -> printf STDOUT ("$var1");
#   <PRINT output="\"%s %d\", var1, var2"/> -> printf STDOUT ("%s %d", $var1, $var2);
#
# The following configuration variables read from the 
# 'basename(appname05-xml).cfg', 
# file which resides in the CGI-BIN appname03ory, control the program:
#
# base_page_dir - absolute path name of base XML page firectory,
#                 i.e. "/home/httpd/appname05-xml/page",
#                 no default
#
# base_data_dir - absolute path name of base data appname03ory,
#                 i.e. "/home/httpd/appname05-xml/data",
#                 no default
#
# server_id - a number indicating server ID, default is 0
#
# cache_max_entry - max. number of XML pages cached, 0 for no caching
#
# data_delimiter - output data file field delimiter,
#                  default "\t" (TAB), can be overridden by the $form{'delimiter'}
#                  CGI form variable.
#
# debug_collapse - if non zero/1 then generate <C>...</C> tags around collapsed XML code.
#                  if zero/0 then no <C>...</C> tags
#
# debug_output - if non zero/1 then output debug information as HTML comments at the end of each generated HTML page.
#                if zero/0 then don't output debug information as HTML comments at the end of each generated HTML page.
#
# debug_xml - if non zero/1 then generate appname05 engine XML tags in HTML output.
#
# disable_cookies - if non zero/1, then don't use cookie for storing the sessionID
#             if 0, then cookies are enabled (default). 
#
# disable_if - if non zero/1, then bypass IF/ELSEIF/ELSE logic to generate the display version
#             if 0, then IF/ELSEIF/ELSE logic is enabled (default). 
#
# disable_random - if non zero/1, then bypass output ALL <R> tags regardless of USE to generate the display version
#             if 0, then RANDOM logic is enabled (default). 
#
# never_serialize - if non zero/1 then never generate or use serialized XML DOM tree.
#
# never_collapse - if non zero/1 then never collapse XML DOM tree.
#
# module - the name of a perl module in the appname05 engine current appname03ory
#          (typically cgi-bin) thet the engine will compile and make available.
#          this appname03ive can appear zero or more time.
#
# output_doctype - if non zero/1 then output the '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
#                  at the start of the generated HTML code.
#
# The following CGI form variables are set by and referenced by this program:
#
# $form{'debug_collapse'} - if non zero then generate <C>...</C> tags around collapsed XML code.
#                           if 0 then no <C>...</C> tags. 
#                           default from configuration file. 
#
# $form{'debug_output'} - if non zero then output debug information as HTML comments at the end of each generated HTML page.
#                         if zero then don't output debug information as HTML comments at the end of each generated HTML page.
#                         default from configuration file.
#
# $form{'debug_xml'} - if non zero then generate appname05 engine XML tags in HTML output.
#                      if 0 then no appname05 engine XML tags. 
#                      default from configuration file. 
#
# $form{'output'} - if non zero then send HTML output to stdout.
#                   default 1 for HTML output.
#
# $form{'outputnotseen'} - if non zero then distinguish between not seen and not answered appname05 questions.
#                   default 0 for to not distinguish between not seen and not answered appname05 questions.
#
# $form{'output_doctype'} - if non zero/1 then output the '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
#                           at the start of the generated HTML code.
#
# $form{'assert'} - if non zero then perform internal consistency checking.
#                   default 0 for no checking.
#
# $form{'appname05'} - path relative to 'base_page_dir' configuration variable of the
#                   appname03ory that XML page file (as specified by the $form{'page'} CGI form
#                   variable) resides in.
#                   no default.
#
# $form{'page'} - XML file within the 'base_page_dir' . '/' . $form{'appname05'} appname03ory to process.
#		  no default.
#
# $form{'pages'} - comma separated list of XML files within 
#                  the 'base_page_dir' . '/' . $form{'appname05'} appname03ory to process,
#		   only if $form{'page'} is empty.
#		   select one at random and remove it from the list.
#                  not used, but passed on if $form{'page'} is not empty.
#
# $form{'appname05data'} - if defined then use this to generate the name of the appname05 results file rather than
#                       $form{'appname05'}. This allows different appname05s to store the survy results data in the 
#                       same appname03ory.
#
# $form{'data'} - if defined then the appname05 results are saved in the file
#                 base_data_dir/$form{'appname05'}/$form{'data'} else the appname05 results are saved in the file
#                 base_data_dir/$form{'appname05'}/basename($form{'page'}, '.xml').dat
#                 if $form{'appname05data'} is defined the use it rather the $form{'appname05'}
#
# $form{'log'} - if defined then a appname05 log entry is generated in the file 
#                base_data_dir/$form{'appname05'}/$form{'log'}. This variable should not be
#                exported. It is recommended that the:
#                <EXPORT name="log" value="no" />
#                be placed in the XML file.
#
# $form{'numappname05'} - the number of appname05 variables to save,
#                      $form{'appname05N'}, 1 <= N <= $form{'numappname05'}
#
# $form{'numtext'} - the number of text variables to save,
#                    $form{'textincludebothN'}, 1 <= N <= $form{'numtext'}
#
# $form{'appname05<1..N>'} - the answer to question 1 .. N.
#
# $form{'textincludeboth<1..N>'} - the answer to text question 1 .. N.
#
# $form{'submitanswers'} - output appname05 data to file if not empty.
#
# $form{'RANDOMORDER_<1..N>'} - the random order for <RANDOM> tag with name 1 .. N.
#
# $form{'delimiter'} - output data field delimiter, default data_delimiter from configuration file.
#
# $form{'date'} - output date field in data file
#
# $form{'time'} - output GMT time field in data file
#
# $form{'local'} - output local time field in data file
#
# $form{'usemethodget'} - if defined then use GET method rather than POST, usefull for debugging
#
# $form{'sessionID'} - the sessionID is saved in a hidden variable in case the client browser does not accept cookies.
#
# $form{'varseen'} - comma separated list of variables seen so far
#
# $form{'debug_xml'} - if true then output appname05 engine XML tags to browser 
#                    otherwise don't
#
# $form{ 'ip_not_saved' } - if true then we will not save the clients ip
#
# $form{ 'ip_saved' } - if true then we will save the clients full ip
#
# $form{ 'allow_zero' } - if true then we will not save the clients ip
#
# All cookies are mapped into form variables by prepending the
# value 'cookie_' to the name of the environment variable;
# i.e. the 'sessionID' cookie is available as 
# $form{'cookie_sessionID'}
#
# The following cookies are set by and referenced by this program:
#
# $cookie{'sessionID'} - the sessionID is saved in a cookie
#
# All environment variables are mapped into form variables by prepending the
# value 'env_' to the name of the environment variable;
# i.e. the 'HTTP_USER_AGENT' environment variable is available as 
# $form{'env_HTTP_USER_AGENT'}
#
# The following environment variables control the program:
#
# $ENV{'SCRIPT_NAME'} - partial URL to this script, for self-referencing scripts, used in the <form> tag
#
# $ENV{'DOCUMENT_ROOT'} - web server document root, used for HTML::Template search path
#
# $ENV{'PATH_TRANSLATED'} - web server document root, for IIS, used for HTML::Template search path
#
# $ENV{'REMOTE_ADDR'} - client IP, used on output
#
# Output format:
#
# 1) .dat file
#
# 2) .log file
#
# 3) .db file
#
# 4) .ser file - created in the data appname03ory, a saved binary representation of the parsed XML file,
#                for fast reloading when the appname05 engine is restarted by the web server
# 
# Not seen and not answered
#
# In order to distinguish between questions that were not seen, due to page skip
# logic and questions that were seen and not answered. @@@
#
# Override exit() et al.
use lib "../bin";
use FindBin;
use lib
    "$FindBin::Bin/lib",
;

local $SIG{__DIE__} = \&mydie;
local $SIG{__WARN__} = sub {my $m = $_[0]; $m =~ s/[\r\n]/ /g; $debug_html .= "<!-- DEBUG: WARN: $m -->\n"; };

use XML::DOM; # XML DOM Parser
use Algorithm::Numerical::Shuffle; # randomly permute list
use Fcntl ':flock'; # import LOCK_* constants
use IO::Seekable; # seek() SEEK_END
use HTML::Template; # include file processing
use appname05XMLState; # per parsed XML document state
use IO::File; # OO filehandle
use Sys::UniqueID; # generate unique sessionID
use MIME::Base64 (); # encode/decode binary CGI data
use Crypt::CBC; # encrypt/decrypt binary CGI data
use Storable; # saved cached XML to file and read back
use CGI::Enurl;       # a handy small module to URL encode a string, array, etc.
use CGI::Deurl NOCGI; # a handy small module to URL decode a string, array, etc.
use File::Basename;   #<MAX> 20030501 -> added
# use Log::Log4perl qw(:easy); #<MAX> 20030527 -> added
use BerkeleyDB;              #<MAX> 20030527 -> added
use BDB;                     #<MAX> 20030527 -> added
use File::Spec::Functions;   #<MAX> 20030527 -> added
use Benchmark::Timer;        #<MAX> 20030623 -> added
use CGI;                     #<MAX> 20030623 -> added
use knoxSave;

# Return codes of outputSuvey
sub SE_FAILED  () { 0;}  # Save failed 
sub SE_SUCCESS () { 1;}  # Save succeeded 
sub SE_CREATED () { 2;}  # Save succeeded to new/empty file 

# get_cookie_domain() - return domain name for setting cookie
# used in the BEGIN{} block, so it must be here.

sub get_cookie_domain {

	my($domain) = @_;

	if(defined($domain)){

		my($dotd) = ($domain =~ m/([^.]+\.[^.]+)$/); # 'dev.appname05-poll.com' -> 'appname05-poll.com';
		if(defined($dotd)){
			$domain = '.' . $dotd;
		}else{
			$domain = ''; # let the client figure it out
		} # if

	}else{

		$domain = ''; # let the client figure it out

	} # if

	return $domain;

} # get_cookie_domain()

# toBool() - convert string to true/false

sub toBool {
	my($value) = @_;

	if(!defined($value)){
		return $false;
	}elsif($value =~ m/y|yes|true|t|1/i){
		return $true;
	}else{
		return $false;
	} # if

} # toBool()

# isShow() - return true if node is to be output

sub isShow {
	my($node) = @_;

	my $is_show = $true;

	my $show = $node->getAttribute('show');

	if(defined($show) && $show ne ''){
		$is_show = toBool($show);
	}else{
		$is_show = $debug_xml;
	} # if

	return $is_show;

} # isShow()

# processModule() - compile external appname05 engine "plugin" module

sub processModule($) {
	my($module_file_name) = @_;

	my $ret= '';

	if(open(M, "<$module_file_name")){

		my @module = <M>;
		close(M);
		my $module = join('', @module); 

		my $ok = eval $module;

		if(defined($@) && $@ ne ''){
			$ret .= sprintf("<!-- DEBUG: CONFIG: error evaluating module '%s' - '%s' -->\n", $module_file_name, $@);
		}else{
			$ret .= sprintf("<!-- DEBUG: CONFIG: evaluated module '%s' - '%s' -->\n", $module_file_name, 'OK');
		} # if

	}else{
		$ret .= sprintf("<!-- DEBUG: CONFIG: can't open module '%s' - $! -->\n", $module_file_name);
	} # if

	return $ret;

} # processModule()

BEGIN {
	# The time mod_perl process started.

	$start = scalar(localtime(time()));

	$begin_debug_html = '';

	$base_page_dir = undef; # base appname05 page appname03ory
	$base_data_dir = undef; # base appname05 data appname03ory
	$data_delimiter = undef; # data file delimiter
	$cgi_cipher_key = undef; # key to encrypt/decrypt session ID
	$config_debug_collapse = undef; # output collapsed XML <C>...</C> tags in HTML
	$config_debug_output = undef; # output debug comments in HTML
	$config_debug_xml = undef; # output appname05 engine XML tags in HTML
	$config_output_doctype = undef; # output '<!DOCTYPE ... !>' tag
	$vers = '$Revision: 1.2 $';
	@vers = split(/ /, $vers);
	$version = $vers[1];
	%cached_xml = (); # parsed XML page cache
	$cache_num_entry = 0; # number of entries in cache
	$cache_max_entry = undef; # max. number of XML pages cached, 0 for no caching
	$never_serialize = undef; # 
	$never_collapse = undef; # 
	*appname05ElementTags = \'^ELSE$|^ELSEIF$|^EXPORT$|^FORM$|^IF$|^INPUT$|^PRINT$|^R$|^RANDOM$|^READ$|^SET$|^WRITE$'; # tags that the appname05 engine is interested in
        
        #<MAX> 20030324 -> disable IF
        $config_disable_if = undef; # bypass IF/ELSEIF/ELSE to generate display version
        
        #<MAX> 20030324 -> disable RANDOM
        $config_disable_random = undef; # bypass RANDOM to generate display version
        
        #<MAX> 20030528 -> disable cookies
        $config_disable_cookies = undef; 
        
        #<MAX> 20030528 -> server ID
        $config_server_id = undef; 

	# characters to escape in XML text.

	%escapeXMLChar = (
		'&' => '&amp;',
		'<' => '&lt;',
		'>' => '&gt;',
		'"' => '&quot;',
		"'" => '&apos;',
	);

	$sessionID = undef; # the appname05 sessionID

	@default_include_path = (); # HTML::Template include path

	# %collapseNode values
	*collapseNodeStateCollapsedByParent = \'CollapsedByParent'; # node already collapsed by {grand}parent
	*collapseNodeStateCollapse = \'Collapse'; # collapse node and children
	*collapseNodeStateNo = \'No'; # do not collapse node and children

	# variables seen
	
	%variableIsSeen = ();

	*true = \1;
	*false = \0;

	# ensure empty <textarea> tag gets output as <textarea></textarea>
	# ensure empty <script> tag gets output as <script></script>
	# ensure empty <td> tag gets output as <td></td>

	XML::DOM::setTagCompression(sub { if($_[0] =~ m/^textarea$|^script$|^td$/i){ return 1; }else{ return 0; } } );

	# Cookie domain and path.

        $sessionID_cookie_domain = get_cookie_domain($ENV{'HTTP_HOST'});
	$sessionID_cookie_path = '/';

	# Session ID must end with this string to be valid.

	$sessionID_trailer = 'must_be_here_to_be_valid';
	$sessionID_delim = ';'; # separate session ID and trailer
  
	# The configuration file name is the base name of the program
	# with ".cfg" prepended.
	my $prog_name = $0;
	$prog_name =~ s:.*/::; # strip off leading ".../.../"
	my($config_file_name) = ($prog_name =~ m:[^_a-zA-Z0-9]*([^.]+):);
	$config_file_name .= '.cfg';

	$begin_debug_html .= sprintf("<!-- DEBUG: CONFIG: HTTP HOST '%s' cookie domain '%s' config file '%s' -->\n", defined($ENV{'HTTP_HOST'}) ? $ENV{'HTTP_HOST'} : '', $sessionID_cookie_domain, $config_file_name);

	# Get configuration data.

        #<MAX> 20030324 -> re-arranged it to improve visibility
        (
         $base_page_dir, 
         $base_data_dir,
         $data_delimiter,
         $cache_max_entry,
         $cgi_cipher_key,
         $config_debug_collapse,
         $config_debug_output,
         $config_debug_xml,
         $never_serialize,
         $never_collapse,
         $config_output_doctype,
         $config_disable_if,      #<MAX> 20030324 -> disable IF: $config_disable_if added
         $config_disable_random,  #<MAX> 20030324 -> disable RANDOM: $config_disable_random added
         $config_disable_cookies, #<MAX> 20030528 -> disable cookies: $config_disable_cookies added
         $config_server_id,       #<MAX> 20030528 -> server ID: $config_server_id added
        ) = getConfiguration(
	 -config_file_name => $config_file_name,
	);

	# CGI form data encryption.

	$cgi_cipher = Crypt::CBC->new(
		{
		 'key' => $cgi_cipher_key,
		 'cipher' => 'Blowfish',
		 'regenerate_key'=> 0,
		 'padding' => 'space',
		 'prepend_iv' => $true,
		}
	);
        
        #<MAX> 20030527 -> object to handle BerkeleyDB interaction
        $bdb_dat = BDB->create(
                               {
                                   'basename' => 'bdb_dat',
                               },
                              );
        $bdb_log = BDB->create(
                               {
                                   'basename' => 'bdb_log',
                               },
                              );
        
	sub getConfiguration {
		my(%args) = @_;
		my($config_file_name) = $args{-config_file_name};

		# Format of the configuration file is:

		# # Comment line
		# name=value # trailing comment
		# name='value' # trailing comment, single quotes stripped off. used when value has embedded white space
		# name="value" # trailing comment, double quotes stripped off. used when value has embedded white space

		open(C, $config_file_name) || die sprintf('getConfiguration(): error: can\'t open configuration file "%s" - "%s"', $config_file_name, $!);

		my($Gbase_page_dir);
		my($Gbase_data_dir);
		my($Gcache_max_entry);
		my($Gdata_delimiter) = "\t"; # TAB
		my($GCGI_cipher_key);
		my($Gdebug_collapse) = $false;
		my($Gdebug_output) = $false;
		my($Gdebug_xml) = $false;
		my($Gnever_serialize) = $false;
		my($Gnever_collapse) = $false;
		my($Goutput_doctype) = $true; # for backward compatability with older appname05s
                
                #<MAX> 20030324 -> disable IF
                my($Gdisable_if) = $false;
                
                #<MAX> 20030324 -> disable RANDOM
                my($Gdisable_random) = $false;
                
                #<MAX> 20030528 -> disable cookies
                my($Gdisable_cookies) = $false;
                
                #<MAX> 20030528 -> server ID
                my($Gserver_id);

		my($line);
		my($line_num);

		while($line = <C>){

			$line_num += 1;
			chop($line);
			$line =~ s/\r//g;

			if($line !~ m/^#/o){

				my($orig_line) = $line;
				$line =~ s/[ \t]*#.*$//o; # strip trailing comment
				$line =~ s/[ \t]*$//o; # strip trailing white space
				my($name, $value) = split('=', $line);

				if(!defined($name) || !defined($value)){
					die sprintf('getConfiguration(): error: invalid format in configuration file "%s" line #%d "%s" - expected "name=value"', $config_file_name, $line_num, $orig_line);

				} # if

				$value =~ s/^['"]//o; # strip leading quote
				$value =~ s/['"]$//o; # strip trailing quote

				if($name =~ m/^base_page_dir$/o){
					$Gbase_page_dir = $value;
				}elsif($name =~ m/^base_data_dir$/o){
					$Gbase_data_dir = $value;
				}elsif($name =~ m/^data_delimiter$/o){
					$Gdata_delimiter = $value;
				}elsif($name =~ m/^cache_max_entry$/o){
					$Gcache_max_entry = $value;
				}elsif($name =~ m/^CGI_cipher_key$/o){
					$GCGI_cipher_key = $value;
				}elsif($name =~ m/^debug_collapse$/o){
					$Gdebug_collapse = toBool($value);
				}elsif($name =~ m/^debug_output$/o){
					$Gdebug_output = toBool($value);
				}elsif($name =~ m/^debug_xml$/o){
					$Gdebug_xml = toBool($value);
				}elsif($name =~ m/^never_serialize$/o){
					$Gnever_serialize = toBool($value);
				}elsif($name =~ m/^never_collapse$/o){
					$Gnever_collapse = toBool($value);
				}elsif($name =~ m/^output_doctype$/o){
					$Goutput_doctype = toBool($value);
				}elsif($name =~ m/^module$/o){
					$begin_debug_html .= processModule($value);
                                #<MAX> 20030324 -> disable IF
                                }elsif($name =~ m/^disable_if$/o){
					$Gdisable_if = toBool($value);
                                #<MAX> 20030324 -> disable RANDOM
                                }elsif($name =~ m/^disable_random$/o){
					$Gdisable_random = toBool($value);
                                #<MAX> 20030528 -> disable cookies
                                }elsif($name =~ m/^disable_cookies$/o){
					$Gdisable_cookies = toBool($value);
                                #<MAX> 20030528 -> server ID
                                }elsif($name =~ m/^server_id$/o){
					$Gserver_id = $value;
				}else{
					warn sprintf('getConfiguration(): warning: invalid name "%s" in configuration file "%s" line #%d "%s" - expected "name=value"', $name, $config_file_name, $line_num, $orig_line);
				} # if

			} # if ... not a comment

		} # while

		close(C);

		defined($Gbase_page_dir) || die sprintf('getConfiguration(): error: "base_page_dir" not defined in configuration file "%s"', $config_file_name);

                if(! -d $Gbase_page_dir){
                        $Gbase_page_dir =~ s|.*/||;
			die sprintf('getConfiguration(): error: base page appname03ory "%s" from configuration file "%s" is not a appname03ory', $Gbase_page_dir, $config_file_name);
		} # if
		
		if(! (-r $Gbase_page_dir && -x $Gbase_page_dir)){
                        $Gbase_page_dir =~ s|.*/||;
			die sprintf('getConfiguration(): error: base page appname03ory "%s" from configuration file "%s" is not read/execute', $Gbase_page_dir, $config_file_name);
		} # if

		$Gbase_page_dir =~ s:/$::o; # strip trailing '/'
		
		defined($Gbase_data_dir) || die sprintf('getConfiguration(): error: "base_data_dir" not defined in configuration file "%s"', $config_file_name);

		if(! -d $Gbase_data_dir){
                        $Gbase_data_dir =~ s|.*/||;
			die sprintf('getConfiguration(): error: base data appname03ory "%s" from configuration file "%s" is not a appname03ory', $Gbase_data_dir, $config_file_name);
		} # if
		
		if(! (-r $Gbase_data_dir && -x $Gbase_data_dir)){
                        $Gbase_data_dir =~ s|.*/||;
			die sprintf('getConfiguration(): error: base data appname03ory "%s" from configuration file "%s" is not read/execute', $Gbase_data_dir, $config_file_name);
		} # if

		$Gbase_data_dir =~ s:/$::o; # strip trailing '/'

		defined($Gcache_max_entry) || die sprintf('getConfiguration(): error: "cache_max_entry" not defined in configuration file "%s"', $config_file_name);
		($Gcache_max_entry >= 0) || die sprintf('getConfiguration(): error: "cache_max_entry" has invalid value "%s" in configuration file "%s"', $Gcache_max_entry, $config_file_name);

		defined($GCGI_cipher_key) || die sprintf('getConfiguration(): error: "CGI_cipher_key" not defined in configuration file "%s"', $config_file_name);

		# HTML::Template include path

		push(@default_include_path, $Gbase_page_dir);
		my $p = $ENV{'DOCUMENT_ROOT'}; # Apache
		if(defined($p) && $p ne ''){
			push(@default_include_path, $p);
		} # if
		$p = $ENV{'PATH_TRANSLATED'}; # IIS
		if(defined($p) && $p ne ''){
			$p =~ s:\/[^/]*$::;
			$p =~ s:\\[^\\]*$::;
			push(@default_include_path, $p);
		} # if

		$begin_debug_html .= sprintf("<!-- DEBUG: CONFIG: base_page_dir '%s' base_data_dir '%s' data_delimiter '%s' cache_max_entry %s default_include_path '%s' debug_collapse %d debug_output %d debug_xml %d never_serialize %d never_collapse %d output_doctype %d -->\n", $Gbase_page_dir, $Gbase_data_dir, $Gdata_delimiter, $Gcache_max_entry, join(':', @default_include_path), $Gdebug_collapse, $Gdebug_output, $Gdebug_xml, $Gnever_serialize, $Gnever_collapse, $Goutput_doctype);

                #<MAX> 20030324 -> re-arranged it to imrove visibility
                return (
                        $Gbase_page_dir,
                        $Gbase_data_dir,
                        $Gdata_delimiter,
                        $Gcache_max_entry,
                        $GCGI_cipher_key,
                        $Gdebug_collapse,
                        $Gdebug_output,
                        $Gdebug_xml,
                        $Gnever_serialize,
                        $Gnever_collapse,
                        $Goutput_doctype,
                        $Gdisable_if,      #<MAX> 20030324 -> disable IF: $Gdisable_if added
                        $Gdisable_random,  #<MAX> 20030324 -> disable RANDOM: $Gdisable_random added
                        $Gdisable_cookies, #<MAX> 20030528 -> disable cookies: $Gdisable_cookies added
                        $Gserver_id,       #<MAX> 20030528 -> server ID: $Gserver_id added
                       );

	} # getConfiguration()

} # BEGIN

$debug_html = $begin_debug_html; # HTML debug output, initialize before first use in BEGIN {}
$begin_debug_html = ''; # HTML debug output, initialize before first use in BEGIN {}


# main() - it all starts (and ends) here.

# Per invocation initialization.

$is_http_headers_output = $false;

$debug_html .= sprintf("<!-- DEBUG: CONFIG: version '%s' XML::DOM version '%s' running since '%s' this request '%s' PID %d -->\n", $version,  $XML::DOM::VERSION, $start, scalar(localtime(time())), $$);

# - Cached state

$xmlState = undef; # instance of appname05XMLState
$doc = undef; # XML::DOM document root

# - Uncached state

undef %cookie; # cookie data
%cookie = ();
undef %form; # form data
%form = ();
$parser = undef; # XML::DOM::Parser
$is_assert = undef; # error checking
$debug_collapse = undef; # debug output
$debug_output = undef; # debug output
$debug_xml = undef; # debug output
$is_output = undef; # HTML output
$output_html = ''; # HTML output

#<MAX> 20030324 -> disable IF/ELSEIF/ELSE logic
$disable_if = undef;

#<MAX> 20030324 -> disable RANDOM logic
$disable_random = undef;

#<MAX> 20030528 -> disable cookies
$disable_cookies = undef;

#<MAX> 20030528 -> server ID
$server_id = undef;

# Must free these when finished.
# We need %collapseNodeRef parallel hash to save the XML node references,
# because using the reference as a key to a hash converts the
# reference to a string.

%collapseNode = (); # list of nodes that can be collapsed into a <![CDATA[...]]>
%collapseNodeRef = (); # list of nodes that can be collapsed into a <![CDATA[...]]>
%variableIsSeen = (); # list of form variables seen so far

# Parse CGI form data.

parse_form_data();

# Variables seen so far.

if(defined($form{'varseen'})){
	my @varseen = StringToArray(-string => $form{'varseen'});
	for my $var (@varseen){
		$variableIsSeen{$var} = 1;
	} # for
} # if

for my $k (sort(keys(%form))) {
	my $isSeen = $variableIsSeen{$k};
	if(!defined($isSeen)){
		$isSeen = $false;
	} # if
	if(defined($form{$k})){
		$debug_html .= sprintf("<!-- DEBUG: START: form variable '%s' = '%s', %sseen -->\n", $k, $form{$k}, $isSeen ? '' : 'not ');
	}else{
		$debug_html .= sprintf("<!-- DEBUG: START: form variable '%s' = '%s', %sseen -->\n", $k, '[NOT DEFINED]', $isSeen ? '' : 'not ');
	} # if
	$variableIsSeen{$k} = 1;
} # for

# Parse CGI cookie data and map into form variables.

#<MAX> 20030528 -> disable cookies can be set as a form variable
$disable_cookies = defined($form{'disable_cookies'}) ? toBool($form{'disable_cookies'}) : $config_disable_cookies; 

#<MAX> 20030528 -> only, if the cookies are enabled
unless ($disable_cookies) {
    %cookie = get_cookies();
}

# Map environment variables into form variables

get_env();
for my $k (sort(keys(%ENV))) {
	my $v = $ENV{$k};
	$v =~ s/[\r\n]/ /g;
	$debug_html .= sprintf("<!-- DEBUG: START: env '%s' = '%s' -->\n", $k, $v);
} # for


for my $k (sort(keys(%cookie))) {
	$debug_html .= sprintf("<!-- DEBUG: START: cookie '%s' = '%s' -->\n", $k, $cookie{$k});
} # for

if(!defined($form{'appname05'})){
	mydie('error: CGI variable \'appname05\' not defined');
} # if

# Extract form variables.

$is_assert = defined($form{'assert'}) ? toBool($form{'assert'}) : $false;
$is_output = defined($form{'output'}) ? toBool($form{'output'}) : $true;
$debug_collapse = defined($form{'debug_collapse'}) ? toBool($form{'debug_collapse'}) : $config_debug_collapse; 
$debug_output = defined($form{'debug_output'}) ? toBool($form{'debug_output'}) : $config_debug_output; 
$debug_xml = defined($form{'debug_xml'}) ? toBool($form{'debug_xml'}) : $config_debug_xml; 
$output_doctype = defined($form{'output_doctype'}) ? toBool($form{'output_doctype'}) : $config_output_doctype; 

#<MAX> 20030324 -> disable IF can be set as a form variable
$disable_if = defined($form{'disable_if'}) ? toBool($form{'disable_if'}) : $config_disable_if; 

#<MAX> 20030324 -> disable RANDOM can be set as a form variable
$disable_random = defined($form{'disable_random'}) ? toBool($form{'disable_random'}) : $config_disable_random; 

#<MAX> 20030528 -> server_id can be set as a form variable. Default is 0
$server_id = defined($form{'server_id'}) ? $form{'server_id'} : (defined($config_server_id) ? $config_server_id: 0); 

$form{'appname05'} = untaint($form{'appname05'});

$appname05_page_dir = $base_page_dir . '/' . $form{'appname05'} ; # appname05 page appname03ory
if(! (-r $appname05_page_dir && -x $appname05_page_dir)){
	$appname05_page_dir =~ s|.*/||;
	mydie(sprintf('error: appname05 page appname03ory "%s" is not read/execute', $appname05_page_dir));
} # if

# Only check 'pages' when 'page' is not defined.

$page = undef;
if(defined($form{'page'})){
	$page = untaint($form{'page'});
} # if ... page defined

# If 'page' not defined then check for list of random 'pages'.

if((!defined($page) || $page eq '') && defined($form{'pages'})){

	my @pages = StringToArray(-string => $form{'pages'});

	(scalar(@pages) > 0) || mydie(sprintf('error: CGI variable \'pages\' has invalid format "%s"', $form{'pages'}));

	# Pick a page at random.

	my $i = int(rand(scalar(@pages))); # random in [0 .. $#pages]
	$page = $pages[$i];

	# Delete that page from the list.

	splice(@pages, $i, 1);

	# Update the form variable, it will be passed along.

	$form{'pages'} = ArrayToString(-array => \@pages);
	
} # if ... random page list

# If 'page' defined, pull it out of cache or parse and process it.

if(defined($page) && $page ne ''){
        
        # output a simplified LOG record here before we even read a page
        outputLogRec();
        
        srand(); # seed random number generator

	$page_file_name = $appname05_page_dir . '/' . $page;

	# Serialized parsed XML file is stored in the data appname03ory with the same name as the XML file
	# with a .ser extension.

	my $base = $page;
	# strip off the extension, if any
	$base =~ s/\..*$//;
	$base .= '.ser';
	my $appname05_data_dir = $base_data_dir . '/' . $form{'appname05'}; # appname05 data appname03ory
	my $serialized_parsed_xml_file_name = $appname05_data_dir . '/' . $base;

	# Check for $page_file_name in cache.
	# If it's there then use it, don't do XML::DOM::Parser
	# If it's not there the run it thru XML::DOM:Parser and store it in cache.

	($doc, $xmlState) = cacheGet($page_file_name, $serialized_parsed_xml_file_name);

	my $root;
	if(!defined($doc)){

		# Cache miss.

                unless (open(XML, $page_file_name)) {
                    $page_file_name =~ s|.*/||;
                    mydie(sprintf('error: can\'t open XML file "%s" - "%s"', $page_file_name, $!));
                }
		my @xml = <XML>;
		close(XML);
		my $xml = join('', @xml);

		# Now run it thru HTML::Template for include processing and other indignities.
		# Really only want to include files, use the XML tags for other features such as IF etc.
		# Note that for cached XML pages, if an underlying include file changes,
		# the XML file itself must be touched to cause the XML page to be reprocessed.

		eval {
			# Ignore die() & warn() in eval		
			local $SIG{__DIE__} = sub { ; } ; 
			local $SIG{__WARN__} = sub { ; } ;

			my $t = new HTML::Template(
				scalarref => \$xml,
				path => [ $appname05_page_dir, @default_include_path ], # search current appname05 page dir as well
				filepath => [ $appname05_page_dir, @default_include_path ], # bug in HTML::Template, get unintialized variable message if not same as path
				search_path_on_include => $true,
				debug => $false,
				strict => $false,
			);
			
			$xml = $t->output(); # XML with include processing

		};

                if (defined($@) && $@ ne '') {
                    $page_file_name =~ s|.*/||;
                    mydie(sprintf('error: HTML::Template error "%s" for XML file "%s"', $@, $page_file_name));
                }

		$parser = new XML::DOM::Parser(
		 ErrorContext => 2, # 2 lines of context around error line
		 KeepCDATA => 0, # do not keep CDATA, convert to text
		);

		# write XML out to file to avoid XML::DOM::parse() memory leak on NT.

		my $base = $page;
		# strip off the extension, if any
		$base =~ s/\..*$//;
		$base .= '.tmpxml';
		my $temp_xml_file_name = $appname05_data_dir . '/' . $base;
                unless (open(T, ">$temp_xml_file_name")) {
                    $temp_xml_file_name =~ s|.*/||;
                    mydie(sprintf('error: can\'t open temp XML file "%s" for write - "%s"', $temp_xml_file_name, $!));
                }
		print T $xml;
		close(T);

		eval {
			# Ignore die() & warn() in eval		
			local $SIG{__DIE__} = sub { ; } ; 
			local $SIG{__WARN__} = sub { ; } ;
			#$doc = $parser->parse($xml);
			$doc = $parser->parsefile($temp_xml_file_name);
		};
		#(!defined($doc)) && mydie(sprintf('error: XML::DOM::Parser error "%s" for XML file "%s"', $@, $page_file_name));
                if (!defined($doc) || (defined( $@ ) && $@ ne '')) {
                    $page_file_name =~ s|.*/||;
                    mydie(sprintf('error: XML::DOM::Parser error "%s" for XML file "%s"', $@, $page_file_name));
                }

		$xml = undef;

		$root = $doc->getDocumentElement();

		$xmlState = new appname05XMLState; # parsed XML document state

		# parse XML doc.

		processNode(
		 -node => $root,
		 -level => 0,
		 -is_collapse => $never_collapse ? $false : $true,
		);

		my $nbefore = numberNode(-node => $root);

		# Collapse non appname05site nodes into single <![CDATA[...]]>

		if(! $never_collapse){
			collapseNodes(
			 -root => $root,
			);
		} # if

		my $nafter = numberNode(-node => $root);

		# Cache the parsed XML page.

                if($never_serialize){
			cacheSet($page_file_name, '', $doc, $xmlState);
                }else{
			cacheSet($page_file_name, $serialized_parsed_xml_file_name, $doc, $xmlState);
                } # if

	}else{
		# Cache hit.

		$root = $doc->getDocumentElement();

	} # if ... parsed XML page not in cache

	# Mark form variables as exported.

	for my $key (sort(keys(%form))) {
		$xmlState->variableIsExported($key, $true);
		$xmlState->outputFormVariable($key, $true); # output 
	} # for ... each form variable

	# Figure out our session ID, if we don't have one then assign one.
	# First check for a session ID cookie, then look for a hidden variable.

	$sessionID = decode_sessionID($cookie{'sessionID'});
	if(!defined($sessionID) || $sessionID eq ''){

		# No session ID cookie, try form variable.

		$debug_html .= sprintf("<!-- DEBUG: SESSIONID: no sessionID cookie -->\n");

		$sessionID = decode_sessionID($form{'sessionID'});

		if(!defined($sessionID) || $sessionID eq ''){

			# No session ID form variable, create one.

			$debug_html .= sprintf("<!-- DEBUG: SESSIONID: no sessionID form variable -->\n");

			$sessionID = new_sessionID();

			$debug_html .= sprintf("<!-- DEBUG: SESSIONID: assign new sessionID='%s' -->\n", $sessionID);

		} # if ... no sessionID form variable
                
                #<MAX> 20030528 -> if cookies are enabled
                unless ($disable_cookies) {
                    $cookie{'sessionID'} = encode_sessionID($sessionID);
                }

	} # if ... no sessionID cookie

	# Save the sessionID cookie as a form variable.

        #<MAX> 20030528 -> if cookies are enabled
        unless ($disable_cookies) {
            $form{'sessionID'} = encode_url($cookie{'sessionID'});
        } else {
            $form{'sessionID'} = encode_url(encode_sessionID($sessionID));
        }
	$xmlState->outputFormVariable('sessionID', $true); # output 
	$xmlState->variableIsExported('sessionID', $true); # exported
	$debug_html .= sprintf("<!-- DEBUG: SESSIONID: sessionID='%s' -->\n", $sessionID);

	outputInit();

	# Output appname05 results before state change.

	outputappname05();

	# Output log results before state change.

	outputLog();

	# Perform <RANDOM> selection, <IF> processing etc.
	# Output HTML.

	outputNode(
	 -node => $root,
	);

	# Output final HTML including DEBUG comments.

	outputFin();

	# $doc stored in cache, don't dispose of here,
        # dispose of in cache update, unless caching is disabled

        if($cache_max_entry <= 0){
                $xmlState->dispose(); # call before $doc->dispose();
                $doc->dispose();
        } # if ... cache disabled


}else{
	mydie('error: CGI variable \'page\' not defined');
} # if

# exit here

exit(0); 

# mydie - 

sub mydie {
	my($message) = @_;

	# filter out XML::DOM::Parser messages.

	if($message !~ m/Can't use string/i){
		$debug_html .= sprintf("<!-- ERROR: %s -->\n", $message);
		browser_message($message);
		exit(1);
	} # if

} # mydie()

# browser_message - send error message to browser

sub browser_message {
	my($message) = @_;

	#printf("HTTP/1.1 200 OK\n");
	if(!$is_http_headers_output){
		printf("Content-Type: text/html\n");
		#printf("Pragma: no-cache\n");
		#printf("Cache-Control: no-cache\n");
		printf("\n");
		$is_http_headers_output = $true;
	} # if
	my $m = html_escape($message);
	print "<html><head><title>Error</title></head><body><pre>$m</pre></body>";

	if($debug_output){
		print "\n";
		print $debug_html;
	} # if ... output debug HTML

	print "</html>\n";

} # browser_message()

# html_escape - escape illegal HTML characters

sub html_escape {
	my($h) = @_;

	$h =~ s/</\&lt;/g;
	$h =~ s/>/\&gt;/g;

	return $h;

} # html_escape()

# untaint() - strip dangerous characters out of path names

sub untaint {

	my($name) = @_;

	$name =~ s#^[./\\:]*##o; # strip leading '.', '/', etc so "../../../x" -> "x"

	return $name;

} # untaint()

# numberNode() - return number of nodes in tree

sub numberNode {
	my(%args) = @_;
	my($node) = $args{-node};

	my $n = 1; # count self

	for my $kid ($node->getChildNodes()) {

		$n += numberNode(-node => $kid);

	} # for ... each child

	return $n;

} # numberNode()

# processNode() - recursively process the document nodes.

sub processNode {
	my(%args) = @_;
	my($node) = $args{-node};
	my($level) = $args{-level};
	my($is_collapse) = $args{-is_collapse};


	processThisNode(
	 -node => $node,
	);

	my @kids = $node->getChildNodes();

	if($is_collapse && scalar(@kids) == 0){

		# No children, at end of branch, search down for first
		# <R>, <IF> , etc. and collapse into single <![CDATA[...]]>

		collapseNodeFind(
		 -node => $node,
		);

	}else{
	
		for my $kid (@kids) {

			processNode(
			 -node => $kid, 
			 -level => $level + 1,
			 -is_collapse => $is_collapse,
			);

		} # for

	} # if ... child nodes

} # processNode()

# processThisNode() - process one document node.

sub processThisNode {
	my(%args) = @_;
	my($node) = $args{-node};

	my $nodeType = $node->getNodeType();

	if($nodeType == ELEMENT_NODE){

		my $elementName = $node->getNodeName();

		if($elementName =~ m/^IF$/oi){

			processIfElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^ELSE$/oi){

			processElseElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^ELSEIF$/oi){

			processElseIfElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^RANDOM$/oi){

			processRandomElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^R$/oi){

			processRElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^SET$/oi){

			processSetElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^EXPORT$/oi){

			processExportElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^READ$/oi){

			processReadElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^WRITE$/oi){

			processWriteElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^PRINT$/oi){

			processPrintElement(
			 -node => $node,
			);

		}else{

			processOtherElement(
			 -node => $node,
			 -name => $elementName,
			);

		} # if ... element name

	}elsif($nodeType == TEXT_NODE){
		processText(
			 -node => $node,
		);
	}elsif($nodeType == CDATA_SECTION_NODE){
		processCDATA(
			 -node => $node,
		);
	}elsif($nodeType == DOCUMENT_TYPE_NODE){
		processDocumentType(
			 -node => $node,
		);
	}elsif($nodeType == COMMENT_NODE){
		processComment(
			 -node => $node,
		);
	}else{
		processOtherNode(
			 -node => $node,
		);
	} # if ... node type

} # processThisNode()

# processDocumentTypeNode() -

sub processDocumentTypeNode {
	my(%args) = @_;
	my($node) = $args{-node};

	$xmlState->elementIsPresent('doctype', $true);
	$is_debug && printf STDERR ("processDocumentTypeNode(): got '%s' node\n", $node->getNodeTypeName());

} # processDocumentTypeNode()

# processOtherNode() -

sub processOtherNode {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie(sprintf("error: processOtherNode(): '%s' node already processed - internal error", $node->getNodeTypeName()));
	} # if

	# Initialize processing state 

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);
	$xmlState->elementIsPresent($node->getNodeTypeName(), 1);

} # processOtherNode()

# processIfElement() - process <IF cond="<relational expression>">

sub processIfElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processIfElement(): <IF> tag already processed - internal error");
	} # if

	($node->hasChildNodes()) || mydie(sprintf('error: processIfElement(): "%s" node must not be self nesting', '<IF>'));

	# <IF> must have a "cond" attribtue.

	my $cond = $node->getAttribute('cond');

	(!defined($cond) || $cond eq '') && mydie('error: processIfElement(): <IF> tag must have a "cond" attribute');

	# Initialize processing state for <IF>, updated by <ELSE/> and <ELSEIF/>

	$xmlState->cond($node, $cond);
	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

} # processIfElement()

# processElseElement() -

sub processElseElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processElseElement(): <ELSE> tag already processed - internal error");
	} # if

	($node->hasChildNodes()) && mydie(sprintf('error: processElseElement(): "%s" node must be self nesting', '<ELSE>'));
	# <ELSE> must NOT have a "cond" attribtue.

	my $cond = $node->getAttribute('cond');

	(defined($cond) && $cond ne '') && mydie('error: processElseElement(): <ELSE> tag must NOT have a "cond" attribute');

	# Initialize processing state for <ELSEIF>

	$xmlState->cond($node, $cond);
	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

	# Find parent <IF> at same level.

	my $ifElement = findParentElement(
	 -node => $node,
	 -elementName => '^IF$',
	 -level => 1,
	);

	defined($ifElement) || mydie('error: processElseElement(): <ELSE> has no parent <IF>');

} # processElseElement()

# processElseIfElement() -

sub processElseIfElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processElseIfElement(): <ELSEIF> tag already processed - internal error");
	} # if

	($node->hasChildNodes()) && mydie(sprintf('error: processElseIfElement(): "%s" node must be self nesting', '<ELSEIF>'));

	# <ELSEIF> must have a "cond" attribtue.

	my $cond = $node->getAttribute('cond');

	(!defined($cond) || $cond eq '') && mydie('error: processElseIfElement(): <ELSEIF> tag must have a "cond" attribute');

	# Initialize processing state for <ELSEIF

	$xmlState->cond($node, $cond);
	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

	# Find parent <IF>

	my $ifElement = findParentElement(
	 -node => $node,
	 -elementName => '^IF$',
	 -level => 1,
	);
	
	(defined($ifElement)) || mydie(sprintf('error: processElseIfElement(): <ELSEIF cond="%s"> has no parent <IF>', $cond));

} # processElseIfElement()

# processSetElement() - process <SET name="<variable name>" value="<expression>">

sub processSetElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processSetElement(): <SET> tag already processed - internal error");
	} # if

	($node->hasChildNodes()) && mydie(sprintf('error: processSetElement(): "%s" node must be self nesting', '<SET>'));

	# <SET> must have a "name" and "value" attribtues.

	my $name = $node->getAttribute('name');
	(!defined($name) || $name eq '') && mydie('error: processSetElement(): <SET> tag must have a "name" attribute');

	my $value = $node->getAttribute('value');
	# Allow variable to be set to ''
	(!defined($value)) && mydie('error: processSetElement(): <SET> tag must have a "value" attribute');

	# Initialize processing state for <SET>

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

} # processSetElement()

# processExportElement() - process <EXPORT name="<variable name>" [ value="yes|no" ]>

sub processExportElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processExportElement(): <EXPORT> tag already processed - internal error");
	} # if

	($node->hasChildNodes()) && mydie(sprintf('error: processExportElement(): "%s" node must be self nesting', '<EXPORT>'));

	# <EXPORT> must have a "name".

	my $name = $node->getAttribute('name');
	(!defined($name) || $name eq '') && mydie('error: processExportElement(): <EXPORT> tag must have a "name" attribute');

	# Initialize processing state for <EXPORT>

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

} # processExportElement()

# processReadElement() - process <READ name="variable" file="filename" lock="yes"/> 

sub processReadElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processReadElement(): <READ> tag already processed - internal error");
	} # if

	($node->hasChildNodes()) && mydie(sprintf('error: processReadElement(): "%s" node must be self nesting', '<READ>'));

	# <READ> must have a "name" & "file" attributes.

	my $name = $node->getAttribute('name');
	(!defined($name) || $name eq '') && mydie('error: processReadElement(): <READ> tag must have a "name" attribute');

	my $file = $node->getAttribute('file');
	(!defined($file) || $file eq '') && mydie('error: processReadElement(): <READ> tag must have a "file" attribute');

	# Initialize processing state for <READ>

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

} # processReadElement()

# processWriteElement() - process <WRITE name="variable" file="filename" unlock="yes" mode="append|truncate"/> 

sub processWriteElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processWriteElement(): <WRITE> tag already processed - internal error");
	} # if

	($node->hasChildNodes()) && mydie(sprintf('error: processWriteElement(): "%s" node must be self nesting', '<WRITE>'));

	# <WRITE> must have a "name" & "file" attributes.

	my $name = $node->getAttribute('name');
	(!defined($name) || $name eq '') && mydie('error: processWriteElement(): <WRITE> tag must have a "name" attribute');

	my $file = $node->getAttribute('file');
	(!defined($file) || $file eq '') && mydie('error: processWriteElement(): <WRITE> tag must have a "file" attribute');

	# Initialize processing state for <WRITE>

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

} # processWriteElement()

# processPrintElement() - process <PRINT output="<printf expression>" >

sub processPrintElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processPrintElement(): <PRINT> tag already processed - internal error");
	} # if

	($node->hasChildNodes()) && mydie(sprintf('error: processPrintElement(): "%s" node must be self nesting', '<PRINT>'));

	# <PRINT> must have "output".

	my $output = $node->getAttribute('output');
	(!defined($output) || $output eq '') && mydie('error: processPrintElement(): <PRINT> tag must have an "output" attribute');

	# Initialize processing state for <PRINT>

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

} # processPrintElement()

# processText() - process text

sub processText {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processText(): text already processed - internal error");
	} # if

	# Initialize processing state 

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

} # processText()

# processCDATA() - process CDATA

sub processCDATA {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processCDATA(): CDATA already processed - internal error");
	} # if

	# Initialize processing state 

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

} # processCDATA()

# processComment() - process Comment

sub processComment {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processComment(): Comment already processed - internal error");
	} # if

	# Initialize processing state 

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

} # processComment()

# processRandomElement() - process <RANDOM name=<unique name> [ use=<number of <R> elements to display> ]>

sub processRandomElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie("error: processRandomElement(): <RANDOM> tag already processed - internal error");
	} # if

	# <RANDOM> must have a "name" attribtue.

	my $name = $node->getAttribute('name');

	(!defined($name) || $name eq '') && mydie('error: processRandomElement(): <RANDOM> tag must have a "name" attribute');
	#(defined($xmlState->randomName($name))) && mydie(sprintf('processRandomElement(): <RANDOM> tag "name" attribute "%s" not unique', $name));

	# <RANDOM> "use" attribtue defines how many of the child <R> elements to display.

	my $use = $node->getAttribute('use');

	if(!defined($use) || $use eq ''){

		$use = 0; # default to all

	} # if ... not specified how many <R> elements to display

	$xmlState->randomName($name, $true);

	# The random list order may already be set via a CGI form variable.
	# Otherwise we don't now how many <R> child elements there are so defer 
	# setting the random order list until this is known.

	my @random_order = ( );

	# Initialize processing state for <RANDOM>, updated by <R>

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);
	$xmlState->name($node, $name);
	$xmlState->num($node, 0);
	$xmlState->randomOrder($node, [ @random_order ]);
	$xmlState->use($node, $use);

} # processRandomElement()

# processRElement - process <R> element, must be nested in <RANDOM> element.

sub processRElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie('error: processRElement(): <R> tag already processed - internal error');
	} # if

	# Initialize processing state for <R>, updated by <RANDOM>

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

	# Find parent <RANDOM>, must be appname03 parent.

	my $randomElement = findParentElement(
	 -node => $node,
	 -elementName => '^RANDOM$',
	 -level => 1,
	);
	
	if(!defined($randomElement)){

		my $error_message = "error: processRElement(): <R> tag immediate child of <RANDOM>...</RANDOM>\n",

		# Find parent;

		my $parent = $node->getParentNode();
		if(defined($parent)){
			$error_message .= "parent tag is:\n\n";
			$error_message .= $parent->toString();
			$error_message .= "\n\n";
		} # if

		# Find closest <RANDOM>

		$randomElement = findParentElement(
		 -node => $node,
		 -elementName => '^RANDOM$',
		);
		if(defined($randomElement)){
			$error_message .= "closest surrounding <RANDOM> is:\n\n";
			$error_message .= $randomElement->toString();
		} # if

		mydie($error_message);
	}else{

		if($is_assert){
			(!defined($xmlState->isOutput($randomElement))) && mydie('error: processRElement(): <R> parent <RANDOM> not processed - internal error');
		} # if

		$xmlState->num($randomElement, $xmlState->num($randomElement) + 1);

		#printf STDERR ("processRElement(): <RANDOM> '%s' now has %d <R> tags\n", $xmlState->name($randomElement), $xmlState->num($randomElement));

	} # if ... <R> nested in <RANDOM>
	
} # processRElement()

# processOtherElement() - process any type of element we don't care about

sub processOtherElement {
	my(%args) = @_;
	my($node) = $args{-node};
	my($name) = $args{-name};

	if($is_assert){
		(defined($xmlState->isOutput($node))) && mydie(sprintf('error: processOtherElement(): "%s" node already processed - internal error', $name));
	} # if

	if($name =~ m/^input$/oi){

		($node->hasChildNodes()) && mydie(sprintf('error: processOtherElement(): "%s" node must be self nesting', $name));
		my $type = $node->getAttribute('type');
		(!defined($type) || $type eq '') && ($type = $node->getAttribute('TYPE'));
		(!defined($type)) && mydie(sprintf('error: processOtherElement(): "%s" node must have "type" attribute"', $name));
		my $var = $node->getAttribute('name');
		(!defined($var) || $var eq '') && ($var = $node->getAttribute('NAME'));
		(!defined($var)) && mydie(sprintf('error: processOtherElement(): "%s" node must have "name" attribute"', $name));

	} # if ... <INPUT> 

	# Initialize processing state 

	$xmlState->isOutput($node, $false);
	$xmlState->isSelected($node, $true);

	# Record interesting elements
	
	my $name_lower = $name;
	$name_lower =~ tr/[A-Z]/[a-z]/;
	$xmlState->elementIsPresent($name_lower, $true);

} # processOtherElement()

# collapseNodes() - run thru the %collapseNode hash and collapse adjacent non appname05site nodes
#  into <![CDATA[...]]> nodes.

sub collapseNodes {
	my(%args) = @_;
	my($root) = $args{-root};

	# Replace collapsable nodes with <![CDATA[...]]>

	for my $node (values(%collapseNodeRef)) {

		my $type = $collapseNode{$node};
		#printf STDERR ("collapseNodes(): node %s '%s' type '%s'\n", $node, $node->getNodeName(), $type);
		if($type eq $collapseNodeStateCollapse && $node->hasChildNodes() && $node != $doc){

			# Convert the node(s) to be collapsed to a string
			# and stick it in a <![CDATA[...]]>

			my $orig = $node->toString();

			# delete nested CDATA

			$orig =~ s/<!\[CDATA\[//ig; # @@@ multi-line ?
			$orig =~ s/\]\]>//ig; # @@@ multi-line ?

			$orig =~ s/\&amp;/\&/ig; # @@@ multi-line ?

			# <br/> to <br> for IE & Netscape

			$orig =~ s:<br/>:<br>:ig; # @@@ multi-line ?

			my $cdata = new XML::DOM::CDATASection;
			$cdata->setOwnerDocument($doc);
			$cdata->setData($orig);
			$xmlState->isOutput($cdata, $xmlState->isOutput($node));
			$xmlState->isSelected($cdata, $xmlState->isSelected($node));

			# Replace the old node(s) with the collapsed node(s).

			my $parent = $node->getParentNode();
			my $old = $parent->replaceChild($cdata, $node);
			disposeXMLState($old); # call before $old->dispose();
			$old->dispose();

			#printf STDERR ("collapseNodes(): replaced '%s' with '%s'\n", $orig, $cdata->toString());
		} # if

	} # for ... each node in XML document

	# Finished, free the %collapseNode hash

	%collapseNode = ();

	# Run thru the XML tree, flatten adjacent child <![CDATA[...]]> nodes into one.

	flattenNode(
	 -node => $root
	);

} # collapseNodes()

# disposeXMLState() - recursively delete xmlState for node

sub disposeXMLState {
	my($node) = @_;

	for my $kid ($node->getChildNodes()) {

		disposeXMLState($kid);

	} # for

	$xmlState->dispose($node);

} # disposeXMLState()

# createXMLStateFromXMLPage() - create XMLState from XML DOM tree

sub createXMLStateFromXMLPage {
	my($XMLPageRef) = @_;

	# Set the global XML state variable.

	$xmlState = new appname05XMLState; # parsed XML document state

	# Run thru the XML tree, setting the XMLState.
	# Since the tree has already been collapsed, don't do it again.

	processNode(
	 -node => $XMLPageRef,
	 -level => 0,
	 -is_collapse => $false,
	);

	return $xmlState;

} # createXMLStateFromXMLPage()

# flattenNode() - flatten adjacent child <![CDATA[...]]> and text nodes into one.

sub flattenNode {
	my(%args) = @_;
	my($node) = $args{-node};

	my @kids = $node->getChildNodes();
	my $is_deleted = $false;

	if(scalar(@kids) > 1){

		my $prev = undef; # previous CDATA in child list
		my $num_cdata = 0; # number consecutive CDATA in child list

		push(@kids, $doc); # magic end of array node of type DOCUMENT_NODE to handle run that goes to last child node

		for my $kid (@kids) {

			# @@@ what about other non-appname05site tags ?
			# @@@ no, can't do it as may be a <table> etc. tag that contains an <IF>, <input> etc.
			my $nodeType = $kid->getNodeType();
			if($nodeType == CDATA_SECTION_NODE || $nodeType == TEXT_NODE || $nodeType == COMMENT_NODE){

				$num_cdata += 1;
				if(!defined($prev)){
					$prev = $kid; # first CDATA in potential run
					#printf STDERR ("flattenNode(): node %s: start run @ %s\n", $node, $prev);
				} # if

			}else{

				if(defined($prev)){

					if($num_cdata > 1){

						#printf STDERR ("flattenNode(): node %s: end run @ %s length %d\n", $node,$kid, $num_cdata);
						my $cdata = new XML::DOM::CDATASection;
						$cdata->setOwnerDocument($doc);
						$cdata->setData('');
						$xmlState->isOutput($cdata, $xmlState->isOutput($prev)); # use state from first node of run
						$xmlState->isSelected($cdata, $xmlState->isSelected($prev));

						my @remove_list = (); # list of nodes to remove
						my $run;
						for($run = $prev; (defined($run)) && $run != $kid; $run = $run->getNextSibling()){
							#printf STDERR ("flattenNode(): node %s: append text '%s'\n", $node, $run->getData());
							my $data = $run->getData(); 
							if($run->getNodeType() == COMMENT_NODE){
								$data = '<!--' . $data . '-->';
							} # if ... comment
							$cdata->appendData($data); # append text

							if($run != $prev){
								 #$xmlState->isSelected($run, 0); # don't output from 2nd on of run
								push(@remove_list, $run);
							} # if ... not node being replaced

						} # for ... consecutive CDATA nodes

						# replace first node of run with flattened CDATA.
						# other nodes in run are marked as not selected.
						
						my $old = $node->replaceChild($cdata, $prev);
						disposeXMLState($old); # call before $old->dispose();
						$old->dispose();
						$is_deleted = $true;

						# Remove flattened nodes.
						
						for my $remove (@remove_list) {
							my $old = $node->removeChild($remove);
							disposeXMLState($old); # call before $old->dispose();
							$old->dispose();
						} # for ... each flattened node to remove

					}else{
						#printf STDERR ("flattenNode(): node %s: degenerate run @ %s length %d\n", $node,$kid, $num_cdata);
					} # if ... more than 1 CDATA/text

					# Get ready for next CDATA run, if any

					$prev = undef;
					$num_cdata = 0;

				} # if ... CDATA run

			} # if

		} # for ... each child node


		if($is_deleted){
			@kids = $node->getChildNodes();
		}else{
			pop(@kids); # toast magic end of array node to handle run that goes to last child node
		} # if ... node(s) deleted

	} # if ... more than  1 child

	for my $kid (@kids) {

		flattenNode(
		 -node => $kid,
		);

	} # for ... each child node

} # flattenNode()

# collapseNodeFind() - starting at a leaf node, find the first parent <R>, <IF> or other "special"
# node. Mark the child of the special node as suitable for collapse.

sub collapseNodeFind {
	my(%args) = @_;
	my($node) = $args{-node};

	# List of nodes between this node and the document root.

	my @parents = findPathToRoot(
	 -node => $node,
	);

	#printf STDERR ("collapseNodeFind(): consider node %s '%s' has parents ", $node, $node->getNodeName());
	#for my $parent (reverse(@parents)) {
		#printf STDERR ("'%s' ", $parent->getNodeName());
	#} # for
	#printf STDERR ("#%d\n", scalar(@parents));

	#printf STDERR ("collapseNodeFind(): consider node %s '%s' has parents %s #%d\n", $node, $node->getNodeName(), join(',', @parents), scalar(@parents));

	# Run thru the list of path nodes, updateing the %collapseNode per node state.

	my $prev = undef; # remember the previous parent (child of the current parent)
	my $isFoundappname05Tag = $false; # seen a appname05Site tag yet ?

	for my $parent (reverse(@parents)) {

		if($isFoundappname05Tag || ($parent->getNodeName() =~ m/$appname05ElementTags/i)){
		
			# A appname05site tag, don't collapse.

			$collapseNode{$parent} = $collapseNodeStateNo;
			$collapseNodeRef{$parent} = $parent; # save node reference as value, gets trashed as key

			$isFoundappname05Tag = $true;
			#printf STDERR (" - collapseNodeFind(): node '%s' is appname05 tag '%s'\n", $parent->getNodeName(),  $collapseNode{$parent});

		}else{

			# A non appname05site tag, candidate for collapse.

			if(!defined($collapseNode{$parent})){
				$collapseNode{$parent} = $collapseNodeStateCollapse;
				$collapseNodeRef{$parent} = $parent;
				#printf STDERR (" - collapseNodeFind(): node '%s' is collapsed\n", $parent->getNodeName());
				if(defined($prev) && ($collapseNode{$prev} eq $collapseNodeStateCollapse)){
					#printf STDERR (" - collapseNodeFind(): prev collapseNode '%s' was state '%s' now '%s'\n", $prev->getNodeName(), $collapseNode{$prev}, $collapseNodeStateCollapsedByParent);
					$collapseNode{$prev} = $collapseNodeStateCollapsedByParent;
				} # if
			}else{
				#printf STDERR (" - collapseNodeFind(): node '%s' is already state '%s'\n", $parent->getNodeName(), $collapseNode{$parent});
			} # if

		} # if

		$prev = $parent;

	} # for ... each parent including self

} # collapseNodeFind()

# outputappname05() - output appname05 results

sub outputappname05 {

	# Only output the appname05 results if form variable 'submitanswers' 
	# is TRUE and there is at least 1 appname05 or text question.
	#
        my $return_code = 1;	
        

        if(
           defined($form{'submitanswers'}) && $form{'submitanswers'} ne '' 
           && $form{'submitanswers'} != 0 
           && ((defined($form{'numappname05'}) && $form{'numappname05'} > 0) || (defined($form{'numtext'}) && $form{'numtext'} > 0))
          ){
		my $data_file = get_data_file();

		$debug_html .= sprintf("<!-- DEBUG: OUTPUT: data file '%s' -->\n", $data_file);

        #<MAX> 20030716 -> use BekeleyDB as a queue for the appname05 results
        # write this info to the BerkeleyDB. Moved up here
        my $res = appname05Results();
        outputToBDB('rec_type' => 'dat', 'res' => $res);


           if (!defined($form{'status_flag'}) || (defined($form{'status_flag'}) && $form{'status_flag'} != 1))
          {


		if( ! -e $data_file  || ! -s $data_file ) {
			$return_code = 2;
	        }

                unless(open(D, ">>$data_file") || open(D, ">$data_file")) {
                    $data_file =~ s|.*/||;
                    mydie(sprintf('error: outputappname05(): can\'t open appname05 data file "%s" - "%s"', $data_file, $!));
                }

		my $oldfh = select(D); $| = 1; select($oldfh); # unbuffered output

		flock(D, LOCK_EX); # Exclusive lock, block till aquired

		# In case someone appended while we were waiting for the lock.

		seek(D, 0, SEEK_END);

		print D $res;

		flock(D, LOCK_UN); # release lock

		close(D);

		# Debug output.

		$res =~ s/[\r\n]//g;
		$res =~ s/-->//g;
                $debug_html .= sprintf("<!-- DEBUG: OUTPUT: numappname05 %d numtext %d result '%s' -->\n", $form{'numappname05'}, $form{'numtext'}, $res);
          } # Dat Line
	}else{

		my $sa = '<NOT DEFINED>';
		if(defined($form{'submitanswers'})){
			$sa = $form{'submitanswers'};
		} # if
		my $ns = '<NOT DEFINED>';
		if(defined($form{'numappname05'})){
			$ns = $form{'numappname05'};
		} # if
		my $nt = '<NOT DEFINED>';
		if(defined($form{'numtext'})){
			$nt = $form{'numtext'};
		} # if
	
		$debug_html .= sprintf("<!-- DEBUG: OUTPUT: no output: submitanswers '%s' numappname05 '%s' numtext '%s' -->\n", $sa, $ns, $nt);

	} # if ... submit appname05 answers

	# 1 If file existed.
	# 2 If new file.
	return $return_code ;

} # outputappname05()

# outputToBDB
sub outputToBDB
{
    my %args = @_;
    
    # start timer
    #my $timer = Benchmark::Timer->new();
    #$timer->start('read_time');
    
    # record type
    my $rec_type = $args{'rec_type'};
    # output result
    my $res      = $args{'res'};
    
    # hash to store in the BDB
    my %output;
    
    # "clean" %form
    my %output_form;
    
    # default REMOTE_ADDR to "0.0.0.0" in case it's not set
    my $remote_addr = "0.0.0.0";
    
    # clean out some redundant stuff from %form
    foreach my $key (keys %form) {
        # we don't need anything starting from
        # "cookie_" or "env_" except REMOTE_ADDR
        next if $key =~ /^cookie_/;
        
        # skip most of the "env_"
        if ($key =~ /^env_/) {
            # get the remote address
            if ($key =~ /^env_REMOTE_ADDR$/) {
                $remote_addr = $form{$key};
            }
            next;
        } # endif env_
        
        # grab the rest
        $output_form{$key} = $form{$key};
    
    } # foreach $key
    
    if ($rec_type eq "dat") {
        
        # different structure for "DAT"
        %output =
        (
         $rec_type =>
         {
             'line'        => $res,       #<MAX> 20030530 keep this for now
             'created'     => time(),
             'remote_addr' => $remote_addr,
             'session_id'  => $sessionID,
             'cgi_params'  => \%output_form,
             'server_id'   => (defined($form{'server_id'}) ? $form{'server_id'} : $server_id),
         },
        );
        
    } elsif ($rec_type eq "log") {
        
        # different structure for "LOG"
        %output =
        (
         $rec_type => $res,
        );
    
    } else {
        
        # invalid record type
        mydie(sprintf('error: outputToBDB(): invalid record type "%s"', $rec_type));
        
    } # endif $rec_type
    
    # serialize %output HASH
    my $serialized = Storable::freeze(\%output);
    
    # get the unique key
    #my $key = $bdb->get_next_id();
    my $key = uniqueid();
    
    if ($key) {
        
        if ($rec_type eq "dat") {
            # store the DAT record in the BDB
            my $rc = $bdb_dat->add_rec(
                                       {
                                           'key'   => $key,
                                           'value' => $serialized,
                                       }
                                      );
            # check the result
            unless ($rc) {
                # something really BAD happened
                mydie(sprintf('error: outputToBDB(): couldn\'t add DAT key "%s" to BDB', $key));
            } # unless $rc
        } elsif ($rec_type eq "log") {
            # store the LOG record in the BDB
            my $rc = $bdb_log->add_rec(
                                       {
                                           'key'   => $key,
                                           'value' => $serialized,
                                       }
                                      );
            # check the result
            unless ($rc) {
                # something really BAD happened
                mydie(sprintf('error: outputToBDB(): couldn\'t add LOG key "%s" to BDB', $key));
            } # unless $rc
        } # endif $rec_type
    } else {
        
        # something really BAD happened
        mydie(sprintf("error: outputToBDB(): couldn't obtain a next ID"));
    
    } # endif $key
    
    # stop timer
    #my $log = get_logger();
    #$timer->stop('read_time');
    #$log->info(sprintf('Record type "%s" took %.3f sec',$rec_type, $timer->result('read_time')));
    #mydebug(sprintf('OutputToBDB: Record type "%s" took %.3f sec',$rec_type, $timer->result('read_time')));
    
} # outputToBDB

sub get_data_file () {
        #####  get_data_file

		# If 'appname05data' form variable defined use it to generate name of the appname05 results appname03ory.
		my $appname05_data_dir = $base_data_dir . '/' . (defined($form{'appname05data'}) ? $form{'appname05data'} : $form{'appname05'}); # appname05 data appname03ory
                if(! (-r $appname05_data_dir && -x $appname05_data_dir && -w $appname05_data_dir)){
                        $appname05_data_dir =~ s|.*/||;
			mydie(sprintf('error: outputappname05(): appname05 data appname03ory "%s" is not read/write/execute', $appname05_data_dir));
		} # if

		# Output the appname05 result.

		my $base; # filename part of output file
		
		# Use $form{'data'} as filename if defined otherwise 
		# strip off trailing '.*' extension from $form{'page'} and tack on '.dat' extension.

		if(defined($form{'data'}) && $form{'data'} ne ''){
			$base = $form{'data'};
		}else{
			$base = $form{'page'};
			# strip off the extension, if any
			$base =~ s/\..*$//;
			$base .= '.dat';
		} # if ... data file name defined in form

		# Open the appname05 results file for append or create it if it does not exist.

		$appname05_data_dir . '/' . $base;

} #### end of get_data_file

# outputLog() - output appname05 log

sub outputLog {

	# Only output the appname05 log if form variable 'log' is defined. 

	if(defined($form{'log'})){

		my $appname05_log_dir = $base_data_dir . '/' . $form{'appname05'}; # appname05 log appname03ory
                if(! (-r $appname05_log_dir && -x $appname05_log_dir && -w $appname05_log_dir)){
                        $appname05_log_dir =~ s|.*/||;
			mydie(sprintf('error: outputLog(): appname05 log appname03ory "%s" is not read/write/execute', $appname05_log_dir));
		} # if

		# Output the appname05 result.

		my $base; # filename part of output file

		# Use $form{'log'} as filename if defined otherwise 
		# strip off trailing '.*' extension from $form{'page'} and tack on '.dat' extension.

		$base = $form{'log'};

		# Open the appname05 log file for append or create it if it does not exist.

		my $log_file = $appname05_log_dir . '/' . $base;

		$debug_html .= sprintf("<!-- DEBUG: LOG: log file '%s' -->\n", $log_file);
		my $res = appname05LogResults();

                unless (open(D, ">>$log_file") || open(D, ">$log_file")) {
                    $log_file =~ s|.*/||;
                    mydie(sprintf('error: outputLog(): can\'t open appname05 log file "%s" - "%s"', $log_file, $!));
                }

		my $oldfh = select(D); $| = 1; select($oldfh); # unbuffered output

		flock(D, LOCK_EX); # Exclusive lock, block till aquired

		# In case someone appended while we were waiting for the lock.

		seek(D, 0, SEEK_END);

		print D $res;

		flock(D, LOCK_UN); # release lock

		close(D);

		# Debug output.

		$res =~ s/[\r\n]//g;
		$res =~ s/-->//g;
		$debug_html .= sprintf("<!-- DEBUG: LOG: result '%s' -->\n", $res);

		# Now mark the 'log' form variable as not exported, so logging happens only once.
		$xmlState->variableIsExported('log', $false);

	}else{

		$debug_html .= sprintf("<!-- DEBUG: LOG: no output -->\n");

	} # if ... log

} # outputLog()

# outputLogRec() - a simplified LOG entry before the page is even processed.

sub outputLogRec {
    
        # output HASH ref
        my $log_res = {};

        # log name
        $log_res->{'LOG'} =  defined($form{'log'}) ? $form{'log'} : '';
        
        # if 'log' is cleared, return: we've already been here
        return unless $log_res->{'LOG'};
        
        # time created in sec
        $log_res->{'TIMESECOND'} = time();
        
        # client IP
        if( ! $form{ 'ip_not_saved' } ) { 
            $log_res->{'CLIENT_IP'} = $ENV{'REMOTE_ADDR'};
        } else {
            $log_res->{'CLIENT_IP'} = '0.0.0.0';
        }
        
        # referer
        $log_res->{'REFERER'} = defined($ENV{'HTTP_REFERER'}) ? $ENV{'HTTP_REFERER'} : 'No Referer';
        
        # session ID, if any
        my $sessionID;
        #<MAX> 20030528 -> if cookies are enabled
        unless ($disable_cookies) {
            $sessionID = defined($cookie{'sessionID'}) ? decode_sessionID($cookie{'sessionID'}) : '';
        } else {
            # use form variable
            $sessionID = defined($form{'sessionID'}) ? decode_sessionID($form{'sessionID'}) : '';
        }
        $log_res->{'SESSIONID'} = $sessionID;
        
        # appname05 name
        $log_res->{'appname05'} = defined($form{'appname05'}) ? $form{'appname05'} : '';
        
        # user agent
        $log_res->{'USER_AGENT'} = defined($ENV{'HTTP_USER_AGENT'}) ? $ENV{'HTTP_USER_AGENT'} : 'No User Agent';
        
        # server ID
        $log_res->{'SERVER_ID'} = defined($form{'server_id'}) ? $form{'server_id'} : $server_id;
        
        # CGI params
        my $q = new CGI;
        my %cgi_params = $q->Vars();
        $log_res->{'CGI_PARAMS'} = \%cgi_params;

        # output to BDB
        outputToBDB(rec_type => 'log', 'res' => $log_res);

} # outputLogRec()

# buildDigits() - build list that defines # digits for each appname05 question

sub buildDigits {
	my($numappname05) = @_;

	my @digits; # number of digits in each appname05 answer

	for my $i (1 .. $numappname05){
		$digits[$i] = 1; # default is 1
	} # for ... each appname05 answer

	# check for *_digits and build question length array

	for my $key (keys(%form)) {

		if($key =~ m/^(\d+)_digits$/){

			my $ndigits = $1;

			my @questions = StringToArray(-string => $form{$key});

			for my $q (@questions){
				$digits[$q] = $ndigits;
			} # for

		} # if 

	} # for ... each form variable 

	return @digits;

} # buildDigits()

# appname05Results() - encode appname05 results in string.

sub appname05Results {

	my $numappname05 = defined($form{'numappname05'}) ? $form{'numappname05'} : 0;
	if($numappname05 > 9999){
		mydie(sprintf("invalid numappname05 %d '%s'\n", $numappname05, $form{'numappname05'}));
	}
	my $numText = defined($form{'numtext'}) ? $form{'numtext'} : 0;
	if($numText > 9999){
		mydie(sprintf("invalid numtext %d '%s'\n", $numText, $form{'numtext'}));
	}
	my $delimiter = defined($form{'delimiter'}) ? $form{'delimiter'} : $data_delimiter;

	#printf STDERR ("appname05Results(): numappname05 %d numText %d delimiter '%s'\n", $numappname05, $numText, $delimiter);

	my $outputNotSeen = (defined($form{'outputnotseen'}) && $form{'outputnotseen'} != 0) ? 1 : 0;
	my @digits = buildDigits($numappname05); # number of digits in each appname05 answer


	my @appname05 = ();

	for my $i (1 .. $numappname05){

		my $key = 'appname05' . $i;
		my $formVar = $form{$key};
		my $isSeen = $variableIsSeen{$key};
		if(!defined($isSeen)){
			$isSeen = 0;
		} # if
		if(defined($formVar) || $isSeen || !$outputNotSeen){
			# if(!defined($formVar) || $formVar eq '' || $formVar == 0){ # seen but not answered
                       
                        # Allow zero as a appname05NN answer
                       
		        my $zero;	
		        if( defined ($form{ "allow_zero"} ) && toBool($form{ "allow_zero"}))	{
				$zero = 0;
			} else {
				$zero = ( $formVar == 0 ) ;
			}
			if(!defined($formVar) || $formVar eq '' || $formVar eq '.' || $zero ){ # seen but not answered
				if($digits[$i] > 1){
					push(@appname05, '9' x $digits[$i]);
				}else{
					push(@appname05, '.');
				} # if
			}else{
				push(@appname05, sprintf("%0*d", $digits[$i], escape($formVar, $delimiter)));
			} # if
		}else{ # output not seen
			if($digits[$i] > 1){
				push(@appname05, ('9' x ($digits[$i] - 1)) . '8');
			}else{
				push(@appname05, '_');
			} # if
		} # if

	} # for ... each appname05 question
;
	if(defined( $form{ "status_flag"} ) ){
	  push(@appname05, sprintf( "%.6d", $form{ "status_flag"}) ); # end of appname05 questions
        } else {
	  push(@appname05, '000009'); # end of appname05 questions
        }

	push(@appname05, time()); # number seconds since epoch

	for my $i (1 .. $numText){

		my $key = 'textincludeboth' . $i;
		my $formVar = $form{$key};
		my $isSeen = $variableIsSeen{$key};
		if(!defined($isSeen)){
			$isSeen = 0;
		} # if
		if(defined($formVar) || $isSeen || !$outputNotSeen){
			if(!defined($formVar) || $formVar eq ''){ # seen but not answered
				push(@appname05, 'no answer');
			}else{
				push(@appname05, escape($formVar, $delimiter));
			} # if
		}else{ # output not seen
			push(@appname05, 'not seen');
		} # if

	} # for ... each appname05 question

	my $date_now = gmtime() . ' GMT';
	push(@appname05, $date_now) if defined($form{'date'});
	$date_now = localtime() ;
	push(@appname05, $date_now) if defined($form{'local'});
	my @date_string = split(/ {1,2}/, $date_now);
	push(@appname05, $date_string[3]) if defined($form{'time'});

        if( $form{ 'ip_not_saved' } ) { 
	  $ip_saved = '0.0.0.0';
        } elsif ( $form{ 'ip_saved' } ) { 
          $ip_saved = $ENV{'REMOTE_ADDR'};
	} else {
          @octect = split( /\./ , $ENV{'REMOTE_ADDR'});
          $ip_saved = $octect[0] . '.' . $octect[1] . '.' . $octect[2] . '.0';
	}
	push(@appname05, escape( $ip_saved, $delimiter));

        my $sessionID;
        #<MAX> 20030528 -> if cookies are enabled
        unless ($disable_cookies) {
            $sessionID = defined($cookie{'sessionID'}) ? decode_sessionID($cookie{'sessionID'}) : '';
        } else {
            # use form variable
            $sessionID = defined($form{'sessionID'}) ? decode_sessionID($form{'sessionID'}) : '';
        }
	push(@appname05, escape($sessionID, $delimiter));

	return join($delimiter, @appname05) . "\n";

} # appname05Results()

# appname05LogResults() - encode appname05 log results in XML formatted string.

sub appname05LogResults {

	my $numappname05 = defined($form{'numappname05'}) ? $form{'numappname05'} : 0;
	if($numappname05 > 9999){
		mydie(sprintf("invalid numappname05 %d '%s'\n", $numappname05, $form{'numappname05'}));
	}
	my $numText = defined($form{'numtext'}) ? $form{'numtext'} : 0;
	if($numText > 9999){
		mydie(sprintf("invalid numtext %d '%s'\n", $numText, $form{'numtext'}));
	}

	my $delimiter = '"';
	my $log_res = '';

	my $t = time();
	my $now = scalar(gmtime($t));

	$log_res .= $now . " GMT\t";
	$log_res .= '<LOG_RECORD>';

	$log_res .= sprintf("<TIMESECOND value=\"%d\"/>", $t); # number seconds since epoch
	$log_res .= sprintf("<TIMEASCII value=\"%s\"/>", $now);
        if( ! $form{ 'ip_not_saved' } ) { 
	  $log_res .= sprintf("<CLIENT_IP value=\"%s\"/>", $ENV{'REMOTE_ADDR'});
	}
	$log_res .= sprintf("<REFERER value=\"%s\"/>", defined($ENV{'HTTP_REFERER'}) ? $ENV{'HTTP_REFERER'} : 'No Referer');
	my $sessionID;
        #<MAX> 20030528 -> if cookies are enabled
        unless ($disable_cookies) {
            $sessionID = defined($cookie{'sessionID'}) ? decode_sessionID($cookie{'sessionID'}) : '';
        } else {
            # use form variable
            $sessionID = defined($form{'sessionID'}) ? decode_sessionID($form{'sessionID'}) : '';
        }
	$log_res .= sprintf("<SESSIONID value=\"%s\"/>", $sessionID);

	# Form variables.

	my @digits = buildDigits($numappname05); # number of digits in each appname05 answer

	my $numOther = 0;
	for my $k (sort(keys(%form))) {
		if($k !~ m/^appname05|^textincludeboth|^env_|^cookie_|^sessionID/){
			$numOther += 1;
		} # if ... not appname05 variable
	} # for

	$log_res .= sprintf("<VARIABLES number=\"%d\">", $numappname05 + $numText + $numOther);
	my $varnum = 1;

	for my $i (1 .. $numappname05){

		my $formVarName = 'appname05' . $i;
		my $formVar = $form{$formVarName};
		my $isSeen = $variableIsSeen{$formVarName};
		if(!defined($isSeen)){
			$isSeen = 0;
		} # if
		if($isSeen){
			if(!defined($formVar) || $formVar eq '' || $formVar == 0){ # seen but not answered
				if($digits[$i] > 1){
					$log_res .= sprintf("<VARIABLE index=\"%d\" name=\"%s\" value=\"%s\"/>", $varnum, $formVarName, '9' x $digits[$i]);
				}else{
					$log_res .= sprintf("<VARIABLE index=\"%d\" name=\"%s\" value=\"%s\"/>", $varnum, $formVarName, '.');
				} # if
			}else{
				$log_res .= sprintf("<VARIABLE index=\"%d\" name=\"%s\" value=\"%0*d\"/>", $varnum, $formVarName, $digits[$i], escapeXML($formVar));
			} # if
		}else{ # not seen
			if($digits[$i] > 1){
				$log_res .= sprintf("<VARIABLE index=\"%d\" name=\"%s\" value=\"%s\"/>", $varnum, $formVarName, ('9' x ($digits[$i] - 1)) . '8');
			}else{
				$log_res .= sprintf("<VARIABLE index=\"%d\" name=\"%s\" value=\"%s\"/>", $varnum, $formVarName, '_');
			} # if
		} # if

		$varnum += 1;

	} # for ... each appname05 question

	for my $i (1 .. $numText){

		my $formVarName = 'textincludeboth' . $i;
		my $formVar = $form{$formVarName};
		my $isSeen = $variableIsSeen{$formVarName};
		if(!defined($isSeen)){
			$isSeen = 0;
		} # if
		if($isSeen){
			if(!defined($formVar) || $formVar eq ''){ # seen but not answered
				$log_res .= sprintf("<VARIABLE index=\"%d\" name=\"%s\" value=\"%s\"/>", $varnum, $formVarName, 'no answer');
			}else{
				$log_res .= sprintf("<VARIABLE index=\"%d\" name=\"%s\" value=\"%s\"/>", $varnum, $formVarName, escapeXML($formVar));
			} # if
		}else{ # not seen
			$log_res .= sprintf("<VARIABLE index=\"%d\" name=\"%s\" value=\"%s\"/>", $varnum, $formVarName, 'not seen');
		} # if

		$varnum += 1;

	} # for ... each appname05 question

	for my $k (sort(keys(%form))) {
		if($k !~ m/^appname05|^textincludeboth|^env_|^cookie_|^sessionID/){
			if(defined($form{$k})){
				$log_res .= sprintf("<VARIABLE index=\"%d\" name=\"%s\" value=\"%s\"/>", $varnum, $k, $form{$k});
				$varnum += 1;
			} # if ... defined
		} # if ... not appname05 variable
	} # for

	$log_res .= '</VARIABLES>'; # end of variables

	$log_res .= '</LOG_RECORD>';

	$log_res .= "\n";

	return $log_res;

} # appname05LogResults()

# escape() - escape output delimiter in string

sub escape {
	my($string, $delimiter) = @_;

	#$string =~ s/$delimiter//gse;

	my $escaped = '';
	my $c;
	my $n;
	my $i;
	for($i = 0; $i < length($string); $i += 1){
		$c = substr($string, $i, 1);
		$n = ord($c);
		if($c eq "\r" || $c eq "\n"){
			$escaped .= ' '; # CR, NL -> space
		}elsif($n >= 0x20 && $c ne $delimiter){ # not delimiter and displayable
			$escaped .= $c;
		} # if
	} # for

	return $escaped;

} # escape()

# escapeXML() - escape magic XML characters in string

sub escapeXML {
	my($string) = @_;

	defined($string) || return undef;

	my $escaped = '';
	my $c;
	my $i;
	for($i = 0; $i < length($string); $i += 1){
		$c = substr($string, $i, 1);
		my $e = $escapeXMLChar{$c};
		if(defined($e)){
			$escaped .= $e;
		}else{
			$escaped .= $c;
		} # if
	} # for

	return $escaped;

} # escapeXML()

# outputInit() - output HTML initialization

sub outputInit {

	my $my_is_output = $true; # @@@
	if($my_is_output){

		# HTTP header 

		$output_html .= "Content-Type: text/html\n";
		#$output_html .= "Content-Type: text/html; charset=ISO-8859-1\n";
		#$output_html .= "Pragma: no-cache\n";
		#$output_html .= "Cache-Control: no-cache\n";
	
                if(  $form{'page'} !~ /close/ ) {	
                    #<MAX> 20030528 -> if cookies are enabled
                    unless ($disable_cookies) {
                        $output_html .= get_sessionID_cookie();
                    }
                }

		$output_html .= "\n";

		# HTML

		if($output_doctype && !defined($xmlState->elementIsPresent('doctype'))){
			$output_html .= '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">';
			$output_html .= "\n";
		} # if ... no <!DOCTYPE> element

		if(!defined($xmlState->elementIsPresent('html'))){
			$output_html .= "<html>\n";
		} # if ... no <HTML> element

		if(!defined($xmlState->elementIsPresent('body'))){
			$output_html .= "<body>\n";
		} # if  ... no <BODY> element

	} # if ... output

} # outputInit()

# outputFin() - output HTML finish

sub outputFin {

	if($is_output){
		if(!defined($xmlState->elementIsPresent('form'))){
			$output_html .= '<form name="appname05Form"';
			if(defined($form{'usemethodget'})){
				$output_html .= ' METHOD="GET"';
			}else{
				$output_html .= ' METHOD="POST"';
			} # if 
                        
                        $output_html .= ' ACTION="' . $ENV{'SCRIPT_NAME'} . '"';
                        #<MAX> 20030613: accept UTF-8
                        $output_html .= ' accept-charset="UTF-8"';
                        #<MAX> 20030501: for display version only
                        if ($disable_if or $disable_random) {
                            # set submitanswers to 1
                            $output_html .= ' onSubmit="' . 'this.submitanswers.value=1;return true;' . '"';
                        }
			$output_html .= ">\n";

			outputFormVariables();

			$output_html .= "</form>\n";
		} # if
                
		if(!defined($xmlState->elementIsPresent('body'))){
			$output_html .= "</body>\n";
		}
		if(!defined($xmlState->elementIsPresent('html'))){
			$output_html .= "\n</html>\n";
		} # if ... not <html> tag

		print $output_html; # actually print it

	} # if ... output

} # outputFin()

# outputNode() - output tree starting at -node

sub outputNode {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie(sprintf("error: outputNode(): node '%s' not processed - internal error", $node->getNodeName()));
	} # if

        #$debug_html .= sprintf("<!-- DEBUG: outputNode 1: node name  '%s'-->\n", $node->getNodeName());
        #$debug_html .= sprintf("<!-- DEBUG: outputNode 1: node value '%s'-->\n", $node->getNodeValue());
        #$debug_html .= sprintf("<!-- DEBUG: outputNode 1: node parent '%s'-->\n", $node->getParentNode()->getNodeName());
        #$debug_html .= sprintf("<!-- DEBUG: outputNode 1: node type '%s'-->\n", $node->getNodeType());
	
	if($xmlState->isSelected($node)){ 

                #$debug_html .= sprintf("<!-- DEBUG: outputNode 2: node is selected '%s'-->\n", $xmlState->isSelected($node));
                
                if(! $xmlState->isOutput($node)){
                
                        #$debug_html .= sprintf("<!-- DEBUG: outputNode 3: node is NOT output '%s'-->\n", $xmlState->isOutput($node));

			$xmlState->isOutput($node, $true);

			outputThisNode(
			 -node => $node,
			);

			for my $kid ($node->getChildNodes()) {

                                        #$debug_html .= sprintf("<!-- DEBUG: outputNode 4: outputting kid '%s'-->\n", $kid->getNodeName());
					outputNode(
					 -node => $kid, 
					);

                        } # for ... each child node
                        
                #} else {
                        # DEBUG: only
                        #$debug_html .= sprintf("<!-- DEBUG: outputNode 5: node IS output '%s'-->\n", $xmlState->isOutput($node));
                    
		} # if ... not already output
                
        #} else {
                # DEBUG only:
                #$debug_html .= sprintf("<!-- DEBUG: outputNode 6: node is NOT selected '%s'-->\n", $xmlState->isSelected($node));
        
        } # if ... selected

} # outputNode()

# outputThisNode() - output one document node.

sub outputThisNode {
	my(%args) = @_;
	my($node) = $args{-node};

	my $nodeType = $node->getNodeType();

	if($nodeType == ELEMENT_NODE){

		my $elementName = $node->getNodeName();

		if($elementName =~ m/^IF$/oi){

			outputIfElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^RANDOM$/oi){

			outputRandomElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^R$/oi){

			outputRElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^SET$/oi){

			outputSetElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^PRINT$/oi){

			outputPrintElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^EXPORT$/oi){

			outputExportElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^READ$/oi){

			outputReadElement(
			 -node => $node,
			);

		}elsif($elementName =~ m/^WRITE$/oi){

			outputWriteElement(
			 -node => $node,
			);

		}else{

			outputOtherElement(
			 -node => $node,
			 -name => $elementName,
			);

		} # if ... element name

	}elsif($nodeType == CDATA_SECTION_NODE){

		outputCDATA(
			 -node => $node,
		);

	}elsif($nodeType == COMMENT_NODE){

		outputComment(
			 -node => $node,
		);

	}elsif($nodeType == TEXT_NODE){

		outputText(
		 -node => $node,
		);

	} # if ... node type

} # outputThisNode()

# outputIfElement() - output <IF> element

sub outputIfElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie("error: outputIfElement(): <IF> not processed - internal error");
	} # if

	if($xmlState->isSelected($node)){
		$is_debug && printf STDERR ("outputIfElement(): parent \"%s\"\n", $node->getParentNode()->getNodeName());
                
                #$debug_html .= sprintf("<!-- DEBUG: outputIf 1: parent '%s'-->\n", $node->getParentNode()->getNodeName());
                
                #<MAX> 20030324 -> for display version we need to move this up
		my @kids = $node->getChildNodes();
                
                #<MAX> 20030324 -> do the rest only, if $disable_if == $false
                unless ($disable_if) {
                    
                    # Evaluate the <IF> condition.
    
                    my $ifCondition = evaluateIfCondition(
                     -ifcondition => $xmlState->cond($node),
                    );
    
                    # Run thru the <IF> element child list,
                    # conditially marking elements as selected/not selected based on the evaluated <IF>, <ELSEIF> 
                    # conditions.
    
                    # Ensure that <IF> ... <ELSEIF> ... <ELSE> sequence is observed
    
                    my $isSeenElseIf = $false;
                    my $isSeenElse = $false;
    
                    my $currentIfCondition = $ifCondition;
                    
                    #$debug_html .= sprintf("<!-- DEBUG: outputIf 2: \$currentIfCondition '%s' -->\n", (defined($currentIfCondition) ? $currentIfCondition : "undef"));
                    
                    for my $kid (@kids) {
    
                            if($is_assert){
                                    (!defined($xmlState->isOutput($kid))) && mydie(sprintf('error: outputIfElement(): <IF> child \'%s\' not processed - internal error', $kid->getNodeName()));
                            } # if
    
                            # Mark the <IF> child as selected/not selected based on the last evaluated <IF> or <ELSEIF> condition.
    
                            #$debug_html .= sprintf("<!-- DEBUG: outputIf 2a: kid '%s' isSelected before '%s' -->\n", $kid->getNodeName, $xmlState->isSelected($kid));
                            
                            $xmlState->isSelected($kid, $currentIfCondition);
                            
                            #$debug_html .= sprintf("<!-- DEBUG: outputIf 2b: kid '%s' isSelected after '%s' -->\n", $kid->getNodeName, $xmlState->isSelected($kid));
    
                            if($kid->getNodeType() == ELEMENT_NODE){
    
                                    if($kid->getNodeName() =~ m/^ELSEIF$/oi){
    
                                            $isSeenElseIf = $true;
    
                                            ($isSeenElse) && mydie(sprintf('error: outputIfElement(): <IF cond="%s">: <ELSEIF cond="%s"/> follows <ELSE/>', $xmlState->cond($kid), $xmlState->cond($kid)));
    
                                            $xmlState->isSelected($kid, $true);
    
                                            #$debug_html .= sprintf("<!-- DEBUG: outputIf 3: \$kid '%s', \$ifCondition '%s' -->\n", $kid->getNodeName(), $ifCondition);
                                            
                                            if(!$ifCondition){
    
                                                    # Previous <IF> or <ELSEIF> was false, so evaluate this condition.
    
                                                    $currentIfCondition = evaluateIfCondition(
                                                     -ifcondition => $xmlState->cond($kid),
                                                    );
                                                    
                                                    #$debug_html .= sprintf("<!-- DEBUG: outputIf 4: \$currentIfCondition '%s' -->\n", $currentIfCondition);
    
                                                    if($currentIfCondition){
                                                            $ifCondition = $true;
                                                    } # if 
    
                                            }else{
    
                                                    # Previous <IF> or <ELSEIF> was true, current must be false.
                                                    
                                                    #$debug_html .= sprintf("<!-- DEBUG: outputIf 5: \$ifCondition '%s' -->\n", $ifCondition);
    
                                                    $currentIfCondition = $false;
    
                                            } # if ... previous <IF> or <ELSEIF> condition FALSE
    
                                    }elsif($kid->getNodeName() =~ m/^ELSE$/oi){
    
                                            ($isSeenElse) && mydie(sprintf('error: outputIfElement(): <IF cond="%s">: <ELSE/> follows <ELSE/>', $xmlState->cond($kid)));
    
                                            $isSeenElse = $true;
    
                                            $xmlState->isSelected($kid, $true);
    
                                            # If previous <IF> and <ELSEIF> conditions were all FALSE then <ELSE> must be TRUE
    
                                            $ifCondition = ! $ifCondition;
                                            $currentIfCondition = $ifCondition;
    
                                    } # if ... <ELSEIF> or <ELSE>
    
                            } # if ... element
    
                    } # for ... each child node
                    
                } # unless ($disable_if), output it straight
                
                #$debug_html .= sprintf("<!-- DEBUG: outputIf 6: getAttribute('cond') '%s' -->\n", $node->getAttribute('cond'));

		my $is_show = isShow($node);
		($is_output && $is_show) && ($output_html .= sprintf('<IF cond="%s">', $node->getAttribute('cond')));

		for my $kid (@kids) {

			outputNode(
			 -node => $kid,
			);

		} # for ... each <IF> child node

		($is_output && $is_show) && ($output_html .= '</IF>');

	} # if ... selected

} # outputIfElement()

# outputExportElement() - output <EXPORT name="var" value="no"/> element

sub outputExportElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie("error: outputExportElement(): <EXPORT> not processed - internal error");
	} # if

	if($xmlState->isSelected($node)){

		my $is_show = isShow($node);

		my $name = $node->getAttribute('name');
		my $value = $node->getAttribute('value');
		if($is_output && $is_show){
			$output_html .= '<EXPORT';
			($name ne '') && ($output_html .= sprintf(' name="%s"', $name));
			($value ne '') && ($output_html .= sprintf(' value="%s"', $value));
			$output_html .= ' />';
		} # if ... output

		if(!defined($value) || $value eq ''){
			$xmlState->outputFormVariable($name, $true); # output 
			$xmlState->variableIsExported($name, $true); # exported
			if(!defined($form{$name})){
				$form{$name} = '';
			} # if
		}else{ 	# value="no"
			$xmlState->outputFormVariable($name, $false);
			$xmlState->variableIsExported($name, $false); # not exported
		} # if 

		$xmlState->isOutput($node, $true);

	} # if ... <EXPORT> selected

} # outputExportElement()

# outputSetElement() - output <SET> element

sub outputSetElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie("error: outputSetElement(): <SET> not processed - internal error");
	} # if

	if($xmlState->isSelected($node)){

		my $is_show = isShow($node);

		my $name = $node->getAttribute('name');
		my $value = $node->getAttribute('value');
		my $is_export = toBool($node->getAttribute('export'));

		if($is_output && $is_show){
			$output_html .= '<SET';
			($name ne '') && ($output_html .= sprintf(' name="%s"', $name));
			($value ne '') && ($output_html .= sprintf(' value="%s"', $value));
			($output_html .= sprintf(' export="%s"', $is_export ? 'true' : 'false'));
			$output_html .= ' />';
		} # if ... output

		$xmlState->isOutput($node, $true);
		if(!defined($form{$name})){
			$form{$name} = '';
		} # if ... variable not defined

		my $evaluatedValue = evaluateSet(-value => $value);
		$xmlState->variableValue($name, $evaluatedValue);
		$form{$name} = $evaluatedValue;

		if($is_export){
			$xmlState->outputFormVariable($name, $true); # output 
			$xmlState->variableIsExported($name, $true); # exported
		} # if ... exported

	} # if ... <SET> selected

} # outputSetElement()

# outputPrintElement() - output <PRINT> element

sub outputPrintElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie("error: outputPrintElement(): <PRINT> not processed - internal error");
	} # if

	if($xmlState->isSelected($node)){

		my $is_show = isShow($node);
		my $output = $node->getAttribute('output');
		if($is_output){
			if($is_show){
				$output_html .= '<PRINT';
				($output ne '') && ($output_html .= sprintf(' output="%s"', $output));
				$output_html .= ' />';
			} # if
			$xmlState->isOutput($node, $true);
			my $evaluatedPrint = evaluatePrint(-output => $output);
			$output_html .= $evaluatedPrint;

		} # if ... output

	} # if ... <PRINT> selected

} # outputPrintElement()

# outputReadElement() - output <READ name="variable" file="filename" lock="yes"/> element

sub outputReadElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie("error: outputReadElement(): <R> not processed - internal error");
	} # if

	if($xmlState->isSelected($node)){

		my $is_show = isShow($node);

		if($is_output){

			# <READ> must have a "name" & "file" attributes.

			my $name = $node->getAttribute('name');
			(!defined($name) || $name eq '') && mydie('error: outputReadElement(): <READ> tag must have a "name" attribute');

			my $file = $node->getAttribute('file');
			(!defined($file) || $file eq '') && mydie('error: outputReadElement(): <READ> tag must have a "file" attribute');

			my $lock = $node->getAttribute('lock');
			(!defined($lock) || $lock eq '') && ($lock = 'no');

			if($is_show){
				$output_html .= '<READ';
				$output_html .= sprintf('<READ name="%s" file="%s" lock="%s"/>', $name, $file, $lock);
			} # if

			$xmlState->isOutput($node, $true);

		} # if ... output

	} # if ... <READ> selected

} # outputReadElement()

# outputWriteElement() - output <WRITE> element

sub outputWriteElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie("error: outputWriteElement(): <R> not processed - internal error");
	} # if

	if($xmlState->isSelected($node)){

		my $is_show = isShow($node);

		if($is_output){

			# @@@ as per outputReadElement()

		} # if ... output

	} # if ... <WRITE> selected

} # outputWriteElement()

# outputRElement() - output <RANDOM> <R> element

sub outputRElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie("error: outputRElement(): <R> not processed - internal error");
	} # if

	# The parent <RANDOM> element state.

	if($xmlState->isSelected($node)){

		$is_debug && printf STDERR ("outputRElement(): parent '%s'\n", $node->getParentNode()->getNodeName());
		my $is_show = isShow($node);

		if($is_output && $is_show){
			$output_html .= '<R';
			my($name) = $node->getAttribute('name');
			($name ne '') && ($output_html .= sprintf(' name="%s"', $name));
			$output_html .= '>';
		} # if ... output

		for my $kid ($node->getChildNodes()) {

			outputNode(
			 -node => $kid, 
			);

		} # for ... each child node

		($is_output && $is_show) && ($output_html .= '</R>');

	}else{
		$is_debug && printf STDERR ("outputRElement(): parent '%s' - not selected\n", $node->getParentNode()->getNodeName());
	} # if ... <R> selected

} # outputRElement()

# outputRandomElement() - output <RANDOM> element

sub outputRandomElement {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie('error: outputRandomElement(): <RANDOM> tag not processed - internal error');
	} # if

	if($xmlState->isSelected($node)){
		$is_debug && printf STDERR ("outputRandomElement(): parent \"%s\"\n", $node->getParentNode()->getNodeName());

		# If the <RANDOM> tag has not been randomized then do so.
		# The random list order may already be set via a CGI form variable.
		# Otherwise we don't now how many <R> child elements there are so defer 
		# setting the random order list until this is known.

		my $name = $xmlState->name($node); # name

		my @random_order = ( ); # The random ordering of <R> tags.
		my $random_cgi_var = 'RANDOMORDER_' . $name;
		if(defined($form{$random_cgi_var})){
			@random_order = StringToArray(-string => $form{$random_cgi_var});
			$is_debug && printf STDERR ("outputRandomElement(): random order already set to \"%s\" via form variable \"%s\"\n", $form{$random_cgi_var}, $random_cgi_var);
			if(defined($xmlState->randomOrder($node)) && scalar(@{$xmlState->randomOrder($node)}) != scalar(@random_order)){

				warn sprintf("outputRandomElement(): random order for name '%s' has %d elements but CGI variable '%s' has %d elements, now %d\n", $name, scalar(@{$xmlState->randomOrder($node)}), $random_cgi_var, scalar(@random_order));
			} # if
			$xmlState->randomOrder($node, [ @random_order ]); # random shuffle
		} # if

		if(!defined($xmlState->randomOrder($node)) || scalar(@{$xmlState->randomOrder($node)}) == 0){

			# Generate a random shuffle.

			@random_order = getRandomOrder(-num => $xmlState->num($node));

			# Save the random order in a CGI form variable.

			my $random_cgi_var = 'RANDOMORDER_' . $name;
			$form{$random_cgi_var} = ArrayToString(-array => \@random_order);

			$is_debug && printf STDERR ("outputRandomElement(): num %d randomorder '%s'\n",  $xmlState->num($node), $form{$random_cgi_var});

			$xmlState->randomOrder($node, [ @random_order ]); # random shuffle
			$xmlState->variableIsExported($random_cgi_var, $true);
			$xmlState->outputFormVariable($random_cgi_var, $true); # output 
		}else{

			@random_order = @{$xmlState->randomOrder($node)};

			# Check that random order is in bounds.

			(scalar(@random_order) == $xmlState->num($node)) || mydie(sprintf('error: outputRandomElement(): <RANDOM> name \'%s\' randomorder \'%s\' has %d elements, expected %d', $node->getAttribute('name'), ArrayToString(-array => \@random_order), scalar(@random_order), $xmlState->num($node)));
			my @seenRandomIndex;
			for my $i (@random_order) {
				($i >= 0 && $i < $xmlState->num($node)) || mydie(sprintf('error: outputRandomElement(): <RANDOM> name \'%s\' randomorder \'%s\' element %d out of bounds', $node->getAttribute('name'), ArrayToString(-array => \@random_order), $i));

				defined($seenRandomIndex[$i]) && mydie(sprintf('error: outputRandomElement(): <RANDOM> name \'%s\' randomorder \'%s\' element %d is not unique', $node->getAttribute('name'), ArrayToString(-array => \@random_order), $i));
				$seenRandomIndex[$i] = 1;
				
			} # for ... each element of random array

		} # if ... not randomized

		my $is_show = isShow($node);

		if($is_output && $is_show){
			$output_html .= sprintf('<RANDOM name="%s" num="%d" randomorder="%s"', $node->getAttribute('name'), $xmlState->num($node), ArrayToString(-array => $xmlState->randomOrder($node)));
			$xmlState->use($node) > 0 && ($output_html .= sprintf(' use="%d"', $xmlState->use($node)));
			$output_html .= '>';
		} # if ... output

		my @kids = $node->getChildNodes(); # list of children for <RANDOM>

		# Find the <R> elements.

		my @shuffle_node_list;

		for my $kid (@kids) {

			if($kid->getNodeType() == ELEMENT_NODE && $kid->getNodeName() =~ m/^R$/oi){

				#printf STDERR ("outputRandomElement(): %d: <R> child %s\n", scalar(@shuffle_node_list), $kid);
				push(@shuffle_node_list, $kid); 

			} # if ... <R> tag

		} # for ... each child node

		if($is_assert){
			(scalar(@random_order) == scalar(@shuffle_node_list)) ||  mydie(sprintf('outputRandomElement(): expected %d <R> child tags but got %d - internal error', scalar(@random_order), scalar(@shuffle_node_list)));
		} # if

		# Apply the shuffle of the <R> tags as they are output.

		my $shuffle_index = 0;
                my $use = $xmlState->use($node); # the number of <R> tags to output, 0 for all
                
		for my $kid (@kids) {

			if($kid->getNodeType() == ELEMENT_NODE && $kid->getNodeName() =~ m/^R$/oi){

				# If the number of <R> elements to use specified via the use attribute 
				# then output only the specified number.

				my $rnode = $shuffle_node_list[$random_order[$shuffle_index]];
                                                                          
                                if($xmlState->use($node) == 0
                                            || $use > 0
                                            || $disable_random #<MAX> 20030324 -> disable RANDOM
                                  ){

					outputNode(
					 -node => $rnode,
					);

					if($xmlState->use($node) > 0 && $use > 0){
						$use -= 1;
					} # if ... specifed number of <R> tags to output

				}else{

					# Mark the node as output.

					$xmlState->isOutput($rnode, $true);
					$xmlState->isSelected($rnode, $false);

				} # if ... all <R> tags to be output or specified number

				$shuffle_index += 1;
			}else{

				# Not an <R> tag.

				outputNode(
				 -node => $kid,
				);

			} # if ... <R> tag
			
		} # for ... each child node

		($is_output && $is_show) && ($output_html .= '</RANDOM>');

	} # if ... selected

} # outputRandomElement()

# outputOtherElement() - output non appname05 engine elements

sub outputOtherElement {
	my(%args) = @_;
	my($node) = $args{-node};
	my($name) = $args{-name};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie(sprintf('error: outputOtherElement(): <%s> tag not processed - internal error', $node->getNodeName()));
	} # if

	if($xmlState->isSelected($node)){

		$is_debug && printf STDERR ("outputOtherElement(): parent \"%s\"\n", $node->getParentNode()->getNodeName());

		if($is_output){
			$output_html .= sprintf('<%s', $name);
			if($name !~ /^form$/i){
				for my $attr ($node->getAttributes()->getValues()) {
					$output_html .= sprintf(' %s="%s"', $attr->getName(), $attr->getValue());
				} # for ... each attribute

				# Mark <input> variables as exported
				# Check for hidden variable and mark as output.

				if($name =~ /^input$/i){

					my $var = $node->getAttribute('name');
					(!defined($var) || $var eq '') && ($var = $node->getAttribute('NAME'));
					if(defined($var) && $var ne ''){
						$variableIsSeen{$var} = 1;

						$xmlState->variableIsExported($var, $true); # exported

						my $type = $node->getAttribute('type');
						(!defined($type) || $type eq '') && ($type = $node->getAttribute('TYPE'));

						if($type =~ m/^hidden$/oi){
							$xmlState->outputFormVariable($var, $false); # output 

							if(!defined($form{$var})){

								my $value = $node->getAttribute('value');
								(!defined($value) || $value eq '') && ($value = $node->getAttribute('VALUE'));
							
								$form{$var} = $value;
								$xmlState->outputFormVariable($var, $true); # output 
							} # if ... new form variable
						} # if ... hidden variable

					} # if ... input has name attribute

				} # if ... input 
			}else{

				# Ignore form attributes, output our own.
				# Used to re-invoke this script.

				$output_html .= ' name="appname05Form"';
				if(defined($form{'usemethodget'})){
					$output_html .= ' METHOD="GET"';
				}else{
					$output_html .= ' METHOD="POST"';
				} # if 
                                
                                $output_html .= ' ACTION="' . $ENV{'SCRIPT_NAME'} . '"';
                                #<MAX> 20030613: accept UTF-8
                                $output_html .= ' accept-charset="UTF-8"';
                                #<MAX> 20030501: for display version only
                                if ($disable_if or $disable_random) {
                                    # set submitanswers to 1
                                    $output_html .= ' onSubmit="' . 'this.submitanswers.value=1;return true;' . '"';
                                }
			} # if

		} # if ... output

		# <textarea> usually has no child nodes, i.e. <textarea></textarea>,
		# which gets output as <textarea/>. The browsers don't like this (IE at least),
		# so ensure it is output with an end tag.
		# ditto for <script></script>
		# ditto for <td></td>

		if($node->hasChildNodes() || ($name =~ m/^textarea$/i) || ($name =~ m/^script$/i) || ($name =~ m/^td$/i)){
			$is_output && ($output_html .= '>');

			# Check for elements that need extra processing.

			for my $kid ($node->getChildNodes()) {

				outputNode(
				 -node => $kid,
				);

			} # for ... each <other> child node

                        if($name =~ m/^html$/oi){
                                
                                #<MAX> 20030501 -> for display version submit results once
                                if ($disable_if or $disable_random) {
                                    # nullify doSubmit()
                                    $output_html .= "\n<SCRIPT LANGUAGE=\"JavaScript\">\n";
                                    $output_html .= "	window.onload = null\n";
                                    $output_html .= "</SCRIPT>\n\n"
                                }

				# Blow out the debug output just before the end.

				for my $k (sort(keys(%form))) {
					if(($k !~ m/^env_/) && ($k !~ m/^cookie_/)){
						my $v = $form{$k};
						if(defined($v)){
							$v =~ s/[\r\n]/ /g;
							$debug_html .= sprintf("<!-- DEBUG: END: form variable '%s' = '%s' -->\n", $k, $v);
						}else{
							$debug_html .= sprintf("<!-- DEBUG: END: form variable '%s' = '%s' -->\n", $k, '[NOT DEFINED]');
						} # if
					} # if
				} # for

				($is_output && $debug_output) && ($output_html .= $debug_html);

			}elsif($name =~ m/^form$/oi){

				outputFormVariables();

			} # if ... special tag

			$is_output && ($output_html .= sprintf('</%s>', $name));

		}else{
			if($name =~ /^br$/i){

				# <br/> must be output as <br> for IE and Netscape.

				$is_output && ($output_html .= '>');
			}else{
				$is_output && ($output_html .= ' />');
			}
		} # if ... has child nodes

	} # if ... selected

} # outputOtherElement()

# outputFormVariables() - output <FORM> variables

sub outputFormVariables {

	if($is_output){

		for my $key (sort(keys(%form))) {

			# If the variable has not already been output (via <input type="hidden" ...>
			# and the variable is exported (defined via <input> or <EXPORT>'ed)
			# and it's not a cookie or environment variable.
                    
                        #$debug_html .= sprintf("<!-- DEBUG: outputFormVar: key '%s', value '%s', output flag '%s', export flag '%s' -->\n", $key, $form{$key},$xmlState->outputFormVariable($key),$xmlState->variableIsExported($key));

			if($key ne 'varseen' && ($key !~ m/^env_/) && ($key !~ m/^cookie_/) && $xmlState->outputFormVariable($key) && $xmlState->variableIsExported($key)){

				$xmlState->outputFormVariable($key, $false); # now output 

				my $value;
				if(ref($form{$key}) eq 'ARRAY'){
					$value = $form{$key}[0];
				}else{
					$value = $form{$key};
				} # if ... array
				$key = escapeXML($key);
				$value = escapeXML($value);
				if(defined($value)){
					$output_html .= sprintf('<input type="hidden" name="%s" value="%s"/>', $key, $value);
				}else{
					$output_html .= sprintf('<input type="hidden" name="%s"/>', $key);
				} # if
				$output_html .= "\n";

                        } elsif($key ne 'varseen' && ($key !~ m/^env_/) && ($key !~ m/^cookie_/) && ($disable_if || $disable_random)){
                                #<MAX> 20030501
                                # we must be less restrictive for the display version
                                # dump everything you find on the page
    
				my $value;
				if(ref($form{$key}) eq 'ARRAY'){
					$value = $form{$key}[0];
				}else{
					$value = $form{$key};
				} # if ... array
				$key = escapeXML($key);
				$value = escapeXML($value);
				if(defined($value)){
					$output_html .= sprintf('<input type="hidden" name="%s" value="%s"/>', $key, $value);
				}else{
					$output_html .= sprintf('<input type="hidden" name="%s"/>', $key);
				} # if
				$output_html .= "\n";
			} # if ... not output yet

		} # for ... each form variable to output

		# Variables seen so far.

		my @varseen = sort(keys(%variableIsSeen));
		my $varseen = ArrayToString(-array => \@varseen);
		$output_html .= sprintf('<input type="hidden" name="%s" value="%s"/>', 'varseen', $varseen);
		$form{'varseen'} = $varseen;

	} # if ... output

} # outputFormVariables()

# outputText() - output text

sub outputText {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie(sprintf("error: outputText(): text not processed - internal error", $node->getNodeName()));
	} # if

	if($xmlState->isSelected($node)){

		$is_debug && printf STDERR ("outputText(): parent '%s'\n", $node->getParentNode()->getNodeName());
		#$is_output && ($output_html .= sprintf('%s', $node->getData()));
		$is_output && ($output_html .= $node->getData());

	} # if ... selected

} # outputText()

# outputComment() - output XML comment

sub outputComment {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie(sprintf("error: outputComment(): text not processed - internal error", $node->getNodeName()));
	} # if

	if($xmlState->isSelected($node)){

		$is_debug && printf STDERR ("outputComment(): parent '%s'\n", $node->getParentNode()->getNodeName());
		$is_output && ($output_html .= sprintf('<!-- %s -->', $node->getData()));

	} # if ... selected

} # outputComment()

# outputCDATA() - output escaped XML code

sub outputCDATA {
	my(%args) = @_;
	my($node) = $args{-node};

	if($is_assert){
		(!defined($xmlState->isOutput($node))) && mydie(sprintf("error: outputCDATA(): CDATA not processed - internal error", $node->getNodeName()));
	} # if

	if($xmlState->isSelected($node)){

		$is_debug && printf STDERR ("outputCDATA(): parent '%s'\n", $node->getParentNode()->getNodeName());
		if($debug_collapse){
			$is_output && ($output_html .= sprintf('<C>%s</C>', $node->getData()));
		}else{
			#$is_output && ($output_html .= sprintf('%s', $node->getData())); 
			$is_output && ($output_html .= $node->getData()); 
		} # if

	} # if ... selected

} # outputCDATA()

# fixPerlExpression() - convert XML perl expression to one that can be eval()uated.

sub fixPerlExpression {
	my($expr) = @_;

	# Relational operators, -ne etc. -> != etc.
	# Note that string relational operators (ne, eq) remain unchanged.

	$expr =~ s/\s-le\s/ <= /oig;
	$expr =~ s/\s-lt\s/ < /oig;
	$expr =~ s/\s-eq\s/ == /oig;
	$expr =~ s/\s-ne\s/ != /oig;
	$expr =~ s/\s-gt\s/ > /oig;
	$expr =~ s/\s-ge\s/ >= /oig;

	# Logical operators, -and etc. -> && etc.

	$expr =~ s/\s-and\s/ && /oig;
	$expr =~ s/\s-or\s/ || /oig;

	# Variables, $variable -> $form{'variable'}

	$expr =~ s/\$([A-Za-z]\w*)/\$form{'$1'}/og;

	return $expr;

} # fixPerlExpression()

# evaluateIfCondition() - evaluate relational expression
# of the form (v1 [<=,-le,<,-lt,=,-eq,eq,!=,-ne,ne,>,-gt,>=,-ge] v2) [&&,-and,||,-or] (...)

sub evaluateIfCondition {
	my(%args) = @_;
	my($ifcondition) = $args{-ifcondition};
        
        # nothing to do unless defined $ifcondition
        return 0 unless defined($ifcondition);
        
	my $fixedIfCondition = fixPerlExpression($ifcondition);

	$is_debug && printf STDERR ("evaluateIfCondition(): ifcondition in '%s''\n", $ifcondition);

	# Evaluate the condition.

	my $truth = eval $fixedIfCondition;

	(defined($@) && $@ ne '') && mydie(sprintf('error: evaluateIfCondition(): invalid <IF> condition, original "%s" processed "%s" error "%s"', $ifcondition, $fixedIfCondition, $@));

	$is_debug && printf STDERR ("evaluateIfCondition(): ifcondition out '%s' truth %d\n", $fixedIfCondition, $truth);
        
        #my $truth_dbg = $truth;
        #$truth_dbg = "[NOT DEFINED]" if (not defined($truth_dbg));
        
        #$debug_html .= sprintf("<!-- DEBUG: evaluateIfCondition(): ifcondition '%s' truth '%s' -->\n",$fixedIfCondition,$truth_dbg);
        
        # set truth to '0', if not defined
        $truth = 0 if (not defined($truth));
        
        return $truth;

} # evaluateIfCondition()

# evaluateSet() - evaluate <SET name="var" value="expr">

sub evaluateSet {
	my(%args) = @_;
	my($value) = $args{-value};

	my $fixedValue = fixPerlExpression($value);

	$is_debug && printf STDERR ("evaluateSet(): value in '%s''\n", $value);

	# Evaluate.

	my $result = eval $fixedValue;

	(defined($@) && $@ ne '') && mydie(sprintf('error: evaluateSet(): invalid <SET> value, original "%s" processed "%s" error "%s"', $value, $fixedValue, $@));

	$is_debug && printf STDERR ("evaluateSet(): value out '%s' result %d\n", $fixedValue, $result);

	return $result;

} # evaluateSet()

# evaluatePrint() - evaluate <PRINT output="expr">

sub evaluatePrint {
	my(%args) = @_;
	my($output) = $args{-output};

	my $fixedOutput = fixPerlExpression($output);

	$is_debug && printf STDERR ("evaluatePrint(): output in '%s''\n", $output);

	# Evaluate.

	my $result = eval $fixedOutput;

	(defined($@) && $@ ne '') && mydie(sprintf('error: evaluatePrint(): invalid <PRINT> output, original "%s" processed "%s" error "%s"', $output, $fixedOutput, $@));

	$is_debug && printf STDERR ("evaluatePrint(): output out '%s' result '%s'\n", $fixedOutput, $result);

	return $result;

} # evaluatePrint()

# findParentElement() - find closest parent element that matches the specified tag RE pattern.

# If called in scalar context, returns undef if not found or reference to specified parent node.
#
# If called in array context, return array, array[0] is the parent
# and array[1] is the immediate child of the parent, array[2] is the next child
# and so on, on the path between the parent and -node, or between the root of the document and -node
# if not found.
#
# i.e. ($parentElement, $parentChildElement) = findParentElement(-elementName => '^RANDOM$', -node => ref to <R>) returns
# <RANDOM> <- $parentElement
#  <ol>    <- $parentChildElement
#   <R>    <- -node
#
# i.e. my @parents = findParentElement(-elementName => '^RANDOM$|^IF$|^R$', -node => ref to text) returns
#
# <IF>        <- 
#  <RANDOM>   <- 
#   <R>       <- $parents[0]
#    <TABLE>  <- $parents[1]
#     <TR>    <- $parents[2]
#      <TD>   <- $parents[3]
#       <B>   <- $parents[4]
#        text <- $parents[5]
#
# If -level is not defined or is 0 then search to root,
# otherwise search only the specified # of levels.

sub findParentElement {
	my(%args) = @_;
	my($node) = $args{-node};
	my($elementName) = $args{-elementName};
	my($level) = defined($args{-level}) ? $args{-level} : 0;

	my @parents = ();
	my $n = $level;

	if(wantarray()){
		unshift(@parents, $node); # starting node is $parents[$#parents]
	} # if

	my $parentNode = $node->getParentNode();
	while(($level == 0 || $n > 0) && defined($parentNode)){

		if(wantarray()){
			unshift(@parents, $parentNode); # parent node is $parents[0]
		} # if

		if($parentNode->getNodeType() == ELEMENT_NODE && $parentNode->getNodeName() =~ m/$elementName/i){
			last; # while
		} # if
	
		$parentNode = $parentNode->getParentNode();
		$n -= 1;

	} # while

	if(wantarray()){
		return @parents;
	}else{
		if(($level == 0 || $n == 1) && $parentNode->getNodeType() == ELEMENT_NODE && $parentNode->getNodeName() =~ m/$elementName/i){
			return $parentNode; # in scalar context, this will be undef if specified parent not found
		}else{
			return undef;
		} # if
	} # if ... array context

} # findParentElement()

# findPathToRoot() - starting at specified node return list of nodes between the root and this node

# Called in array context, return array, array[0] is the root
# and array[1] is the immediate child of the root, array[2] is the next child
# and so on, on the path between the parent and -node, or between the root of the document and -node
# if not found.
#
# i.e. my @parents = findPAthToRoot(-node => ref to text) returns
#
# root        <- $parents[0]
#  <RANDOM>   <- $parents[1]
#   <R>       <- $parents[2]
#    <TABLE>  <- $parents[3]
#     <TR>    <- $parents[4]
#      <TD>   <- $parents[5]
#       <B>   <- $parents[6]
#        text <- $parents[7]
#
# For each element of @parents, $i > 0, $parents[$i - 1] is the parent of $parents[$i].
# $parents[0] is the XML docuemnt root.
# $parents[$#@parents] is the specified node.

sub findPathToRoot {
	my(%args) = @_;
	my($node) = $args{-node};

	my @parents = ();

	unshift(@parents, $node); # starting node is $parents[$#parents]

	my $parentNode = $node->getParentNode();
	while(defined($parentNode)){

		unshift(@parents, $parentNode); # parent node is $parents[0]

		$parentNode = $parentNode->getParentNode();

	} # while

	return @parents;

} # findPathToRoot()

# getRandomOrder() - return array [ 0 .. -num - 1 ] randomized

sub getRandomOrder {
	my(%args) = @_;
	my($num) = $args{-num};

	my @r = ( 0 .. $num - 1 );

        #<MAX> 20030324 -> disable RANDOM, if set to $true
        unless ($disable_random) {
            Algorithm::Numerical::Shuffle::shuffle(\@r);
        }

	return @r;

} # getRandomOrder()

# StringToArray() - comma delimited string to array

sub StringToArray {
	my(%args) = @_;
	my($string) = $args{-string};

	my @array = split(/,/, $string);

	return @array;

} # StringToArray()

# ArrayToString() - array reference to comma delimited string

sub ArrayToString {
	my(%args) = @_;
	my($array_ref) = $args{-array};

	my $string = join(',',  @{$array_ref});

	return $string;

} # ArrayToString()

# cacheGet() - retrieve parsed XML page and associated state from cache.

sub cacheGet {
	my($page, $serialized_parsed_xml_file_name) = @_;
	
	# Cache enabled ?

	if($cache_max_entry <= 0){
		$debug_html .= sprintf("<!-- DEBUG: CACHE: cache disabled -->\n");
		return(undef, undef);
	} # if ... cache disabled
	$debug_html .= sprintf("<!-- DEBUG: CACHE: # pages cached %d, max pages that can be cached %d -->\n", $cache_num_entry, $cache_max_entry);

	# XML source file modification time.
	my $mtime_xml;
	my $dev_xml;
	my $ino_xml;
	($dev_xml, $ino_xml, undef, undef, undef, undef, undef, undef, undef, $mtime_xml, undef, undef, undef) = stat($page);

	# XML serialized parsed file modification time.
	my $mtime_ser;
	my $dev_ser;
	my $ino_ser;
	my $size_ser;
	($dev_ser, $ino_ser, undef, undef, undef, undef, undef, $size_ser, undef, $mtime_ser, undef, undef, undef) = stat($serialized_parsed_xml_file_name);

	$debug_html .= sprintf("<!-- DEBUG: CACHE: XML file '%s' mtime '%s' serialized file '%s' mtime '%s' -->\n", $page, defined($mtime_xml) ? scalar(localtime($mtime_xml)) : "<never>", $serialized_parsed_xml_file_name, defined($mtime_ser) ? scalar(localtime($mtime_ser)) : "<never>");

	my $key = $page;

	my $value = $cached_xml{$key};

	if(defined($value)){
		$debug_html .= sprintf("<!-- DEBUG: CACHE: XML file '%s' is in cache -->\n", $page);

		# In cache.

		#$is_debug && printf STDERR ("cacheGet(): hit parsed XML page for '%s' key '%s', num %d, max %d\n", $page, $key, $cache_num_entry, $cache_max_entry);
		#printf STDERR ("cacheGet(): hit parsed XML page for '%s' key '%s', num %d, max %d\n", $page, $key, $cache_num_entry, $cache_max_entry);

		# Compare TIME_CACHED with file modification time
		# and delete from cache if file different since last access.
		# We don't compare for a greater time as some FTP clients set 
		# the XML file modification time to that of the sender, not the
		# web server, and the times can be skewed.

		if(defined($mtime_xml) && $mtime_xml != $value->{TIME_CACHED}){

			# File updated since being cached.

			$debug_html .= sprintf("<!-- DEBUG: CACHE: XML file '%s' on disk more recent than cache, discarding cached version -->\n", $page);

			$value->{XMLSTATE_REF}->dispose(); # call before $value->{XMLPAGE_REF}->dispose()
			delete($value->{XMLSTATE_REF}); # delete XML document state
			$value->{XMLPAGE_REF}->dispose(); # delete parsed XML document

			# Delete the entry from cache

			delete($cached_xml{$key});
			$cache_num_entry -= 1;

			return(undef, undef);

		}else{

			# Cache entry valid.

			my $t_xmlState = $value->{XMLSTATE_REF};

			# Reset saved XML state.

			my $n = $t_xmlState->reset();

			$value->{LAST_TIME_ACCESSED} = time();

		$debug_html .= sprintf("<!-- DEBUG: CACHE: using cached version  of XML file '%s', %d nodes -->\n", $page, $n);

			return($value->{XMLPAGE_REF}, $value->{XMLSTATE_REF});
		} # if

	}elsif(defined($mtime_ser) && defined($mtime_xml)){

		# Not in cache.
		# Serialized version of parsed XML exists.

		$debug_html .= sprintf("<!-- DEBUG: CACHE: XML file '%s' is not in cache but serialized file exists -->\n", $page);

		if($mtime_xml > $mtime_ser){

			# XML page updated more recently than serialized data.

			$debug_html .= sprintf("<!-- DEBUG: CACHE: XML disk file '%s' more recent than serialized file, not using serilized file -->\n", $page);

			return(undef, undef);

		}else{

			# Read the saved XML data from the serialized file.
			# @@@ probably want to lock the file

			my $XMLPageRef;

			eval {
				# Ignore die() & warn() in eval		
				local $SIG{__DIE__} = sub { ; } ; 
				local $SIG{__WARN__} = sub { ; } ;

				$XMLPageRef = Storable::retrieve($serialized_parsed_xml_file_name);
			};
                        if (defined( $@ ) && $@ ne '') {
                            $serialized_parsed_xml_file_name =~ s|.*/||;
                            mydie(sprintf('error: rerieve() error "%s" for file "%s"', $@, $serialized_parsed_xml_file_name));
                        }

                        if(!defined($XMLPageRef)){
                                $serialized_parsed_xml_file_name =~ s|.*/||;
				die sprintf("cacheGet(): %s: thaw() '%s' error\n", scalar(localtime(time())), $serialized_parsed_xml_file_name);
			} # if

			# rebuild $xmlState from $XMLPage
			$XMLState = createXMLStateFromXMLPage($XMLPageRef);


			# Save it in the cache. Don't update the serialized file.
			cacheSet($page, '', $XMLPageRef, $XMLState);

			# Reset saved XML state.

			my $n = $XMLState->reset();

			my $value = $cached_xml{$key};
			defined($value) || mydie(sprintf('cacheGet(): expected page "%s" to be in cache but not there'), $key);

			$value->{LAST_TIME_ACCESSED} = time();

			$debug_html .= sprintf("<!-- DEBUG: CACHE: XML serialized file '%s' read into cache, %d nodes -->\n", $serialized_parsed_xml_file_name, $n);

			return($value->{XMLPAGE_REF}, $value->{XMLSTATE_REF});

		} # if
		
	}else{
		# Not in cache.

		$debug_html .= sprintf("<!-- DEBUG: CACHE: XML file '%s' is not in cache and serialized file does not exist -->\n", $page);

		return(undef, undef);
	} # if

} # cacheGet()

# cacheSet() - store parsed XML page and associated state in cache, toss oldest item if full

sub cacheSet {
	my($page, $serialized_parsed_xml_file_name, $XMLPageRef, $XMLStateRef) = @_;

	# Cache enabled ?

	if($cache_max_entry <= 0){
		return;
	} # if ... cache disabled

	my $key = $page; # @@@ should normalize name

	# Already in cache ?

	if(defined($cached_xml{$key})){
            
                $page =~ s|.*/||;
                $key  =~ s|.*/||;
		mydie(sprintf('cacheSet(): page "%s" key "%s" already in cache - internal error', $page, $key));

	} # if ... already in cache

	# Cache full ?

	if($cache_num_entry >= $cache_max_entry){

		$debug_html .= sprintf("<!-- DEBUG: CACHE: cache full -->\n");

		# Find the oldest entry in the cache and toss it.

		my $okey = undef; # key of oldest entry
		my $ovalue = undef; # oldest entry

		for my $k (keys(%cached_xml)) {

			my $v = $cached_xml{$k};

			if(!defined($ovalue) || ($v->{LAST_TIME_ACCESSED} < $ovalue->{LAST_TIME_ACCESSED})){
				$ovalue = $v;
				$okey = $k;
			} # if ... oldest entry so far

		} # for ... each entry in cache

		# Release the XML::DOC data

		if(defined($ovalue)){

			$debug_html .= sprintf("<!-- DEBUG: CACHE: deleted cache entry for page '%s' -->\n", $okey);

			$ovalue->{XMLSTATE_REF}->dispose(); # call before $value->{XMLPAGE_REF}->dispose()
			delete($ovalue->{XMLSTATE_REF}); # delete XML document state
			$ovalue->{XMLPAGE_REF}->dispose(); # delete parsed XML document

			# Delete the entry from cache

			delete($cached_xml{$okey});
			$cache_num_entry -= 1;

		}else{

                        $page =~ s|.*/||;
                        $key  =~ s|.*/||;
			mydie(sprintf("cacheSet(): cache full but failed to find entry to delete for page '%s' key '%s' - internal error", $page, $key));

		} # if

	} # if ... time to toss an entry

	# Store parsed XML page and associated state in cache.

	my $mtime_xml;
	(undef, undef, undef, undef, undef, undef, undef, undef, undef, $mtime_xml, undef, undef, undef) = stat($page);

	$cached_xml{$key} = {
	 PAGE => $page,
	 KEY => $key,
	 XMLPAGE_REF => $XMLPageRef, # save reference
	 XMLSTATE_REF => $XMLStateRef, # save reference
	 LAST_TIME_ACCESSED => time(),
	 TIME_CACHED => $mtime_xml, # use XML file modification time in case XML file time and web server time not same
	};

	$cache_num_entry += 1;
	$debug_html .= sprintf("<!-- DEBUG: CACHE: added XML file '%s' to cache ' -->\n", $page);

	if(defined($serialized_parsed_xml_file_name) && $serialized_parsed_xml_file_name ne ''){
		# Serialize the parsed XML data into a file.
		# @@@ probably want to lock it

		my $value = Storable::store($XMLPageRef, $serialized_parsed_xml_file_name);
		# Set the mtime of the serialized file to that of the XML file
		# so that modification times can be compared.
		utime($mtime_xml, $mtime_xml, $serialized_parsed_xml_file_name);

		$debug_html .= sprintf("<!-- DEBUG: CACHE: serialized XML file '%s' to '%s' ' -->\n", $page, $serialized_parsed_xml_file_name);

	} # if ... update serialized page


} # cacheSet()

# parse_form_data() - parse form content and put into %form associative array.

sub parse_form_data {
        my($request_method) = $ENV{'REQUEST_METHOD'};
        if(!defined($request_method)){
		mydie('error: REQUEST_METHOD not defined');
        } # if

        # Allow GET or POST methods.

	my $content = '';

        if($request_method eq 'GET'){

                # Request is a GET.

                if(defined($ENV{'QUERY_STRING'})){
                        $content = $ENV{'QUERY_STRING'};
                }else{
			mydie('error: QUERY_STRING not defined for GET method');
                } # if

        }elsif($request_method ne 'POST'){
		mydie(sprintf('error: REQUEST_METHOD "%s" is not "GET" or "POST"', $request_method));
        }elsif(!defined($ENV{'CONTENT_LENGTH'})){
		mydie('error: CONTENT_LENGTH not defined for GET method');
        }else{ # POST
                my($content_length) = $ENV{'CONTENT_LENGTH'};
                sysread(STDIN, $content, $content_length);
	} # if ... POST

	# Split into field=value items.

	my(@fvs) = split(/\&/, $content);

	# Split each field=value item into a field, value pair and store
	# in the associative array.

	foreach my $fv (@fvs) {

		my($name, $value) = split(/=/, $fv);


		if(!defined($value)){
			$value = '';
		} # if

		# Convert %XX from hex numbers to alphanumeric

		$name =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
		$value =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
		$value =~ s/\+/ /g;

		# If variable assigned a value via <SET> and <INPUT>,
		# the first value only is used.

		if(!defined($form{$name})){
			$form{$name} = $value;
		} # if .. not already assigned a value

	} # for ... each field=value item

} # parse_form_data()

# get_cookies() - return cookies in associative array

sub get_cookies {

	my $http_cookie = $ENV{'HTTP_COOKIE'};
	if(!defined($http_cookie)){
		$http_cookie = '';
	} # if

        #<MAX> 20030325 -> sessionID
        #$debug_html .= sprintf("<!-- DEBUG: get_cookies(): \$http_cookie '%s' -->\n", $http_cookie);
        
        my @rawCookies = split (/; /, $http_cookie);
	my %cookies;

	for my $c (@rawCookies){
            my($key, $val) = split (/=/, $c);
            $cookies{$key} = $val;
            
            #<MAX> 20030325 -> sessionID
            #$debug_html .= sprintf("<!-- DEBUG: get_cookies(): Setting form var 'cookie_%s' to '%s' -->\n", $key, $val);
            
            $form{'cookie_' . $key} = $val; # map cookie into form variable
	} # for ... each cookie

	return %cookies; 

} # get_cookies()

# get_env() - map environment variables into form variable

sub get_env {

	# IIS Perl does not load all the interesting CGI ENV variables, so do it now.

	my @env_list = qw/GATEWAY_INTERFACE
		HTTPS
		HTTP_ACCEPT
		HTTP_ACCEPT_ENCODING 
		HTTP_ACCEPT_LANGUAGE
		HTTP_CONNECTION
		HTTP_HOST
		HTTP_REFERER 
		HTTP_USER_AGENT
		PATH
		REMOTE_ADDR
		REMOTE_HOST
		REQUEST_METHOD 
		SCRIPT_NAME
		SERVER_NAME
		SERVER_PORT
		SERVER_PROTOCOL
		SERVER_SOFTWARE 
		SERVER_URL
		SYSTEMROOT
		CONTENT_LENGTH/;

	my $junk = '';
	for my $k (@env_list) {
		$junk = $ENV{$k};
	} # for

	for my $key (keys(%ENV)){
		my $v = $ENV{$key};
		$v =~ s/[\r\n]/ /g;
		    $form{'env_' . $key} = $v; # map evnvironment variable into form variable
	} # for ... each environment variable

} # get_env()

# set_cookie() - emit HTTP set cookie header line
# Set-Cookie: sessionID=xyzzy; domain=.appname05site.net; path=/; expires=Wed, 20-Feb-2002 20:14:15 GMT

sub set_cookie {
	my($name, $value, $expiration, $path, $domain, $secure) = @_;

	my $set_cookie = 'Set-Cookie: ';
	$set_cookie .= "$name=$value; path=$path; domain=$domain";
	if(defined($expiration) && $expiration ne ''){
		$set_cookie .= "; expires=$expiration";
	} # if ... cookie expiration date defined

	if(defined($secure) && $secure ne ''){
		$set_cookie .= ";$secure";
	} # if ... cookie is secure

	$set_cookie .= "\n";
        
        #<MAX> 20030325 -> sessionID
        #$debug_html .= sprintf("<!-- DEBUG: set_cookie(): Setting cookie to '%s' -->\n", $set_cookie);

	return $set_cookie;

} # set_cookie()

# new_sessionID() - assign a new, unique sessionID

sub new_sessionID {

	# Unique ID with validation data.
	# When a session ID is decoded/decrypted, 
	# the validation data must be present, 
	# otherwise the sessionID has been diddled.

	return uniqueid();

} # new_sessionID()

# get_sessionID_cookie - generate HTTP Set-Cookie for sessionID cookie

sub get_sessionID_cookie {

	# encrypt/encode the sessionID so it not immediately obvious what it is.
    
        #<MAX> 20030325 -> sessionID
        #$debug_html .= sprintf("<!-- DEBUG: get_sessionID_cookie(): Calling set_cookie()... -->\n");

	my $cookie = set_cookie('sessionID', encode_sessionID($sessionID), get_cookie_expire_date(), $sessionID_cookie_path, $sessionID_cookie_domain);

	return $cookie;

} # get_sessionID_cookie()

# get_cookie_expire_date - return expire date for setting cookie in the form
#  "Fri, 01-Mar-2002 00:00:00 GMT". Cookie expires 1 year from now

sub  get_cookie_expire_date {
	($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime(time() + (60*60*24*365));

	return sprintf('%s, %02d-%s-%04d %02d:%02d:%02d GMT',
                ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')[$wday],
                $mday, 
                ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$mon],
                $year + 1900, $hour, $min, $sec
               );

} # get_cookie_expire_date()

# encode_url() - escape magic characters in URL

sub encode_url {
	my($url) = @_;
        
        #<MAX> 20030325 -> sessionID: use CPAN module
        $url = enurl($url);
        
	return $url;

} # encode_url()

#<MAX> 20030325 -> sessionID
# decode_url() - de-escape magic characters in URL: it does the opposite to encode_url()

sub decode_url {
	my($url) = @_;
        
        #<MAX> 20030325 -> sessionID: use CPAN module
        $url = deurlstr($url);

	return $url;

} # decode_url()

#<MAX> 20030325 -> sessionID
# is_url_encoded() - returns 'true', if the string is URL-encoded
# The function is needed because cookies are not encoded but the $form{'sessionID'} is.

sub is_url_encoded {
	my($url) = @_;
        
        if ($url =~ /%\w\w/) {
            return 1;
        } else {
            return 0;
        }
} # is_url_encoded()

# encode_sessionID() - encode sessionID

sub encode_sessionID {
	my($decoded_sessionID) = @_;
        
        #<MAX> 20030325 -> sessionID
        #$debug_html .= sprintf("<!-- DEBUG: encode_sessionID(): decoded_sessionID '%s' -->\n", $decoded_sessionID);

	if(!defined($decoded_sessionID)){
                #<MAX> 20030325 -> sessionID
                #$debug_html .= sprintf("<!-- DEBUG: encode_sessionID(): decoded_sessionID is 'undef' -->\n");
		return '';
	}else{
		my $encoded_sessionID = MIME::Base64::encode($cgi_cipher->encrypt($decoded_sessionID . $sessionID_delim . $sessionID_trailer), '');
                #<MAX> 20030325 -> sessionID
                #$debug_html .= sprintf("<!-- DEBUG: encode_sessionID(): encoded_sessionID is '%s' -->\n", $encoded_sessionID);
		return $encoded_sessionID;
	} # if

} # encode_sessionID()

# decode_sessionID() - decode sessionID

sub decode_sessionID {
	my($encoded_sessionID) = @_;
        
        #<MAX> 20030325 -> sessionID
        #$debug_html .= sprintf("<!-- DEBUG: decode_sessionID() start: encoded_sessionID '%s' -->\n", $encoded_sessionID);

	my $decoded_sessionID = '';

	if(defined($encoded_sessionID)){

            if (is_url_encoded($encoded_sessionID)) {
                
                #<MAX> 20030325 -> sessionID, URL decode the $encoded_sessionID before decrypting
                $encoded_sessionID = decode_url($encoded_sessionID);
                
                #<MAX> 20030325 -> sessionID
                #$debug_html .= sprintf("<!-- DEBUG: decode_sessionID(): de-URLed encoded_sessionID '%s', length '%d' -->\n", $encoded_sessionID, length($encoded_sessionID));
            }
        
            while((length($encoded_sessionID) % 4) != 0){
                $encoded_sessionID .= '=';
            }

            #<MAX> 20030325 -> sessionID
            #$debug_html .= sprintf("<!-- DEBUG: decode_sessionID(): encoded_sessionID before MIME::decode '%s', length '%d' -->\n", $encoded_sessionID, length($encoded_sessionID));
            
            $decoded_sessionID = $cgi_cipher->decrypt(MIME::Base64::decode($encoded_sessionID));
            
            #<MAX> 20030325 -> sessionID
            #$debug_html .= sprintf("<!-- DEBUG: decode_sessionID(): decoded_sessionID after encryption '%s' -->\n", $decoded_sessionID);

            my(@f) = split(/$sessionID_delim/o, $decoded_sessionID);

            # If the session if is not valid, assign a new one.

            if(scalar(@f) != 2){
                $f[0] = new_sessionID();
                $debug_html .= sprintf("<!-- DEBUG: SESSIONID: invalid format for session ID '%s' -->\n", $encoded_sessionID);
            }elsif($f[1] ne $sessionID_trailer){
                $f[0] = new_sessionID();
                $debug_html .= sprintf("<!-- DEBUG: SESSIONID: invalid trailer for session ID '%s' -->\n", escape($decoded_sessionID));
            } # if

            $decoded_sessionID = $f[0];

	} # if

	return $decoded_sessionID;

} # decode_sessionID()

sub get_sessionID {
  return $sessionID;
} # get_sessionID();

} # package appname05BIN
