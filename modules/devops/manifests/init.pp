class devops () {
  
  include appcmd
  require iiswebserver::iissetup
  require devops::setup

  $nameSite = 'devops.mydomain.mycompany.com'
  
  appcmd::createapppool { 'Create AppPool Devops':
     appName         => 'devops',
     runtimeVersion  => 'v4.0',
     managedPipeline => 'Classic',
     userName        => 'yourdomain\daewebuser',
     password        => 'yourpassword'
  }

  #copy file
  devops::copyfile {'Call copy file':
     site    => "${nameSite}",
     require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\Reports\\inv"],
  }
  
  appcmd::createsite{ 'CreateSite Devops':
     siteName     => "${nameSite}",
     physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
     apppool      => "devops",
     require      => [Appcmd::Createapppool['Create AppPool Devops'],File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]]
  }

  appcmd::startapppool{ "Start AppPool ${nameSite}":
     appName => 'devops',
     require => Appcmd::Createapppool['Create AppPool Devops'],
  }
}
