class folderpermission()
{

$powershellPath = 'C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe'
  
file { "${powershellPath}":
    ensure => present
}

}
