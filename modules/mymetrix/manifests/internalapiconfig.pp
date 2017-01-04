class appname04::internalapiconfig () {

include appcmd
include installutil
require appname04::setup
require iiswebserver

$nameSite = 'internalmmxapi.mycompany.com'

$temp = downcase($machine_env)
if $machine_env == "PRD" {
  if $machine_role == "Client - Web APIs" {
    $defservername= "internalmmxapi.mydomain.mycompany.com"
  } else {
    $defservername= "${nameSite}"
  }
} elsif $machine_env == "STAG" {
  $defservername = "stage-internalmmxapi.mydomain.mycompany.com"
} else {
  $defservername = "${temp}-internalmmxapi.mydomain.mycompany.com"
}

#create apppool

appcmd::createapppool { 'mmxqatservice':
  appName         => 'mmxqatservice',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'mmxrestapi':
  appName         => 'mmxrestapi',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'mmxwcfservice':
  appName         => 'mmxwcfservice',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'mmxmediabuilder':
  appName         => 'mmxmediabuilder',
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
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool 	   => 'mmxwcfservice',
  bindings     => "http/*:80:${defservername}",
  require     =>  Appcmd::Createapppool['mmxwcfservice']
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
  path         => '/QatWebApi',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\QatWebApi",
  document     => 'default.aspx',
  apppool 	   => 'mmxqatservice',
  require      => [ Appcmd::Createapppool['mmxqatservice'], Appcmd::Createsite["Root for ${nameSite}"] ]
}

appcmd::createwebapp { "RestAPI for ${nameSite}":
  siteName     => "${nameSite}",
  path         => '/RestApi',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\RestApi",
  document     => 'default.aspx',
  apppool 	   => 'mmxrestapi',
  require      => [ Appcmd::Createapppool['mmxrestapi'], Appcmd::Createsite["Root for ${nameSite}"] ]
}

appcmd::createwebapp { "WcfService for ${nameSite}":
  siteName     => "${nameSite}",
  path         => '/WcfService',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\WcfService",
  document     => 'default.aspx',
  apppool 	   => 'mmxwcfservice',
  require      => [ Appcmd::Createapppool['mmxwcfservice'], Appcmd::Createsite["Root for ${nameSite}"] ]
}

appcmd::createwebapp { "MediaBuilder for ${nameSite}":
  siteName     => "${nameSite}",
  path         => '/MediaBuilder',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\MediaBuilder",
  document     => 'default.aspx',
  apppool 	   => 'mmxmediabuilder',
  require      => [ Appcmd::Createapppool['mmxmediabuilder'], Appcmd::Createsite["Root for ${nameSite}"] ]
}

}
