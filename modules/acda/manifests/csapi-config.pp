class acda::csapi-config () {

include appcmd
include registry
include stdlib
include loopbackv2
require appfabricclient
require iiswebserver
require iiswebserver::iissetup
require acda::setup

$nameSite = 'csapi.mydomain.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-csapi.mydomain.mycompany.com"
}
    
##############
# NETWORKING #
##############

$hierasubnet = "mask-${nameSite}"
$ip_from_hiera = hiera("${nameSite}")
$subnetmask_from_hiera = hiera("${hierasubnet}")

if $machine_env == "PRD" {
  $ip_csapi = hiera("external-csapi")
}

if $ip_from_hiera == $getip {
  $site_ip = "${getip}"
} else {
  $site_ip = "${ip_from_hiera}"
}

if $machine_env == "PRD" {
  loopbackv2::setup {'adding loopback for ${nameSite}':
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
  
file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app":
     ensure  => appname03ory,
     require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\mmxservice":
     ensure  => appname03ory,
     require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname05":
     ensure  => appname03ory,
     require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}


###############
# IIS OBJECTS #
###############

appcmd::createapppool { 'csapi-amtool':
  appName         => 'csapi-amtool',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'csapi-common':
  appName         => 'csapi-common',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi-amtool'],
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'csapi-common2':
  appName         => 'csapi-common2',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi-amtool'],
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'csapi-cpm2':
  appName         => 'csapi-cpm2',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi-amtool'],
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'csapi-feedbackservice':
  appName         => 'csapi-feedbackservice',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi-amtool'],
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'csapi-icrf':
  appName         => 'csapi-icrf',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi-amtool'],
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'csapi-mmxservice':
  appName         => 'csapi-mmxservice',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi-amtool'],
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'csapi-appname05':
  appName         => 'csapi-appname05',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi-amtool'],
  idletimeout     => "00:00:00"
}

appcmd::32bit { 'csapi-icrf':
  appName => 'csapi-icrf',
  enabled => true,
  require => Appcmd::Createapppool['csapi-icrf']
}

appcmd::createapppool { 'csapi-my':
  appName         => 'csapi-my',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi-amtool'],
  idletimeout     => "00:00:00"
}

#create web app
appcmd::createwebapp { 'amtool':
  siteName     => "$nameSite",
  path         => '/amtool',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\amtool",
  document     => 'default.aspx',
  apppool      => 'csapi-amtool',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['csapi-amtool']]
}

appcmd::createwebapp { 'common':
  siteName     => "$nameSite",
  path         => '/common',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\common",
  document     => 'default.aspx',
  apppool      => 'csapi-common',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['csapi-common']]
}

appcmd::createwebapp { 'common2':
  siteName     => "$nameSite",
  path         => '/common2',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\common2",
  document     => 'default.aspx',
  apppool      => 'csapi-common2',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['csapi-common2']]
}

appcmd::createwebapp { 'cpm2':
  siteName     => "$nameSite",
  path         => '/cpm2',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\cpm2",
  document     => 'default.aspx',
  apppool      => 'csapi-cpm2',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['csapi-cpm2']]
}

appcmd::createwebapp { 'feedbackservice':
  siteName     => "$nameSite",
  path         => '/feedbackservice',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\feedbackservice",
  document     => 'default.aspx',
  apppool      => 'csapi-feedbackservice',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['csapi-feedbackservice']]
}

appcmd::createwebapp { 'icrf':
  siteName     => "$nameSite",
  path         => '/icrf',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\icrf",
  document     => 'default.aspx',
  apppool      => 'csapi-icrf',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['csapi-icrf']]
}

appcmd::createwebapp { 'my':
  siteName     => "$nameSite",
  path         => '/my',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\my",
  document     => 'default.aspx',
  apppool      => 'csapi-my',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['csapi-my']]
}

appcmd::createwebapp { 'MMXService':
  siteName     => "$nameSite",
  path         => '/MMXService',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\mmxservice",
  document     => 'default.aspx',
  apppool      => 'csapi-mmxservice',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['csapi-mmxservice'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\mmxservice"]]
}

appcmd::createwebapp { 'appname05':
  siteName     => "$nameSite",
  path         => '/appname05',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname05",
  document     => 'default.aspx',
  apppool      => 'csapi-appname05',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['csapi-appname05'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname05"]]
}

appcmd::startapppool{ "Start common":
  appName => 'csapi-common',
  require => Appcmd::Createapppool['csapi-common']
}

appcmd::startapppool{ "Start amtool":
  appName => 'csapi-amtool',
  require => Appcmd::Createapppool['csapi-amtool']
}

appcmd::startapppool{ "Start common2":
  appName => 'csapi-common2',
  require => Appcmd::Createapppool['csapi-common2']
}

appcmd::startapppool{ "Start feedbackservice":
  appName => 'csapi-feedbackservice',
  require => Appcmd::Createapppool['csapi-feedbackservice']
}

appcmd::startapppool{ "Start icrf":
  appName => 'csapi-icrf',
  require => Appcmd::Createapppool['csapi-icrf']
}
appcmd::startapppool{ "Start my":
  appName => 'csapi-my',
  require => Appcmd::Createapppool['csapi-my']
}

appcmd::startapppool{ "Start cpm2":
  appName => 'csapi-cpm2',
  require => Appcmd::Createapppool['csapi-cpm2']
}

appcmd::startapppool{ "Start csapi-mmxservice":
  appName => 'csapi-mmxrestapi',
  require => Appcmd::Createapppool['csapi-mmxservice']
}

appcmd::startapppool{ "Start csapi-appname05":
  appName => 'csapi-appname05',
  require => Appcmd::Createapppool['csapi-appname05']
}

appcmd::createsite {"${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\app",
  apppool      => "csapi-amtool",
  bindings     => "http/*:80:${defservername}",
  require      => [Appcmd::Createapppool['csapi-amtool'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app"]]
}

}
