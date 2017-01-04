class appname04::setup () {
include registry
include stdlib
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

$nameSite = 'appname04.mycompany.com'

appcmd::isapimapping {'ASZX Isapi Mapping':
	extension => "aszx"
}

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub'],
}

file {'D:\\mycompany\\webpub\\conf':
  ensure  => appname03ory,
  require => File['D:\\mycompany\\webpub'],
}
}
