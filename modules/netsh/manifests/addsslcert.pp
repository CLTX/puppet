define netsh::addsslcert(
  $ipPort,
  $certHash,
  $appID
){

include netsh
	
exec { "netshimportcert ${name}":	
  command => "netsh.exe http add sslcert $ipPort:443 certhash=$certHash appid={${appID}}",
  #return => [0,1],
  unless  => "cmd.exe /c \"netsh.exe http show sslcert| findstr.exe /I \"${certHash}\" \" "
 }
}

