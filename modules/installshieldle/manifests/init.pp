class installshieldle() {

$tsconfig = 'C:\Program Files (x86)\InstallShield\2013LE\System\TSConfig.exe'
$serialnumber = '5F9E8QW-D0C-A1597F73AN'

  exec{'Install InstallShield 2013 Limited Edition':
    command => "cmd.exe /C \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Installshield\\InstallShield2013LimitedEdition.exe /S /v/qn\"",
    timeout => 0,
	unless  => "powershell.exe -ExecutionPolicy ByPass -command \"if (Test-Path -path \'${tsconfig}\') { exit 0;}  else { exit 1; }\"",
  }
  
  exec { 'activate serial number':
    command     => "\"${tsconfig}\" /activate /serial_number ${serialnumber} /verbose /silent ",
	subscribe   =>  Exec['Install InstallShield 2013 Limited Edition'],
	refreshonly => true
  }
  
  
}
