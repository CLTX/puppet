class loopbacknetwork (){

$script = "\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\add-loopbacknetwork.ps1"
$defaultIPAddr = "127.0.0.1"

  $ipAddresses = { #'appname01'           => "10.101.78.151",
                   #'DevOps'           => "10.101.78.151",
                   #'Clients'          => "10.101.78.151",
                   #'appname03'           => "10.101.78.151",
                   #'Confirmit'        => "10.101.78.151",
                   #'DatamartDelivery' => "10.101.78.151",
                   #'Marketer'         => "10.101.78.151",
                   #'Splunk'           => "10.101.78.151",
                   #'appname02'            => "10.101.78.151",
                   #'PlatfformTeam'    => "10.101.78.151",
                   #'TechSQL'          => "10.101.78.151",
                   #'Marcom'           => "10.101.78.151",
           'appname05'           => "10.101.248.75",
                   #'Atlassian'        => "10.101.78.151",
                   #'Common'           => "10.101.78.151",
				   'appname04'         => "10.101.248.83"
                  }

  if $machine_app != null {
      exec{'newloopback':
        command => "powershell.exe -ExecutionPolicy ByPass -File ${script} ${ipAddresses[$machine_app]}",
	    unless => "cmd.exe /c \"ipconfig.exe /all | find.exe \"Ethernet adapter LVS Loopback\"\"",
      }
  } else {
      exec{'newloopback':
        command => "powershell.exe -ExecutionPolicy ByPass -File ${script} ${defaultIPAddr}",
	    unless => "cmd.exe /c \"ipconfig.exe /all | find.exe \"Ethernet adapter LVS Loopback\" \" ",
      }
  }
}
