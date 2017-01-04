class delivery::config () {

include appcmd
include myplatform
include sslcerts

$nameSite = 'delivery.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-delivery.mydomain.mycompany.com"
}

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

if ($hostname == 'pvusaPPW09') or ($hostname == 'pvusaPPW10') {
  appcmd::createapppool { 'delivery':
    appName         => 'delivery',
    runtimeVersion  => 'v4.0',
    managedPipeline => 'Integrated',
    userName        => 'yourdomain\daewebuser',
    password        => 'yourpassword'
  }
}else{
  appcmd::createapppool { 'delivery':
    appName         => 'delivery',
    runtimeVersion  => 'v4.0',
    managedPipeline => 'Classic',
    userName        => 'yourdomain\daewebuser',
    password        => 'yourpassword'
  }
}

# create web site
appcmd::createsite { "${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "delivery",
  require      => Appcmd::Createapppool['delivery']
}

appcmd::isapifilter { 'IsapiFilterCsAuth':
  site         => "${nameSite}",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["${nameSite}"]
}

#create web app

appcmd::createwebapp { 'cgi-bin':
  siteName     => "$nameSite",
  path         => '/cgi-bin',
  physicalPath => "D:\\mycompany\\web-applications\cgi-bin",
  document     => 'default.aspx',
  apppool      => 'delivery',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'dc':
  siteName     => "$nameSite",
  path         => '/dc',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\dc",
  document     => 'default.aspx',
  apppool      => 'delivery',
  require      => Appcmd::Createsite["${nameSite}"]
}

#Apply Root Reappname03 Rule
appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName     => "${nameSite}",
  reappname03Path => '/dc/',
  require      => Appcmd::Createsite["${nameSite}"]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'delivery',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::startapppool{ "'Start delivery":
  appName => 'delivery',
  require => Appcmd::Createapppool['delivery']
}

sslcerts::run{'ssl-certs': 
  siteName        => "${nameSite}",
  pathSite        => '/',
  hostHeaderValue => "${defservername}",
  require         => Appcmd::Createsite["${nameSite}"]
}

}
