class my::config () {

include appcmd
include myplatform
include sslcerts
require my::setup

$nameSite = 'my.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-my.mydomain.mycompany.com"
}


# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

appcmd::createapppool { 'my_2.0':
  appName         => 'my_2.0',
  runtimeVersion  => 'v2.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'oauthlogin-.net-4.0':
  appName         => 'oauthlogin-.net-4.0',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'my_pm_4.0':
  appName         => 'my_pm_4.0',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'my_4':
  appName         => 'my_4',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'wwwapps':
  appName         => 'wwwapps',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

# create web site
appcmd::createsite { "${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "my_2.0",
  require      => Appcmd::Createapppool['my_2.0']
}

######## install csauth, remember change it wherever csauth-x64.dll will be copied this case using D:\mycompany\inetpub\can.tst\isapi\csauth-x64.dll
appcmd::isapifilter { 'IsapiFilterCsAuth':
  site         => "$nameSite",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["${nameSite}"]
}

#create web app
appcmd::createwebapp { 'accounts':
  siteName     => "$nameSite",
  path         => '/accounts',
  physicalPath => "D:\\mycompany\\webpub\\accounts\\wwwroot",
  document     => 'default.aspx',
  apppool      => 'my_2.0',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'cgi-bin':
  siteName     => "$nameSite",
  path         => '/cgi-bin',
  physicalPath => "D:\\mycompany\\webpub\\cgi.bin",
  document     => 'default.aspx',
  apppool      => 'login',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'ext31':
  siteName     => "$nameSite",
  path         => '/ext31',
  physicalPath => 'D:\mycompany\webpub\javascript\wwwroot\ext\3_2_1',
  document     => 'default.aspx',
  apppool      => 'my_2.0',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'LMSPublic':
  siteName     => "$nameSite",
  path         => '/LMSPublic',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\LMSPublic",
  document     => 'default.aspx',
  apppool      => 'my_2.0',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'OAuthLogin':
  siteName     => "$nameSite",
  path         => '/OAuthLogin',
  physicalPath => "D:\\mycompany\\webpub\\OAuthLogin\\wwwroot",
  document     => 'default.aspx',
  apppool      => 'oauthlogin-.net-4.0',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'autologin':
  siteName     => "$nameSite",
  path         => '/autologin',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\autologin",
  document     => 'default.aspx',
  apppool      => 'my_4',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'mydomainlink':
  siteName     => "$nameSite",
  path         => '/mydomainlink',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\mydomainlink",
  document     => 'default.aspx',
  apppool      => 'my_4',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'pm':
  siteName     => "$nameSite",
  path         => '/pm',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\pm",
  document     => 'default.aspx',
  apppool      => 'my_pm_4.0',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'PMXF':
  siteName     => "$nameSite",
  path         => '/PMXF',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\PMXF",
  document     => 'default.aspx',
  apppool      => 'my_2.0',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'ResponseRate':
  siteName     => "$nameSite",
  path         => '/ResponseRate',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\ResponseRate",
  document     => 'ResponseRate.aspx',
  apppool      => 'my_4',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'welcome':
  siteName     => "$nameSite",
  path         => '/welcome',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\welcome",
  document     => 'default.aspx',
  apppool      => 'my_2.0',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'wwwapps':
  siteName     => "$nameSite",
  path         => '/wwwapps',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\wwwapps",
  document     => 'default.aspx',
  apppool      => 'wwwapps',
  require      => Appcmd::Createsite["${nameSite}"]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'my_2.0',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["${nameSite}"]
}


sslcerts::run{'ssl-certs': 
  siteName      => "${nameSite}",
  pathSite      => '/',
  hostHeaderValue => "${defservername}",
  require       => Appcmd::Createsite["${nameSite}"]
}

appcmd::startapppool{ 'Start AppPool':
  appName => 'my',
  require => Appcmd::Createapppool['my_2.0']
}

}
