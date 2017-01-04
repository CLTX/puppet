use lib "../bin"; # get into the appname05BIN namespace

package sendMail; 

=head1 NAME

C<sendMail>

=head1 VERSION

	$Id: sendMail.pm,v 1.11 2005/03/14 22:36:05 maxim Exp $

=head1 SYNOPSIS

	<!-- Create a new email message object. -->
	<SET name="msg" export="no" show="no"
	 value="new sendMail (
		'to@somewhere.com',
		'from@appname05site.com',
		'reply-to@appname05site.com', 
		'bcc@appname05site.com', 
		'This message has no subject.', 
		$dir, 
		'message.txt', 
		'message.htm', 
		'mess.log',
		'ONE', 'First parameter: named ONE.',
		'TWO', 'Second parameter: named TWO.');" 
	/>
	<!-- 
		You can also add or change parameters (used to generate
		the messages from the templates) after creating the
		message object. 
	-->
	<SET show="no" export="no" name="junk" value="$msg->set_param('foo', 'Krispy Creme Donuts rule.'" />
	<!--- 
		You can even remove parameters, if you want to. 
	-->
	<SET show="no" export="no" name="junk" value="$msg->del_param('foo')" />
	<!-- 
		Allow sending of duplicates to same recipient.
		DO NOT USE unless recipient address is hardcoded or you're
		using cleanSave to control duplicates as described below.
		Default behaviour is to check the message log (as specified
		by the 9th parameter of new).
	-->
	<SET name="junk" show="no" export="no" value="$msg->allow_duplicates(1);" />
	<!-- 
		If your appname05 uses cleanSave (which it probably should)
		then you can use the faster and more efficient result 
		obtained from the cleansave module to control duplicate
		sends.
	-->
	<SET show="no" export="no" name="status" value="cleanSave();" />
	<SET show="no" export="no" name="junk" value="$msg->sent(not CS_OK == $status)" />
	<!-- 
		You typically want to send the message immediately.
		Here's how to do that.  Otherwise the message will
		be sent about 3 to 15 minutes after the appname05 is
		completed.
	-->
	<SET show="no" export="no" name="junk" value="$msg->send_now;" />

=head1 DETAILS

=cut

##############################################################################
use strict;
use warnings FATAL => 'all';		# paranoia => max
use integer;				# strictly integer math

# use Date::Parse;			# un-used???

use Carp;
use dbTools;				# for db file stuff
use File::Basename;
use File::Spec::Functions qw(rel2abs);
use fTools;				# provides rmkdir
use Net::SMTP;				# used to send messages
use MIME::Entity;			# used to build mime messages
#use Mail::Date;			# requies Perl 5.8
use HTML::Template;			# used for message tempates
use Text::Iconv;
Text::Iconv->raise_error(0);		# will catch errors instead.
#use Log::Log4perl;			# logging, debugging, etc.
use LWP::UserAgent;
use HTTP::Request::Common qw(GET POST);

our $VERSION = '$Revision: 1.11 $';	# good programmers use CVS!
$VERSION     =~ s/^\D*(\S*).*$/$1/o;
sub VERSION () { $VERSION; }

##############################################################################

=head2 C<new ($to, $from, $reply, $bcc, $subject, $dir, $text, $html, $log, ...)>

Create a new sendMail object to send a message from within a appname05.  You 
can't B<EXPORT> it or manipulate it from any other pages, so don't bother 
trying.  The parameters are as follows:

=over 4

=item C<$to>

Address to send message to.

=item C<$from>

Address to say message is from.

=item C<$reply>

Address used in Reply-To: header of message.

=item C<$bcc>

Blind Carbon Copy address.  (Typically used to verify messages have been sent.)

=item C<$subject>

The subject of the message.

=item C<$dir>

The appname03ory to look in for the following templates as well as any other
stuff such as attached images.

=item C<$text>

File name of the plain text message template.  Assumed to be in C<$dir>.

=item C<$html>

File name of the html message template.  Assumed to be in C<$dir>.

=item C<$log>

File name for the message log.  B<NOT> assumed to be in C<$dir>.  
This file will be automatically created if it does not already exist.  If
you want to add extra information to this log file (please only add message
relevant stuff) see the C<log_entry> function which follows.

=item C<...>

Name, Value pairs used to substitute into the text and html templates.  See 
also C<set_param> and C<del_param>.

=back

	<SET name="msg" export="no" show="no"
	 value="new sendMail (
		'recipient@somewhere.com',
		'sender@foo.bar',
		'replyto@foo.bar',
		'blindcopy@foo.bar',
		'This message has no subject.',
		$dir,
		'mess.txt',
		'mess.htm',
		'mess.log',
		'ONE', 'First parameter: named ONE.',
		'TWO', 'Second parameter: named TWO.');"
	/>

=cut

# no proto since can take any number of parameters
sub new {
	my $this = shift @_;
	my $class = ref($this) || $this;

	my %self;
	$self{'to_address'}	= lc shift; # lower case all addresses
	$self{'from_address'}	= lc shift;
	$self{'reply_address'}	= lc shift;
	$self{'bcc_address'}	= lc shift;
	$self{'subject'}	= shift;
	$self{'appname03ory'}	= shift;
	$self{'textfile'}	= shift;
	$self{'htmlfile'}	= shift;
	$self{'logfile'}	= shift;
	$self{'dbfile'}		= '';

	my %values;			# get extra parameters
	while($#_ > 0) {
		my $name	= shift;
		my $value	= shift;
		$values{$name}	= $value;
	}

	$self{'values'} = \%values;	# store values
	$self{'check_log'} = 1; 	# check against log by default
	$self{'check_db'} = 0;		# don't use db file by default
	$self{'sent'} = 0;		# haven't sent a message yet
	$self{'wait_until'} = 0;	# don't delay by default
        $self{'server'} = '127.0.0.1';	# default to using the localhost
        #$self{'server'} = 'mm1.appname05sitemail.com';	# XNET
	$self{'recode_params_to'} = 'UTF-8';	# don't, by default

#	my $log = Log::Log4perl->new($class);
#	$log->debug('New sendMail: ', $self{'to'}, ', ', $self{'from'},
#		    ',', $self{'subject'});

	return bless \%self, $class;	# bless me!
} # new()


##############################################################################

=head2 Accessor Functions

Accessor functions all support the get/set paradigm of data access.  If
called without a parameter, it gets the current state.  If called with a
parameter, it sets the state to the value of the parameter.  For example:

	<!-- Get the current recipient address. -->
	<SET show="no" export="no" name="current_to_address" value="$msg->to" />

	<!-- Set the recipient address. -->
	<SET show="no" export="no" name="junk" value="$msg->to('someone_else@somewhere_else.com');" />

=cut

##############################################################################

=head3 C<server (E<lt>$mail_serverE<gt>)>

Accessor function to control which B<server> to use for sending.  
Defaults to localhost (C<127.0.0.1>).
Don't touch unless you I<know what you're doing>.

=cut

sub server {
        my $self = shift;
        @_ ? $self->{'server'} = lc shift
           : $self->{'server'};
}

##############################################################################

=head3 C<to (E<lt>$addressE<gt>)>

Accessor function to control B<recipient> address.  
All addresses are lowercased.

=cut

sub to {
	my $self = shift;
	@_ ? $self->{'to_address'} = lc shift
	   : $self->{'to_address'};
}

##############################################################################

=head3 C<from (E<lt>$addressE<gt>)>

Accessor function to control B<From> address.
All addresses are lowercased.

=cut

sub from {
	my $self = shift;
	@_ ? $self->{'from_address'} = lc shift
	   : $self->{'from_address'};
}


##############################################################################

=head3 C<reply (E<lt>$addressE<gt>)>

Accessor function to control B<Reply-To> address.
All addresses are lowercased.

=cut

sub reply {
	my $self = shift;
	@_ ? $self->{'reply_address'} = lc shift
	   : $self->{'to_address'};
}


##############################################################################

=head3 C<bcc (E<lt>$addressE<gt>)>

Accessor function to control B<BCC> address.
All addresses are lowercased.

By setting BCC to an empty string you can disable bcc sends.

=cut

sub bcc {
	my $self = shift;
	@_ ? $self->{'bcc_address'} = lc shift
	   : $self->{'bcc_address'};
}


##############################################################################

=head3 C<subject (E<lt>$subjectE<gt>)>

Accessor function to control B<Subject>.

=cut

sub subject {
	my $self = shift;
	@_ ? $self->{'subject'} = shift
	   : $self->{'subject'};
}


##############################################################################

=head3 C<tmpl_path (E<lt>$pathE<gt>)>

Accessor function to control the path to the template files.

=cut

sub tmpl_path {
	my $self = shift;
	@_ ? $self->{'appname03ory'} = shift
	   : $self->{'appname03ory'};
}


##############################################################################

=head3 C<text_tmpl (E<lt>$file_nameE<gt>)>

Accessor function to control the file name of the text template.

=cut

sub text_tmpl {
	my $self = shift;
	@_ ? $self->{'textfile'} = shift
	   : $self->{'textfile'};
}


##############################################################################

=head3 C<html_tmpl (E<lt>$file_nameE<gt>)>

Accessor function to control the file name of the html template.

=cut

sub html_tmpl {
	my $self = shift;
	@_ ? $self->{'htmlfile'} = shift
	   : $self->{'htmlfile'};
}


##############################################################################

=head3 C<log_file (E<lt>$path_nameE<gt>)>

Accessor function to control the path and name of the log file.

=cut

sub log_file {
	my $self = shift;
	@_ ? $self->{'logfile'} = shift
	   : $self->{'logfile'};
}


##############################################################################

=head3 C<db_file (E<lt>$path_nameE<gt>)>

Accessor function to control the path and name of the db file.  If you don't
set the db file then all db functionality will be dissabled.  This is the
backwards compatible default.

=cut

sub db_file {
	my $self = shift;
	@_ ? $self->{'dbfile'} = shift
	   : $self->{'dbfile'};
}


##############################################################################

=head3 C<allow_duplicates (E<lt>$booleanE<gt>)>

Accessor function for C<allow_duplicates>.  When set to 1 it dissables the
sendMail module's internal duplicate checking.   This means you probably 
want to be using some kind of external duplicate checking.  Currently there
are two internal duplicate checking methods available: log file and db file.
Log file checking is used by default.

This snippet demonstrates how to test if duplicates are currently
allowed.

	<IF cond="$msg->allow_duplicates" show="no">
		<!-- I'm can send more than one message to the same address. -->
	<ELSE />
		<!-- I'm not allowed to send multiple messages. -->
	</IF>

This snippet demonstrates how to allow duplicates for a message.
Set C<allow_duplicates> to C<1> to allow sending multiple messages 
to the I<same recipient>.  B<Do not use this unless you have hardcoded
the recipient or are using some other method to make sure we don't 
send multiple emails to people!> 

	<SET name="junk" show="no" export="no" value="$msg->allow_duplicates(1);" />

=cut

sub allow_duplicates {
	my $self = shift;	

	if ( @_ ) {				# settor
		my $state = shift;
		if ($state) {			# disable checking
			$self->check_log(0);
			$self->check_db(0);
		} else {			# use default checking
			$self->check_log(1);
			$self->check_db(0);
		}
	}
	return not ($self->check_log or $self->check_db);
}


##############################################################################

=head3 C<check_log (E<lt>$booleanE<gt>)>

Accessor function for C<check_log>.
Defaults to C<1>.

=cut

sub check_log {
	my $self = shift;	

	@_ ? $self->{'check_log'} = shift
	   : $self->{'check_log'};
}


##############################################################################

=head3 C<check_db (E<lt>$booleanE<gt>)>

Accessor function for C<check_db>.
Defaults to C<0>.

=cut

sub check_db {
	my $self = shift;	

	@_ ? $self->{'check_db'} = shift
	   : $self->{'check_db'};
}


##############################################################################

=head3 C<sent (E<lt>$booleanE<gt>)>

Accessor function for C<sent>.  Initially C<0>, gets set to C<1> when
message is actually sent.  Can be used to check if message has been sent 
yet.  B<NOTE>: messages are sent by default on the destruction of the 
C<sendMail> object, which happens after the page has passed through the 
appname05 engine and perl decides to "garbage collect" the now defunct mail 
object.

Check to see if the message has been sent:

	<IF cond="$msg->sent" show="no">
		<!-- message has already been sent -->
	<ELSE />
		<!-- message has not been sent yet -->
	</IF>

Abort sending of message by pretending it's already been sent:

	<SET show="no" export="no" name="junk" value="$msg->sent(1)" />

Here's an example demonstrating how to use C<cleanSave> to avoid sending
duplicate messages, even when you need to send multiple messages to the same 
recipient, requiring you to use C<allow_duplicates>.  This will not stop 
"blacklisted" submitters (such as clients who insist on "testing" appname05s 
on production servers) from sending email.

	<SET show="no" export="no" name="status" value="cleanSave();" />
	<SET show="no" export="no" name="junk" value="$msg->allow_duplicates(1);" />
	<SET show="no" export="no" name="junk" value="$msg->sent(CS_DUPLICATE == $status)" />

B<NOTE>: if you want do this without calling C<cleanSave>, you can use the
following I<before> you call C<cleanSave>:

	<SET show="no" export="no" name="status" value="checkData();" />
	<SET show="no" export="no" name="junk" value="$msg->allow_duplicates(1);" />
	<SET show="no" export="no" name="junk" value="$msg->sent(CS_DUPLICATE == $status)" />

Or alternatively, to stop all but "OK" submissions:

	<SET show="no" export="no" name="status" value="cleanSave();" />
	<SET show="no" export="no" name="junk" value="$msg->allow_duplicates(1);" />
	<SET show="no" export="no" name="junk" value="$msg->sent(not CS_OK == $status)" />

=cut

sub sent {
	my $self = shift;
	@_ ? $self->{'sent'} = shift
	   : $self->{'sent'};
}


##############################################################################

=head3 C<recode_params_to ($charset)>

If you have the pleasure of dealing with a non-english appname05 for a client
who's not UTF-8 compliant, you'll need to recode your outgoing parameter
values to match the templates encoding. This is where you specify the 
outbound encoding. Standard accessor function, but also creates a
converter (or fails and dies with warning message).

=cut

sub recode_params_to {
	my $self = shift;
	my $charset = shift or return $self->{'recode_params_to'};

	$self->{'param_converter'} = Text::Iconv->new('UTF-8', $charset);
	$self->{'recode_params_to'} = $charset;
}



##############################################################################

=head2 C<set_param ($name, $value)>

Add (or replace) a parameter for substitution into the html and text 
templates.  

For example, every instance of C<E<lt>TMPL_VAR NAME="foo"E<gt>> in the
text and html message template will replaced with the phrase "C<You should
give Drew a Krispy Creme Donut.>"  (not including any quotes.)

	<SET show="no" export="no" name="junk" value="$msg->set_param('foo', 'You should give Drew a Krispy Creme Donut.'" />

=cut

sub set_param ($$$) {
	my ($self, $k, $v) = @_;
	$self->{'values'}->{$k} = $v;
}

##############################################################################

=head2 C<get_param ($name)>

Get the value of a parameter for substitution into the templates.

=cut

sub get_param ($$) {
	my ($self, $k) = @_;
	return undef unless exists $self->{'values'}->{$k};
	return $self->{'values'}->{$k};
}

##############################################################################

=head2 C<del_param ($name)>

Remove a parameter for substitution into the html and test templates.
This may not be terribly usefull right now, but our usage of email seems 
to be on the rise.  We'll probably end up sending even more complicated
emails in the future (with perhaps conditional text controlled by the 
parameters), so this function is available.

	<SET show="no" export="no" name="junk" value="$msg->del_param('foo')" />

=cut

sub del_param ($$) {
	my ($self, $k) = @_;

	my $values = $self->{'values'};
	delete $$values{$k};
}

##############################################################################

=head2 C<dump_params()>

Dump all parameters into a plain text string for debugging.

=cut

sub dump_params ($) {
	my $self = shift;
	my %values = %{$self->{'values'}};

	my $result_str = '';
	while (my ($k, $v) = each %values) {
		$result_str .= "$k \t: $v\n";
	}
	return $result_str;
}

##############################################################################
# internal usage only: generates the message from the templates
sub make_msg ($) {
	my $self = shift;
	my $values = $self->{'values'};

	# first, recode the parameters if requested...
	if ($self->{'param_converter'}) {
		my $c = $self->{'param_converter'};
		while (my ($k, $v) = each %$values) {
			eval { $values->{$k} = $c->convert($v); };
			return 0 if $@;
		}
	}

	# format of message:
	# multipart/alternative
	# 	text/plain
	# 	multipart/related
	# 		text/html
	# 		images (as needed)
	
	my $texttmpl = HTML::Template->new( 
		filename => $self->{'appname03ory'} . '/' . $self->{'textfile'}, 
		die_on_bad_params => 0 
	);

	my $htmltmpl = HTML::Template->new( 
		filename => $self->{'appname03ory'} . '/' . $self->{'htmlfile'},
		die_on_bad_params => 0 
	);

	while (my ($k, $v) = each %$values) {
		$texttmpl->param($k, $v);
		$htmltmpl->param($k, $v);
	}

	#my $ts = datetime_rfc2822(time + $self->{'wait_until'}, '?????');

	my $msg = MIME::Entity->build( 
		To		=> $self->{'to_address'},
		From		=> $self->{'from_address'}, 
		Bcc		=> $self->{'bcc_address'},
		'Reply-To'	=> $self->{'reply_address'},
		Subject 	=> $self->{'subject'},
	#	Date		=> $ts,
	#	'Priority:'	=> 'bulk',
	#	'X-Priority:'	=> 'bulk',
		Encoding	=> '8bit',
		Type		=> 'multipart/alternative'
	);
	
	my $plain = $msg->attach( 
		Type		=> 'text/plain; charset=' .
				   $self->{'recode_params_to'},
		Encoding	=> '8bit',
		Data		=> [ $texttmpl->output() ] 
	);
	
	my $fancy = $msg->attach(
		Type 		=> 'multipart/related',
		Encoding	=> '8bit'
	);
	
	$fancy->attach(
		Type		=> 'text/html; charset=' .
				   $self->{'recode_params_to'},
		Encoding 	=> '8bit',
		Data		=> [ $htmltmpl->output() ] 
	);
	
	# if gif html should have <IMG SRC="cid:1809mt.gif" ....
	#
	#   $fancy->attach( Path     => '1809mt.gif',
	#                   Type     => 'image/gif',
	#                   Encoding => 'base64',
	#                   Id       => '1809mt.gif' );
	
	$self->{'msg'} = $msg;

	return 1;
} # end make_msg ($self)


##############################################################################

=head2 C<can_send>

Tells you if the message will be sent.  Returns C<1> for yes and C<0> for no.

=head3 Rules for determining sendability. 

=over 4

=item 1

Messages will not be sent if they have already been sent by this object. 
For example by using C<send_now> (although you can change that, see 
C<sent> above).

=item 2

Messages will always be send when called dirrectly from a script in a
non-cgi environment. 

=item 3

Messages will always be sent if you're running on B<dev>.

=item 4

Messages will not be sent if the message log indicates that a message 
has already been sent to the recipient (by another instance of the 
sendMail object), unless either C<ignore_log> or C<allow_duplicates> is 
set.  (They currently have the same effect, but might not in the future).

=item 5

Otherwise we'll send the message.

=back

	<IF cond="$msg->can_send" show="no">
		<!-- I can send this message according to the rules. -->
	<ELSE />
		<!-- I can't send this message according to the rules. -->
	</IF>

=cut

sub can_send ($) {
	my $self = shift;

	# don't send more than once per object!
	return 0 if $self->sent;
#	$self->log_entry("Haven't sent yet.\n");

	# always send when running under a non-cgi environment.
	return 1 unless	defined $ENV{'SERVER_NAME'};
#	$self->log_entry("SERVER_NAME is defined, running in CGI environment.\n");
	
	# always send when running on a machine named dev
	return 1 if $ENV{'SERVER_NAME'} =~ /dev/o;
#	$self->log_entry("SERVER_NAME isn't dev.\n");

	# otherwise make sure it's not in the log already.
	return 0 if $self->check_log && $self->in_log;

	# and not in the db file...
	return 0 if $self->check_db && $self->in_db; 

	return 1;				# by default, send.
}


##############################################################################

=head2 C<send_now>

Force an immediate send of the message.  By default, messages are sent
after the page is done processing. Returns 1 on success, 0 on failure.

	<SET show="no" export="no" name="send_status" value="$msg->send_now" />

=cut

sub send_now ($) {
	my $self = shift;

	do {	$self->log_entry("WARNING: message already sent:\t" . 
				 $self->{'to_address'} );
		return 0;
	} unless $self->can_send();

	$self->make_msg() or return 0;
	$self->send_msg() or do {
		$self->log_entry("NOTICE: failed to send message: $!");
		return 0;
	};
	return 1;
}


##############################################################################

=head2 C<send_later (E<lt>$whenE<gt>)>

B<NOT IMPLEMENTED! WRITE ME!>

Queue the message for delayed delivery.
Message will be delivered B<after> the delay expires.  

$when can be in one of two formats:

offset (ie +1 23:59:59 = now + 1 day, 23 hours, ...)

absolute (ie "2003-12-31 23:59:59") Timezone offsets are not supported.

=cut

sub send_later ($$) {
	my ($self, $when_str) = @_;

	die "NOT SUPPORTED YET!\n";
	
	# parse when_str into a numeric time timelocal?

	# create the message with the appropriate time (modify make_msg)
	#$self->make_msg();

	# write the message to a file (naming convention?) in a temp dir

	# put the appropriate date in the timestamp

	# move the message from the temp dir to the delay queue dir?
	# or better still insert $time -> $file_name into a queue db?
	# then need to write a queue runner... 
}


##############################################################################
# internal function to send the message
sub send_msg ($) {
	my $self = shift;
	
	my $smtp = Net::SMTP->new($self->server) or do {
		$self->log_entry("ERROR: couldn't connect to mail server " .
			$self->server . ": $!");
		return 0;
	};
	$smtp->mail($self->from);
	$smtp->recipient($self->to);
	$smtp->recipient($self->bcc) unless $self->bcc eq '';
	$smtp->data();
	$smtp->datasend( $self->{'msg'}->as_string );
	$smtp->dataend();
	$smtp->quit;

	# make an entry in the log
	$self->log_entry("Mail Sent:\t" . 
		$self->to . "\t" . 
		$self->subject . "\t" . 
		$self->from . "\t" . 
		scalar localtime() . "\n");

	# and entry in the db file?
	dbAdd($self->db_file, $self->to, time) 
		unless $self->db_file eq '';

	# remember that we've sent already!
	$self->sent(1);
	return 1;
}


##############################################################################

=head2 C<get_abs_log_file>

Returns the full absolute path and of the log file.

=cut

sub get_abs_log_file ($) {
	my $self = shift;

	return rel2abs $self->log_file;
}

##############################################################################

=head2 C<touch_log>

Creates both the log file and any dirrectories or subdirs necessary.

=cut

sub touch_log ($) {
	my $self = shift;

	touch_dir $self->log_file or do {
		warn "Can't make dir for log file ", $self->log_file, ": $!\n";
		return 0;
	};
	open (TOUCH, '>>', $self->log_file) or do {
		warn "Can't open/create logfile ", $self->log_file, ": $!\n";
		return 0;
	};
	close TOUCH;
	return 1;
}


##############################################################################

=head2 C<in_db>

Test if an address exists in the db file.  Currently used internally, but
may be usefull.

=cut

sub in_db ($) {
	my $self = shift;

	if ($self->db_file eq '') {
		return 0;			# not in if no file
	} else {
		return dbExists $self->db_file, $self->to;
	}
}


##############################################################################

=head2 C<in_log>

Test if an address exists in the message log.  Currently used internally, 
but perhaps may be useful externally too.

=cut

sub in_log ($) {
	my $self = shift;

	$self->touch_log or do {;	# make sure log file and subdirs exist.
		warn "Can't create logfile/dir " . $self->log_file . ": $!\n";
		return 0;		# error -> not in log?
	};
	my $to = $self->to;
	my $match = qr/^Mail Sent:\t$to\t/o;
	open LOG, '<' . $self->log_file or do {
		warn "Can't read " . $self->log_file . ": $!\n";
		return 0;		# no log file -> not in log.
	};
 	flock LOG, 1;			# 1 is for shared lock.
 	while (<LOG>) { 		# for each line in the log file...
		if (/$match/o) { 	#   check if it matches
			return 1; 	#     return true if it does
		} 
	}
	close LOG;
	
	return 0;			# didn't find -> not in log
}


##############################################################################

=head2 C<log_entry ($entry)>

Put C<$entry> into the message log.  This could be used for several things.
Off hand, message related logging and marking an email address as having 
already been sent to (without actually sending a message).

I<Please> don't use this for general purpose logging or debugging.

	<SET show="no" export="no" name="junk" value="$msg->log_entry('message...')" />

=cut

sub log_entry ($$) {
	my ($self, $entry) = @_;
	
	$self->touch_log;	# make sure log file and dir exist.
	chomp $entry;		# remove trailing whitespace

	open LOG , '>>' . $self->log_file or do {
		warn "Couldn't append to " . $self->log_file . ": $!\n";
		return undef;
	};
	flock LOG, 2;		# block for exclusive lock
	seek LOG, 0, 2;		# seek to end of file
	print LOG $entry, "\n";
	close LOG;
	return 1;
}


##############################################################################
# We needed to add the ability to allow_duplicates, while retaining
# backwards compatibility with the current API.
# 
# So, I'm actually going to do the sending in the destroy method (by
# default).  This makes doing any kind of debugging or testing
# to see if the message went out pretty much impossible.  However, 
# the web guys don't seem to do any of that kind of stuff anyway.
#
# This has the unplanned bonus side-effect of very slightly improving
# responsiveness on pages which use the sendMail stuff.
sub DESTROY ($) {
        my $self = shift;

	$self->send_now() unless $self->sent;
} # DESTROY()

##############################################################################
# New function to create a record in the automail_message table
# the way the POP-UP does by calling the appname05 engine
##############################################################################
sub create_automail_message
{
    my %args = @_;
    my $server = $args{'server'};
    my $appname05 = $args{'appname05'};
    my $page   = $args{'page'};
    my $log    = $args{'log'};
    my $email  = $args{'email'};   # optional, if specified in $params
    my $name   = $args{'name'};    # optional
    my $uid    = $args{'uid'};     # optional
    my $params = $args{'params'};  # optional params joined by '&'
    
    if ($uid) {
        # sessionID is encoded, we must decode it first,
        # if we're coming from the appname05 engine
        eval
        {
            $uid = appname05BIN::decode_sessionID($uid);
        };
        
        # we're called outside of the appname05 engine namespace
        if ( $@ ) {
            # leave it unchanged
            $uid = $args{'uid'};
        }
    }
    
    # open debug log
    # my $logfile = "../"."data"."/".$appname05."/"."automail_message.log";
    # open(DBG,">>$logfile") || die "Can't open $logfile: $!";
    
    # User Agent
    my $ua = LWP::UserAgent->new();
    
    # build a URL
    my $url = $server.'?'.'appname05='.$appname05
        .'&'.'page='.$page
        .'&'.'log=' .$log;
    
    # optional stuff
    $url .= '&'.'email='. $email if $email;
    $url .= '&'.'name=' . $name if $name;
    $url .= '&'.'uid='  . $uid  if $uid;
    if ($params and ref($params) eq "HASH") {
        # reference to HASH
        my %tmp = %{ $params };
        foreach my $k (keys %tmp) {
            $url .= '&'.$k.'='.$tmp{$k} if $k;
        }
    } else {
        # plain SCALAR
        $url .= '&'.$params  if $params;
    }
    
    # print DBG "$url\n";
    # close DBG;
    
    # Call the URL
    $ua->request(GET $url);
    
    return 1;
    
} # create_automail_message

##############################################################################
1;

=head1 LOG

	$Log: sendMail.pm,v $
	Revision 1.11  2005/03/14 22:36:05  maxim
	Reverted back to 127.0.0.1
	
	Revision 1.10  2004/09/10 16:16:58  maxim
	Changed "localhost" to "mm1.appname05sitemail.com"
	
	Revision 1.9  2004/06/25 16:34:42  maxim
	Added HASH ref params, return 1
	
	Revision 1.8  2004/04/21 16:08:51  maxim
	sendMail in production is a few versions behind the one in CVS. Drew commented out some stuff related to dbTools.pm. To make as little changes as possible, this version is essentially the same as the production one plus an additional sub create_automail_message. For changes Drew made please refer to version 1.7
	
	Revision 1.18  2003/06/24 20:59:54  drew
	made Text::Iconv fail silently, catching exception instead
	
	Revision 1.17  2003/06/24 18:59:56  drew
	removed debugging code
	
	Revision 1.16  2003/06/19 16:16:14  drew
	added return code from send_now()
	
	Revision 1.15  2003/06/18 19:35:27  drew
	added debugging code to can_send()
	
	Revision 1.14  2003/06/18 19:13:43  drew
	switched to use 0 instead of undef for result codes
	
	Revision 1.13  2003/06/18 18:26:58  drew
	removed debugging stuff for re-code
	
	Revision 1.12  2003/06/13 15:45:24  drew
	Mail::Date requires 5.8, so held back
	
	Revision 1.11  2003/06/12 20:50:53  drew
	testing release of sendMail
	
	Revision 1.10  2003/06/03 20:22:19  drew
	added get_param function, doc cleaning
	
	Revision 1.9  2003/06/03 18:42:48  drew
	added some documentation on approach for send_later
	
	Revision 1.8  2002/11/18 16:53:05  drew
	comment changes and documentation changes
	
	Revision 1.7  2002/11/15 18:45:35  drew
	removed references to Cwd modules (non-portable)
	and FileHandle (unused due to locking issues)
	switched over to using rel2abs instead of stuff from Cwd that didn't work.
	remove crufty code in place of inline functions
	added several calls to warn in various places (testing return codes)
	
	Revision 1.6  2002/11/15 16:31:57  drew
	documentation tweaks
	added croak message to send_later call (for now)
	
	Revision 1.5  2002/11/14 17:06:02  drew
	moved to cleanSave from sendMail repository.
	
	Revision 1.3  2002/10/24 14:41:36  drew
	added error logging for failed connection to mail server.
	
	Revision 1.2  2002/10/24 14:39:34  drew
	
	further minor changes
	
	Revision 1.1  2002/10/24 13:21:01  drew
	fixed typos
	
	Revision 1.0  2002/10/23 20:42:40  drew
	commented out redundant calls to flock.
	added checks on open.
	
	Revision 0.9  2002/10/23 20:29:27  drew
	commented out date stuff in make_msg for now.  get other functionality working first.
	
	Revision 0.8  2002/10/23 19:43:32  drew
	extracted log checking info to seperate subroutine
	added db file based routines for duplicate checking
	modified the make_msg call to set a date header
	changed numerous places to prefer accessor functions to dirrect access to class data
	
	Revision 0.7  2002/10/17 18:14:02  drew
	created touch_log_dir function which ensures that the log dir is there.
	and called touch_log_dir from logger.
	
	Revision 0.6  2002/10/17 17:36:56  drew
	Further documentation work.
	Added accessor functions for all remaining attributes.
	
	Revision 0.5  2002/10/17 14:59:32  drew
	documentation updates and changes:
	changed head3 stuff to head2
	make xml parameter names lowercase as uppercase doesn't work
	changed synopsis from regular perl code to appname05-xml engine code
	
	Revision 0.4  2002/10/02 21:40:58  drew
	*** empty log message ***
	
	Revision 0.3  2002/10/02 19:29:00  drew
	documentation tweaking
	

=head1 AUTHORS

Andrew G. Hammond E<lt>F<mailto:andrew.hammond@appname05site.com>E<gt>

Peter Hircock E<lt>F<mailto:peter.hircock@appname05site.com>E<gt>

Shamshinur Taktayeva E<lt>F<mailto:shamshinur.taktayeva@appname05site.com>E<gt>

=head1 SEE ALSO

C<Net::SMTP>, C<Date::Parse>, C<MIME::Entity>, C<HTML::Template>

=head1 COPYRIGHT

Copyright (C) 2002, appname05Site Inc.  All rights reserved.

=cut
