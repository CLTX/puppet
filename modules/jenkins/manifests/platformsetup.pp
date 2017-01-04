class jenkins::platformsetup() {

include registry
include appfabricclient
require senchawindowsnew
include robocopy
include rubywindows

$pathMSVisualStudio2010 = 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe'
$pathMSVisualStudio2012isolated = 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\VSIXInstaller.exe'
$pathMSVisualStudio2012integrated = 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\shellintegrated\1033\License.htm'
$programFiles = 'C:\Program Files'
$programFilesx86 = 'C:\Program Files (x86)'
$pathPhantom = 'C:\Program Files (x86)\phantomjs-1.6.1'
$pathNAnt = 'C:\Program Files (x86)\nant-0.92\bin'
$unzip = 'C:\Program Files\7-Zip\7z.exe'
$path7zip = "C:\\Program Files\\7-Zip\\"
$phantomzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\Phantom\phantomjs-1.6.1-win32-static.zip'
$nantzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\NAnt\nant-0.92-bin.zip'
$nantcontribzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\NAnt\nantcontrib-0.92-bin.zip'
$pstoolszip = '\\yourdomain.mycompany.com\installers\Shared-Apps\Microsoft\PSTools\PSTools.zip'
$pathPsTools = 'C:\Program Files (x86)\Pstools'
$PathGIT = "C:\\Program Files (x86)\\Git\\bin"
$gitactualversion = "git version 1.8.1.msysgit.1"
$PathNET35 = "C:\\Windows\\Microsoft.NET\\Framework64\\v3.5"
$PathWinSDK7 = "C:\Program Files\\Microsoft SDKs\\Windows\\v7.0"
$pathVS2010bin = 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin'
$nssmzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\NSSM\nssm-2.15.zip'
$pathNssm = 'C:\Program Files\nssm-2.15\nssm-2.15'

  if $gitversion != "${gitactualversion}" {
    exec{'Install GIT':
      command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Git\\Git-1.8.1.2-preview20130201.exe  /verysilent /LOADINF=\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Git\\git.inf /NORESTART /CLOSEAPPLICATIONS",
    }
  }
 
  exec{'Install .NET 4.5':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\dotNet\\dotNetFx45_Full_setup.exe /q /norestart",
    timeout => 0,
	returns  => ['0','194'],
	unless  => "powershell.exe -ExecutionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\check_dotnet45.ps1"
  }
  
  robocopy::run {"Copy Windows SDK 7 and .NET 3.5 SP1 install files":
    source       => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\SDK\\winSDK7-donet3.5-sp1\GRMSDKX-x64_EN_DVD",
    destination  => "C:\\temp\\winsdk7\\GRMSDKX-x64_EN_DVD",
    options      => "*.* /E /MIR /XO",
	skipifexists => "C:\\temp\\winsdk7",
    notify       =>  Exec['Install Windows SDK 7.1  and .NET 3.5 SP1']
  }
		
  exec{'Install Windows SDK 7.1  and .NET 3.5 SP1':
    command => "C:\\temp\\winsdk7\\GRMSDKX-x64_EN_DVD\\setup.exe -q -params:ADDLOCAL=ALL -l*:C:\\temp\\winsdk7.log",
	timeout => 0,
	onlyif  => "cmd.exe /c if exist \"${PathWinSDK7}\" (EXIT /B 1) ELSE (EXIT /B 0)",
	notify  => [File["C:\\temp\\winsdk7\\GRMSDKX-x64_EN_DVD"],Exec["Create Sym Link for Windows SDK 7"],Registry_key['HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v7.0A']]
  }
  
  exec{'NSSM':
    command => "\"${unzip}\" x -o\"${programFiles}\\nssm-2.15\" ${nssmzip}",
    onlyif  => "cmd.exe /c if exist \"${pathNssm}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  windows_env { 'Add NSSM to Path':
    variable  => 'PATH',
    value     => "${pathNssm}\\win64",
    mergemode => insert,
  }
  
  file{"C:\\temp\\winsdk7\\GRMSDKX-x64_EN_DVD":
    ensure  => absent,
	recurse => true,
	force   => true
  }
  
  package {"MSBuild Community Tasks":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\MSBuild.Community.Tasks\\MSBuild.Community.Tasks.msi",
	install_options => {
	  "INSTALLDIR"   => 'C:\Program Files (x86)\MSBuild\MSBuildCommunityTasks',
    },
  }
  
  exec {"Create Sym Link for Windows SDK 7":
    command => "cmd.exe /c \"mklink /D \"C:\\Program Files\\Microsoft SDKs\\Windows\\v7.0A\" \"C:\\Program Files\\Microsoft SDKs\\Windows\\v7.0\"\"",
	onlyif  => "cmd.exe /c if exist \"C:\\Program Files\\Microsoft SDKs\\Windows\\v7.0A\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  registry_key { 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v7.0A':
    ensure => present,
  }
  
  registry_value { 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v7.0A\InstallationFolder':
    ensure => present,
	type   => expand,
    data   => "C:\\Program Files\\Microsoft SDKs\\Windows\\v7.0A\\",
  }
  
  exec{'Install Microsoft Visual Studio 2010 Shell':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\Visual_Studio\\VSIntShell.exe /passive /q /full /norestart",
    timeout => 0,
    onlyif  => "cmd.exe /c if exist \"${pathMSVisualStudio2010}\" (EXIT /B 1) ELSE (EXIT /B 0)",
	require => Exec['Install .NET 4.5']
  }
  
  exec{'Install Microsoft Visual Studio 2012 Shell Isolated':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\Visual_Studio\\vs_isoshell.exe /passive /Q /NoRestart /Full ",
    timeout => 0,
	require => [Exec['Install .NET 4.5'],Exec['Install Microsoft Visual Studio 2010 Shell']],
    onlyif  => "cmd.exe /c if exist \"${pathMSVisualStudio2012isolated}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  exec{'Install Microsoft Visual Studio 2012 Shell Integrated':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\Visual_Studio\\vs2012_intshelladditional.exe /passive /Q /NoRestart /Full ",
    timeout => 0,
    onlyif  => "cmd.exe /c if exist \"${pathMSVisualStudio2012integrated}\" (EXIT /B 1) ELSE (EXIT /B 0)",
	require => Exec['Install Microsoft Visual Studio 2012 Shell Isolated']
  }
  
  package {"7-Zip 9.20 (x64 edition)":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\7z\\7z920-x64.msi",
  }      

  exec{'PhantomJS':
    command => "\"${unzip}\" x -o\"${programFilesx86}\" ${phantomzip}",
    onlyif  => "cmd.exe /c if exist \"${pathPhantom}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  exec{'NAnt':
    command => "\"${unzip}\" x -o\"${programFilesx86}\" ${nantzip}",
    onlyif  => "cmd.exe /c if exist \"${pathNAnt}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  exec{'NAnt-Contrib':
    command => "\"${unzip}\" e -ir!*.dll -o\"${pathNAnt}\" ${nantcontribzip}",
    onlyif  => "cmd.exe /c if exist \"${pathNAnt}\\NAnt.Contrib.Tasks.dll\" (EXIT /B 1) ELSE (EXIT /B 0)",
	require => Exec['NAnt'],
  }

  exec{'PSTools':
    command => "\"${unzip}\" x -o\"${pathPsTools}\" ${pstoolszip}",
    onlyif  => "cmd.exe /c if exist \"${pathPsTools}\" (EXIT /B 1) ELSE (EXIT /B 0)",
    require => Package["7-Zip 9.20 (x64 edition)"]
  }  

  exec{'Adding paths to System variable Path':
    command => "cmd.exe /c \"reg.exe add \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /t REG_SZ /d \"$::path;${pathPhantom};${pathNAnt};${pathPsTools};${$path7zip};${PathGIT};${pathJSBuilder};${pathVS2010bin}\" /f\"",
    require => [Exec['PhantomJS'],Exec['NAnt'],Exec['PSTools'],Package["7-Zip 9.20 (x64 edition)"],Exec['Install Microsoft Visual Studio 2010 Shell']],
  	unless  => "cmd.exe /c \"reg.exe query  \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /s | findstr.exe /i \"Git\"\"",
  }  

  exec {'Set users home':
    command => "cmd.exe /c \"setx Home \"C:\\Users\\daebuilduser\" /m\"\"",
	unless  => "cmd.exe /c \"reg.exe query  \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Home /s | findstr.exe /i \"C:\\Users\\daebuilduser\"\"",
	require => Exec['Adding paths to System variable Path']
  }
}