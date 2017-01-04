class login::config () {

include appcmd
include myplatform
include login::setup

$nameSite = 'auth.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-login.mydomain.mycompany.com"
}

  file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub'],
  }
  
file {"D:\\mycompany\\webpub\\${nameSite}\\conf":
  ensure  => appname03ory,
  require => File["D:\\mycompany\\webpub\\${nameSite}"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf":
  ensure  => file,
  content => template("login/conf/css.erb"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\conf\\aci.txt":
  ensure  => file,
  content => template("login/conf/aci.txt"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\conf"]
}  

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

appcmd::createapppool { 'login':
  appName         => 'login',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}


# create web site
appcmd::createsite { "${nameSite}":
  siteName     => "${nameSite}",
  physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
  apppool      => "login",
  document     => 'default.pli',
  require      => Appcmd::Createapppool['login']
}

appcmd::isapifilter { 'IsapiFilterCsAuth':
  site         => "${nameSite}",
  modName         => 'csauth',
  path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
  preCondition => 'bitness64',
  require      => Appcmd::Createsite["${nameSite}"]
}

#create web app

appcmd::createwebapp { 'login':
  siteName     => "${nameSite}",
  path         => '/login',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => 'login',
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::createwebapp { 'logout':
  siteName     => "${nameSite}",
  path         => '/logout',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\logout",
  apppool      => 'login',
  require      => Appcmd::Createsite["${nameSite}"]
}

myplatform::install { "InstallMyPlatform for ${nameSite}":
  siteName     => "${nameSite}",
  appPool      => 'login',
  environment  => "${machine_env}",
  require      => Appcmd::Createsite["${nameSite}"]
}

appcmd::handlermappings {'Perl-pli':
  name            => 'Perl-pli',
  paTh            => '*.pli',
  verb            => 'GET,HEAD,POST',
  modules         => 'CgiModule',
  scriptProcessor => "C:\\Perl\\bin\\perl.exe \"\"\"%s\"\"\" %s",
  require         => Appcmd::Createsite["${nameSite}"]
} 

appcmd::isapicgirestrictionperl { 'true':
  require       => Appcmd::Createsite["${nameSite}"]
}

appcmd::impersonatecgi { 'False':
  require => Appcmd::Createsite["${nameSite}"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\logout\\web.config":
  ensure  => file,
  content => template("login/wwwroot/logout/web.erb"),
  require => Appcmd::Createwebapp['logout']
}

sslcerts::run{"ssl-certs for ${nameSite}": 
  siteName      => "${nameSite}",
  pathSite      => '/',
  hostHeaderValue => "${defservername}",
  require       => Appcmd::Createsite["${nameSite}"]
}

exec { "Adding HTTP_CSCFGFILE system Variable":
  command => "cmd.exe /c \"setx /M  HTTP_CSCFGFILE \"D:\\mycompany\\webpub\\${nameSite}\\conf\\css.conf\"\" ",
  unless => "cmd.exe /c \"set | findstr.exe /i \"HTTP_CSCFGFILE\""
}

appcmd::startapppool{ "Start login":
  appName => 'login',
  require => Appcmd::Createapppool['login']
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\web.config":
  ensure  => absent,
  require => myplatform::install["InstallMyPlatform for ${nameSite}"]
}  

}
