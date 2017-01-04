define appcmd::adddocument (
	$sitePath,
	$document,
) {
	include appcmd
	
	exec { "adding ${document} to defaultDocuments":
		command => "appcmd.exe set config \"${sitePath}\" /section:defaultDocument /+files.[value=\'${document}\'] /commit:\"${sitePath}\"",
		unless  => "cmd.exe /c \"appcmd.exe list config \"${sitePath}\" -section:defaultDocument | find.exe \"${document}\"\"",
	}
}

