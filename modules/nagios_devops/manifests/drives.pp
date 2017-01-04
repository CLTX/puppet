class nagios_devops::drives () {

require nagios_devops::setup
include nagios_devops::setup

$lowhostname = $nagios_devops::setup::variablecfg
$newfile = "\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$lowhostname"
$oldfile = "\\\\pvusapeds02\\shares\\devops\\nsclient\\templates\\$lowhostname"

if ( "pvusaPAR0" in $hostname ) {  
    notify {"no adding drives":}
  } else {
    exec { "Adding drives to Nagios Template":
      command => "powershell.exe -ExecutionPolicy bypass \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\drives_to_nagios.ps1",
      require => Exec['restart nsc-devops']
    }

    #copy config file
    exec{'copy config file':
      #command  => "robocopy.exe \"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\" \"\\\\pvusapeds02\\shares\\devops\\nsclient\\templates\" $lowhostname /R:1 /W:1 /E",
        command => "powershell.exe -ExecutionPolicy bypass \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\compareandcopy.ps1 $newfile $oldfile",
        provider => windows,
        returns  => ['0','1','2','3'],
       require  => Exec["Adding drives to Nagios Template"]
      }
    }
 }
