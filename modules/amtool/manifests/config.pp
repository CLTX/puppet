class amtool::config () {

include appcmd
include myplatform

$nameSite = 'amtool.mydomain.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-amtool.mydomain.mycompany.com"
}

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

appcmd::createapppool { 'amtool':
  appName         => 'amtool',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}

# create web site
appcmd::createsite { "${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "amtool",
  require      => Appcmd::Createapppool['amtool']
}

appcmd::isapifilter { 'IsapiFilterCsAuth':
  site         => "${nameSite}",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["${nameSite}"]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'login',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::startapppool{ "'Start amtool":
  appName => 'amtool',
  require => Appcmd::Createapppool['amtool']
}

}