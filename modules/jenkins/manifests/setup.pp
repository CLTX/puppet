class jenkins::setup() {

include registry
include appfabricclient
include robocopy

$pathCollabSubversion = 'C:\Program Files\CollabNet\Subversion Client'
$pathPutty = 'C:\Program Files (x86)\PuTTY'
$pathMSVisualStudio2010 = 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe'
$pathMSVisualStudio2012isolated = 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\VSIXInstaller.exe'
$pathMSVisualStudio2012integrated = 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\shellintegrated\1033\License.htm'
$pathJavaJDK17 = 'C:\Program Files\Java\jdk1.7.0_17'
$pathJavabin = 'C:\Program Files\Java\jdk1.7.0_17\bin'
$pathPython = 'C:\Python'
$pathGallio = 'C:\Program Files\Gallio\bin'
$pathNUnit = 'C:\Program Files (x86)\NUnit 2.6.2\bin'
$programFiles = 'C:\Program Files'
$programFilesx86 = 'C:\Program Files (x86)'
$pathPhantom = 'C:\Program Files (x86)\phantomjs-1.6.1'
$pathNAnt = 'C:\Program Files (x86)\nant-0.92\bin'
$unzip = 'C:\Program Files\7-Zip\7z.exe'
$path7zip = "C:\\Program Files\\7-Zip\\"
$pathMWPT = "C:\\Program Files\\Microsoft Windows Performance Toolkit\\"
$pathGIT = "C:\\Program Files (x86)\\Git\\cmd"
$pathJSBuilder = 'C:\Program Files (x86)\JS Builder'
$phantomzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\Phantom\phantomjs-1.6.1-win32-static.zip'
$nantzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\NAnt\nant-0.92-bin.zip'
$nantcontribzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\NAnt\nantcontrib-0.92-bin.zip'
$pstoolszip = '\\yourdomain.mycompany.com\installers\Shared-Apps\Microsoft\PSTools\PSTools.zip'
$nssmzip = '\\yourdomain.mycompany.com\installers\Shared-Apps\NSSM\nssm-2.15.zip'
$pathPsTools = 'C:\Program Files (x86)\Pstools'
$pathNssm = 'C:\Program Files\nssm-2.15\nssm-2.15'
$pathSeleniumServer = 'C:\Program Files (x86)\Selenium Server'
$jarseleniumserver = '\\yourdomain.mycompany.com\installers\Shared-Apps\Selenium Server'
$binnssm = 'C:\Program Files\nssm-2.15\nssm-2.15\win64\nssm.exe'
$seleniumServerJar = 'C:\Program Files (x86)\Selenium Server\selenium-server-standalone-2.25.0.jar'
$cs_automation = '2763d54b-0840-42c5-8299-cb46c5943495'
$dev_API_Key = '9a8f291a-06a5-4eee-a5f4-6500b9f8b288'
$PathGIT = "C:\\Program Files (x86)\\Git\\bin"
$gitactualversion = "git version 1.8.1.msysgit.1"
$PathNET35 = "C:\\Windows\\Microsoft.NET\\Framework64\\v3.5"
$PathWinSDK7 = "C:\Program Files\\Microsoft SDKs\\Windows\\v7.0"
$PathCC = "C:\\program Files (x86)\\CruiseControl.NET"
$pathVS2010bin = 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin'


  if $gitversion != "${gitactualversion}" {
    exec{'Install GIT':
      command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Git\\Git-1.8.1.2-preview20130201.exe  /verysilent /LOADINF=\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Git\\git.inf /NORESTART /CLOSEAPPLICATIONS",
    }
  }
 
  exec{'Install .NET 4.5':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\dotNet\\dotNetFx45_Full_setup.exe /q /norestart",
    timeout => 0,
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
  
  package {"TortoiseSVN 1.7.9.23248 (64 bit)":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\TortoiseSVN\\TortoiseSVN-1.7.9.23248-x64-svn-1.7.6.msi",
	install_options => {
	  "ADDLOCAL"    => 'ALL',
    },
  }
		
  package {"Syncfusion Essential Studio Link Install 11.2.0.25":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Syncfusion\\Essential Studio Link Install.msi",
	install_options => {
	  "ADDLOCAL"   => 'asp.net,asp.net_mvc,mobile_web,silverlight,windowsforms,windows_phone,wpf,WINRT,windows_phone7',
	  "COMPANYNAME" => 'mycompany Inc.',
      "PIDKEY"      => '@31312e322e30hEv+iAJ6MkVupr6ZN1/Dj7u9pD7gKpEUPBim3b9H3TI=',
      "TARGETDIR"   => "C:\\",
      "MACHINETYPE" => 'BUILD',
      "USERNAME"    => 'Build User 1',
    },
  }
  
  exec{'Install CollabNat Subversion Client':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\CollabNet\\CollabNetSubversion-client-1.7.6-1-x64.exe /S",
    onlyif  => "cmd.exe /c if exist \"${pathCollabSubversion}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }

  exec{'Install Putty':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Putty\\putty-0.62-installer.exe /silent",
    onlyif  => "cmd.exe /c if exist \"${pathPutty}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  package {"JS Builder":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\JSBuilder\\JSBuilderSetup.msi",
	install_options => {
	  "TARGETDIR"   => "C:\\Program Files (x86)\\JS Builder\\",
    },
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
  
  exec{'Install Java JDK':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Java\\jdk-7u17-windows-x64.exe /s",
    onlyif  => "cmd.exe /c if exist \"${pathJavaJDK17}\" (EXIT /B 1) ELSE (EXIT /B 0)",
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
  
  package {"Gallio 3.4 build 14":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Galio\\GallioBundle-3.4.14.0-Setup-x64.msi",
  }    
  
  package {"Sandcastle":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\Sandcastle.msi",
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
  
  exec{'Copy Selenium Server':
    command => "cmd.exe /c robocopy.exe ${jarseleniumserver} \"${pathSeleniumServer}\" selenium-server-standalone-2.25.0.jar /R:1 /W:1",
    returns => [0,1,2],
    onlyif  => "cmd.exe /c if exist \"${pathSeleniumServer}\\selenium-server-standalone-2.25.0.jar\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  exec{'NSSM':
    command => "\"${unzip}\" x -o\"${programFiles}\\nssm-2.15\" ${nssmzip}",
    onlyif  => "cmd.exe /c if exist \"${pathNssm}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }

  exec{'PSTools':
    command => "\"${unzip}\" x -o\"${pathPsTools}\" ${pstoolszip}",
    onlyif  => "cmd.exe /c if exist \"${pathPsTools}\" (EXIT /B 1) ELSE (EXIT /B 0)",
    require => Package["7-Zip 9.20 (x64 edition)"]
  }  
  
  exec{'Installing Selenium Server as Service':
    command => "\"${binnssm}\" install \"Selenium Server\" \"java.exe\" \"-jar \"\"${seleniumServerJar}\"\" \" ",
    path    => ['C:\windows\System32','C:\Windows\Sysnative\WindowsPowerShell\v1.0',"${pathJavabin}","${pathNssm}"],
    require => [Exec['Copy Selenium Server'],Exec['NSSM'],Exec['Install Java JDK'],Exec['Adding paths to System variable Path']],
	unless  => "cmd.exe /c \"powershell.exe -ExecutionPolicy ByPass -Command \"get-service | where-object {\$_.Name -eq \'Selenium Server\'}\" | find.exe \"Selenium Server\"\"",
    notify  => Registry_value['HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Selenium Server\Parameters\Appappname03ory']
  }
 
  registry_value { 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Selenium Server\Parameters\Appappname03ory':
    ensure => present,
    type   => expand,
    data   => 'C:\Program Files (x86)\Selenium Server',
  }
 
  service { "Selenium Server":
	ensure => 'running',
	enable => true,
	require => Exec['Installing Selenium Server as Service']
  } 
  
  exec{'Adding paths to System variable Path':
    command => "cmd.exe /c \"reg.exe add \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /t REG_SZ /d \"$::path;${pathNUnit};${pathPython};${pathPhantom};${pathNAnt};${pathPsTools};${pathNssm}\\win64;${pathCollabSubversion};${pathJavabin};${$path7zip};${pathGallio};${pathMWPT};${pathGIT};${pathJSBuilder};${PathGIT};${pathVS2010bin}\" /f\"",
    require => [Package["NUnit 2.6.2"],Package["Python 3.3.0 (64-bit)"],Exec['Install Java JDK'],Exec['PhantomJS'],Exec['NAnt'],Exec['PSTools'],Exec['NSSM'],Package["JS Builder"],Package["7-Zip 9.20 (x64 edition)"],Package["Gallio 3.4 build 14"],Exec['Install Microsoft Visual Studio 2010 Shell']],
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
	require => Service["Selenium Server"]
  }
  
  exec{'Visual C++ Redistributable for Visual Studio 2012 x86':
    command => "cmd.exe /c \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\Visual_C++_Redist_for_VS2012_U3\\vcredist_x86.exe /install /quiet /norestart\"",
	unless  => "cmd.exe /c if exist \"C:\\ProgramData\\Package Cache\\{E7D4E834-93EB-351F-B8FB-82CDAE623003}v11.0.60610\\packages\\vcRuntimeMinimum_x86\\vc_runtimeMinimum_x86.msi\" (EXIT /B 0) ELSE (EXIT /B 1)",
	require => Exec['Visual C++ Redistributable for Visual Studio 2012 x64']
  }
}

