class serverdb::config () {

include appcmd
include sslcerts
require serverdb::setup

$nameSite = 'serverdb.mydomain.mycompany.com'
$temp = downcase($machine_env)
if $machine_env == "PRD" {
  $defservername= "${nameSite}"
} else {
  $defservername = "${temp}-${nameSite}"
}

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
}

appcmd::createapppool { 'serverdb':
  appName         => 'serverdb',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword'
}


# create web site
appcmd::createsite { 'CreateSite':
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => "serverdb",
  require      => Appcmd::Createapppool['serverdb']
}

}
