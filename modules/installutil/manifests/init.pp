class installutil()
{
	file { 'C:\\Windows\\Microsoft.NET\\Framework':
		ensure => present
	} -> Installutil::Run<| |>
}
