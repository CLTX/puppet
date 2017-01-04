class appname03::config () {

include appcmd
include myplatform
include sslcerts
require appname03::setup

$nameSite = 'appname03.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-appname03.mydomain.mycompany.com"
}

# Applying change only to DSW01
if "pvusaSDW01" in $hostname or "pvusaPDW01" in $hostname or "pvusaPDW02" in $hostname {
  $apppoolmanagedpipeline = "Integrated"
} else {
  $apppoolmanagedpipeline = "Classic"
}  


# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

appcmd::createapppool { 'Create AppPool appname03':
  appName         => 'appname03',
  runtimeVersion  => 'v4.0',
  managedPipeline => "${apppoolmanagedpipeline}",
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

# create web site
appcmd::createsite { 'CreateSite':
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "appname03",
  require      => Appcmd::Createapppool['Create AppPool appname03']
}

######## install csauth, remember change it wherever csauth-x64.dll will be copied this case using D:\mycompany\inetpub\can.tst\isapi\csauth-x64.dll
appcmd::isapifilter { 'IsapiFilterCsAuth':
  site         => "$nameSite",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite['CreateSite']
}

#create web app
appcmd::createwebapp { 'Ext':
  siteName     => "$nameSite",
  path         => '/ext',
  physicalPath => 'D:\mycompany\webpub\javascript\wwwroot\ext\3_2_1',
  document     => 'default.aspx',
  apppool      => 'appname03',
  require      => Appcmd::Createsite['CreateSite']
}

appcmd::createwebapp { 'Clients':
  siteName     => "$nameSite",
  path         => '/Clients',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\Clients",
  document     => 'default.aspx',
  apppool      => 'appname03',
  require      => Appcmd::Createsite['CreateSite']
}

appcmd::createwebapp { 'ClientsCssExt':
  siteName     => "$nameSite",
  path         => '/Clients/css/ext',
  physicalPath => 'D:\mycompany\webpub\appname03.mycompany.com\wwwroot\Clients\js\lib\ext',
  document     => 'default.aspx',
  apppool      => 'appname03',
  require      => [Appcmd::Createsite['CreateSite'],Appcmd::Createwebapp['Clients']]
}

appcmd::createwebapp { 'PDF-gen':
  siteName     => "$nameSite",
  path         => '/pdf-gen',
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot\\Clients",
  document     => 'default.aspx',
  apppool      => 'appname03',
  require      => Appcmd::Createsite['CreateSite']
}

appcmd::createwebapp { 'PDF-genCssExt':
  siteName     => "$nameSite",
  path         => '/pdf-gen/css/ext',
  physicalPath => 'D:\mycompany\webpub\appname03.mycompany.com\wwwroot\Clients\js\lib\ext',
  document     => 'default.aspx',
  apppool      => 'appname03',
  require      => [Appcmd::Createsite['CreateSite'],Appcmd::Createwebapp['PDF-gen']]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'appname03',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite['CreateSite']
}

sslcerts::run{'ssl-certs': 
  siteName        => "${nameSite}",
  pathSite        => '/Clients/Settings.aspx',
  hostHeaderValue => "${defservername}",
  require         => Appcmd::Createwebapp['Clients']
}

appcmd::startapppool{ 'Start AppPool':
  appName => 'appname03',
  require => Appcmd::Createapppool['Create AppPool appname03']
}

}
