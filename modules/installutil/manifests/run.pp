define installutil::run (
	$serviceName,
	$path,
	$domain,
	$username,
	$password,
	$successcode = [0, 255],
	$pathMustExist = "true"
) {
	include installutil
		
	if $pathMustExist != "true"
	{
		exec { "installing service ${path}" :
			command => "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\installutil.exe /username=${domain}\\${username} /password=${password} /unattended ${path}",
			timeout => 0,
			returns => 0,
			onlyif => "powershell.exe -ExecutionPolicy ByPass -command \"if (Get-Service \"${serviceName}\" -ErrorAction SilentlyContinue) { exit 1; } if (Test-Path ${path}) { exit 0;}  else { exit 1; }\""
		}
	}
	else
	{
		exec { "installing service ${path}" :
			command => "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\installutil.exe /username=${domain}\\${username} /password=${password} /unattended ${path}",
			timeout => 0,
			returns => 0,
			onlyif => "powershell.exe -ExecutionPolicy ByPass -command \"if (Get-Service \"${serviceName}\" -ErrorAction SilentlyContinue) { exit 1; } else { exit 0;} \""
		}
	}
	
}
