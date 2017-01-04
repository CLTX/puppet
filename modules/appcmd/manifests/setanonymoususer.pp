define appcmd::setanonymoususer (
	$userName,
	$password
) {
	include appcmd
	
	exec { "appcmdsetanonymoususer ${name}":
		command => "appcmd.exe set config /section:anonymousAuthentication /userName:$userName /password:$password",
		unless  => "cmd.exe /c \"appcmd.exe list CONFIG | find.exe \"anonymousAuthentication\" | find.exe \"${userName}\" | find.exe \"${password}\"\"",
	}
}
