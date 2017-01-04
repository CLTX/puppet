define akamaisureroute::copy(
  $path = $title
){

  file {"${path}\\akamai":
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/akamaisureroute/akamai_sureroute_files',
    recurse => true,
  }
}