class serverdb::setup () {

include registry
include stdlib
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

$nameSite = 'serverdb.mydomain.mycompany.com'

$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername = "${nameSite}"
} else {
  $defservername = "${temp}-${nameSite}"
}
	
  file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub'],
  }
		
}
