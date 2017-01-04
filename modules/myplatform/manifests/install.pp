define myplatform::install(
	$siteName,
	$appPool,
	$environment = 'TST'
  ){
	include appcmd
	include robocopy
	
	robocopy::run { "MyPlatform Copy for ${siteName}":
		source => "\\\\yourdomain.mycompany.com\\pdfs\\Shares\\team01\\MyPlatform\\${environment}",
		destination => "D:\\mycompany\\webpub\\myplatform\\wwwroot"
		
	}
	
	appcmd::createwebapp { "Creating Web App for MyPlatform for for ${siteName}":
		siteName     => "${siteName}",
		path         => '/myplatform',
		physicalPath => "D:\\mycompany\\webpub\\myplatform\\wwwroot",
		document     => 'default.aspx',
		apppool      => "${appPool}",
		require      => Robocopy::Run["MyPlatform Copy for ${siteName}"]
	
	}
	
}
