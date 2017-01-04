class appname05::responserateconfig() {

include appcmd
include sslcerts
require appname05::setup

$nameSite = 'responserate.mycompany.com'

$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-responserate.mydomain.mycompany.com"
}

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}	
	
#create apppool
appcmd::createapppool { 'responserate':
  appName         => 'responserate',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => 'responserate',
  bindings     => "http/*:80:${defservername}",
  require      => Appcmd::Createapppool['responserate']
}

sslcerts::run{"ssl-certs for ${nameSite}": 
  siteName      => "${nameSite}",
  pathSite      => '/',
  hostHeaderValue => "${defservername}",
  require       => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::sslsettings { "Forcing SSL for ${nameSite}":
  siteName     => "${nameSite}",
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

# Restart site
exec { 'responserate-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10,
  unless  => "cmd.exe /c \"appcmd.exe list site \"${nameSite}\" | find.exe \"state:Started\"\"",
  require  => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}