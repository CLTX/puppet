class searchplanner::setup () {
include registry
include stdlib
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

$nameSite = 'searchplanner.mycompany.com'

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

file {'D:\\mycompany\\webpub\\conf\\css.conf':
  ensure  => file,
  content => template("searchplanner/conf/css.erb"),
  require => File['D:\\mycompany\\webpub\\conf']
}
}
