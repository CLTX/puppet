class acda::comcom-config () {

include appcmd
include registry
include stdlib
include loopbackv2
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup
require acda::setup

$nameSite = 'comcom.mydomain.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-comcom.mydomain.mycompany.com"
}
    
##############
# NETWORKING #
##############

$hierasubnet = "mask-${nameSite}"
$ip_from_hiera = hiera("${nameSite}")
$subnetmask_from_hiera = hiera("${hierasubnet}")

#if $machine_env == "PRD" {
#  $ip_comcom= hiera("external-comcom")
#  }

if $ip_from_hiera == $getip {
  $site_ip = "${getip}"
} else {
  $site_ip = "${ip_from_hiera}"
}

#if $machine_env == "PRD" {
#  loopbackv2::setup {"adding loopback for ${nameSite}":
#  lvsip      => "${ip_from_hiera}",
#  subnetmask => "${subnetmask_from_hiera}"
#  }
#}

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

if $machine_env == "PRD" {
  file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
    ensure  => present,
    content => template("acda/comcom/css-nonprd.erb"),
    require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
} else {
  file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
    ensure  => present,
    content => template("acda/comcom/css-nonprd.erb"),
    require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt":
  ensure  => present,
  content => template("acda/comcom/aci.txt"),
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

appcmd::createapppool {'comcom':
  appName         => 'comcom',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

appcmd::createvdir {"docs":
  sitename     => "${nameSite}",
  vdirname     => 'docs',
  appName      => 'app',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\docs",
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp {'comcom':
  siteName     => "${nameSite}",
  path         => '/app',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app",
  document     => 'default.aspx',
  apppool      => 'comcom',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createsite {"${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "comcom",
  bindings     => "http/*:80:${defservername}",
  require      => [Appcmd::Createapppool['comcom'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]]
}

appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName => "${nameSite}",
  reappname03Path => '/app/',
  require => Appcmd::Createsite["${nameSite}"]
}

appcmd::startapppool{ "Start AppPool ${nameSite}":
  appName => 'comcom',
  require => Appcmd::Createapppool['comcom']
}

}
