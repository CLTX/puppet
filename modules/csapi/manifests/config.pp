class csapi::config () {

include appcmd
include myplatform
#include sslcerts

$nameSite = 'csapi.mydomain.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
   $defservername= "${nameSite}"
} 
else {
   $defservername = "${temp}-csapi.mydomain.mycompany.com"
   }

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
   siteName => 'Default Web Site'
   }

appcmd::createapppool { 'csapi_amtool':
  appName         => 'csapi_amtool',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Deletesite['DeleteSite']
}


appcmd::createapppool { 'csapi_common':
  appName         => 'csapi_common',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi_amtool']
}

appcmd::createapppool { 'csapi_mmxrestapi':
  appName         => 'csapi_mmxrestapi',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi_amtool']
}
   
appcmd::createapppool { 'csapi_mmxservice':
  appName         => 'csapi_mmxservice',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi_amtool']
}

appcmd::createapppool { 'csapi_common2':
  appName         => 'csapi_common2',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi_amtool']
}

appcmd::createapppool { 'csapi_appname05':
  appName         => 'csapi_appname05',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi_amtool']
}

appcmd::createapppool { 'csapi_feedbackservice':
  appName         => 'csapi_feedbackservice',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi_amtool']
}

appcmd::createapppool { 'csapi_icrf':
  appName         => 'csapi_icrf',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi_amtool']
}

appcmd::createapppool { 'csapi_my':
  appName         => 'csapi_my',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => Appcmd::Createapppool['csapi_amtool']
}

# create web site
appcmd::createsite { "${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "csapi_common",
  require      => Appcmd::Createapppool['csapi_common']
}

#appcmd::isapifilter { 'IsapiFilterCsAuth':
#  site         => "${nameSite}",
#  modName         => 'csauth',
#  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
#  preCondition => 'bitness64',
#  require      => Appcmd::Createsite["${nameSite}"]
#}

#create web app
appcmd::createwebapp { 'AMTool':
  siteName     => "$nameSite",
  path         => '/AMTool',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\amtool",
  document     => 'default.aspx',
  apppool      => 'csapi_amtool',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'Common':
  siteName     => "$nameSite",
  path         => '/Common',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\Common",
  document     => 'default.aspx',
  apppool      => 'csapi_common',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'MMXPublicRestAPI':
  siteName     => "$nameSite",
  path         => '/MMXPublicRestAPI',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\MMXPublicRestAPI",
  document     => 'default.aspx',
  apppool      => 'csapi_mmxrestapi',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'MMXRestAPI':
  siteName     => "$nameSite",
  path         => '/MMXRestAPI',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\MMXRestAPI",
  document     => 'default.aspx',
  apppool      => 'csapi_mmxrestapi',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'mmxservice':
  siteName     => "$nameSite",
  path         => '/mmxservice',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\mmxservice",
  document     => 'default.aspx',
  apppool      => 'csapi_mmxservice',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'Common2':
  siteName     => "$nameSite",
  path         => '/Common2',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\Common2",
  document     => 'default.aspx',
  apppool      => 'csapi_common2',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'CPM2':
  siteName     => "$nameSite",
  path         => '/CPM2',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\CPM2",
  document     => 'default.aspx',
  apppool      => 'csapi_appname05',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'FeedbackService':
  siteName     => "$nameSite",
  path         => '/FeedbackService',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\FeedbackService",
  document     => 'default.aspx',
  apppool      => 'csapi_feedbackservice',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'ICRF':
  siteName     => "$nameSite",
  path         => '/ICRF',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\ICRF",
  document     => 'default.aspx',
  apppool      => 'csapi_icrf',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'MY':
  siteName     => "$nameSite",
  path         => '/MY',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\MY",
  document     => 'default.aspx',
  apppool      => 'csapi_my',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'appname05':
  siteName     => "$nameSite",
  path         => '/appname05',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\appname05",
  document     => 'default.aspx',
  apppool      => 'csapi_appname05',
  require      => Appcmd::Createsite["${nameSite}"]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'login',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::startapppool{ "'Start csapi_common":
  appName => 'csapi_common',
  require => Appcmd::Createapppool['csapi_common']
}

appcmd::startapppool{ "'Start csapi_amtool":
  appName => 'csapi_amtool',
  require => Appcmd::Createapppool['csapi_amtool']
}

appcmd::startapppool{ "'Start csapi_mmxrestapi":
  appName => 'csapi_mmxrestapi',
  require => Appcmd::Createapppool['csapi_mmxrestapi']
}
   
appcmd::startapppool{ "'Start csapi_mmxservice":
  appName => 'csapi_mmxservice',
  require => Appcmd::Createapppool['csapi_mmxservice']
}
   
appcmd::startapppool{ "'Start csapi_common2":
  appName => 'csapi_common2',
  require => Appcmd::Createapppool['csapi_common2']
}
   
appcmd::startapppool{ "'Start csapi_appname05":
  appName => 'csapi_appname05',
  require => Appcmd::Createapppool['csapi_appname05']
}

appcmd::startapppool{ "'Start csapi_feedbackservice":
  appName => 'csapi_feedbackservice',
  require => Appcmd::Createapppool['csapi_feedbackservice']
}

appcmd::startapppool{ "'Start csapi_icrf":
  appName => 'csapi_icrf',
  require => Appcmd::Createapppool['csapi_icrf']
}

appcmd::startapppool{ "'Start csapi_my":
  appName => 'csapi_my',
  require => Appcmd::Createapppool['csapi_my']
}   

}   
