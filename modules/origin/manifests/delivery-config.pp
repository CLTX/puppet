class origin::delivery-config () {

include appcmd
include sslcerts
include registry
include stdlib
include loopbackv2
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup
require origin::setup

$nameSite = 'delivery.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-delivery.mydomain.mycompany.com"
}
    
##############
# NETWORKING #
##############

$hierasubnet = "mask-${nameSite}"
$ip_from_hiera = hiera("${nameSite}")
$subnetmask_from_hiera = hiera("${hierasubnet}")

if $machine_env == "PRD" {
  $ip_delivery = hiera("external-delivery")
  }

if $ip_from_hiera == $getip {
  $site_ip = "${getip}"
} else {
  $site_ip = "${ip_from_hiera}"
}

if $machine_env == "PRD" {
  loopbackv2::setup {'adding loopback for delivery':
  lvsip      => "${ip_from_hiera}",
  subnetmask => "${subnetmask_from_hiera}"
  }
}

################################
# Creating Folders and subdirs #
################################

file {"D:\\mycompany\\webpub\\${nameSite}":
  ensure => appname03ory,
  require => File['D:\\mycompany\\webpub'],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\dc":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

#################################################
# Adding ISAPI-Filter setting files as required #
#################################################

if $machine_env == "PRD" {
  file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
    ensure  => present,
    content => template("origin/delivery/css.erb"),
    require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
} else {
  file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
    ensure  => present,
    content => template("origin/delivery/css-nonprod.erb"),
    require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt":
  ensure  => present,
  content => template("origin/delivery/aci.txt"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
}

append_if_no_such_line {"Append $nameSite to common css":
  file    => "D:\\mycompany\\webpub\\conf\\css.conf",
  line    => "Domaincfg D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf",
  ensure  => insync,
  require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
}

appcmd::isapifilter { "IsapiFilterCsAuth for ${nameSite}":
  site         => "${nameSite}",
  modName      => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["${nameSite}"]
}


###############
# IIS OBJECTS #
###############

appcmd::createapppool { 'delivery':
  appName         => 'delivery',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createsite {"${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "delivery",
  bindings     => "http/*:80:${defservername}",
  require      => [Appcmd::Createapppool['delivery'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]]
}

#Apply Root Reappname03 Rule
appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName => "${nameSite}",
  reappname03Path => '/dc/',
  require => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'cgi-bin':
  siteName     => "$nameSite",
  path         => '/cgi-bin',
  physicalPath => "D:\\mycompany\\web-applications\cgi-bin",
  document     => 'default.aspx',
  apppool      => 'delivery',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['delivery']] 
}

appcmd::createwebapp { 'dc':
  siteName     => "$nameSite",
  path         => '/dc',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\dc",
  document     => 'default.aspx',
  apppool      => 'delivery',
  require      => [Appcmd::Createsite["${nameSite}"],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\dc"]]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'delivery',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::startapppool{ "Start AppPool ${nameSite}":
  appName => 'delivery',
  require => Appcmd::Createapppool['delivery']
}

sslcerts::run{"ssl-certs ${nameSite}":
  siteName        => "${nameSite}",
  pathSite        => '/',
  hostHeaderValue => "${defservername}",
  require         => Appcmd::Createsite["${nameSite}"]
}
}
