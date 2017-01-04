class deliverynew::config () {

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

appcmd::createapppool { 'delivery':
  appName         => 'delivery',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

# create web site
appcmd::createsite { "${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "delivery",
  require      => Appcmd::Createapppool['delivery']
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

exec { "Removing ISAPI csauth as ISAPI Filter":
  command => "cmd.exe /C \"appcmd.exe set config \"${nameSite}/\" /section:isapiFilters  /-[name=\'csauth\'] /commit:apphost\"",
  onlyif  => "cmd.exe /C \"appcmd.exe list config \"${nameSite}/\" | find \"csauth\"\"",
  require => Appcmd::Createsite["${nameSite}"]
}
  
if $authmoduleversion != "noAuthModule" {
  appcmd::addisapimodule { 'AuthModule':
    site         => "${nameSite}",
    modName      => "mycompanyAuthModule",
    type         => "mycompany.SSO.AuthHTTPModule.AuthModule, mycompany.SSO.AuthHTTPModule, Version=$authmoduleversion, Culture=neutral, PublicKeyToken=bcd2b958bd340364",
    preCondition => "managedHandler",
    require      => [Appcmd::Createsite["${nameSite}"],Package["mycompany SingleSignOn - Release"]]
  }
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
