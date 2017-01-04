package SimpleWrite;

use vars qw($VERSION);
=head1 NAME

SimpleWrite.pm - perl module for the appname05-xml.pl engine to output to file

=head1 SYNOPSIS

The SimpleWrite new() method takes the following parameters:

 file_name - absolute or relative pathname of the file to output to. Should always use the SimpleWrite::base_data_dir() method to get the name of the appname05 engine base data appname03ory, which is the only area appname05s should write in, i.e. <SET name="f" value="SimpleWrite::base_data_dir() . '/' . $appname05 . '/simpleWrite.out'" />

 access_mode - either 'append' to append to the end of a existing or new file or 'truncate' to first truncate the file to zero bytes and then append. If this parameter is not specified it defaults to 'append'.

The SimpleWrite printf() method is invoked exactly as the perl printf function. The first parameter is the format string and remaining parameters are output to the file according to the format string. Note the the output file_name specified in the call to new() is opened and closed each time printf() method is called. If the file is opened for 'append' then data will be appended to the file on each call but if the file is opened for 'truncate' the file is truncated to zero byes on each call so only the data written on the last call to printf() will appear in the file.

The SimpleWrite base_data_dir() method can be invoked statically via SimpleWrite::base_data_dir(). It returns the base appname03ory that the appname05 engine saves appname05 results in and should be used to construct file_name parameter values for the SimpleWrite new() method.

=cut

$VERSION = '1.00';

sub new {

	my($this, $file_name, $access_mode) = @_;

	my $class = ref($this) || $this;
	my $self  = {};
	bless($self, $class);

	if(!defined($file_name)){
		$appname05BIN::debug_html .= sprintf("<!-- MODULE: SimpleWrite: new(): error: file_name not defined -->\n");

	}else{
		$self->{FILE_NAME} = $file_name; 

		if(!defined($access_mode)){
			$access_mode = 'append';
		} # if

		if($access_mode !~ m/^append$|^truncate$/i){
			$appname05BIN::debug_html .= sprintf("<!-- MODULE: SimpleWrite: new(): error: file_name '%s' has invalid access_mode '%s' -->\n", $self->{FILE_NAME}, access_mode);
			$self->{ACCESS_MODE} = undef;
		}else{
			$self->{ACCESS_MODE} = $access_mode; 
			$appname05BIN::debug_html .= sprintf("<!-- MODULE: SimpleWrite: OK: new(file_name '%s', access_mode '%s') -->\n", $self->{FILE_NAME}, $self->{ACCESS_MODE});
		} # if

	} # if

	return $self;

} # new()

sub VERSION { $VERSION; }

sub printf {
	my($self, $format) = @_;
	shift;
	shift;

	if(defined($self->{FILE_NAME}) && defined($self->{ACCESS_MODE})){

		my $file_name;
		if($self->{ACCESS_MODE} eq 'append'){
			$file_name = '>>' . $self->{FILE_NAME};
		}else{
			$file_name = '>' . $self->{FILE_NAME};
		} # if

		local(*W);
		if(open(W, $file_name)){
			printf W ($format, @_);
			close(W);
		}else{
			$appname05BIN::debug_html .= sprintf("<!-- MODULE: SimpleWrite: write(): error: can't open file_name '%s' access_mode '%s', error '%s'-->\n", $self->{FILE_NAME}, $self->{ACCESS_MODE}, $!);
		} # if
	}else{
		$appname05BIN::debug_html .= sprintf("<!-- MODULE: SimpleWrite: write(): error: missing file_name and/or invalid access_mode -->\n");
	} # if


} # printf()

sub base_data_dir {
	my($self) = @_;

	return $appname05BIN::base_data_dir;

} # base_data_dir()

sub base_page_dir {
	my($self) = @_;

	return $appname05BIN::base_page_dir;

} # base_page_dir()

sub dispose {
	my($self) = @_;

	undef($self->{FILE_NAME});
	undef($self->{ACCESS_MODE});

} # dispose()

sub DESTROY {

        my $self = shift;

	$appname05BIN::debug_html .= sprintf("<!-- MODULE: SimpleWrite: DESTROY -->\n");

} # DESTROY()

1;
