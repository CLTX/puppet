class labs::config () {

include appcmd
include myplatform
include sslcerts

$nameSite = 'labs.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
   $defservername= "${nameSite}"
} 
else {
   $defservername = "${temp}-labs.mydomain.mycompany.com"
   }

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
   siteName => 'Default Web Site'
   }

appcmd::createapppool { 'labs.mycompany.com':
   appName         => 'labs.mycompany.com',
   runtimeVersion  => 'v4.0',
   managedPipeline => 'Classic',
   userName        => 'yourdomain\daewebuser',
   password        => 'yourpassword',
   require         => Appcmd::Deletesite['DeleteSite']
   }


appcmd::createapppool { 'labs.mycompany.com-imtservices':
   appName         => 'labs.mycompany.com-imtservices',
   runtimeVersion  => 'v4.0',
   managedPipeline => 'Classic',
   userName        => 'yourdomain\daewebuser',
   password        => 'yourpassword',
   require         => Appcmd::Createapppool['labs.mycompany.com']
   }

appcmd::createapppool { 'labs.mycompany.com-mob':
   appName         => 'labs.mycompany.com-mob',
   runtimeVersion  => 'v4.0',
   managedPipeline => 'Classic',
   userName        => 'yourdomain\daewebuser',
   password        => 'yourpassword',
   require         => Appcmd::Createapppool['labs.mycompany.com']
   }

# create web site
appcmd::createsite { "${nameSite}":
   siteName     => "$nameSite",
   physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
   apppool      => "labs.mycompany.com",
   require      => Appcmd::Createapppool['labs.mycompany.com']
   }

appcmd::isapifilter { 'IsapiFilterCsAuth':
   site         => "${nameSite}",
   modName         => 'csauth',
   path         => 'D:\mycompany\webpub\isapi\csauth-x64.dll',
   preCondition => 'bitness64',
   require      => Appcmd::Createsite["${nameSite}"]
   }

#create web app
appcmd::createwebapp { 'cgi-bin':
   siteName     => "$nameSite",
   path         => '/cgi-bin',
   physicalPath => "D:\\mycompany\\web-applications\cgi-bin",
   document     => 'default.aspx',
   apppool      => 'labs.mycompany.com',
   require      => Appcmd::Createsite["${nameSite}"]
   }

appcmd::createwebapp { 'login':
   siteName     => "$nameSite",
   path         => '/login',
   physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\login",
   document     => 'default.aspx',
   apppool      => 'labs.mycompany.com',
   require      => Appcmd::Createsite["${nameSite}"]
   }

appcmd::createwebapp { 'logout':
   siteName     => "$nameSite",
   path         => '/logout',
   physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\logout",
   document     => 'default.aspx',
   apppool      => 'labs.mycompany.com',
   require      => Appcmd::Createsite["${nameSite}"]
   }

appcmd::createwebapp { 'ImtServices':
   siteName     => "$nameSite",
   path         => '/ImtServices',
   physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\ImtServices",
   document     => 'default.aspx',
   apppool      => 'labs.mycompany.com-imtservices',
   require      => Appcmd::Createsite["${nameSite}"]
   }

appcmd::createwebapp { 'mob':
   siteName     => "$nameSite",
   path         => '/mob',
   physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\mob",
   document     => 'default.aspx',
   apppool      => 'labs.mycompany.com-mob',
   require      => Appcmd::Createsite["${nameSite}"]
   }

myplatform::install { "InstallMyPlatform for ${nameSite}":
   siteName     => "${nameSite}",
   appPool      => 'login',
   environment  => "${machine_env}",
   require      => Appcmd::Createsite["${nameSite}"]
   }

appcmd::startapppool{ "'Start labs.mycompany.com":
   appName => 'labs.mycompany.com',
   require => Appcmd::Createapppool['labs.mycompany.com']
   }

appcmd::startapppool{ "'Start labs.mycompany.com-imtservices":
   appName => 'labs.mycompany.com-imtservices',
   require => Appcmd::Createapppool['labs.mycompany.com-imtservices']
   }

appcmd::startapppool{ "'Start labs.mycompany.com-mob":
   appName => 'labs.mycompany.com-mob',
   require => Appcmd::Createapppool['labs.mycompany.com-mob']
   }
         
sslcerts::run{'ssl-certs':
   siteName        => "${nameSite}",
   pathSite        => '/',
   hostHeaderValue => "${defservername}",
   require         => Appcmd::Createsite["${nameSite}"]
   }
}   
