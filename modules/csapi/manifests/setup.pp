class csapi::setup () {

include stdlib
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup
include csapi::config

$nameSite = 'csapi.mydomain.mycompany.com'

$temp = downcase($machine_env)

if $machine_env == "PRD" {
   $defservername = "${nameSite}"
} 
else {
   $defservername = "${temp}-csapi.mydomain.mycompany.com"
   } 

file {"D:\\mycompany\\webpub\\${nameSite}":
   ensure => appname03ory,
   require => File['D:\\mycompany\\webpub'],
   }

}
