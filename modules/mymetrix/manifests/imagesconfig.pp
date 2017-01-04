class appname04::imagesconfig () {

include appcmd
require appname04::setup
require iiswebserver

$nameSite = 'images.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} elsif $machine_env == "STAG" {
  $defservername = "stage-images.mydomain.mycompany.com"
} else {
  $defservername = "${temp}-images.mydomain.mycompany.com"
}

#create apppool

appcmd::createapppool { 'images':
  appName         => 'images',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
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
  physicalPath => "D:\\mycompany\\webpub\\appname04.mycompany.com\\wwwroot\\app\\images",
  apppool 	   => 'images',
  bindings     => "http/*:80:${defservername}",
  require     =>  Appcmd::Createapppool['images']
}

appcmd::createvdir { "myplatform for ${nameSite}":
  sitename     => "${nameSite}",
  vdirname     => 'myplatform',
  appName      => '',
  physicalPath => '\\yourdomain.mycompany.com\PDFS\Shares\team01\MyPlatform\images',
  require   => Appcmd::Createsite["Root for ${nameSite}"],
}

appcmd::createvdir { "akamai for ${nameSite}":
  sitename     => "${nameSite}",
  vdirname     => 'akamai',
  appName      => '',
  physicalPath => '\\yourdomain.mycompany.com\installers\Shared-Apps\akamai',
  require   => Appcmd::Createsite["Root for ${nameSite}"],
}

appcmd::createvdir { "ext for ${nameSite}":
  sitename     => "${nameSite}",
  vdirname     => 'ext',
  appName      => '',
  physicalPath => 'D:\mycompany\webpub\appname04.mycompany.com\wwwroot\app\scripts\ext\resources\images',
  require   => Appcmd::Createsite["Root for ${nameSite}"],
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

sslcerts::run{"ssl-certs for ${nameSite}": 
  siteName        => "${nameSite}",
  pathSite        => '/',
  hostHeaderValue => "${defservername}",
  require         => Appcmd::Createsite["Root for ${nameSite}"]
}

}
