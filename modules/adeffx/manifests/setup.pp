class appname01::setup () {
include registry
include stdlib
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

require mdbaccess

$nameSite = 'appname01.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-appname01.mydomain.mycompany.com"
}
  
file {'D:\\mycompany\\webpub\\conf':
  ensure  => appname03ory,
  require => File['D:\\mycompany\\webpub']
}

file {'D:\\mycompany\\webpub\\conf\\css.conf':
  ensure  => file,
  content => template("appname01/conf/css.conf"),
  require => File['D:\\mycompany\\webpub\\conf']
  }
}
