class acda::auth-config () {

include appcmd
include registry
include stdlib
include loopbackv2
require appfabricclient
require iiswebserver
require iiswebserver::iissetup
require acda::setup

$nameSite = 'auth-admin.mydomain.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-auth-admin.mydomain.mycompany.com"
}
    
##############
# NETWORKING #
##############

$hierasubnet = "mask-${nameSite}"
$ip_from_hiera = hiera("${nameSite}")
$subnetmask_from_hiera = hiera("${hierasubnet}")
if $machine_env == "PRD" {
  $ip_amt = hiera("external-auth")
  loopbackv2::setup {"adding loopback for ${nameSite}":
    lvsip      => "${ip_from_hiera}",
    subnetmask => "${subnetmask_from_hiera}"
  }
}

if $ip_from_hiera == $getip {
  $site_ip = "${getip}"
} else {
  $site_ip = "${ip_from_hiera}"
}

################################
# Creating Folders and subdirs #
################################

file {"D:\\mycompany\\webpub\\${nameSite}":
  ensure => appname03ory,
  require => File['D:\\mycompany\\webpub'],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

###############
# IIS OBJECTS #
###############

appcmd::createapppool { 'auth-admin':
  appName         => 'auth-admin',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
}

#create web app
appcmd::createwebapp { 'auth-admin':
  siteName     => "${nameSite}",
  path         => '/app',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  document     => 'default.aspx',
  apppool      => 'auth-admin',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['auth-admin']]
}
appcmd::createsite {"${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "auth-admin",
  bindings     => "http/*:80:${defservername}",
  require      => [Appcmd::Createapppool['auth-admin'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]]
}

appcmd::startapppool{ "Start AppPool ${nameSite}":
  appName => 'auth-admin',
  require => Appcmd::Createapppool['auth-admin']
}

}
