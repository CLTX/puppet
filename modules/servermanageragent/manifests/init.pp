class servermanageragent ()
{

include registry

$path = '\\yourdomain.mycompany.com\installers\Shared-Apps\Compellent'
$media = "CompellentEnterpriseManagerServerAgentSetup.msi"
$deployServer  = 'cviappname0202'

  registry_key { 'HKEY_LOCAL_MACHINE\SOFTWARE\Compellent\EnterpriseManager\ServerAgent':
    ensure => present,
  }

  registry_value { 'HKEY_LOCAL_MACHINE\SOFTWARE\Compellent\EnterpriseManager\ServerAgent\AutoManage':
    ensure => present,
	type   => string,
	data   => '1',
  }

  registry_value { 'HKEY_LOCAL_MACHINE\SOFTWARE\Compellent\EnterpriseManager\ServerAgent\DcHost':
    ensure => present,
    type   => string,
    data   => "$deployServer",
  }

  package {"Compellent Enterprise Manager Server Agent":
	ensure          => present, 
	source          => "${path}\\${media}",
    install_options => {
		"SERVER" => "${deployServer}"		
    }
  }
  
    service { "CompellentEMServerAgent":
	ensure => 'running',
	enable => true,
	require => Package["Compellent Enterprise Manager Server Agent"]
  }

  file {"C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\Compellent Server Agent Manager.lnk":
    ensure => absent,
  }
  
  file {"C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\ServerAgentManager.lnk":
    ensure => absent,
  }
  
}

