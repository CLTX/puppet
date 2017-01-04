class chrome()
{

$chromePathx64 = 'C:\Program Files (x86)\Google\Chrome\Application'
$chromePathx86 = 'C:\Program Files\Google\Chrome\Application'

if $architecture == "x64" {
  exec{"installing Chrome x64":
    command => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Google\\ChromeStandaloneSetup.exe /silent /install",
	unless  => "cmd.exe /c \"powershell.exe -Command \"if (test-path \\\"$chromePathx64\\chrome.exe\\\" -erroraction silentlycontinue) { exit 0} else {exit 1}\"\""
  }
  
  exec{'Adding Chrome to System variable Path':
    command => "cmd.exe /c reg add \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /t REG_SZ /d \"$::path;${chromePathx64}\" /f",
    require => Exec["installing Chrome x64"],
  	unless  => "cmd.exe /c \"reg.exe query  \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /s | findstr.exe /I \"chrome\"\"",
  } 
} else {
  exec{"installing Chrome x86":
    command => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Google\\ChromeStandaloneSetup.exe /silent /install",
	unless  => "cmd.exe /c \"powershell.exe -Command \"if (test-path \\\"$chromePathx86\\chrome.exe\\\" -erroraction silentlycontinue) { exit 0} else {exit 1}\"\""
  }
  
  exec{'Adding Chrome to System variable Path':
    command => "cmd.exe /c reg add \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /t REG_SZ /d \"$::path;${chromePathx64}\" /f",
    require => Exec["installing Chrome x86"],
  	unless  => "cmd.exe /c \"reg.exe query  \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /s | findstr.exe /I \"chrome\"\"",
  } 
}
}
