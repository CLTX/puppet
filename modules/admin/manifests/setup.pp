class admin::setup () {
include registry
include folderpermission
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

$nameSite = 'admin.mycompany.com'

file {'D:\mycompany\webpub\conf':
  ensure  => appname03ory,
  group   => 'Administrators',
  require => File['D:\\mycompany\\webpub']
}

file {'D:\mycompany\webpub\conf\css.conf':
  ensure  => present,
  content => template("admin/conf/css.conf"),
  require => File['D:\mycompany\webpub\conf']
}

file {'D:\mycompany\css-sessions':
  ensure  => appname03ory,
  group   => 'Administrators',
  require => File['D:\\mycompany']
}

file {'D:\mycompany\appshares':
  ensure  => appname03ory,
  group   => 'Administrators',
  require => File['D:\\mycompany']
}

sharefolder::create{'css-sessions':
  sharename => 'css-sessions',
  path => 'D:\mycompany\css-sessions',
  user => 'yourdomain\daewebuser',
  rights => 'Full',
  require => Folderpermission::Rights['css-sessions']
}

folderpermission::rights{'css-sessions':
  path       => 'D:\mycompany\css-sessions',
  user       => "$hostname\Administrators",
  rights     => 'FullControl',
  permission => 'Allow',
  require => File['D:\mycompany\css-sessions']
}

sharefolder::create{'appshares':
  sharename => 'appshares',
  path => 'D:\mycompany\appshares',
  user => 'yourdomain\daewebuser',
  rights => 'Full',
  require => Folderpermission::Rights['appshares']
}

folderpermission::rights{'appshares':
  path       => 'D:\mycompany\appshares',
  user       => "$hostname\Administrators",
  rights     => 'FullControl',
  permission => 'Allow',
  require => File['D:\mycompany\appshares']
}

}
