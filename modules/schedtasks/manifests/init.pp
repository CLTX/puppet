class schedtasks()
{

$schtaskPath = 'C:\Windows\System32\schtasks.exe'

file { "${schtaskPath}":
  ensure => present
} 

}
