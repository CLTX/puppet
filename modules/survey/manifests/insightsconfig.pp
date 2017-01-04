class appname05::insightsconfig() {

include appcmd
require appname05::setup

$nameSite = 'insights.mycompany.com'

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}	
	
file {"D:\\mycompany\\webpub\\$nameSite\\conf":
  ensure => appname03ory,
}
	
file {"D:\\mycompany\webpub\\$nameSite\\conf\\css.conf":
  ensure  => present,
  content => template("appname05/insights/css.erb"),
  require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
}
	
file {"D:\mycompany\webpub\\$nameSite\conf\aci.txt":
  ensure  => present,
  content => template("appname05/insights/aci.txt"),
  require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
}

append_if_no_such_line {"Append $nameSite to common css":
  file    => "D:\\mycompany\\webpub\\conf\\css.conf",
  line    => "Domaincfg D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf",
  ensure  => insync,
  require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
  }

#create apppool
appcmd::createapppool { 'bmxins':
  appName         => 'bmxins',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

#create web site
appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => "bmxins",
  bindings     => "http/*:80:${nameSite}",
  require      => Appcmd::Createapppool["bmxins"]
}

appcmd::isapifilter { "IsapiFilterCsAuth for ${nameSite}":
  site         => "${nameSite}",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#create web app
appcmd::createwebapp { 'BMX':
  siteName     => "${nameSite}",
  path         => '/bmx',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\bmx",
  document     => 'default.aspx',
  apppool      => 'bmxins',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#Asign AppPool to the site
exec { "asign appool to ${nameSite}":
  command => "appcmd.exe set site /site.name:${nameSite} /[path=\'/\'].applicationPool:bmxins",
  require => Appcmd::Createsite["CreateSite ${nameSite}"]
}

# Restart site
exec { 'insights-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10,
  unless  => "cmd.exe /c \"appcmd.exe list site \"${nameSite}\" | find.exe \"state:Started\"\"",
  require   => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}
