class powershell()
{
	file { 'C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe':
		ensure => present
	} -> Powershell::Run<| |>
}
