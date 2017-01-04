class appname05::securestudiesconfig() {

include appcmd
include sslcerts
require appname05::setup

$nameSite = 'my.securestudies.com'
$temp = downcase($machine_env)

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
  } else {
  $defservername = "${temp}-my-securestudies.mydomain.mycompany.com"
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

if $machine_env == "PRD" {
    sslcerts::run{'ssl-certs':
      siteName      => "${nameSite}",
      pathSite      => '/',
      pfxFile       => "STAR_securestudies_com.pfx",
      require       => Appcmd::Createsite["CreateSite ${nameSite}"]
    }
} 
else {
    sslcerts::run{"ssl-certs": 
      siteName        => "${nameSite}",
      pathSite        => '/',
      hostHeaderValue => "",
      require         => Appcmd::Createsite["CreateSite ${nameSite}"]
    }
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
