class appname01::config () {

include appcmd
include myplatform
require appname01::setup

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

file {"D:\\mycompany\\webpub\\${nameSite}\\conf":
  ensure  => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
  ensure  => file,
  content => template("appname01/conf/appname01/conf/css.erb"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt":
  ensure  => file,
  content => template("appname01/conf/appname01/conf/aci.txt"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"]
}

file {"C:\\temp\\aci.txt":
  ensure  => file,
  content => template("appname01/conf/appname01/conf/aci.txt"),
}
->
exec {"Updating aci.txt":
  command    => "cmd.exe /c \"type C:\\temp\\aci.txt > D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt",
  subscribe  => File["C:\\temp\\aci.txt"],
  refreshonly => true,
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

appcmd::isapifilter { "IsapiFilterCsAuth for ${nameSite}":
  site         => "$nameSite",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
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

}