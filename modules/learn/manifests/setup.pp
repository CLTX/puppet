class learn::setup () {

include registry
include stdlib
include authmodule
require appfabricclient
require iiswebserver
require iiswebserver::iissetup
include learn::config

$nameSite = 'learn.mycompany.com'

$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername = "${nameSite}"
} else {
  $defservername = "${temp}-learn.mycompany.com"
}
  
  file {'D:\\mycompany\\webpub\\learn.mycompany.com\\wwwroot':
    ensure  => appname03ory,
    require => File['D:\\mycompany\\webpub']
  }
}
