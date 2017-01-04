define appcmd::deletesite (
	$siteName
){
	include appcmd
	
	exec { "appcmddeletesite ${name}":
		command => "appcmd.exe delete site \"$siteName\"",
		onlyif => "cmd.exe /c \"appcmd.exe list SITE | find.exe \"$siteName\"\"",
		}
}
