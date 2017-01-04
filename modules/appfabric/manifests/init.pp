class appfabric{

$fabricpath = '\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\appFabric\\appFabric 1.0\\WindowsServerAppFabricSetup_x64_6.1.exe' 
$fhostPSpath = '\\\\yourdomain.mycompany.com\\DDFS\\Shares\\team01\\DevOps\\scripts\\AddAppFabricHost.ps1'
$fconfigpath = '\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\appfabric'
$winSynPSpath = 'C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\'

if $appfabric_installed == 'false' {
  exec { 'appfabrichost':
    command   => "${fabricpath} /i CachingService,CacheAdmin",
    path      => 'C:\\',
  }
  
exec {'addcachehost':
  command => "powershell.exe -ExecutionPolicy ByPass -File ${fhostPSpath} -NewCacheCluster -Pvd 'XML' -ConnStr ${fconfigpath}",
  path    => "$winSynPSpath",
  cwd     => "$winSynPSpath",
  tries   => 3,
  try_sleep => 30,
	}
  }
}
