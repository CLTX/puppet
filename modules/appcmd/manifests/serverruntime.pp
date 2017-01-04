define appcmd::serverruntime (

) {
	include appcmd
	
	exec { "ServerRuntime":
		command => "appcmd.exe set config  /section:system.webServer/serverRuntime /frequentHitThreshold:\"1\" /commit:apphost",
		unless  => "cmd.exe /c \"appcmd.exe list CONFIG /section:system.webServer/serverRuntime | find.exe \"frequentHitThreshold\" | find.exe \"1\"\"",
	}
}

