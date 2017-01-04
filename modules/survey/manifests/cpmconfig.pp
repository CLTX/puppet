class appname05::cpmconfig() {

include appcmd
require appname05::setup
include registry
include loopbackv2
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

$nameSite = 'cpm.mydomain.mycompany.com'
$temp = downcase($machine_env)
$hierasubnet = "mask-${nameSite}"

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-cpm.mydomain.mycompany.com"
}

$ip_from_hiera = hiera("${nameSite}")
$subnetmask_from_hiera = hiera("${hierasubnet}")

if $machine_env == "PRD" {
  $ip_cpm = hiera("physical-cpm") 
} 

 if $ip_from_hiera == $getip {
  $site_ip = "${getip}"
  } else {
  $site_ip = "${ip_from_hiera}"
  }

if $machine_env == "PRD" {
  loopbackv2::setup {'adding loopback for cpm':
    lvsip      => "${ip_from_hiera}",
    subnetmask => "${subnetmask_from_hiera}"
    }
  }

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\$nameSite\\conf":
  ensure  => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"]
}

if $machine_env == "PRD" {
  file {"D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf":
    ensure    => file,
    content   => template("appname05/cpm/css.erb"),
    require   => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
} else {
  file {"D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf":
    ensure    => file,
    content   => template("appname05/cpm/css-nonprd.erb"),
    require   => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
  }
}

file {"D:\\mycompany\\webpub\\$nameSite\\conf\\aci.txt":
  ensure  => file,
  content => template("appname05/cpm/aci.txt"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"],
}

append_if_no_such_line {"Append $nameSite to common css":
  file    => "D:\\mycompany\\webpub\\conf\\css.conf",
  line    => "Domaincfg D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf",
  ensure  => insync,
  require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
  }


file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

#create web site
appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => "cpm",
  bindings     => "http/*:80:${defservername}",
  require      => Appcmd::Createapppool["cpm"],
}

#create apppool
appcmd::createapppool { 'AutoMailerMgnt':
  appName         => 'AutoMailerMgnt',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName => 'yourdomain\daewebuser',
  password => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app"]
}

appcmd::createapppool { 'bmx':
  appName         => 'bmx',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName => 'yourdomain\daewebuser',
  password => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app"]
}

appcmd::createapppool { 'cpm':
  appName         => 'cpm',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName => 'yourdomain\daewebuser',
  password => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app"]
}

appcmd::createapppool { 'dst':
  appName         => 'dst',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName => 'yourdomain\daewebuser',
  password => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app"]
}

appcmd::createapppool { 's2emgt':
  appName         => 's2emgt',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName => 'yourdomain\daewebuser',
  password => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app"]
}

appcmd::createapppool { 'SiteCodeMapper':
  appName         => 'SiteCodeMapper',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName => 'yourdomain\daewebuser',
  password => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app"]
}

appcmd::createapppool { 'TrustScore':
  appName         => 'TrustScore',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName => 'yourdomain\daewebuser',
  password => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app"]
}

appcmd::createapppool { 'responserate':
  appName         => 'responserate',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName => 'yourdomain\daewebuser',
  password => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app"]
}

appcmd::isapifilter { "IsapiFilterCsAuth for ${nameSite}":
  site         => "$nameSite",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#create web app
appcmd::createwebapp { 'bmx':
  siteName     => "${nameSite}",
  path         => '/bmx',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\bmx",
  document     => 'counts.aspx',
  apppool      => 'bmx',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'cpm':
  siteName     => "${nameSite}",
  path         => '/cpm',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\cpm",
  document     => 'default.aspx',
  apppool      => 'cpm',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'dst':
  siteName     => "${nameSite}",
  path         => '/dst',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\dst",
  document     => 'default.aspx',
  apppool      => 'dst',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'AutomailerManagement':
  siteName     => "${nameSite}",
  path         => '/AutomailerManagement',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\AutomailerManagement",
  document     => 'default.aspx',
  apppool      => 'AutoMailerMgnt',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 's2emgt':
  siteName     => "${nameSite}",
  path         => '/s2emgt',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\s2emgt",
  document     => 'default.aspx',
  apppool      => 's2emgt',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'SiteCodeMapper':
  siteName     => "${nameSite}",
  path         => '/SiteCodeMapper',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\SiteCodeMapper",
  document     => 'default.aspx',
  apppool      => 'SiteCodeMapper',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'TrustScore':
  siteName     => "${nameSite}",
  path         => '/TrustScore',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\TrustScore",
  document     => 'default.aspx',
  apppool      => 'TrustScore',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#creating Reappname03s 
appcmd::createrdir { 'cpm2':
  url1    => "${nameSite}/cpm2",
  url2    => "${nameSite}/cpm",
  require => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName     => "${nameSite}",
  reappname03Path => '/cpm/',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#Asign AppPool to the site
exec { 'AddAppPooltoSite':
  command => "appcmd.exe set site /site.name:${nameSite} /[path=\'/\'].applicationPool:cpm",
  require => Appcmd::Createsite["CreateSite ${nameSite}"]
}

# Restart site
exec { 'cpm-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10,
  unless    => "cmd.exe /c \"appcmd.exe list site \"${nameSite}\" | find.exe \"state:Started\"\"",
  require   => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}
