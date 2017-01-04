class appname02::confignew () {

include appcmd
include sslcerts
include registry
include stdlib
include authmodule
require appfabricclient

$nameSite = 'appname02.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "appname02.mydomain.mycompany.com"
} else {
  $defservername = "${temp}-appname02.mydomain.mycompany.com"
}

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

################################
# Creating Folders and subdirs #
##################################

file {"D:\\mycompany\\webpub\\${nameSite}":
  ensure => appname03ory,
  require => File['D:\\mycompany\\webpub'],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02-external":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02management":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02api":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

###############
# IIS OBJECTS #
###############

appcmd::createapppool { 'appname02':
  appName         => 'appname02',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'appname02-classic':
  appName         => 'appname02-classic',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createsite {"${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "appname02",
  bindings     => "http/*:80:${defservername}",
  require      => [Appcmd::Createapppool['appname02'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]]
}

appcmd::createwebapp { 'appname02api':
  siteName     => "$nameSite",
  path         => '/appname02api',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\appname02api",
  document     => 'default.aspx',
  apppool      => 'appname02-classic',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['appname02-classic'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02api"]]
}

appcmd::createwebapp { 'appname02-external':
  siteName     => "$nameSite",
  path         => '/appname02-external',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\appname02-external",
  document     => 'default.aspx',
  apppool      => 'appname02-classic',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['appname02-classic'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02-external"]]
}

appcmd::createwebapp { 'appname02management':
  siteName     => "$nameSite",
  path         => '/appname02management',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\appname02management",
  document     => 'default.aspx',
  apppool      => 'appname02',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['appname02'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02management"]]
}

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

appcmd::startapppool{ "Start AppPool ${nameSite}":
  appName => 'appname02',
  require => Appcmd::Createapppool['appname02']
}

sslcerts::run{"ssl-certs ${nameSite}":
  siteName        => "${nameSite}",
  pathSite        => '/',
  hostHeaderValue => "${defservername}",
  require         => Appcmd::Createsite["${nameSite}"]
}
}

