class appname04apiservice::setup () {
include sharefolder
include stdlib
require appfabricclient
include servicerecoveryoptions

$nameSite = 'api.mycompany.com'

installutil::run {'Installing WebApiService':
	serviceName => "cswebapiservice",
	path => "D:\\mycompany\\webpub\\${nameSite}\\wwwroot\\mmx\\bin\\WebAPIBatchService.exe",
	domain => "yourdomain",
	username => "daeadminuser",
	password => "yourpassword",
	pathMustExist => "false"
}

servicerecoveryoptions::failure{ 'WebApiService':
  service => "cswebapiservice",
  action1 => "restart",
  delay1   => "60000",
  require => Installutil::Run['Installing WebApiService']
}

}
