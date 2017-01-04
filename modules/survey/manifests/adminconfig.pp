class appname05::adminconfig() {

include appcmd
include loopbackv2
require appname05::cpmconfig

$nameSite = 'ch-admin.mydomain.mycompany.com'
$temp = downcase($machine_env)
$hierasubnet = "mask-${nameSite}"

if $machine_env == "PRD" {
  $defservername= "${nameSite}"
  $ip_ch = hiera("physical-ch")
  } else {
  $defservername = "${temp}-ch-admin.mydomain.mycompany.com"
  }

$ip_from_hiera = hiera("${nameSite}")
$subnetmask_from_hiera = hiera("${hierasubnet}")


if $ip_from_hiera == $getip {
  $site_ip = "${getip}"
  } else {
  $site_ip = "${ip_from_hiera}"
  }

if $machine_env == "PRD" {
  loopbackv2::setup {'adding loopback for admin': 
    lvsip      => "${ip_from_hiera}",
    subnetmask => "${subnetmask_from_hiera}"
    }
  }
  
file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
  }
  
file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
  }	
	
file {"D:\\mycompany\\webpub\\$nameSite\\conf":
  ensure => appname03ory,
  }


if $machine_env == "PRD" {
  file {"D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf":
    ensure  => present,
    content => template("appname05/admin/css.erb"),
    require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
    }
} else {
  file {"D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf":
    ensure  => present,
    content => template("appname05/admin/css-nonprd.erb"),
    require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
    }
}

file {"D:\\mycompany\\webpub\\$nameSite\\conf\\aci.txt":
  ensure  => present,
  content => template("appname05/admin/aci.txt"),
  require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
  }

append_if_no_such_line {"Append $nameSite to common css":
  file    => "D:\\mycompany\\webpub\\conf\\css.conf",
  line    => "Domaincfg D:\\mycompany\\webpub\\$nameSite\\conf\\css.conf",
  ensure  => insync,
  require => File["D:\\mycompany\\webpub\\$nameSite\\conf"],
  }

#create apppool
appcmd::createapppool { 'ch':
  appName         => 'ch',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
  }

#create web site
appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => "ch",
  bindings     => "http/*:80:${defservername}",
  require      => Appcmd::Createapppool["ch"]
  }

appcmd::isapifilter { "IsapiFilterCsAuth for ${nameSite}":
  site         => "${nameSite}",
  modName      => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
  }

#Asign AppPool to the site
exec { "asign appool to ${nameSite}":
  command => "appcmd.exe set site /site.name:${nameSite} /[path=\'/\'].applicationPool:ch",
  require => Appcmd::Createsite["CreateSite ${nameSite}"]
  }

# Restart site
exec { 'clubhouse-start':
  command   => "appcmd.exe start site ${nameSite}",
  timeout   => 500,
  tries     => 3,
  try_sleep => 10,
  unless    => "cmd.exe /c \"appcmd.exe list site \"${nameSite}\" | find.exe \"state:Started\"\"",
  require   => Appcmd::Createsite["CreateSite ${nameSite}"]
  }
}
