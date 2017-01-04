class appname03::setup () {

include registry
include stdlib
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

$nameSite = 'appname03.mycompany.com'

$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername = "${nameSite}"
} else {
  $defservername = "${temp}-appname03.mydomain.mycompany.com"
}

  file {'D:\mycompany\webpub\conf':
    ensure  => appname03ory,
	require => File['D:\\mycompany\\webpub'],
  }
	
  file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub'],
  }
	
  file {'D:\mycompany\webpub\conf\css.conf':
    ensure  => present,
    content => template("appname03/conf/css.conf"),
	require => File['D:\mycompany\webpub\conf']
  }
}
