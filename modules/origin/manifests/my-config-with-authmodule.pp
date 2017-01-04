class origin::my-config-with-authmodule () {

include appcmd
include sslcerts
include loopbackv2
include authmodule
require origin::setup

$codeapp = hiera('appcode') 
$nameSite = 'my.mycompany.com'
$nameSiteNonPrd = 'my.mydomain.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-${nameSiteNonPrd}"
}
    
##############
# NETWORKING #
##############

$hierasubnet = "mask-${nameSite}"
$ip_from_hiera = hiera("${nameSite}")
$subnetmask_from_hiera = hiera("${hierasubnet}")

if $machine_env == "PRD" {
  $ip_my = hiera("external-my")
  }

if $ip_from_hiera == $getip {
  $site_ip = "${getip}"
} else {
  $site_ip = "${ip_from_hiera}"
}

if $machine_env == "PRD" {
  loopbackv2::setup {'adding loopback for my':
  lvsip      => "${ip_from_hiera}",
  subnetmask => "${subnetmask_from_hiera}"
  }
}

################################
# Creating Folders and subdirs #
################################

file {'D:\mycompany\webpub\javascript':
  ensure      => appname03ory,
  require => File['D:\\mycompany\\webpub'],
}

file {'D:\mycompany\webpub\javascript\ext':
  ensure      => appname03ory,
  require => File['D:\mycompany\webpub\javascript'],
}

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

file { "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\web.config":
  ensure => file,
  content => template('origin/my/web.erb'),
  replace => "no",
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

###############
# IIS OBJECTS #
###############

appcmd::createapppool { 'accounts':
  appName         => 'accounts',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'autologin':
  appName         => 'autologin',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'LMSPublic':
  appName         => 'LMSPublic',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'my_4.0':
  appName         => 'my_4.0',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'my3':
  appName         => 'my3',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'my3web':
  appName         => 'my3web',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'pm':
  appName         => 'pm',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'myplatform':
  appName         => 'myplatform',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'my-clients':
  appName         => 'my-clients',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'responserate':
  appName         => 'responserate',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'mydomainlink':
  appName         => 'mydomainlink',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'welcome':
  appName         => 'welcome',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'wwwapps':
  appName         => 'wwwapps',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createsite {"${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "my_4.0",
  bindings     => "http/*:80:${defservername}",
  require      => [Appcmd::Createapppool['my_4.0'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]]
}

appcmd::createvdir { "ext31":
  sitename     => "${nameSite}",
  vdirname     => 'ext',
  physicalPath => "D:\\mycompany\\webpub\\javascript\\ext",
  require      => Appcmd::Createsite["${nameSite}"]
}

#Apply Root Reappname03 Rule
appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName => "${nameSite}",
  reappname03Path => '/welcome/',
  require => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'accounts':
  siteName     => "$nameSite",
  path         => '/accounts',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\accounts",
  document     => 'default.aspx',
  apppool      => 'accounts',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['accounts']] 
}

appcmd::createwebapp { 'LMSPublic':
  siteName     => "$nameSite",
  path         => '/LMSPublic',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\LMSPublic",
  document     => 'default.aspx',
  apppool      => 'LMSPublic',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['LMSPublic']]
}

appcmd::createwebapp { 'clients':
  siteName     => "$nameSite",
  path         => '/clients',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\clients",
  document     => 'default.aspx',
  apppool      => 'my-clients',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['my-clients']]
}

appcmd::createwebapp { 'autologin':
  siteName     => "$nameSite",
  path         => '/autologin',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\autologin",
  document     => 'default.aspx',
  apppool      => 'autologin',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['autologin']]
}

appcmd::createwebapp { 'mydomainlink':
  siteName     => "$nameSite",
  path         => '/mydomainlink',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\mydomainlink",
  document     => 'default.aspx',
  apppool      => 'mydomainlink',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['mydomainlink']]
}

appcmd::createwebapp { 'my3':
  siteName     => "$nameSite",
  path         => '/my3',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\my3",
  document     => 'default.aspx',
  apppool      => 'my3',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['my3']]
}

appcmd::createwebapp { 'my3web':
  siteName     => "$nameSite",
  path         => '/my3web',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\my3web",
  document     => 'default.aspx',
  apppool      => 'my3web',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['my3web']]
}

appcmd::createwebapp { 'pm':
  siteName     => "$nameSite",
  path         => '/pm',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\pm",
  document     => 'default.aspx',
  apppool      => 'pm',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['pm']]
}

appcmd::createwebapp { 'responserate':
  siteName     => "$nameSite",
  path         => '/responserate',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\responserate",
  document     => 'default.aspx',
  apppool      => 'responserate',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['responserate']]
}

appcmd::createwebapp { 'welcome':
  siteName     => "$nameSite",
  path         => '/welcome',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\welcome",
  document     => 'default.aspx',
  apppool      => 'welcome',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['welcome']]
}

appcmd::createwebapp { 'wwwapps':
  siteName     => "$nameSite",
  path         => '/wwwapps',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\wwwapps",
  document     => 'default.aspx',
  apppool      => 'wwwapps',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['wwwapps']]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'myplatform',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["${nameSite}"]
}

#################################################
# Removing ISAPI-Filter setting files           #
#################################################

exec { "Removing ISAPI csauth as ISAPI Filter for ${nameSite}":
  command => "cmd.exe /C \"appcmd.exe set config \"${nameSite}/\" /section:isapiFilters  /-[name=\'csauth\'] /commit:apphost\"",
  onlyif  => "cmd.exe /C \"appcmd.exe list config \"${nameSite}/\" /section:isapiFilters | find \"csauth\"\"",
  require => Appcmd::Createsite["${nameSite}"]
}

if $authmoduleversion != "noAuthModule" {
  appcmd::addisapimodule { "adding AuthModule to ${nameSite}":
    site         => "${nameSite}",
    modName      => "mycompanyAuthModule",
    type         => "mycompany.SSO.AuthHTTPModule.AuthModule, mycompany.SSO.AuthHTTPModule, Version=$authmoduleversion, Culture=neutral, PublicKeyToken=bcd2b958bd340364",
    preCondition => "managedHandler",
    require      => [Appcmd::Createsite["${nameSite}"],Package["mycompany SingleSignOn - Release"]]
	#,File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\web.config"]]
  }
}

file_line { "css2.conf":
  ensure => absent,
  path   => 'D:/mycompany/webpub/conf/css.conf',
  line   => "Domaincfg D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf"
}

appcmd::startapppool{ "Start AppPool ${nameSite}":
  appName => 'my_4.0',
  require => Appcmd::Createapppool['my_4.0']
}

sslcerts::run{"ssl-certs ${nameSite}":
  siteName        => "${nameSite}",
  pathSite        => '/',
  hostHeaderValue => "${defservername}",
  require         => Appcmd::Createsite["${nameSite}"]
}
}
