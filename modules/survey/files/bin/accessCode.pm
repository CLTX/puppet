#
# $Log: accessCode.pm,v $
# Revision 1.2  2006/01/30 16:03:41  mmaltchevski
# Commented out STDERR output
#
# Revision 1.1  2004/03/31 21:24:48  maxim
# Added Engine stuff to new repository
#
# Revision 1.2  2003/10/27 20:26:51  maxim
# Production version of accessCode.pm checked-in
#
#
package accessCode;

use vars qw($VERSION);
# use Tie::DB_Lock;
# use DB_File;

use DB_File::Lock;
use Fcntl qw(:flock O_RDWR O_CREAT);


$VERSION = '1.20';

sub new {

        my ( $this, $filename, $code, $index , $deliminator ) = @_;
	# my($this) = @_;

	my $class = ref($this) || $this;
	my $self  = {};

        $appname05BIN::debug_html .= sprintf("<!-- MODULE: accessCode: module loaded -->\n");

        $deliminator = '\|' if( ! defined $deliminator );
        $index       =  0   if( ! defined $index );
        $line = readAccess( $filename, $code, $index, $deliminator );

	if( defined $line) { 
          $self->{isAccessCode} = 1;
          $self->{accessLine} = $line;
          my @test = split( /$deliminator/, $line);
          $self->{accessField} = \@test;
          $self->{numAccessField} = $#test;
        } else {
          $self->{isAccessCode} = 0;
          $self->{accessLine} = "";
          $self->{accessField} = [];
          $self->{numAccessField} = 0;
        }

        bless($self, $class);
	return $self;

} # new()

sub VERSION { $VERSION; }

sub isAccessCode {
  my ( $self) = @_;
  return $self->{isAccessCode} ;
}

sub getAccessLine {
  my ( $self) = @_;
  return $self->{accessLine} ;
}

sub getAccessField {
  my ( $self, $index ) = @_;
  if( $index <= $self->{numAccessField} ) {
    return $self->{accessField}[$index] ;
  } else {
    return "";
  }
}

sub getNumAccessField {
  my ( $self) = @_;
  return $self->{numAccessField};
}

sub test {
	my($self, $key, $value) = @_;

	if(defined($value)) { ${$self->{TEST}}{$key} = $value }
	return ${$self->{TEST}}{$key};

} # test()

sub dispose {
	my($self, $key) = @_;

	if(defined($key)){
		undef(${$self->{TEST}}{$key});
	}else{
		undef($self->{TEST});
	} # if ... specific key

} # dispose()

sub DESTROY {

        my $self = shift;

} # DESTROY()

sub readAccess {
  my ( $file, $code, $index, $deliminator ) = @_;
  my $filename = $appname05BIN::base_data_dir . '/' . $file;
  my $database_file = substr( $filename, 0, length( $filename ) - 4 ) . ".db";
  my $pass = lc $code;
  my $return ;
  #  open and load passwords
  # note: we don't check for success on purpose
  # print STDERR ( "opening password file $filename \n");
  # print STDERR ( "opening database file $$database_file  \n") ;

#   open(PASS, "$clients_path/$in{'password_file'}")base ;
#       || debug "<h3>Open failed</h3>";
#
# Create Database
#
my $update_database = 0;
if ( ! -e "$database_file" ) {
  $update_database = 1;
} else {
  ( my @text ) = stat( "$filename" );
  ( my @data ) = stat( "$database_file" );
  if( $text[9] > $data[9] ) {  # Mod time
    $update_database = 1;
  }
}

if ( $update_database) {
  my %database ;
  # print STDERR ( "Update password file $database_file \n");

  tie ( %database,  'DB_File::Lock', $database_file, O_CREAT|O_RDWR, 0666, $DB_HASH, 'write' ) or
		$appname05BIN::debug_html .= sprintf("<!-- MODULE: accessCode: error: creating db file  %s -->\n", $database_file );

  open(PASS, "$filename")  or
    $appname05BIN::debug_html .= sprintf("<!-- MODULE: accessCode: error: reading txt file   %s -->\n", $filename );
  while ( $line = <PASS>) {
    #    chomp;
    # chomp is not good enough for MSDOG files
    #    s/[\s\r\n ]//g;
    chomp ( $line );
    my @fields = split(/$deliminator/,$line, 2);
    my $key = $fields[ $index ];
    if ( defined $key && length( $key) > 0  ) {
      $database{lc $key} = $line;
    }
    # $appname05BIN::debug_html .= sprintf("<!-- MODULE: accessCode Adding : keys: %s data  %s line %s -->\n", $key , $database{ $key }, $line  );
  }
  untie %database; 
  close PASS;
} # End of update 
#
# Do some reading
#
  my %database;
  tie( %database,  'DB_File::Lock', $database_file, O_RDONLY , 0666, $DB_HASH, 'read') or
      $appname05BIN::debug_html .= sprintf("<!-- MODULE: accessCode: error: reading database file   %s -->\n", $database_file );


  if (exists $database{$pass}) {
    $return = $database{$pass};
  }
  # for my $key ( keys %database ) {
  #     $appname05BIN::debug_html .= sprintf("<!-- MODULE: accessCode: keys: %s data  %s -->\n", $key , $database{ $key }  );
  # }
  untie %database; 
  return $return ;
}

1;
