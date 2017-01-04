class appname04::mysearchconfig () {

include appcmd
include installutil
require appname04::setup
require iiswebserver

$nameSite = 'mysearch.mycompany.com'

$temp = downcase($machine_env)
if $machine_env == "PRD" {
  if $machine_role == "Web" {
          $defservername= "mysearch.mydomain.mycompany.com"
  } else {
          $defservername= "${nameSite}"
  }
} elsif $machine_env == "STAG" {
  $defservername = "stage-mysearch.mydomain.mycompany.com"
} else {
  $defservername = "${temp}-mysearch.mydomain.mycompany.com"
}

#create apppool

appcmd::createapppool { 'mmxmysearch':
  appName         => 'mmxmysearch',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}

#create web app 
appcmd::createsite { "Root for ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool 	   => 'mmxmysearch',
  bindings     => "http/*:80:${defservername}",
  require     =>  Appcmd::Createapppool['mmxmysearch']
}

appcmd::siteauthentication { "Site Authentication for ${nameSite}":
  siteName  => "${nameSite}",
  anonymous => 'true',
  basic     => 'false',
  digest    => 'false',
  windows   => 'false',
  forms     => 'false',
  aspnet    => 'false',
  require   => Appcmd::Createsite["Root for ${nameSite}"],
}

}
