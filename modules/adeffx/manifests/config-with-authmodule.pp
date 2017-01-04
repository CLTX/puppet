class appname01::config-with-authmodule () {

include appcmd
include myplatform
require appname01::setup
include authmodule

$nameSite = 'appname01.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-appname01.mydomain.mycompany.com"
}

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\admin":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\adfx_bsl":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\adfx_ce":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\admin":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\home":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\public":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"]
}

file { "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\web.config":
  ensure => file,
  content => template("appname01/appname01/web.erb"),
  replace => "no",
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

#create apppool
appcmd::createapppool { 'appname01':
  appName         => 'appname01',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

appcmd::createapppool { 'appname01-beta':
  appName         => 'appname01-beta',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"],
}

#create web site
appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "appname01",
  require      => Appcmd::Createapppool["appname01"]
}

#create web app
appcmd::createwebapp { 'bsl':
  siteName     => "${nameSite}",
  path         => '/bsl',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\adfx_bsl",
  document     => 'default.aspx',
  apppool      => 'appname01',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'admin':
  siteName     => "${nameSite}",
  path         => '/admin',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\admin",
  document     => 'default.aspx',
  apppool      => 'appname01',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'bsl_print':
  siteName     => "${nameSite}",
  path         => '/bsl_print',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\adfx_bsl",
  document     => 'default.aspx',
  apppool      => 'appname01',
  require      => [Appcmd::Createsite["CreateSite ${nameSite}"],Appcmd::Createwebapp['bsl']]
}

appcmd::createwebapp { 'ce':
  siteName     => "${nameSite}",
  path         => '/ce',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\adfx_ce",
  document     => 'default.aspx',
  apppool      => 'appname01',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'ce_print':
  siteName     => "${nameSite}",
  path         => '/ce_print',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\adfx_ce",
  document     => 'default.aspx',
  apppool      => 'appname01',
  require      => [Appcmd::Createsite["CreateSite ${nameSite}"],Appcmd::Createwebapp['ce']]
}

appcmd::createwebapp { 'home':
  siteName     => "${nameSite}",
  path         => '/home',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\home",
  document     => 'default.aspx',
  apppool      => 'appname01',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'pub':
  siteName     => "${nameSite}",
  path         => '/pub',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\public",
  document     => 'default.aspx',
  apppool      => 'appname01',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'common':
  siteName     => "${nameSite}",
  path         => '/common',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\common",
  document     => 'default.aspx',
  apppool      => 'appname01',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#Create Virtual Dirs
appcmd::createvdir { "beta for ${nameSite}":
  sitename     => "${nameSite}",
  vdirname     => 'beta',
  appName      => '',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta",
  require      => [File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"], Appcmd::Createsite["CreateSite ${nameSite}"]]
}

appcmd::createwebapp { '/beta/bsl':
  siteName     => "${nameSite}",
  path         => '/beta/bsl',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\adfx_bsl",
  document     => 'default.aspx',
  apppool      => 'appname01-beta',
  require      => Appcmd::Createvdir["beta for ${nameSite}"]
}

appcmd::createwebapp { '/beta/ce':
  siteName     => "${nameSite}",
  path         => '/beta/ce',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\adfx_ce",
  document     => 'default.aspx',
  apppool      => 'appname01-beta',
  require      => Appcmd::Createvdir["beta for ${nameSite}"]
}

appcmd::createwebapp { '/beta/admin':
  siteName     => "${nameSite}",
  path         => '/beta/admin',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\admin",
  document     => 'default.aspx',
  apppool      => 'appname01-beta',
  require      => Appcmd::Createvdir["beta for ${nameSite}"]
}

appcmd::createwebapp { '/beta/home':
  siteName     => "${nameSite}",
  path         => '/beta/home',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\home",
  document     => 'default.aspx',
  apppool      => 'appname01-beta',
  require      => Appcmd::Createvdir["beta for ${nameSite}"]
}

appcmd::createwebapp { '/beta/pub':
  siteName     => "${nameSite}",
  path         => '/beta/pub',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\public",
  document     => 'default.aspx',
  apppool      => 'appname01-beta',
  require      => Appcmd::Createvdir["beta for ${nameSite}"]
}

#Apply Root Reappname03 Rule
appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName     => "${nameSite}",
  reappname03Path => '/home/',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#creating Reappname03s 
appcmd::createurlrdir { 'betaReappname03':
  url1      => "${nameSite}/beta",
  url2      => "/beta/home/",
  childonly => "true",
  require   => Appcmd::Createsite["CreateSite ${nameSite}"]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'appname01',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

sharefolder::create{'appname01Share':
  sharename => 'appname01.mycompany.com',
  path => 'D:\mycompany\webpub\appname01.mycompany.com',
  user => 'Everyone',
  rights => 'Full',
  require => File["D:\\mycompany\\webpub\\${nameSite}"]
}


#################################################
# Removing ISAPI-Filter setting files           #
#################################################

exec { "Removing ISAPI csauth as ISAPI Filter for ${nameSite}":
  command => "cmd.exe /C \"appcmd.exe set config \"${nameSite}/\" /section:isapiFilters  /-[name=\'csauth\'] /commit:apphost\"",
  onlyif  => "cmd.exe /C \"appcmd.exe list config \"${nameSite}/\" /section:isapiFilters | find \"csauth\"\"",
  require => Appcmd::Createsite["CreateSite ${nameSite}"]
}

if $authmoduleversion != "noAuthModule" {
  appcmd::addisapimodule { "adding AuthModule to ${nameSite}":
    site         => "${nameSite}",
    modName      => "mycompanyAuthModule",
    type         => "mycompany.SSO.AuthHTTPModule.AuthModule, mycompany.SSO.AuthHTTPModule, Version=$authmoduleversion, Culture=neutral, PublicKeyToken=bcd2b958bd340364",
    preCondition => "managedHandler",
    require      => [Appcmd::Createsite["CreateSite ${nameSite}"],Package["mycompany SingleSignOn - Release"]]
  }
}

###################################################
# Gautam requested leave this file till next week.#
###################################################

#file_line { "css.conf":
#  ensure => absent,
#  path   => 'D:/mycompany/webpub/conf/css.conf',
#  line   => "Domaincfg D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf"
#}

}
