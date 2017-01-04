define appcmd::32bit (
	$appName,
	$enabled
) {
	include appcmd
	
	exec { "appcmd32bit ${name}":
		command => "appcmd.exe set apppool /apppool.name:${appName} /enable32BitAppOnWin64:${enabled}",
		onlyif  => "cmd.exe /c \"appcmd.exe list CONFIG | find.exe \"${appName}\" | find.exe \"enable32BitAppOnWin64=\"\"false\"\"\"\"",
	}
}
