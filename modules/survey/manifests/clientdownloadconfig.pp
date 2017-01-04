class appname05::clientdownloadconfig() {

include appcmd
require appname05::setup

$nameSite = 'client-download.appname05site.com'

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}	
	
#create apppool
appcmd::createapppool { 'client-download':
  appName         => 'client-download',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => 'client-download',
  bindings     => "http/*:80:${nameSite}",
  require      => Appcmd::Createapppool['client-download']
}

appcmd::32bit { 'client-download':
  appName  => 'client-download',
  enabled  => true,
}

sslcerts::run{"ssl-certs for ${nameSite}": 
  siteName      => "${nameSite}",
  pathSite      => '/',
  hostHeaderValue => "${nameSite}",
  require       => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::sslsettings { "Forcing SSL for ${nameSite}":
  siteName     => "${nameSite}",
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

# Restart site
exec { 'client-download-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10,
  unless  => "cmd.exe /c \"appcmd.exe list site \"${nameSite}\" | find.exe \"state:Started\"\"",
  require  => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}
