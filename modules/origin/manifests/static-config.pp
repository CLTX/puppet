class int-my::config () {

include appcmd
include sslcerts
require int-my::setup

$nameSite = 'my.mycompany.com'

$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-my.mycompany.com"
}


# delete Default Web Site
#appcmd::deletesite { 'DeleteSite':
#  siteName => 'Default Web Site'
#}

appcmd::createapppool { 'accounts':
  appName         => 'accounts',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'autologin':
  appName         => 'autologin',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'ext31':
  appName         => 'ext31',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'LMSPublic':
  appName         => 'LMSPublic',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'my_4.0':
  appName         => 'my_4.0',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'my3':
  appName         => 'my3',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'my3web':
  appName         => 'my3web',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'pm':
  appName         => 'pm',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'myplatform':
  appName         => 'myplatform',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'responserate':
  appName         => 'responserate',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'mydomainlink':
  appName         => 'mydomainlink',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

appcmd::createapppool { 'welcome':
  appName         => 'welcome',
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
  apppool      => "my_4.0",
  require      => Appcmd::Createapppool['my_4.0']
}

#create vdir
appcmd::createvdir { "ext31":
  sitename     => "${nameSite}",
  vdirname     => 'ext31',
  appName      => '',
  physicalPath => "D:\\mycompany\\webpub\\javascript\\ext",
  require      => Appcmd::Createsite["${nameSite}"]
}

#Apply Root Reappname03 Rule
appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName => "${nameSite}",
  reappname03Path => '/welcome/',
  require => Appcmd::Createsite["${nameSite}"]
}


#create response Header
#for Value dont Use space.
#appcmd::httpresponseheader { 'HTTP Response':
#  nameHttp  => 'Access-Control-Allow-Headers',
#  value     => 'Origin,X-Requested-With,Content-Type,Accept',
#  siteName  => "$nameSite",
#  appName   => 'my3',
#  require   => [Appcmd::Createsite["${nameSite}"], Appcmd::Createapppool['my3']]
#}

######## install csauth, remember change it wherever csauth-x64.dll will be copied this case using D:\mycompany\inetpub\can.tst\isapi\csauth-x64.dll
#appcmd::isapifilter { 'IsapiFilterCsAuth':
#  site         => "$nameSite",
#  modName      => 'csauth',
#  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
#  preCondition => 'bitness64',
#  require      => Appcmd::Createsite["${nameSite}"]
#}

#create web app
appcmd::createwebapp { 'accounts':
  siteName     => "$nameSite",
  path         => '/accounts',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\accounts",
  document     => 'default.aspx',
  apppool      => 'accounts',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['accounts']] 
}

appcmd::createwebapp { 'ext31':
  siteName     => "$nameSite",
  path         => '/ext',
  physicalPath => "D:\\mycompany\\webpub\\javascript\\ext",
  document     => 'default.aspx',
  apppool      => 'ext31',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['ext31']]
}

appcmd::createwebapp { 'LMSPublic':
  siteName     => "$nameSite",
  path         => '/LMSPublic',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\LMSPublic",
  document     => 'default.aspx',
  apppool      => 'LMSPublic',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['LMSPublic']]
}

appcmd::createwebapp { 'autologin':
  siteName     => "$nameSite",
  path         => '/autologin',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\autologin",
  document     => 'default.aspx',
  apppool      => 'autologin',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['autologin']]
}

appcmd::createwebapp { 'mydomainlink':
  siteName     => "$nameSite",
  path         => '/mydomainlink',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\mydomainlink",
  document     => 'default.aspx',
  apppool      => 'mydomainlink',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['mydomainlink']]
}

appcmd::createwebapp { 'my3':
  siteName     => "$nameSite",
  path         => '/my3',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\my3",
  document     => 'default.aspx',
  apppool      => 'my3',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['my3']]
}

appcmd::createwebapp { 'my3web':
  siteName     => "$nameSite",
  path         => '/my3web',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\my3web",
  document     => 'default.aspx',
  apppool      => 'my3web',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['my3web']]
}

appcmd::createwebapp { 'pm':
  siteName     => "$nameSite",
  path         => '/pm',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\pm",
  document     => 'default.aspx',
  apppool      => 'pm',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['pm']]
}

appcmd::createwebapp { 'responserate':
  siteName     => "$nameSite",
  path         => '/responserate',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\responserate",
  document     => 'default.aspx',
  apppool      => 'responserate',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['responserate']]
}

appcmd::createwebapp { 'welcome':
  siteName     => "$nameSite",
  path         => '/welcome',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\welcome",
  document     => 'default.aspx',
  apppool      => 'welcome',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['welcome']]
}

appcmd::createwebapp { 'wwwapps':
  siteName     => "$nameSite",
  path         => '/wwwapps',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\wwwapps",
  document     => 'default.aspx',
  apppool      => 'wwwapps',
  require      => [Appcmd::Createsite["${nameSite}"],Appcmd::Createapppool['wwwapps']]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'myplatform',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["${nameSite}"]
}

#sslcerts::run{'ssl-certs': 
#  siteName      => "${nameSite}",
#  pathSite      => '/',
#  hostHeaderValue => "${defservername}",
#  require       => Appcmd::Createsite["${nameSite}"]
#}

appcmd::startapppool{ 'Start AppPool':
  appName => 'my_4.0',
  require => Appcmd::Createapppool['my_4.0']
}

}
