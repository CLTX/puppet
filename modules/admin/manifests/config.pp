class admin::config() {

include appcmd
include myplatform
require admin::setup

$nameSite = 'admin.mycompany.com'

$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-admin.mydomain.mycompany.com"
}

file {"D:\\mycompany\\webpub\\${nameSite}":
  ensure => appname03ory,
  require => File['D:\\mycompany\\webpub']
}
	
file {"D:\\mycompany\\webpub\\$nameSite\\conf":
  ensure => appname03ory,
  require => File['D:\\mycompany\\webpub']
}
	
file {"D:\mycompany\webpub\\$nameSite\conf\css.conf":
  ensure  => present,
  content => template("admin/conf/admin/conf/css.erb"),
  require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
}
	
file {"D:\mycompany\webpub\\$nameSite\conf\aci.txt":
  ensure  => present,
  content => template("admin/conf/admin/conf/aci.txt"),
  require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
}

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

#create apppool
appcmd::createapppool { "admin":
  appName         => 'admin',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
}

#create web site
appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => "admin",
  document     => 'default.html',
  require      => Appcmd::Createapppool["admin"],  
}

appcmd::isapifilter { "IsapiFilterCsAuth for ${nameSite}":
  site         => "$nameSite",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::32bit { '32bitAppPool':
  appName  => 'admin',
  enabled  => false,
}

#create web app
appcmd::createwebapp { 'am':
  siteName     => "${nameSite}",
  path         => '/am',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\am",
  document     => 'default.aspx',
  apppool      => 'admin',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'cannon':
  siteName     => "${nameSite}",
  path         => '/cannon',
  physicalPath => 'D:\mycompany-builds\Cannon\INT\src\mycompany.DAE.Cannon.Web',
  document     => 'default.aspx',
  apppool      => 'admin',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'ch':
  siteName     => "${nameSite}",
  path         => '/ch',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\ch",
  document     => 'default.aspx',
  apppool      => 'admin',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'mycompany.Utils':
  siteName     => "${nameSite}",
  path         => '/mycompany.Utils',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\mycompany.Utils",
  document     => 'default.aspx',
  apppool      => 'admin',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'lp2':
  siteName     => "${nameSite}",
  path         => '/lp2',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\lp2",
  document     => 'default.aspx',
  apppool      => 'admin',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'MachIntel':
  siteName     => "${nameSite}",
  path         => '/MachIntel',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\MachIntel",
  document     => 'default.aspx',
  apppool      => 'admin',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'comcom':
  siteName     => "${nameSite}",
  path         => '/comcom',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\comcom",
  document     => 'default.aspx',
  apppool      => 'admin',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'appname03':
  siteName     => "${nameSite}",
  path         => '/appname03',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname03",
  document     => 'default.aspx',
  apppool      => 'admin',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"],
}

#Asign AppPool to the site
exec { 'AddAppPooltoSite':
  command => "appcmd.exe set site /site.name:${nameSite} /[path=\'/\'].applicationPool:admin",
  require => Appcmd::Createsite["CreateSite ${nameSite}"],
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'appname01',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

exec { 'appSettingsCommon2':
  command => "appcmd.exe set config /commit:MACHINE /section:appSettings /+\"[key=\'Common2EnvironmentCode\',value=\'INT\']\"",
  returns => ['0','183'],
  require      => Appcmd::Createsite["CreateSite ${nameSite}"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\web.config":
  ensure => absent,
  require      => Appcmd::Createsite["CreateSite ${nameSite}"],
  }

# Restart site
exec { 'admin-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10,
  require   => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}
