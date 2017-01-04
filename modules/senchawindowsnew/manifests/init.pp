class senchawindowsnew()
{
include java

$installer = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Sencha\\SenchaCmd-4.0.4.84-windows.exe"
$senchaexec = 'C:\Program Files (x86)\Sencha\Cmd\4.0.4.84\sencha.exe'
$params = " --unattendedmodeui none --mode unattended --prefix \"C:\\Program Files (x86)\""

$uninstallerSenchaSDK  = 'C:\Program Files (x86)\Sencha\Cmd\3.1.1.274\uninstall.exe'
$paramsSDK = '--unattendedmodeui none --mode unattended'

exec{'Uninstall Sencha SDK Tools':
    command => "cmd.exe /c \"${uninstallerSenchaSDK}\" ${paramsSDK}",
	unless  => "cmd.exe /c if exist \"${uninstallerSenchaSDK}\" (EXIT /B 1) ELSE (EXIT /B 0)"
  }

exec{'Install Sencha Cmd':
    command => "cmd.exe /c ${installer} ${params}",
	onlyif  => "cmd.exe /c if exist \"${senchaexec}\" (EXIT /B 1) ELSE (EXIT /B 0)"
  }

windows_env { 'Add Sencha to Path':
  variable  => 'PATH',
  value     => 'C:\Program Files (x86)\Sencha\Cmd\4.0.4.84',
  mergemode => insert,
}
  
}
