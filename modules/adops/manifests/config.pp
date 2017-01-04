class appname02::config () {

include appcmd
include sslcerts
include registry
include stdlib
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup
require appname02::setup

$nameSite = 'appname02.mycompany.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "appname02.mydomain.mycompany.com"
} else {
  $defservername = "${temp}-appname02.mydomain.mycompany.com"
}

################################
# Creating Folders and subdirs #
##################################

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

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02-external":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02-management":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02api":
  ensure      => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

#################################################
# Adding ISAPI-Filter setting files as required #
#################################################

if $machine_env == "PRD" {
  file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
    ensure  => present,
    content => template("appname02/css.erb"),
    require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
} else {
  file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
    ensure  => present,
    content => template("appname02/css-nonprod.erb"),
    require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt":
  ensure  => present,
  content => template("appname02/aci.txt"),
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

appcmd::createapppool { 'appname02':
  appName         => 'appname02',
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
  apppool      => 'appname02',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['appname02'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02api"]]
}

appcmd::createwebapp { 'appname02-external':
  siteName     => "$nameSite",
  path         => '/appname02-external',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\appname02-external",
  document     => 'default.aspx',
  apppool      => 'appname02',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['appname02'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02-external"]]
}

appcmd::createwebapp { 'appname02-management':
  siteName     => "$nameSite",
  path         => '/appname02-management',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\appname02-management",
  document     => 'default.aspx',
  apppool      => 'appname02',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['appname02'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\appname02-management"]]
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

