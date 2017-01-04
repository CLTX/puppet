class firefox()
{

$firefoxPathx64 = 'C:\Program Files (x86)\Mozilla Firefox'
$firefoxPathx86 = 'C:\Program Files\Mozilla Firefox'


if $architecture == "x64" {
  exec{"installing Firefox x64":
    command => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Firefox\\Firefox-Setup-21.0.exe -ms",
	unless  => "cmd.exe /c \"reg.exe query \"HKLM\SOFTWARE\Wow6432Node\Mozilla\Mozilla Firefox\" /v CurrentVersion | findstr /I \"currentversion\"\""
  }
  
  exec{'Adding firefox to System variable Path':
    command => "cmd.exe /c reg add \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /t REG_SZ /d \"$::path;${firefoxPathx64}\" /f",
    require => Exec["installing Firefox x64"],
  	unless  => "cmd.exe /c \"reg.exe query  \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /s | findstr.exe /I \"firefox\"\"",
  } 
  
} else {
  exec{"installing Firefox x86":
    command => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Firefox\\Firefox-Setup-21.0.exe -ms",
	unless  => "cmd.exe /c \"reg.exe query \"HKLM\SOFTWARE\Mozilla\Mozilla Firefox\" /v CurrentVersion | findstr /I \"currentversion\"\""
  }
  
  exec{'Adding firefox to System variable Path':
  command => "cmd.exe /c reg add \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /t REG_SZ /d \"$::path;${firefoxPathx86}\" /f",
    require => Exec["installing Firefox x86"],
  	unless  => "cmd.exe /c \"reg.exe query  \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /s | findstr.exe /I \"firefox\"\"",
  } 
}


}
