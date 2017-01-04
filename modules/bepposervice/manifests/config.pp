class bepposervice::config()
{
include robocopy
include installutil
include sharefolder
require appfabricclient

robocopy::run {'Copyappname04Folder' :
	source => '\\ppusadcs03\D$\mycompany_shares\unreplicated_shares\beta',
	destination => 'D:\mycompany\webpub\bepposervice\\',
	skipifexists => 'D:\mycompany\webpub\bepposervice\\'
}

installutil::run {'InstallBeppoService':
	serviceName => "csbepposervice",
	path => 'D:\mycompany\webpub\bepposervice\bepposervice.exe',
	domain => 'yourdomain',
	username => 'daeadminuser',
	password => 'yourpassword'
}

sharefolder::create { 'CreateBetaShare':
	sharename => 'beta',
	path => 'D:\mycompany\webpub\bepposervice',
	user => 'Administrators',
	rights => 'Full'
}

service { 'csbepposervice':
	name => 'csbepposervice',
	ensure => 'running',
	enable => true
}

}
