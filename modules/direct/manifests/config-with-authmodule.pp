class appname03::config-with-authmodule () {

include appcmd
include myplatform
include sslcerts
require appname03::setup
include authmodule

$nameSite = 'appname03.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-appname03.mydomain.mycompany.com"
}

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
  ensure => appname03ory,
  require => File['D:\\mycompany\\webpub'],
}


file { "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\web.config":
 ensure => file,
 content => template("appname03/web.erb"),
 replace => "no",
 require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

appcmd::createapppool { 'Create AppPool appname03':
  appName         => 'appname03',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
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

exec { "Removing ISAPI csauth as ISAPI Filter for ${nameSite}":
  command => "cmd.exe /C \"appcmd.exe set config \"${nameSite}/\" /section:isapiFilters  /-[name=\'csauth\'] /commit:apphost\"",
  onlyif  => "cmd.exe /C \"appcmd.exe list config \"${nameSite}/\" /section:isapiFilters | find \"csauth\"\"",
  require => Appcmd::Createsite['CreateSite']
}

if $authmoduleversion != "noAuthModule" {
  appcmd::addisapimodule { "adding AuthModule to ${nameSite}":
    site         => "${nameSite}",
    appname      => "/Clients",
    modName      => "mycompanyAuthModule",
    type         => "mycompany.SSO.AuthHTTPModule.AuthModule, mycompany.SSO.AuthHTTPModule, Version=$authmoduleversion, Culture=neutral, PublicKeyToken=bcd2b958bd340364",
    preCondition => "managedHandler",
    require      => [Appcmd::Createsite['CreateSite'],Package["mycompany SingleSignOn - Release"]]
  }
}

file {"D:\mycompany\webpub\${nameSite}\conf":
ensure => absent,
recurse => true,
force => true,
}

file_line { "css.conf":
ensure => absent,
path => 'D:/mycompany/webpub/conf/css.conf',
line => "Domaincfg D:\mycompany\webpub\$nameSite\conf\css.conf"
}

appcmd::startapppool{ 'Start AppPool':
  appName => 'appname03',
  require => Appcmd::Createapppool['Create AppPool appname03']
}

}
