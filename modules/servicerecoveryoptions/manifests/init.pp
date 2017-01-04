class servicerecoveryoptions()
{
  $scPath = 'C:\Windows\System32\sc.exe'
   
  file { "${scPath}":
    ensure => present,
  } 

}