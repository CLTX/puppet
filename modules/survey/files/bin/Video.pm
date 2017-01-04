package Video;

use vars qw($VERSION);
=head1 NAME

Video.pm - perl module for the appname05-xml.pl engine that processes Video/Hollywood appname05 data.

=head1 SYNOPSIS

The Video module converts video appname05 questions from the sampling format to SPSS/reporting format
and updates the appname05 subsets.

The Video new() method takes the following parameters:

 - cfg_file_name: absolute or relative pathname of the configuration file that contains
the appname05 video information. The file format is:

variable <appname05 variable name>
subset <name> <appname05 variable name> value
subset <name> <appname05 variable name> value
...
variable <appname05 variable name>
subset <name> <name> <appname05 variable name> value
subset <name> <appname05 variable name> value
...

A sample configuration file:

variable textincludeboth19
subset male appname051 1
subset female appname051 2

The video data is in appname05 form variable "textincludeboth19".
There are 2 subsets;
- male: updated when appname05 form variable appname051 has the value 1
- female: updated when appname05 form variable appname051 has the value 2

Note: This file is ignorde for now. The package converts all text fields of
that start with 'VIDEO' and converts them to 'VIDEO-DECODED' format.
=cut

$VERSION = '1.00';

sub new {

	my($this, $cfg_file_name) = @_;

	my $class = ref($this) || $this;
	my $self  = {};
	bless($self, $class);

	$self->{VIDEO_appname05_VARIABLE_NAMES} = {}; # list of servey variables with video data
	$self->{STATUS} = "OK"; # module status

	if(!defined($cfg_file_name) || $cfg_file_name eq ''){
		$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: new(): ERROR: cfg_file_name not defined -->\n");
		$self->{STATUS} = "ERROR";

	}else{
		if(open(C, "<$cfg_file_name")){

			$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: new(): OK: config file name '%s' -->\n", $cfg_file_name);
			my $line;

			while($line = <C>){
				$line =~ s/[\r\n]//;
				$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: new(): OK: line '%s' -->\n", $line);

				if(($line !~ m/^#/) && length($line) > 0){

					my($option, @values) = split(/\s/, $line);

					if(defined($option)){

						if($option =~ m/^variable/i){

							if(scalar(@values) != 1){
							}else{
								my $name = $values[0];
								if(!defined(${$self->{VIDEO_appname05_VARIABLE_NAMES}}{$name})){
									${$self->{VIDEO_appname05_VARIABLE_NAMES}}{$name} = ''; # value provided in decode() method
									$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: new(): OK: video appname05 variable name '%s' -->\n", $name);
								}else{
									$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: new(): WARN: video appname05 variable name '%s' already specified -->\n", $name);
								} # if ... video variable already specified
							} # if ... valid option value
						}elsif($option =~ m/^subset/i){
							$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: new(): WARN: config file option '%s' not implemented -->\n", $option);
						}else{
							$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: new(): WARN: config file option '%s' not valid -->\n", $option);
						} # if ... option

					}else{
						$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: new(): WARN: config file line '%s' not valid -->\n", $line);
					} # if ... valid config file line

				} # if ... non comment/empty config file line
				
			} # while ... config file lines

			close(C);

		}else{
			$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: new(): ERROR: can't open config file '%s' error '%s' -->\n", $cfg_file_name, $!);
			$self->{STATUS} = "ERROR";
		} # if

	} # if

	return $self;

} # new()

sub VERSION { $VERSION; }

# status() - return module status, "OK" if initialized OK else "ERROR"

sub status {
	my($self) = @_;

	return $self->{STATUS};

} # status()

# decode() - decode video variables

sub decode {
	my($self) = @_;

	# @@@ could run thru all text variables and look for leading "VIDEO" string

	my $base_var_name = 'textincludeboth';
	my $num_text = $appname05BIN::form{'numtext'};
	$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: decode(): INFO: num_text '%d' -->\n", $num_text);
	for my $var_num (1 .. $num_text) {
		my $var = sprintf("%s%d", $base_var_name, $var_num);
		if(defined($appname05BIN::form{$var})){
			my $value = $appname05BIN::form{$var};
			$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: decode(): INFO: video variable name '%s' value '%s' -->\n", $var, $value);
			my($header, $time, $sample_rate, $encoded) = split(/,/, $value);
			if(!defined($header) || !defined($time) || !defined($sample_rate) || !defined($encoded) || $header ne 'VIDEO' || $sample_rate <= 0.0){
				$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: decode(): WARN: video variable name '%s' value '%s' has invalid format -->\n", $var, $value);
			}else{
				my $decoded = decode_sample($sample_rate, $encoded);
				$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: decode(): INFO: video variable name '%s' value '%s' encoded '%s' decoded '%s' -->\n", $var, $value, $encoded, $decoded);
				$appname05BIN::form{$var} = join(',', $header . '-DECODED', $time, $sample_rate, $decoded);
                                #
                                # PH Changes to pop the results into the fixed length area appname05NN
                                #
                                { 
                                  my @samples = split( /,/ , $decoded );
                                  my $i = 0;
                                  for( $i = 0; $i <= $#samples; $i++ ) {
                                     my $field_num = $appname05BIN::form{numappname05} + $i + 1;
                                     ( my $timestamp, my $slide_value ) = split( / /, $samples[$i] );
                                     $appname05BIN::form{ "appname05" . $field_num } = $slide_value * 10;
                                     $appname05BIN::form{ "3_digits" } .= ","  if(defined($appname05BIN::form{"3_digits"}));
                                     $appname05BIN::form{ "3_digits" } .= $field_num ;
                                  } 
                                  $appname05BIN::form{numappname05} += $i;
                                }
                                #
                                # End of PH Changes
                                #
			} # if
		} # if
	} # for ... each video variable

} # decode()

# decode_sample() - decode an encoded sample

sub decode_sample {
	my($sample_rate, $encoded) = @_;

	my $time = 0.0;
	my $sample_interval = 1.0/$sample_rate;

	my $decoded_sample = '';
	my $delim = '';
	
	# Format of $encoded is "A001B034C045A100B000..."
	# which decodes as, assuming a 2 Hz sample frequency:
	# 0.0,0.1, 0.5,3.4,1.0,3.4, 1.5,4.5,2.0,4.5,2.5,4.5, 3.0,10.0, 3.5,0.0,4.0,0.0, ...
	# Note that uncompressed data without the alphabetic counts is handled as well:
	# 000100050 -> 0.0,0.0, 0.5,10.0, 1.0,5.0

	my $count = 0;
	my $value = '';
	while(length($encoded) > 0){

		my $c = substr($encoded, 0, 1);

		if($count == 0){
			if($c ge 'A' && $c le 'Z'){
				$count = (ord($c) - ord('A')) + 1;
				$encoded = substr($encoded, 1);
			}else{
				$count = 1;
			} # if
			$value = '';
		}else{
			$value .= $c;
			$encoded = substr($encoded, 1);
			if(length($value) == 3){
				for(my $j = 0; $j < $count; $j += 1){
					#$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: decode_sample(): WARN: time %.2f j %d count %d value '%s' -->\n", $time, $j, $count, $value);
					# Transfor sample data from (0 .. 99) to (0.0 .. 9.9)
					$decoded_sample .= $delim . sprintf("%.2f %.1f", $time, $value/10.0);
					$delim = ',';
					$time += $sample_interval;
				} # for

				$count = 0;
			} #if
		} # if

	} # while

	return $decoded_sample;

} # decode_sample()

sub dispose {
	my($self) = @_;

	undef($self->{VIDEO_appname05_VARIABLE_NAMES});

} # dispose()

sub DESTROY {

        my $self = shift;

	$appname05BIN::debug_html .= sprintf("<!-- MODULE: Video: DESTROY -->\n");

} # DESTROY()

1;
