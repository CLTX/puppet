class acda::amt-config () {

include appcmd
include registry
include stdlib
include loopbackv2
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup
require acda::setup

$nameSite = 'amt.mydomain.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-amt.mydomain.mycompany.com"
}
    
##############
# NETWORKING #
##############

$hierasubnet = "mask-${nameSite}"
$ip_from_hiera = hiera("${nameSite}")
$subnetmask_from_hiera = hiera("${hierasubnet}")
#if $machine_env == "PRD" {
if  'pvusaPPW15' in $hostname or 'pvusaPPW16' in $hostname { 
  $ip_amt = hiera("external-amt")
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

file {"D:\\mycompany\\webpub\\${nameSite}\\conf":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

#################################################
# Adding ISAPI-Filter setting files as required #
#################################################
#if $machine_env == "PRD" {

if 'pvusaPPW15' in $hostname or 'pvusaPPW16' in $hostname { 
  file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
    ensure  => present,
    content => template("acda/amt/css.erb"),
    require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
} else {
  file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
    ensure  => present,
    content => template("acda/amt/css-nonprd.erb"),
    require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt":
  ensure  => present,
  content => template("acda/amt/aci.txt"),
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

appcmd::createapppool { 'amt':
  appName         => 'amt',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

#create web app
appcmd::createwebapp { 'amt':
  siteName     => "${nameSite}",
  path         => '/app',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app",
  document     => 'default.aspx',
  apppool      => 'amt',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['amt']]
}
appcmd::createsite {"${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "amt",
  bindings     => "http/*:80:${defservername}",
  require      => [Appcmd::Createapppool['amt'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]]
}

appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName => "${nameSite}",
  reappname03Path => '/app/',
  require => Appcmd::Createsite["${nameSite}"]
}

appcmd::startapppool{ "Start AppPool ${nameSite}":
  appName => 'amt',
  require => Appcmd::Createapppool['amt']
}

}
