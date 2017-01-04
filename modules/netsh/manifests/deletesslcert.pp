define netsh::deletesslcert(
  $ipPort,
  $siteName,
){

include netsh
	
exec { "netshdeletecert ${name} for ${siteName}":	
  command => "netsh.exe http delete sslcert $ipPort:443",
  onlyif  => "cmd.exe /c \"netsh.exe http show sslcert | findstr.exe /I \"${ipPort}:443\" \" "
 }
}

