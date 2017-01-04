class ssoapi::config()
{
  include appcmd

  $nameSite = 'auth-api.mydomain.mycompany.com'
  $temp = downcase($machine_env)

  file {"D:\\mycompany\\webpub\\${nameSite}":
	ensure => appname03ory,
	require => File['D:\\mycompany\\webpub'],
  }

  appcmd::createapppool { 'login':
    appName         => 'login',
    runtimeVersion  => 'v4.0',
    managedPipeline => 'Integrated',
    userName        => 'yourdomain\daewebuser',
    password        => 'yourpassword'
  }

  # create web site
  appcmd::createsite { "${nameSite}":
    siteName     => "${nameSite}",
    physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
    apppool      => "login",
    document     => 'default.aspx',
    require      => Appcmd::Createapppool['login']
  }

  appcmd::startapppool{ "Start login":
    appName => 'login',
    require => Appcmd::Createapppool['login']
  }
}