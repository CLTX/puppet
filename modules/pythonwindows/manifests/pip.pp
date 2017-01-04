class pythonwindows::pip()
{

$pip_version = '1.5.4'
$setuptools_version = '2.2'

include pythonwindows

file {'D:\python\Scripts':
    ensure  => appname03ory,
	require => Package["Python 2.7.6 (64-bit)"]
  }

file {'D:\python\Scripts\ez_setup.py':
    ensure  => present,
    source  => 'puppet:///modules/pythonwindows/ez_setup.py',
	require => File['D:\python\Scripts']
  }
  
file {'D:\python\Scripts\get-pip.py':
    ensure  => present,
    source  => 'puppet:///modules/pythonwindows/get-pip.py',
	require => File['D:\python\Scripts']
  }

exec { 'Install EZ_Setup':
    command => 'D:\python\python.exe D:\python\Scripts\ez_setup.py',
	require => File['D:\python\Scripts\ez_setup.py'],
	#unless  => "D:\python\Scripts\pip.exe list | findstr /I \"setuptools\" | findstr/I \"${setuptools_version}\""
	onlyif => "powershell.exe -ExecutionPolicy ByPass -command \"if (Test-Path D:\\python\\Scripts\\easy_install-script.py) { exit 1;}  else { exit 0; }\""
  }  
  
exec { 'Install PiP':
    command => 'D:\python\python.exe D:\python\Scripts\get-pip.py',
	require => [File['D:\python\Scripts\get-pip.py'], Exec['Install EZ_Setup']],
	unless  => "cmd.exe /c \"powershell.exe -Command \"if (test-path \\\"D:\\python\\Scripts\\pip.exe\\\" -erroraction silentlycontinue) { exit 0} else {exit 1}\"\"",
  }  
  


}
