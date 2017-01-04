class buildserver::setup () {

 $PathNET35 = "C:\\Windows\\Microsoft.NET\\Framework64\\v3.5"
 $PathWinSDK71 = "C:\\Program Files\\Microsoft SDKs\\Windows\v7.1"
 $PathCC = "C:\\program Files (x86)\\CruiseControl.NET"
 $PathGIT = "C:\\Program Files (x86)\\Git\\bin"
 $gitactualversion = "git version 1.8.1.msysgit.1"
 
  exec{'Install .NET 3.5':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\dotNet\\dotnetfx35sp1.exe /q /norestart", 
	onlyif  => "cmd.exe /c if exist \"${PathNET35}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
		
  exec{'Install Windows SDK 7.1':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\\\Microsoft\\SDK\\WindowsSDK7.1\\setup.exe -q -params:ADDLOCAL=ALL", 
	onlyif => "cmd.exe /c if exist \"${PathWinSDK71}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
	
  package {"MSBuild Community Tasks":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\MSBuild.Community.Tasks\\MSBuild.Community.Tasks.msi", 
	install_options => {
	  "INSTALLDIR"   => 'C:\Program Files (x86)\MSBuild\MSBuildCommunityTasks',
    },
  }
	
  exec{'Install Cruise Control':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\CruiseControl\\CruiseControl.NET-1.8.0.0-Setup.exe /S", 
	onlyif => "cmd.exe /c if exist \"${PathCC}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
		
  package {"TortoiseSVN 1.7.9.23248 (64 bit)":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\TortoiseSVN\\TortoiseSVN-1.7.9.23248-x64-svn-1.7.6.msi", 
	install_options => {
	  "ADDLOCAL"   => 'ALL',
    },
  }

  if $gitversion != "${gitactualversion}" {
    exec{'Install GIT':
      command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Git\\Git-1.8.1.2-preview20130201.exe  /verysilent",
    }
  }
	
}
