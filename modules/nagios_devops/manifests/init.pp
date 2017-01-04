class nagios_devops()
{

include nagios_devops::setup
include nagios_devops::drives
include nagios_devops::hostheader

$nagiosdevopsservicename = "nsc-devops"
$nagiospath = "C:\\NSClient"
$rmadmin =  "\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\rmadmin\\rmadmin.bat"

	if ( "pvusaPAR0" in $hostname ) {	
    notify {"no nagios config":}
  } else {

    # client folder copy
    exec{'copy folder':
      command  => "robocopy.exe \"\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\nsclient\\NSClient++\" C:\\NSClient /NP /MIR",
      provider => windows,
      returns  => ['0','1','2','3'],
    }	

    #Create Service
    exec{'Create Service nsc-devops':
      command => "powershell.exe new-service -name nsc-devops -binaryPathName \\\"C:\\NSClient\\nsclient++.exe\\\" -displayname nsc-devops -startuptype Automatic -Description \\\"Nagios Agent managed by DevOps\\\"",
      unless  => "${rmadmin} service $hostname nsc-devops check | find.exe \"Running\"",
      require => Exec['copy folder'],
    }

    # Replace File
    file {"$nagiospath\\NSC.ini":
      ensure  => 'present',
      content => template('nagios_devops/NSC.ini'),
      require => Exec['copy folder'],
    }  
  
    # restart Service nsc-devops service only if file NSC.ini is modified
    exec{'restart nsc-devops':
      command   => "cmd.exe /c \"net stop \"${nagiosdevopsservicename}\" &sc start \"${nagiosdevopsservicename}\"\"",
      subscribe => File["$nagiospath\\NSC.ini"],
      refreshonly => true,
    }

    service {'nsc-devops':
      ensure     => 'running',
      enable     => true,
      require    => File["$nagiospath\\NSC.ini"],
    }
  }

}
