class appname05::stagingarconfig () {
include appcmd
require appname05::setup
require iiswebserver::iissetup

$nameSite = 'staging-ar.voicefive.com'

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}	

#create apppool
appcmd::createapppool { 'staging-ar':
  appName         => 'staging-ar',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => "staging-ar",
  bindings     => "http/*:80:${nameSite}",
  require      => Appcmd::Createapppool["staging-ar"]
}

#create web app
appcmd::createwebapp { 'DEVBRANCH':
  siteName     => "${nameSite}",
  path         => '/DEVBRANCH',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\branchwwwroot",
  document     => 'index.htm',
  apppool      => 'ch',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#Enabling appname03oryBrowse
appcmd::appname03orybrowse { 'appname03orybrowse':
  sitePath => "${nameSite}/DEVBRANCH",
  state    => 'true',
  require  => [Appcmd::Createsite["CreateSite ${nameSite}"],Appcmd::Createwebapp['DEVBRANCH']]
}

# Restart site
exec { 'staging-ar-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10, 
  unless  => "cmd.exe /c \"appcmd.exe list site \"${nameSite}\" | find.exe \"state:Started\"\"",
  require   => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}
