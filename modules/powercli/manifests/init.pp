class powercli () {

$vmwareVIX = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\VmWare\\VMwareVIX.msi"
$vmwarePWCLI = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\VmWare\\VMware-PowerCLI-5.1.0-793510.msi"

  package {"VMware VIX":
	ensure          => present, 
	source          => "${vmwareVIX}",
	install_options => {
		"AGREETOLICENSE" => "Yes"
    }
  }
  
  package {"VMware vSphere PowerCLI":
	ensure  => present, 
	source  => "${vmwarePWCLI}",
	require => Package["VMware VIX"],
    install_options => {
	    "ADDLOCAL"       => "PowerCLICore,PowerCLI_Common",
		"AGREETOLICENSE" => "Yes"
    }
  }
}