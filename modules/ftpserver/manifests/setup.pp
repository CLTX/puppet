class ftpserver::setup{

dism { 'IIS-FTPServer':
      ensure => present,
    }
	
dism { 'IIS-FTPSvc':
      ensure => present,
    }
	
}
