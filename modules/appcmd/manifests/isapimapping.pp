define appcmd::isapimapping (
  $extension
) 
{
	include appcmd
	
	exec { "AppCmdIsapiMapping ${extension}-2.0-32bit":
		command => "appcmd.exe set config /section:handlers /+[name='${extension}-ISAPI-2.0',path='*.${extension}',verb='*',scriptProcessor='C:\\Windows\\Microsoft.NET\\Framework\\v2.0.50727\\aspnet_isapi.dll',modules='IsapiModule']",
		unless  => "cmd.exe /c \"appcmd.exe list CONFIG /section:handlers | find.exe \"${extension}\" | find.exe \"Framework\\v2.0\"\"",
	}
	
	exec { "AppCmdIsapiMapping ${extension}-2.0-64bit":
		command => "appcmd.exe set config /section:handlers /+[name='${extension}-ISAPI-2.0-64',path='*.${extension}',verb='*',scriptProcessor='C:\\Windows\\Microsoft.NET\\Framework64\\v2.0.50727\\aspnet_isapi.dll',modules='IsapiModule']",
		unless  => "cmd.exe /c \"appcmd.exe list CONFIG /section:handlers | find.exe \"${extension}\" | find.exe \"Framework64\\v2.0\"\"",
	}
	
	exec { "AppCmdIsapiMapping ${extension}-4.0-32bit":
		command => "appcmd.exe set config /section:handlers /+[name='${extension}-ISAPI-4.0',path='*.${extension}',verb='*',scriptProcessor='C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\aspnet_isapi.dll',modules='IsapiModule']",
		unless  => "cmd.exe /c \"appcmd.exe list CONFIG /section:handlers | find.exe \"${extension}\" | find.exe \"Framework\\v4.0\"\"",
	}
	
	exec { "AppCmdIsapiMapping ${extension}-4.0-64bit":
		command => "appcmd.exe set config /section:handlers /+[name='${extension}-ISAPI-4.0-64',path='*.${extension}',verb='*',scriptProcessor='C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\aspnet_isapi.dll',modules='IsapiModule']",
		unless  => "cmd.exe /c \"appcmd.exe list CONFIG /section:handlers | find.exe \"${extension}\" | find.exe \"Framework64\\v4.0\"\"",
	}
}