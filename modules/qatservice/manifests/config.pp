class qatservice::config()
{
include installutil
require appfabricclient

installutil::run {'InstallQATWindowsService':
	serviceName => "csqatwindowsservice",
	path => 'D:\mycompany\webpub\internalmmxapi.mycompany.com\wwwroot\QatWebApi\bin\QATWindowsService.exe',
	domain => 'yourdomain',
	username => 'daeadminuser',
	password => 'yourpassword'
}

service { 'csqatwindowsservice':
	name => 'csqatwindowsservice',
	ensure => 'running',
	enable => true
}

}
