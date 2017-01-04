class tst-appfabric{

if $appfabric_installed == 'false' {
    exec { 'appfabrichost':
      command     => "\\yourdomain.mycompany.com\installers\Shared-Apps\Microsoft\appFabric\appFabric 1.0\WindowsServerAppFabricSetup_x64_6.1.exe /i CachingService,CacheAdmin", 
      path      => 'C:\\',
    }
	exec {'addcachehost':
	  command   => 'powershell.exe -ExecutionPolicy ByPass -File \\yourdomain.mycompany.com\DDFS\Shares\team01\DevOps\scripts\AddAppFabricHost.ps1 -NewCacheCluster -Pvd "XML" -ConnStr "\\yourdomain.mycompany.com\DDFS\Shares\team01\DevOps\appFabric\config"',
	  path    => 'C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\',
	  cwd     => 'C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\',
	  tries   => 3,
	  try_sleep => 30,
		}
}
  service {"AppFabricCachingService":
    ensure  => running,
    enable  => true,
  }

}
