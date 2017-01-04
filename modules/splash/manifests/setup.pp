class splash::setup () {

include appcmd
include folderpermission

file {"D:\\mycompany\\webpub\\appname052.securestudies.com":
 ensure => appname03ory,
}

file {"D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot":
 ensure  => appname03ory,
 require => File["D:\\mycompany\\webpub\\appname052.securestudies.com"],
  }

file {"D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash":
 ensure  => appname03ory,
 require => File["D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot"],
 }

folderpermission::changeowner{ "Changing the Owner D:\\mycompany\\webpub\\appname052.securestudies.com":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com",
 user => 'Administrators',
}

folderpermission::rights{ "Giving rights to Everyone to D:\\mycompany\\webpub\\appname052.securestudies.com":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com",
 user => 'Everyone',
 rights => 'FullControl',
 permission => 'Allow',
 require => Folderpermission::Changeowner["Changing the Owner D:\\mycompany\\webpub\\appname052.securestudies.com"],
 }

folderpermission::rights{ "Giving rights to Administrators to D:\\mycompany\\webpub\\appname052.securestudies.com":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com",
 user => 'Administrators',
 rights => 'FullControl',
 permission => 'Allow',
 require => Folderpermission::Rights["Giving rights to Everyone to D:\\mycompany\\webpub\\appname052.securestudies.com"],
 }

folderpermission::changeowner{ "Changing the Owner D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot",
 user => 'Administrators',
 require => Folderpermission::Rights["Giving rights to Administrators to D:\\mycompany\\webpub\\appname052.securestudies.com"],
 }

folderpermission::rights{ "Giving rights to Everyone to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot",
 user => 'Everyone',
 rights => 'FullControl',
 permission => 'Allow',
 require => Folderpermission::Changeowner["Changing the Owner D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot"],
 }

folderpermission::rights{ "Giving rights to Administrators to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot",
 user => 'Administrators',
 rights => 'FullControl',
 permission => 'Allow',
 require => Folderpermission::Rights["Giving rights to Everyone to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot"],
 }

folderpermission::changeowner{ "Changing the Owner D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash",
 user => 'Administrators',
 require => Folderpermission::Rights["Giving rights to Administrators to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot"],
 }

folderpermission::rights{ "Giving rights to Everyone to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash",
 user => 'Everyone',
 rights => 'FullControl',
 permission => 'Allow',
 require => Folderpermission::Changeowner["Changing the Owner D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash"],
 }

folderpermission::rights{ "Giving rights to Administrators to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash",
 user => 'Administrators',
 rights => 'FullControl',
 permission => 'Allow',
 require => Folderpermission::Rights["Giving rights to Everyone to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash"],
 }

 # create apppool splash_4
 appcmd::createapppool { 'splash_4':
 appName => 'splash_4',
 runtimeVersion  => 'v4.0',
 managedPipeline => 'Classic',
 userName => 'yourdomain\daewebuser',
 password => 'yourpassword',
 require => Folderpermission::Rights["Giving rights to Administrators to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash"],
 }

# create web app splash  
exec { "appcmdcreatewebapp splash":
 command => "appcmd.exe add app /site.name:\"Default Web Site\" /path:\"/splash\" /physicalPath:\"D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\splash\"",
 unless  => "cmd.exe /c \"appcmd.exe list app | findstr.exe \"splash\"\"",
 require => Appcmd::Createapppool['splash_4'],
 }

# set anonymous user
exec { "appcmdsetanonymoususer splash":
 command => "appcmd.exe set config /section:anonymousAuthentication /userName:yourdomain\\daewebuser /password:yourpassword",
 unless  => "cmd.exe /c \"appcmd.exe list CONFIG | find.exe \"anonymousAuthentication\" | find.exe \"yourdomain\\daewebuser\" |find.exe \"yourpassword\"\"",
 require => Exec["appcmdcreatewebapp splash"],
 }

# set windows auth
exec { "appcmdWindowsAuth splash":
 command => "appcmd.exe set config /section:windowsAuthentication /enabled:true",
 unless  => "cmd.exe /c \"appcmd.exe list CONFIG | find.exe \"windowsAuthentication enabled=\"\"true\"\"\"\"",
 require => Exec["appcmdcreatewebapp splash"],
 }

# assign app pool to web app
exec { "appcmdassignapppool splash":
 command => "appcmd.exe set app /app.name:\"Default Web Site/splash\" /applicationPool:\"splash_4\"",
 unless  => "cmd.exe /c \"appcmd.exe list app |find.exe \"splash\" | find.exe \"applicationPool:splash_4\"\"",
 require => Exec["appcmdcreatewebapp splash"],
 }

exec { "set user for splash":
  command => "appcmd.exe set site \"Default Web Site\" -virtualappname03oryDefaults.userName:\"yourdomain\\daewebuser\" -virtualappname03oryDefaults.password:yourpassword",
  require  => Exec["appcmdassignapppool splash"],
  }

}
