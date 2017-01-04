class appname05::clubhouseconfig() {

include appcmd
require appname05::setup

$nameSite = 'my.securestudies.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
  } else {
  $defservername = "${temp}-clubhouse.mydomain.mycompany.com"
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
appcmd::createapppool { 'my_securestudies.com_4.0':
  appName         => 'my_securestudies.com_4.0',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => 'my_securestudies.com_4.0',
  bindings     => "http/*:80:${defservername}",
  require      => Appcmd::Createapppool['my_securestudies.com_4.0']
}

appcmd::32bit { 'my_securestudies.com_4.0':
  appName  => 'my_securestudies.com_4.0',
  enabled  => true,
}
# Restart site
exec { 'mysecurestudies-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10,
  unless  => "cmd.exe /c \"appcmd.exe list site \"${nameSite}\" | find.exe \"state:Started\"\"",
  require  => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}
