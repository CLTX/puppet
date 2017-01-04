class qaapi::setup () {

include appcmd
include folderpermission

file {"D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api":
 ensure  => appname03ory,
 require => File["D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot"],
 }

folderpermission::changeowner{ "Changing the Owner D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api",
 user => 'Administrators',
 require => Folderpermission::Rights["Giving rights to Administrators to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot"],
 }

folderpermission::rights{ "Giving rights to Everyone to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api",
 user => 'Everyone',
 rights => 'FullControl',
 permission => 'Allow',
 require => Folderpermission::Changeowner["Changing the Owner D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api"],
 }

folderpermission::rights{ "Giving rights to Administrators to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api":
 path => "D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api",
 user => 'Administrators',
 rights => 'FullControl',
 permission => 'Allow',
 require => Folderpermission::Rights["Giving rights to Everyone to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api"],
 }

 # create apppool qa_api
appcmd::createapppool { 'qa_api':
 appName => 'qa_api',
 runtimeVersion  => 'v4.0',
 managedPipeline => 'Classic',
 userName => 'yourdomain\daewebuser',
 password => 'yourpassword',
 require => Folderpermission::Rights["Giving rights to Administrators to D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api"],
 }

# create web app qa_api  
exec { "appcmdcreatewebapp qa_api":
 command => "appcmd.exe add app /site.name:\"Default Web Site\" /path:\"/qa_api\" /physicalPath:\"D:\\mycompany\\webpub\\appname052.securestudies.com\\wwwroot\\qa_api\"",
 unless  => "cmd.exe /c \"appcmd.exe list app | findstr.exe \"qa_api\"\"",
 require => Appcmd::Createapppool['qa_api'],
 }

# set anonymous user
exec { "appcmdsetanonymoususer qa_api":
 command => "appcmd.exe set config /section:anonymousAuthentication /userName:yourdomain\\daewebuser /password:yourpassword",
 unless  => "cmd.exe /c \"appcmd.exe list CONFIG | find.exe \"anonymousAuthentication\" | find.exe \"yourdomain\\daewebuser\" |find.exe \"yourpassword\"\"",
 require => Exec["appcmdcreatewebapp qa_api"],
 }

# set windows auth
exec { "appcmdWindowsAuth qa_api":
 command => "appcmd.exe set config /section:windowsAuthentication /enabled:true",
 unless  => "cmd.exe /c \"appcmd.exe list CONFIG | find.exe \"windowsAuthentication enabled=\"\"true\"\"\"\"",
 require => Exec["appcmdcreatewebapp qa_api"],
 }

# assign app pool to web app
exec { "appcmdassignapppool qa_api":
 command => "appcmd.exe set app /app.name:\"Default Web Site/qa_api\" /applicationPool:\"qa_api\"",
 unless  => "cmd.exe /c \"appcmd.exe list app |find.exe \"qa_api\" | find.exe \"applicationPool:qa_api\"\"",
 require => Exec["appcmdcreatewebapp qa_api"],
 }

exec { "set user for qa_api":
  command => "appcmd.exe set site \"Default Web Site\" -virtualappname03oryDefaults.userName:\"yourdomain\\daewebuser\" -virtualappname03oryDefaults.password:yourpassword",
  require  => Exec["appcmdassignapppool qa_api"],
  }
}
