class labs::setup () {

include registry
include stdlib
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup
include labs::config

$nameSite = 'labs.mycompany.com'

$temp = downcase($machine_env)

if $machine_env == "PRD" {
   $defservername = "${nameSite}"
} 
else {
   $defservername = "${temp}-labs.mydomain.mycompany.com"
   } 

file {'D:\\mycompany\\webpub\\conf':
   ensure  => appname03ory,
   require => File['D:\\mycompany\\webpub']
   }

file {'D:\\mycompany\\webpub\\conf\\css.conf':
   ensure  => file,
   content => template("labs/css.conf"),
   require => File['D:\\mycompany\\webpub\\conf']
   }

file {"D:\\mycompany\\webpub\\${nameSite}":
   ensure => appname03ory,
   require => File['D:\\mycompany\\webpub'],
   }

file {"D:\\mycompany\\webpub\\${nameSite}\\conf":
   ensure  => appname03ory,
   require => File["D:\\mycompany\\webpub\\${nameSite}"],
   }

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
   ensure  => present,
   content => template("labs/conf/css.erb"),
   require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
   }

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt":
   ensure  => present,
   content => template("labs/conf/aci.txt"),
   require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
   }
}
