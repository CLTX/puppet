class appname04::apiconfig () {

include appcmd
include sslcerts
include installutil
require appname04::setup
require iiswebserver

$nameSite = 'api.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} elsif $machine_env == "STAG" {
  $defservername = "stage-api.mydomain.mycompany.com"
} else {
  $defservername = "${temp}-api.mydomain.mycompany.com"
}


#create apppool

appcmd::createapppool { 'mmxapi':
  appName         => 'mmxapi',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'searchplannerapi':
  appName         => 'searchplannerapi',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'mmxmydomainlinkapi':
  appName         => 'mmxmydomainlinkapi',
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
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\mmx",
  apppool 	   => 'mmxapi',
  bindings     => "http/*:80:${defservername}",
  require     =>  Appcmd::Createapppool['mmxapi']
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

appcmd::createwebapp { "SearchPlanner for ${nameSite}":
  siteName     => "${nameSite}",
  path         => '/searchplanner',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\searchplanner",
  document     => 'default.aspx',
  apppool 	   => 'searchplannerapi',
  require      => [ Appcmd::Createapppool['searchplannerapi'], Appcmd::Createsite["Root for ${nameSite}"] ]
}

appcmd::createwebapp { "mydomainLink for ${nameSite}":
  siteName     => "${nameSite}",
  path         => '/mydomainlink',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\mydomainlink",
  document     => 'default.aspx',
  apppool 	   => 'mmxmydomainlinkapi',
  require      => [ Appcmd::Createapppool['mmxmydomainlinkapi'], Appcmd::Createsite["Root for ${nameSite}"] ]

}

sslcerts::run{"ssl-certs for ${nameSite}": 
  siteName      => "${nameSite}",
  pathSite      => '/',
  hostHeaderValue => "${defservername}",
  require       => Appcmd::Createsite["Root for ${nameSite}"]
}

}
