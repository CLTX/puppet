# package appname05XMLState - appname05-xml.pl per XML document state class
#!/usr/bin/perl -w

package appname05XMLState;
use Carp;
use strict;

use vars qw($VERSION);

$VERSION = '1.00';

sub new {

	my($this) = @_;

	my $class = ref($this) || $this;
	my $self  = {};
	bless($self, $class);

	$self->{COND} = {}; # parsed XML document state, reference to hash, cond="" for <IF> tag
	$self->{ELEMENTISPRESENT} = {}; # keep track of elements processed, reference to hash
	$self->{IS_OUTPUT} = {}; # parsed XML document state, reference to hash, has tag been output
	$self->{IS_SELECTED} = {}; # parsed XML document state, reference to hash, has tag been selected
	$self->{NAME} = {}; # parsed XML document state, reference to hash, tag num
	$self->{NUM} = {}; # parsed XML document state, reference to hash, number of <R> tags in <RANDOM>
	$self->{OUTPUTFORMVARIABLE} = {}; # list of CGI variables to output in <FORM>...</FORM>, reference to hash
	$self->{RANDOMNAME} = {}; # list of <RANDOM> tag "name" attributes, reference to hash
	$self->{RANDOMORDER} = {}; # parsed XML document state, reference to hash, order of <R> tags in <RANDOM>
	$self->{USE} = {}; # parsed XML document state, reference to hash, number of <R> tags to use in <RANDOM>
	$self->{VARIABLEISEXPORTED} = {}; # variable exported via <FORM> <INPUT> tags
	$self->{VARIABLEVALUE} = {}; # variable = expression

	#carp "appname05XMLState::Creating $self ";
	return $self;

} # new()

sub VERSION { $VERSION; }

sub cond {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{COND}}{$key} = $value }
	return ${$self->{COND}}{$key};

} # cond()

sub elementIsPresent {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{ELEMENTISPRESENT}}{$key} = $value }
	return ${$self->{ELEMENTISPRESENT}}{$key};

} # elementIsPresent()

sub isOutput {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{IS_OUTPUT}}{$key} = $value }
	return ${$self->{IS_OUTPUT}}{$key};

} # isOutput()

sub isSelected {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{IS_SELECTED}}{$key} = $value }
	return ${$self->{IS_SELECTED}}{$key};

} # isSelected()

sub name {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{NAME}}{$key} = $value }
	return ${$self->{NAME}}{$key};

} # name()

sub num {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{NUM}}{$key} = $value }
	return ${$self->{NUM}}{$key};

} # num()

sub outputFormVariable {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{OUTPUTFORMVARIABLE}}{$key} = $value }
	return ${$self->{OUTPUTFORMVARIABLE}}{$key};

} # outputFormVariable()

sub randomName {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{RANDOMNAME}}{$key} = $value }
	return ${$self->{RANDOMNAME}}{$key};

} # randomName()

sub randomOrder {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{RANDOMORDER}}{$key} = $value }
	return ${$self->{RANDOMORDER}}{$key};

} # randomOrder()

sub reset {
	my($self) = @_;

	my $n = 0;
	for my $selected (keys(%{$self->{IS_SELECTED}})) {
		${$self->{IS_SELECTED}}{$selected} = 1; # selected by default
		$n += 1;
	} # for ... each node state

	for my $output (keys(%{$self->{IS_OUTPUT}})) {
		${$self->{IS_OUTPUT}}{$output} = 0; # not yet output
	} # for ... each node state

	for my $randomorder (keys(%{$self->{RANDOMORDER}})) {
		if(defined(${$self->{RANDOMORDER}}{$randomorder})){
			${$self->{RANDOMORDER}}{$randomorder} = undef;
		} # if
	} # for ... each node state

	return $n;

} # reset();

sub use {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{USE}}{$key} = $value }
	return ${$self->{USE}}{$key};

} # use()

sub variableValue {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{VARIABLEVALUE}}{$key} = $value }
	return ${$self->{VARIABLEVALUE}}{$key};

} # variableValue()

sub variableIsExported {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{VARIABLEISEXPORTED}}{$key} = $value }
	return ${$self->{VARIABLEISEXPORTED}}{$key};

} # variableIsExported()

sub dispose {
	my($self, $key) = @_;

	if(defined($key)){
		undef(${$self->{COND}}{$key});
		undef(${$self->{IS_OUTPUT}}{$key});
		undef(${$self->{IS_SELECTED}}{$key});
		undef(${$self->{NAME}}{$key});
		undef(${$self->{NUM}}{$key});
		undef(${$self->{OUTPUTFORMVARIABLE}}{$key});
		undef(${$self->{RANDOMNAME}}{$key});
		undef(${$self->{RANDOMORDER}}{$key});
		undef(${$self->{USE}}{$key});
	}else{
		undef($self->{COND});
		undef($self->{ELEMENTISPRESENT});
		undef($self->{IS_OUTPUT});
		undef($self->{IS_SELECTED});
		undef($self->{NAME});
		undef($self->{NUM});
		undef($self->{OUTPUTFORMVARIABLE});
		undef($self->{RANDOMNAME});
		undef($self->{RANDOMORDER});
		undef($self->{USE});
		undef($self->{VARIABLEISEXPORTED});
		undef($self->{VARIABLEVALUE});
	} # if ... specific key

} # dispose()

sub DESTROY {

        my $self = shift;
	#carp "appname05XMLState::DESTROY() $self ";

} # DESTROY()

1;
