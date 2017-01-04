class devops::setup () {

   require iiswebserver
   require iiswebserver::iissetup

   $nameSite = 'devops.mydomain.mycompany.com'

   file {"D:\\mycompany\\webpub\\${nameSite}":
      ensure => appname03ory,
      require => File['D:\\mycompany\\webpub'],
   }

   file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot":
      ensure => appname03ory,
      require => File["D:\\mycompany\\webpub\\${nameSite}"],
   }
   
   file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\Reports":
      ensure => appname03ory,
      require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
   }

   file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\Reports\\inv":
      ensure => appname03ory,
      require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\Reports"],
   }

}
