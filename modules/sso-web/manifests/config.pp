class sso-web::config()
{

  include appcmd
  include sslcerts

  $nameSite = 'auth.mycompany.com'
  $temp = downcase($machine_env)

  if $machine_env == "PRD" {
      $defservername= "${nameSite}"
  } else {
      $defservername = "${temp}-auth.mydomain.mycompany.com"
  }

  file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub'],
  }

  # delete Default Web Site
  appcmd::deletesite { 'DeleteSite':
    siteName => 'Default Web Site'
  }

  appcmd::createapppool { 'auth.mycompany.com':
    appName         => 'auth.mycompany.com',
    runtimeVersion  => 'v4.0',
    managedPipeline => 'Integrated',
    userName        => 'yourdomain\daewebuser',
    password        => 'yourpassword'
  }

  # create web site
  appcmd::createsite { "${nameSite}":
    siteName     => "${nameSite}",
    physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
    apppool      => "auth.mycompany.com",
    document     => 'default.aspx',
    require      => Appcmd::Createapppool['auth.mycompany.com']
  }

  sslcerts::run{"ssl-certs for ${nameSite}": 
    siteName      => "${nameSite}",
    pathSite      => '/',
    hostHeaderValue => "${defservername}",
    require       => Appcmd::Createsite["${nameSite}"]
  }

  appcmd::startapppool{ "Start auth.mycompany.com":
    appName => 'auth.mycompany.com',
    require => Appcmd::Createapppool['auth.mycompany.com']
  }
}
