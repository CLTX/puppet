class learn::config () {

include appcmd
include sslcerts

$nameSite = 'learn.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-learn.mycompany.com"
}

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

appcmd::createapppool { 'learn':
  appName         => 'learn',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

# create web site
appcmd::createsite { "${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "learn",
  require      => Appcmd::Createapppool['learn']
}

#create web app
if $authmoduleversion != "noAuthModule" {
  appcmd::addisapimodule { 'AuthModule':
    site         => "${nameSite}",
    modName      => "mycompanyAuthModule",
    type         => "mycompany.SSO.AuthHTTPModule.AuthModule, mycompany.SSO.AuthHTTPModule, Version=$authmoduleversion, Culture=neutral, PublicKeyToken=bcd2b958bd340364",
    preCondition => "managedHandler",
    require      => [Appcmd::Createsite["${nameSite}"],Package["mycompany SingleSignOn - Release"]]
  } 
}

appcmd::startapppool{ "'Start learn":
  appName => 'learn',
  require => Appcmd::Createapppool['learn']
}

sslcerts::run{'ssl-certs': 
  siteName        => "${nameSite}",
  pathSite        => '/',
  hostHeaderValue => "${defservername}",
  require         => Appcmd::Createsite["${nameSite}"]
}

}
