class netsh()
{

$netshPath = 'C:\Windows\System32\netsh.exe'

file { "${netshPath}":
  ensure => present
}

}
