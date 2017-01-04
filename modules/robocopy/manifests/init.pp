class robocopy()
{
	file { 'C:\\Windows\\System32\\robocopy.exe':
		ensure => present
	} -> Robocopy::Run<| |>
}
