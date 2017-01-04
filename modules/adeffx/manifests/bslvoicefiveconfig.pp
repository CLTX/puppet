class appname01::bslvoicefiveconfig () {

include appcmd
include sslcerts
require appname01::setup

$nameSite = 'bsl-sf.voicefive.com'
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

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\crossdomain.xml":
  ensure  => file,
  content => template("appname01/bsl/crossdomain.xml"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\w3c":
	ensure => appname03ory,
	require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"]
}

file {"D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\w3c\\p3p.xml":
  ensure  => file,
  content => template("appname01/bsl/w3c/p3p.xml"),
  require => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\w3c"]
}

#create apppool
appcmd::createapppool { 'bslapi':
  appName         => 'bslapi',
  runtimeVersion  => 'v4.0',
  managedPipeline => 'Classic',
  userName        => 'yourdomain\daewebuser',
  password        => 'yourpassword',
  require         => File["D:\\mycompany\\webpub\\${nameSite}\\wwwroot"],
}

#create web site
appcmd::createsite { "CreateSite ${nameSite}":
  siteName     => "$nameSite",
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot",
  apppool      => "bslapi",
  require      => Appcmd::Createapppool["bslapi"]
}

appcmd::createwebapp { 'homeapp':
  siteName     => "${nameSite}",
  path         => '/home',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\home",
  document     => 'default.aspx',
  apppool      => 'bslapi',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'videotestapp':
  siteName     => "${nameSite}",
  path         => '/videotest',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\videotest",
  document     => 'default.aspx',
  apppool      => 'bslapi',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::createwebapp { 'tagapp':
  siteName     => "${nameSite}",
  path         => '/tag',
  physicalPath => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\tag",
  document     => 'default.aspx',
  apppool      => 'bslapi',
  require      => Appcmd::Createsite["CreateSite ${nameSite}"]
}

appcmd::siteauthentication { "Site Authentication for ${nameSite}/home":
  siteName  => "${nameSite}/home",
  anonymous => 'true',
  basic     => 'false',
  digest    => 'false',
  windows   => 'false',
  forms     => 'false',
  aspnet    => 'false',
  require   => Appcmd::Createwebapp['homeapp']
}

appcmd::siteauthentication { "Site Authentication for ${nameSite}/videotest":
  siteName  => "${nameSite}/videotest",
  anonymous => 'true',
  basic     => 'false',
  digest    => 'false',
  windows   => 'false',
  forms     => 'false',
  aspnet    => 'false',
  require   => Appcmd::Createwebapp['videotestapp']
}

appcmd::siteauthentication { "Site Authentication for ${nameSite}/tag":
  siteName  => "${nameSite}/tag",
  anonymous => 'true',
  basic     => 'false',
  digest    => 'false',
  windows   => 'false',
  forms     => 'false',
  aspnet    => 'false',
  require   => Appcmd::Createwebapp['tagapp']
}

appcmd::customheaders { "adding Custom Header to ${nameSite}":
  site    => "${nameSite}",
  name    => "P3P",
  value   => "CP=\"\"\"NOI DSP COR NID OUR IND COM STA OTC\"\"\"",
  require => Appcmd::Createsite["CreateSite ${nameSite}"]
}

sslcerts::run{'ssl-certs': 
  siteName      => "${nameSite}",
  pathSite      => '/',
  pfxFile       => "STAR_voicefive_com.pfx",
  require       => Appcmd::Createsite["CreateSite ${nameSite}"]
}

}
