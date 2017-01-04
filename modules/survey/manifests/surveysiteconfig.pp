class appname05::appname05siteconfig() {

include appcmd
require appname05::setup

$nameSite = 'www.appname05site.com'

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}	
	
#create apppool
appcmd::createapppool { 'appname05':
  appName         => 'appname05',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => 'appname05',
  document     => 'index.html',
  bindings     => "http/*:80:",
  require      => Appcmd::Createapppool['appname05']
}

appcmd::customerrors { 'Reappname03 404 errors':
  statuscode   => '404',
  siteName     => "${nameSite}",
  reappname03Path => 'http://www.mycompany.com/Products',
  responseMode => 'Reappname03',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::32bit { 'appname05':
  appName  => 'appname05',
  enabled  => true,
}
# Restart site
exec { 'appname05-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10,
  unless  => "cmd.exe /c \"appcmd.exe list site \"${nameSite}\" | find.exe \"state:Started\"\"",
  require  => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}
