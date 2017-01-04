class static-nginx::setup () {

include stdlib
require iiswebserver
require iiswebserver::iissetup
include static-nginx::config

$nameSite = 'static.mycompany.com'

$temp = downcase($machine_env)

if $machine_env == "PRD" {
   $defservername = "${nameSite}"
} 
else {
   $defservername = "${temp}-static.mydomain.mycompany.com"
   } 
}
