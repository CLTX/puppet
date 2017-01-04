class iiswebserver::iissetup()
{
	include sharefolder
	include appcmd
	include folderpermission
	include schedtasks
	require iiswebserver::windowsfeatures

	
	$pathNET4 = "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319"
	$pathNET4x32 = "C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319"
	$pathMVC3 = "C:\\Program Files (x86)\\Microsoft ASP.NET\\ASP.NET MVC 3"
	
registry_key { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment':
		ensure => present,
}

registry_value { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\CSSCFGFILE':
		ensure => present,
		type   => string,
		data   => 'D:\mycompany\webpub\conf\css.conf',
}

registry_key { 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0':
		ensure => present,
}

registry_value { 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Enabled':
		ensure => present,
		type   => dword,
		data  => '0x00000000'
}
	
exec { 'Install-MVC3':
			command => "cmd.exe /c start /wait \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\AspNetMVC\\AspNetMVC3ToolsUpdateSetup.exe /q /norestart", 
		    onlyif => "cmd.exe /c if exist \"${pathMVC3}\" (EXIT /B 1) ELSE (EXIT /B 0)",
			timeout => 0,
			require => Package['Microsoft Web Deploy 2.0'],
    }

exec{'Install .NET 4.0':
			command => "cmd.exe /c start /wait \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\dotNet\\dotNetFx40_Full_x86_x64.exe /q /norestart", 
			timeout => 0,
			unless  => "cmd.exe /c \"${pathNET4}\\aspnet_regiis.exe -lv | find.exe \"${pathNET4}\"\"",
	}

package {"Microsoft Web Deploy 2.0":
  source  => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\WebDeploy_2_10_amd64_en-US.msi", 
  install_options => {
    "ADDLOCAL" => "ALL",
  },
  ensure  => installed,
  require => Exec['Install .NET 4.0'],
}

package {"IIS URL Rewrite Module 2":
  source  => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\URL_Rewrite\\rewrite_2.0_rtw_x64.msi",
  ensure  => installed,
  require => Exec['Install .NET 4.0']
}

file {'D:\\mycompany':
  ensure => appname03ory,
}

file {'D:\\mycompany\\webpub':
  ensure => appname03ory,
}

file {'D:\mycompany\web-applications':
  ensure => appname03ory,
  }

sharefolder::create{'web-applicationShare':
  sharename => 'web-applications',
  path => 'D:\mycompany\web-applications',
  user => 'Everyone',
  rights => 'Full',
  require => File['D:\mycompany\web-applications']
  }

file { 'D:\mycompany\web-applications\nagios':
  ensure   => appname03ory,
  owner    => "Everyone",
  require  => Sharefolder::Create['web-applicationShare']
  }


file {'D:\\DAECommonConfigLocal':
  ensure => absent,
  force => true,
}

file {'D:\\mycompany\\DAECommonConfigLocal':
  ensure => appname03ory,
}

folderpermission::changeowner{ 'Changing the Owner':
  path       => 'D:\mycompany',
  user       => 'Administrators'
}

folderpermission::rights{ 'Giving rights to Everyone':
  path       => 'D:\mycompany',
  user       => 'Everyone',
  rights     => 'FullControl',
  permission => 'Allow',
}

folderpermission::rights{ ' Giving rights to Administrators':
  path       => 'D:\mycompany',
  user       => 'Administrators',
  rights     => 'FullControl',
  permission => 'Allow',
}

folderpermission::rights{'CommonConfigFullAccess':
  path       => 'D:\mycompany\DAECommonConfigLocal',
  user       => 'Everyone',
  rights     => 'FullControl',
  permission => 'Allow',
  require => File['D:\\mycompany\\DAECommonConfigLocal']
}

sharefolder::create { 'CreateWebPubShare':
	sharename => 'webpub',
	path => 'D:\mycompany\webpub',
	user => 'Everyone',
	rights => 'Full',
	require => File['D:\\mycompany\\webpub']
}

sharefolder::create { 'CreateNagiosShare':
	sharename => 'nagios',
	path => 'D:\mycompany\webpub',
	user => 'Everyone',
	rights => 'Full',
	require => File['D:\\mycompany\\webpub']
}

sharefolder::create { 'CreateDAECommonConfigLocal':
	sharename => 'DAECommonConfigLocal',
	path => 'D:\mycompany\DAECommonConfigLocal',
	user => 'Everyone',
	rights => 'Full',
	require => File['D:\\mycompany\\DAECommonConfigLocal']
}

folderpermission::rights{'TempASP64RightsIIS':
  path       => "\"\"\"C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\Temporary ASP.NET Files\"\"\"",
  user       => 'IIS_IUSRS',
  rights     => 'FullControl',
  permission => 'Allow',
}

folderpermission::rights{'TempASP64RightsEveryone':
  path       => "\"\"\"C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\Temporary ASP.NET Files\"\"\"",
  user       => 'Everyone',
  rights     => 'FullControl',
  permission => 'Allow',
}

folderpermission::rights{'Giving rights to daewebuser':
  path       => "\"\"\"C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\Temporary ASP.NET Files\"\"\"",
  user       => 'yourdomain\daewebuser',
  rights     => 'FullControl',
  permission => 'Allow',
}

appcmd::isapicgirestriction { '32 bits':
  path => "c:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\aspnet_isapi.dll",
}

appcmd::isapicgirestriction { '64 bits':
  path => "c:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\aspnet_isapi.dll",
}

# Common Headers expire content time format is d.hh:mm:ss.
# status can be 'UseMaxAge' (Enabled) or NoControl (Disabled).
appcmd::expirewebcontent { ' ExpireWebContent TimeStamp':
  timeStamp => '180.00:00:00',
  status    => 'UseMaxAge',
}

exec {'Enable-ASP-NET4' :
  command => 'c:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\aspnet_regiis.exe -i',
  unless  => "cmd.exe /c \"${pathNET4x32}\\aspnet_regiis.exe -lv | find.exe \"${pathNET4x32}\"\"",  
}

appcmd::setanonymoususer { 'SetAnonymousUser':
  userName => 'yourdomain\daewebuser',
  password => 'yourpassword'
}

appcmd::windowsauth { 'WindowsAuthentication':
  enabled => true
}

schedtasks::create {'Adding schedule tasks for IIS log rotation':
  ruUsername  => 'yourdomain\daebuilduser',
  rpPassword  => 'yourpassword',
  scFrequency => 'DAILY',
  tn          => 'Cleaning IIS logfiles older than 30 days',
  tr          => 'powershell.exe -ExecutionPolicy Bypass -File \\yourdomain.mycompany.com\PDFS\Shares\team01\DevOps\Scripts\powershell\IIS_logcleanup.ps1',
  stTime      => '23:00',
  rl          => 'HIGHEST',
  require     => Package["IIS URL Rewrite Module 2"] 
}


}
