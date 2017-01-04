class origin::delivery-config-with-authmodule () {

include appcmd
include sslcerts
include loopbackv2
include authmodule
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
  ensure  => absent,
  recurse => true,
  force   => true
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

###############
# IIS OBJECTS #
###############

appcmd::createapppool { 'delivery':
  appName         => 'delivery',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
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
  require      => Appcmd::Createsite["${nameSite}"]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'delivery',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["${nameSite}"]
}

exec { "Removing ISAPI csauth as ISAPI Filter":
  command => "cmd.exe /C \"appcmd.exe set config \"${nameSite}/\" /section:isapiFilters  /-[name=\'csauth\'] /commit:apphost\"",
  onlyif  => "cmd.exe /C \"appcmd.exe list config \"${nameSite}/\" /section:isapiFilters | find \"csauth\"\"",
  require => Appcmd::Createsite["${nameSite}"]
}
  
if $authmoduleversion != "noAuthModule" {
  appcmd::addisapimodule { 'AuthModule':
    site         => "${nameSite}",
    modName      => "mycompanyAuthModule",
    type         => "mycompany.SSO.AuthHTTPModule.AuthModule, mycompany.SSO.AuthHTTPModule, Version=$authmoduleversion, Culture=neutral, PublicKeyToken=bcd2b958bd340364",
    preCondition => "managedHandler",
    require      => [Appcmd::Createsite["${nameSite}"],Package["mycompany SingleSignOn - Release"]]
  }
}

file_line { "css.conf":
  ensure => absent,
  path   => 'D:/mycompany/webpub/conf/css.conf',
  line   => "Domaincfg D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf"
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
