class appname05::appname05pollconfig() {

include appcmd
require appname05::setup

$nameSite = 'web.appname05-poll.com'

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}	

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\w3c":
	ensure => present,
	owner   => 'Everyone',
	group   => 'Administrators',
	mode    => '0770',
	source => 'puppet:///modules/appname05/w3c',
	recurse => true,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\beacon":
	ensure => present,
	owner   => 'Everyone',
	group   => 'Administrators',
	mode    => '0770',
	source => 'puppet:///modules/appname05/beacon',
	recurse => true,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\bin":
	ensure  => present,
	owner   => 'Everyone',
	group   => 'Administrators',
	mode    => '0770',
	source  => 'puppet:///modules/appname05/bin',
	recurse => true,
	ignore  => ".{log}",
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\bin\logs":
	ensure => appname03ory,
	owner   => 'Everyone',
	group   => 'Administrators',
	mode    => '0770',
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\bin"]
}
		
#create web site
appcmd::createsite { 'CreateSite':
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => "appname05poll",
  bindings     => "http/*:80:",
  require      => Appcmd::Createapppool['appname05poll']
}

#create apppool
appcmd::createapppool { 'appname05poll':
  appName         => 'appname05poll',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::32bit { '32bitAppPool':
  appName  => 'appname05poll',
  enabled  => true,
}

#create web app
appcmd::createwebapp { 'bin':
  siteName     => "${nameSite}",
  path         => '/bin',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\bin",
  document     => 'index.htm',
  apppool      => 'appname05poll',
  require      => Appcmd::Createsite['CreateSite']
}

appcmd::createwebapp { 'tc':
  siteName     => "${nameSite}",
  path         => '/tc',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\tc",
  document     => 'default.aspx',
  apppool      => 'appname05poll',
  require      => Appcmd::Createsite['CreateSite']
}

appcmd::createwebapp { 'beacon':
  siteName     => "${nameSite}",
  path         => '/beacon',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\beacon",
  document     => 'default.aspx',
  apppool      => 'appname05poll',
  require      => Appcmd::Createsite['CreateSite']
}

sslcerts::run{'ssl-certs':
  siteName      => "${nameSite}",
  pathSite      => '/',
  pfxFile       => "STAR_appname05-poll_com.pfx",
  require       => Appcmd::Createsite['CreateSite']
}

# Restart site
exec { 'web.appname05-poll-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10,
  unless  => "cmd.exe /c \"appcmd.exe list site \"${nameSite}\" | find.exe \"state:Started\"\"",
  require   => Appcmd::Createsite['CreateSite']
}

}
