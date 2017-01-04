class appname01::apiconfignew () {

include appcmd
include sslcerts
require appname01::setup

$nameSite = 'appname01-api.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-${nameSite}"
}

file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\bslapi":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\client-api-v3":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\restapi":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\api":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\webroot":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\webroot\\api":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\webroot"]
}

#create apppool
appcmd::createapppool { 'appname01api':
  appName         => 'appname01api',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

appcmd::createapppool { 'appname01api-v4-integrated':
  appName         => 'appname01api-v4-integrated',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

#AppPool Beta
appcmd::createapppool { 'appname01api-beta':
  appName         => 'appname01api-beta',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"],
}

appcmd::createapppool { 'appname01api-v4-integtrated-beta':
  appName         => 'appname01api-v4-integtrated-beta',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Integrated',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta"],
}

#create virtual dir Beta
appcmd::createvdir {"vdir ${nameSite}":
  sitename     => "${nameSite}",
  vdirname     => 'beta',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta",
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#create web site
appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => "appname01api",
  require      => Appcmd::Createapppool["appname01api"]
}

appcmd::createwebapp { 'vceapp':
  siteName     => "${nameSite}",
  path         => '/vce',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\restapi",
  document     => 'default.aspx',
  apppool      => 'appname01api',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'bslapp':
  siteName     => "${nameSite}",
  path         => '/bsl',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\bslapi",
  document     => 'default.aspx',
  apppool      => 'appname01api',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'coreapp':
  siteName     => "${nameSite}",
  path         => '/core',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\coreapi",
  document     => 'default.aspx',
  apppool      => 'appname01api',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'v3':
  siteName     => "${nameSite}",
  path         => '/api/v3',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\client-api-v3",
  document     => 'default.aspx',
  apppool      => 'appname01api-v4-integrated',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

#webApp Beta

appcmd::createwebapp { 'bsl-beta':
  siteName     => "${nameSite}",
  path         => '/beta/bsl',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\bslapi",
  document     => 'default.aspx',
  apppool      => 'appname01api-beta',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'vce-beta':
  siteName     => "${nameSite}",
  path         => '/beta/vce',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\restapi",
  document     => 'default.aspx',
  apppool      => 'appname01api-beta',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'v3-beta':
  siteName     => "${nameSite}",
  path         => '/beta/api/v3',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot-beta\\client-api-v3",
  document     => 'default.aspx',
  apppool      => 'appname01api-v4-integtrated-beta',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::siteauthentication { "Site Authentication for ${nameSite}/vce":
  siteName  => "${nameSite}/vce",
  anonymous => 'true',
  basic     => 'false',
  digest    => 'false',
  windows   => 'false',
  forms     => 'false',
  aspnet    => 'false',
  require   => Appcmd::Createwebapp['vceapp']
}

appcmd::siteauthentication { "Site Authentication for ${nameSite}/bsl":
  siteName  => "${nameSite}/bsl",
  anonymous => 'true',
  basic     => 'false',
  digest    => 'false',
  windows   => 'false',
  forms     => 'false',
  aspnet    => 'false',
  require   => Appcmd::Createwebapp['bslapp']
}

sslcerts::run{'ssl-certs': 
  siteName      => "${nameSite}",
  pathSite      => '/',
  require       => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::enablesslwebapp{'vce': 
  site    => "${nameSite}",
  path    => '/vce',
  require => Appcmd::Createwebapp['vceapp']
}

appcmd::enablesslwebapp{'bsl': 
  site    => "${nameSite}",
  path    => '/bsl',
  require => Appcmd::Createwebapp['bslapp']
}

exec { "Updating ExtensionlessUrlHandler-ISAPI-4.0_64bit to ${nameSite}" :
  command => "\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\update-ExtensionlessHandler64.bat ${nameSite}",
  unless  => "cmd.exe /c \"appcmd.exe list config \"${nameSite}/\" /section:handlers | find \"ExtensionlessUrlHandler-ISAPI-4.0_64bit\" | find \"path=\"\"*.\"\"\" | find \"scriptProcessor=\"\"C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\aspnet_isapi.dll\"\"\" | find \"verb=\"\"*\"\"\"\"",
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::httpcompression { 'Enabling httpCompression':
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}
appcmd::serverruntime { 'Set serverRunTime':
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}
