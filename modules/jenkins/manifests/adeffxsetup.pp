class jenkins::appname01setup() {

include registry
include appfabricclient
include robocopy

$pathMSVisualStudio2012isolated = 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\VSIXInstaller.exe'
$pathMSVisualStudio2012integrated = 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\shellintegrated\1033\License.htm'
$pathNUnit = 'C:\Program Files (x86)\NUnit 2.6.2\bin'
$pathGIT = "C:\\Program Files (x86)\\Git\\cmd"
$pathPython = 'C:\Python'
$pstoolszip = '\\yourdomain.mycompany.com\installers\Shared-Apps\Microsoft\PSTools\PSTools.zip'
$pathPsTools = 'C:\Program Files (x86)\Pstools'
$gitactualversion = "git version 1.8.1.msysgit.1"
$PathWinSDK7 = "C:\Program Files\\Microsoft SDKs\\Windows\\v7.0"
$unzip = 'C:\Program Files\7-Zip\7z.exe'
$path7zip = "C:\\Program Files\\7-Zip\\"
$programFiles = 'C:\Program Files'
$nssmzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\NSSM\nssm-2.15.zip'
$pathNssm = 'C:\Program Files\nssm-2.15\nssm-2.15'
$pathJavaJDK17 = 'C:\Program Files\Java\jdk1.7.0_17'
$pathJavabin = 'C:\Program Files\Java\jdk1.7.0_17\bin'
$pathNAnt = 'C:\Program Files (x86)\nant-0.92\bin'
$nantzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\NAnt\nant-0.92-bin.zip'
$nantcontribzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\NAnt\nantcontrib-0.92-bin.zip'

  if $gitversion != "${gitactualversion}" {
    exec{'Install GIT':
      command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Git\Git-1.8.1.2-preview20130201.exe  /verysilent /LOADINF=\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Git\\git.inf /NORESTART /CLOSEAPPLICATIONS",
    }
  }
  
  package {"7-Zip 9.20 (x64 edition)":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\7z\\7z920-x64.msi",
  }    
  
  exec{'NAnt':
    command => "\"${unzip}\" x -o\"C:\\Program Files (x86)\\${programFilesx86}\" ${nantzip}",
    onlyif  => "cmd.exe /c if exist \"${pathNAnt}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  exec{'NAnt-Contrib':
    command => "\"${unzip}\" e -ir!*.dll -o\"${pathNAnt}\" ${nantcontribzip}",
    onlyif  => "cmd.exe /c if exist \"${pathNAnt}\\NAnt.Contrib.Tasks.dll\" (EXIT /B 1) ELSE (EXIT /B 0)",
	require => Exec['NAnt'],
  }
  
  exec{'Install .NET 4':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\dotNet\\dotNetFx40_Full_setup.exe /q /norestart",
    timeout => 0,
	onlyif  => "cmd.exe /c \"powershell.exe -Command \"if (test-path \\\"c:\Windows\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll\\\") { exit 1;}  else { exit 0; }\""
  }
  
  exec{'Install .NET 4.5':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\dotNet\\dotNetFx45_Full_setup.exe /q /norestart",
    timeout => 0,
	unless  => "powershell.exe -ExecutionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\check_dotnet45.ps1",
	require => Exec['Install .NET 4']
  }
  
  robocopy::run {"Copy Windows SDK 7 and .NET 3.5 SP1 install files":
    source       => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\Microsoft\\SDK\\winSDK7-donet3.5-sp1\\GRMSDKX-x64_EN_DVD",
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
  
  file{"C:\\temp\\winsdk7\\GRMSDKX-x64_EN_DVD":
    ensure  => absent,
	recurse => true,
	force   => true
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
  
    
  exec{'Install Microsoft Visual Studio 2012 Shell Isolated':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\Visual_Studio\\vs_isoshell.exe /passive /Q /NoRestart /Full ",
    timeout => 0,
	require => Exec['Install .NET 4.5'],
    onlyif  => "cmd.exe /c if exist \"${pathMSVisualStudio2012isolated}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  exec{'Install Microsoft Visual Studio 2012 Shell Integrated':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\Visual_Studio\\vs2012_intshelladditional.exe /passive /Q /NoRestart /Full ",
    timeout => 0,
    onlyif  => "cmd.exe /c if exist \"${pathMSVisualStudio2012integrated}\" (EXIT /B 1) ELSE (EXIT /B 0)",
	require => Exec['Install Microsoft Visual Studio 2012 Shell Isolated']
  }

  package {"Python 3.3.0 (64-bit)":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Phyton\\python-3.3.0.amd64.msi",
	install_options => {
	  "TARGETDIR"   => "C:\\Python\\",
    },
  }
  
  file {'C:\Python\Scripts':
    ensure  => appname03ory,
	require => Package["Python 3.3.0 (64-bit)"]
  }

  file {'C:\Python\Scripts\ez_setup.py':
    ensure  => present,
    source  => 'puppet:///modules/jenkins/ez_setup.py',
	require => File['C:\Python\Scripts']
  }
  
  file {'C:\Python\Scripts\get-pip.py':
    ensure  => present,
    source  => 'puppet:///modules/jenkins/get-pip.py',
	require => File['C:\Python\Scripts']
  }

  exec { 'Install EZ_Setup':
    command => 'C:\Python\python.exe c:\python\Scripts\ez_setup.py',
	require => File['C:\Python\Scripts\ez_setup.py'],
	onlyif => "powershell.exe -ExecutionPolicy ByPass -command \"if (Test-Path \\\"C:\\Python\\Scripts\\easy_install-script.py\\\") { exit 1;}  else { exit 0; }\""
  }  
  
  exec { 'Install PiP':
    command => 'C:\python\python.exe c:\python\Scripts\get-pip.py',
	require => [File['C:\Python\Scripts\get-pip.py'], Exec['Install EZ_Setup']],
	unless  => "cmd.exe /c \"powershell.exe -Command \"if (test-path \\\"C:\\Python\\Scripts\\pip.exe\\\" -erroraction silentlycontinue) { exit 0} else {exit 1}\"\"",
  }  
  
  package {"NUnit 2.6.2":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Nunit\\NUnit-2.6.2.msi",
  }  
  
  package {"Microsoft ASP.NET MVC 2":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\AspNetMVC\\aspnetmvc2.msi",
  }   
   
  exec{'PSTools':
    command => "\"${unzip}\" x -o\"${pathPsTools}\" ${pstoolszip}",
    onlyif  => "cmd.exe /c if exist \"${pathPsTools}\" (EXIT /B 1) ELSE (EXIT /B 0)",
    require => Package["7-Zip 9.20 (x64 edition)"]
  }  
  
  exec{'NSSM':
    command => "\"${unzip}\" x -o\"${programFiles}\\nssm-2.15\" ${nssmzip}",
    onlyif  => "cmd.exe /c if exist \"${pathNssm}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  exec{'Install Java JDK':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Java\\jdk-7u17-windows-x64.exe /s",
    onlyif  => "cmd.exe /c if exist \"${pathJavaJDK17}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  
  exec{'Adding paths to System variable Path':
    command => "cmd.exe /c \"reg.exe add \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /t REG_SZ /d \"$::path;${pathNUnit};${pathPython};${$path7zip};${pathPsTools};${pathGIT};${pathNAnt};${pathNssm};${pathJavabin}\" /f\"",
    require => [Package["NUnit 2.6.2"],Package["Python 3.3.0 (64-bit)"],Exec['PSTools'],Package["7-Zip 9.20 (x64 edition)"],Exec['NSSM'],Exec['Install Java JDK'],Exec['NAnt']],
  	unless  => "cmd.exe /c \"reg.exe query  \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /s | findstr.exe /i \"Python\"\"",
  }  

  exec {'Set users home':
    command => "cmd.exe /c \"setx Home \"C:\\Users\\daebuilduser\" /m\"\"",
	unless  => "cmd.exe /c \"reg.exe query  \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Home /s | findstr.exe /i \"C:\\Users\\daebuilduser\"\"",
	require => Exec['Adding paths to System variable Path']
  }
  
  exec{'Visual C++ Redistributable for Visual Studio 2012 x64':
    command => "cmd.exe /c \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\Visual_C++_Redist_for_VS2012_U3\\vcredist_x64.exe /install /quiet /norestart\"",
	unless  => "cmd.exe /c if exist \"C:\\ProgramData\\Package Cache\\{764384C5-BCA9-307C-9AAC-FD443662686A}v11.0.60610\\packages\\vcRuntimeAdditional_amd64\\vc_runtimeAdditional_x64.msi\" (EXIT /B 0) ELSE (EXIT /B 1)",
	require => Exec['Install Microsoft Visual Studio 2012 Shell Integrated']
  }
  
  exec{'Visual C++ Redistributable for Visual Studio 2012 x86':
    command => "cmd.exe /c \"\\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\Visual_C++_Redist_for_VS2012_U3\\vcredist_x86.exe /install /quiet /norestart\"",
	unless  => "cmd.exe /c if exist \"C:\\ProgramData\\Package Cache\\{E7D4E834-93EB-351F-B8FB-82CDAE623003}v11.0.60610\\packages\\vcRuntimeMinimum_x86\\vc_runtimeMinimum_x86.msi\" (EXIT /B 0) ELSE (EXIT /B 1)",
	require => Exec['Visual C++ Redistributable for Visual Studio 2012 x64']
  }
}

