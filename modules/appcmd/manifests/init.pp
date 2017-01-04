class appcmd()
{
$appCmdPath  = 'C:\Windows\System32\inetsrv\appcmd.exe'

  file { "${appCmdPath}":
    ensure => present,
  }
}
