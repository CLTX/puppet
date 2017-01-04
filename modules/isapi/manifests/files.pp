class isapi::files () {
require iiswebserver
require iiswebserver::iissetup

file {'D:\csauth.log':
  ensure => file,
  }

file {'D:\mycompany\webpub\isapi':
  ensure => appname03ory,
  }              

folderpermission::changeowner{ 'Changing the Owner on Isapi Folder':
  path       => 'D:\mycompany\webpub\isapi',
  user       => 'Administrators'
  }

folderpermission::rights{ 'Giving rights to Everyone on Isapi Folder':
  path       => 'D:\mycompany\webpub\isapi',
  user       => 'Everyone',
  rights     => 'FullControl',
  permission => 'Allow',
  }

if $machine_env == "PRD" {
  file {"D:\\mycompany\\webpub\\isapi\\csauth-x64.dll":
  mode   => 0770, 
  ensure => 'file',
  source => "puppet:///modules/isapi/isapi/csauth-x64.dll",
  owner  => Everyone,
  require => File['D:\mycompany\webpub\isapi'],
  }
  } else {
  file {"D:\\mycompany\\webpub\\isapi\\csauth-x64.dll":
  mode   => '0770', 
  ensure => 'file',
  source => "puppet:///modules/isapi/newisapi/csauth-x64.dll",
  owner  => 'Everyone',
  require => File['D:\mycompany\webpub\isapi'],
  }
  }
}  
