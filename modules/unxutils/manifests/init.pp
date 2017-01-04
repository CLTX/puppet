class unxutils()
{
$pathUnxUtils = 'D:\UnxUtils'
$pathUnxUtilsusrbin = 'D:\UnxUtils\usr\local\wbin'

  file {'D:\UnxUtils':
    ensure  => present,
    source  => 'puppet:///modules/unxutils/UnxUtils',
	recurse => true,
  }

  windows_env { 'UnxUtils':
    variable  => 'PATH',
    value     => "${pathUnxUtils}\bin",
    mergemode => insert,
    require   => File['D:\UnxUtils']
  }

  windows_env { 'UnxUtilsUsrBin':
    variable  => 'PATH',
    value     => "${pathUnxUtilsusrbin}",
    mergemode => insert,
    require   => File['D:\UnxUtils']
  }
}