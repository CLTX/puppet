class static::config () {

include appcmd
include sslcerts

$nameSite = 'static.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
   $defservername= "${nameSite}"
} 
else {
   $defservername = "${temp}-static.mydomain.mycompany.com"
   }

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
   siteName => 'Default Web Site'
   }

# create app-pool
appcmd::createapppool { 'static.mycompany.com':
   appName         => 'static.mycompany.com',
   runtimeVersion  => 'v4.0',
   managedPipeline => 'Integrated',
   userName        => 'yourdomain\daewebuser',
   password        => 'yourpassword',
   require         => Appcmd::Deletesite['DeleteSite']
   }

# create web site 
appcmd::createsite { "${nameSite}":
   siteName     => "$nameSite",
   physicalPath => "D:\\mycompany\\webpub\\$nameSite\\wwwroot",
   apppool      => "static.mycompany.com",
   bindings     => "http/*:80:${defservername}",
   require      => Appcmd::Createapppool['static.mycompany.com']
   }

#start app-pool
appcmd::startapppool{ "Start static.mycompany.com":
   appName => 'static.mycompany.com',
   require => Appcmd::Createapppool['static.mycompany.com']
   }

sslcerts::run{"ssl-certs for ${nameSite}":
  siteName        => "${nameSite}",
  pathSite        => '/',
  hostHeaderValue => "${defservername}",
  require         => Appcmd::Startapppool["Start static.mycompany.com"]
  }
} 