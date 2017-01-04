define robocopy::run (
	$source,
	$destination,
	$files = "*.*",
	$options = '/E /R:1 /W:1 /PURGE',
	$skipifexists = undef,
	$successcode = [0, 1]
) {
		  
	if $skipifexists {
		exec { "robocopy ${name}" :
			command => "robocopy.exe  ${source} ${destination} ${files} ${options}",
			timeout => 0,
			returns => $successcode,
			onlyif => "powershell.exe -ExecutionPolicy ByPass -command \"if (Test-Path ${skipifexists}) { exit 1;}  else { exit 0; }\""
		}
	}
	else {
		exec { "robocopy ${name}" :
			command => "robocopy.exe  ${source} ${destination} ${files} ${options}",
			timeout => 0,
			returns => $successcode
		}
	}
}
