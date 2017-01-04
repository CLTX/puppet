define appcmd::windowsauth (
	$enabled
) {
	include appcmd
	
	exec { "appcmdWindowsAuth ${name}":
		command => "appcmd.exe set config /section:windowsAuthentication /enabled:$enabled",
		unless  => "cmd.exe /c \"appcmd.exe list CONFIG | find.exe \"windowsAuthentication enabled=\"\"${enabled}\"\"\"\"",
	}
}
