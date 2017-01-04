class automailer()
{
$userservice = "yourdomain\\daewebuser"

$installerautomailer = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\mycompany\\appname05\\Automailer\\PRD\\mycompany Automailer Service.msi"

  exec { "Grant LogonAsService to ${userservice}":
    command => "powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\Add-Account-To-LogonAsService.ps1 ${userservice}",
    onlyif  => "powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\check-logonasservice.ps1 ${userservice}",
  }

  package {"mycompany Automailer Service":
    source  => "${installerautomailer}",
    require => Exec["Grant LogonAsService to ${userservice}"],
  }  

  service { "mycompany Automailer Service":
    ensure  => 'running',
    enable  => true,
	require => Package["mycompany Automailer Service"],
  }
}