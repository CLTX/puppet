class appname04::appname04config () {

include appcmd
include installutil
include myplatform
include servicerecoveryoptions
require appname04::setup


if $machine_env == "PRD" {
  $cmDataPath = '\\yourdomain.mycompany.com\pdfs\Shares\team01\appname04\content_management'
  $dundasPath = '\\yourdomain.mycompany.com\pdfs\Shares\team01\appname04\dundas-images'
} 
elsif $machine_env == "INT" {
  $cmDataPath = '\\yourdomain.mycompany.com\DDFS\Shares\team01\appname04\content_management_data' 
  $dundasPath = '\\yourdomain.mycompany.com\DDFS\Shares\team01\appname04\dundas-images' 
}
else
{
  $cmDataPath = '\\yourdomain.mycompany.com\TDFS\Shares\team01\appname04\content_management_data' 
  $dundasPath = '\\yourdomain.mycompany.com\TDFS\Shares\team01\appname04\dundas-images' 
}

$nameSite = 'appname04.mycompany.com'

$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} elsif $machine_env == "STAG" {
  $defservername = "stage-mmx.mydomain.mycompany.com"
} else {
  $defservername = "${temp}-mmx.mydomain.mycompany.com"
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf":
  ensure  => appname03ory,
  owner   => 'Everyone',
  group   => 'Administrators',
  require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"],
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
  ensure  => file,
  owner   => 'Everyone',
  group   => 'Administrators',
  content => template("appname04/conf/appname04/css.erb"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt":
  ensure  => file,
  owner   => 'Everyone',
  group   => 'Administrators',
  force   => true,
  content => template("appname04/conf/appname04/aci.erb"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"]
}

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}


#create apppool
appcmd::createapppool { 'appname04':
  appName         => 'appname04',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

appcmd::createapppool { 'appname04web':
  appName         => 'appname04web',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  idletimeout     => "00:00:00"
}

#create web site
appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "appname04",
  bindings     => "http/*:80:${defservername}",
  require      => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

appcmd::siteauthentication { "Site Authentication for ${nameSite}":
  siteName  => "${nameSite}",
  anonymous => 'true',
  basic     => 'false',
  digest    => 'false',
  windows   => 'false',
  forms     => 'false',
  aspnet    => 'false',
  require   => Appcmd::Createsite["CreateSite ${nameSite}"],
}

appcmd::isapifilter { "IsapiFilterCsAuth for ${nameSite}":
  site         => "$nameSite",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#create web app
appcmd::createwebapp { 'App':
  siteName     => "${nameSite}",
  path         => '/app',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app",
  document     => 'default.aspx',
  apppool      => 'appname04',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'web':
  siteName     => "${nameSite}",
  path         => '/web',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\web",
  document     => 'default.aspx',
  apppool      => 'appname04web',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'print':
  siteName     => "${nameSite}",
  path         => '/print',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app",
  document     => 'default.aspx',
  apppool      => 'appname04',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'public':
  siteName     => "${nameSite}",
  path         => '/public',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\public",
  document     => 'default.aspx',
  apppool      => 'appname04',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'tools':
  siteName     => "${nameSite}",
  path         => '/tools',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\tools",
  document     => 'default.aspx',
  apppool      => 'appname04',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}
#Create Virtual Dirs

appcmd::createvdir { "akamai for ${nameSite}":
  sitename     => "${nameSite}",
  vdirname     => 'akamai',
  appName      => '',
  physicalPath => '\\yourdomain.mycompany.com\installers\Shared-Apps\akamai',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createvdir { 'App-cmdata':
  sitename     => "${nameSite}",
  vdirname     => 'cmdata',
  appName      => 'app',
  physicalPath => "${cmDataPath}",
  require      => Appcmd::Createwebapp["App"]
}

appcmd::createvdir { 'App-dundas':
  sitename     => "${nameSite}",
  vdirname     => 'dundas',
  appName      => 'app',
  physicalPath => "${dundasPath}",
  require      => Appcmd::Createwebapp["App"]
}

appcmd::createvdir { 'App-help-guide-images':
  sitename     => "${nameSite}",
  vdirname     => "help-guide-images",
  appName      => "app",
  physicalPath => "\\\\yourdomain.mycompany.com\\pdfs\\Shares\\team01\\appname04\\help-guide-images",
  require      => Appcmd::Createwebapp["App"]
}

appcmd::createvdir { 'App-appname04-downloadable-content':
  sitename     => "${nameSite}",
  vdirname     => 'appname04-downloadable-content',
  appName      => "app",
  physicalPath => "\\\\yourdomain.mycompany.com\\pdfs\\Shares\\team01\\appname04\\appname04-downloadable-content",
  require      => Appcmd::Createwebapp["App"]
}

appcmd::createvdir { 'Public-ajax':
  sitename     => "${nameSite}",
  vdirname     => 'ajax',
  appName      => 'public',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app\\ajax",
  require      => Appcmd::Createwebapp['public']
}

appcmd::createvdir { "Errors vdir for ${nameSite}": 
  sitename     => "${nameSite}",
  vdirname     => 'errors',
  appName      => '',
  physicalPath => "\\\\yourdomain.mycompany.com\\pdfs\\Shares\\team01\\appname04\\errorpages",
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#appcmd::errorcodereappname03 { "404 Reappname03 for ${nameSite}":
#  site         => "${nameSite}",
#  reappname03Path => '/errors/beppo404.asp',
#  errorCode    => '404',
#  require      => Appcmd::Createvdir["Errors vdir for ${nameSite}"]
#}

appcmd::createvdir { 'Public-css':
  sitename     => "${nameSite}",
  vdirname     => 'css',
  appName      => 'public',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app\\css",
  require      => Appcmd::Createwebapp['public']
}

appcmd::createvdir { 'Public-scripts':
  sitename     => "${nameSite}",
  vdirname     => 'scripts',
  appName      => 'public',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app\\scripts",
  require      => Appcmd::Createwebapp['public']
}

appcmd::createvdir { 'cmimages':
  vdirname     => 'cmimages',
  sitename     => "${nameSite}",
  physicalPath => "\\\\yourdomain.mycompany.com\\pdfs\\Shares\\team01\\appname04\\cmimages",
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createvdir { 'creative':
  vdirname     => 'creative',
  sitename     => "${nameSite}",
  physicalPath => "\\\\pvusapeds02\\creative",
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createvdir { 'userguides':
  vdirname     => 'userguides',
  sitename     => "${nameSite}",
  physicalPath => "\\\\yourdomain.mycompany.com\\pdfs\\Shares\\team01\\appname04\\appname04-downloadable-content\\userguides",
  require      => [Appcmd::Createsite["CreateSite ${nameSite}"],Appcmd::Createsite["CreateSite ${nameSite}"]]
}

#Apply Root Reappname03 Rule
appcmd::rootreappname03 {"RootReappname03 for ${nameSite}":
  siteName     => "${nameSite}",
  reappname03Path => '/app/',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createvdir { 'mydomainlink':
  vdirname     => 'mydomainlink',
  sitename     => "${nameSite}",
  physicalPath => "\\\\yourdomain.mycompany.com\\pdfs\\Shares\\team01\\appname04\\mydomain-link",
  appName      => 'public',
  require      => Appcmd::Createwebapp['public']
}

#creating Reappname03s 
appcmd::createrdir { 'mmx':
  url1 => "${nameSite}/mmx",
  url2 => "${nameSite}/app",
}

appcmd::createrdir { 'beta':
  url1 => "${nameSite}/beta",
  url2 => "${nameSite}/app",
}

appcmd::createrdir { 'legacy':
  url1 => "${nameSite}/legacy",
  url2 => "${nameSite}/app",
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'appname04',
  environment  => "${machine_env}"
}

appcmd::ipaddressrestriction{ 'ipaddress restriction':
 site      => "${nameSite}",
 path      => "print",
 ipaddress => "$getip",
 require   => [Appcmd::Createwebapp["print"],Appcmd::Createsite["CreateSite ${nameSite}"]]
}

sslcerts::run{"ssl-certs for ${nameSite}": 
  siteName        => "${nameSite}",
  pathSite        => '/',
  hostHeaderValue => "",
  require         => Appcmd::Createwebapp["App"]
}

installutil::run {'Installing BeppoService':
	serviceName => "csbepposervice",
	path => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app\\bin\\BeppoService.exe",
	domain => "yourdomain",
	username => "daeadminuser",
	password => "yourpassword",
	pathMustExist => "false"
}

installutil::run {'Installing BatchManagerService':
	serviceName => "csbatchservice",
	path => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\app\\bin\\BatchManagerService.exe",
	domain => "yourdomain",
	username => "daeadminuser",
	password => "yourpassword",
	pathMustExist => "false"
}

servicerecoveryoptions::failure{ 'csbepposervice':
  service => "csbepposervice",
  action1 => "restart",
  delay1   => "60000",
  require => Installutil::Run['Installing BeppoService']
}

servicerecoveryoptions::failure{ 'csbatchservice':
  service => "csbatchservice",
  action1 => "restart",
  delay1   => "60000",
  require => Installutil::Run['Installing BatchManagerService']
}

}
