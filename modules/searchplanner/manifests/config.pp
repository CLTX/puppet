class searchplanner::config () {

include appcmd
include installutil
include myplatform
require searchplanner::setup

$nameSite = 'searchplanner.mycompany.com' 

$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} elsif $machine_env == "INT" and $hostname == 'pvusaDMW02'{
  $defservername = "${temp}-regression-searchplanner.mydomain.mycompany.com"
} elsif $machine_env == "STAG" {
  $defservername = "stage-searchplanner.mydomain.mycompany.com"
} else {
  $defservername = "${temp}-searchplanner.mydomain.mycompany.com"
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf":
  ensure  => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
  ensure  => file,
  content => template("searchplanner/conf/searchplanner/css.erb"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt":
  ensure  => file,
  content => template("searchplanner/conf/searchplanner/aci.erb"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"]
}

#create apppool
appcmd::createapppool { 'searchplanner':
  appName         => 'searchplanner',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

#create web site
appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "searchplanner",
  bindings     => "http/*:80:${defservername}",
  require      => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

appcmd::siteauthentication { "Site Authentication for ${nameSite}":
  siteName  => "${nameSite}",
  anonymous => 'true',
  basic     => 'false',
  digest    => 'false',
  windows   => 'false',
  forms     => 'false',
  aspnet    => 'false',
  require   => Appcmd::Createsite["CreateSite ${nameSite}"],
}

appcmd::isapifilter { "IsapiFilterCsAuth for ${nameSite}":
  site         => "$nameSite",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#Apply Root Reappname03 Rule
appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName     => "${nameSite}",
  reappname03Path => '/report.aspx/',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}


myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'searchplanner',
  environment  => "${machine_env}"
}

}
