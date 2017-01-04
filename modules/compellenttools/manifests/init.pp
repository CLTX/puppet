class compellenttools () {

$CompellentPSC ="\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Compellent\\Powershell Command Scripts\\CompellentPowerShellCommandSetSetup_070000004.msi"
$CompellentReplayManagerService = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Compellent\\Replay Manager 7.2\\CompellentReplayManagerServiceSetup_070200007.msi"
$CompellentReplayManagerManagement = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Compellent\\Replay Manager 7.2\\CompellentReplayManagerManagementSetup_070200007.msi"

  package {"Dell Compellent Storage Center Command Set":
	ensure          => present, 
	source          => "${CompellentPSC}",
    install_options => {
		"AGREETOLICENSE" => "Yes"
    }
  }
  
  package {"Dell Compellent Replay Manager Management Tools":
	ensure          => present, 
	source          => "${CompellentReplayManagerManagement}",
    install_options => {
		"AGREETOLICENSE" => "Yes"
    }
  }
  
  package {"Dell Compellent Replay Manager":
	ensure          => present, 
	source          => "${CompellentReplayManagerService}",
    install_options => {
		"AGREETOLICENSE" => "Yes",
		"ADDLOCAL"       => "ReplayManager,SQL,Win64Libraries"
    }
  } 
  
  service { "ReplayManager":
	ensure => 'running',
	enable => true,
	require => Package["Dell Compellent Replay Manager"],
  }
  
}