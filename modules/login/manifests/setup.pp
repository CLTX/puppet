class login::setup () {
include registry
include stdlib
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

$cssdbconnection = hiera('cssdbconnection')
$nameSite = 'auth.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-login.mydomain.mycompany.com"
}
  
file {'D:\\mycompany\\webpub\\conf':
  ensure  => appname03ory,
  require => File['D:\\mycompany\\webpub']
}

file {'D:\\mycompany\\webpub\\conf\\css.conf':
  ensure  => file,
  content => template("login/css.conf"),
  require => File['D:\\mycompany\\webpub\\conf']
  }
}
