define powershell::run (
	$command = undef,
	$file = undef,
	$policy = 'ByPass',
	$successcode = 0
) {

	if $command {
		$Path = "-Command ${command}"
	} else {
		$Path = "-File ${file}"
	}
	
	exec { "powershell ${name}":
		command => "C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy ${policy} ${Path}",
		returns => $successcode
	}
}
