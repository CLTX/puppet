define appcmd::ipaddressrestriction (
	$site,
	$path,
	$ipaddress,
	
) {
	include appcmd
	
  exec { "IP Address restriction ${ipaddress} to ${site}/${path}":
    command => "appcmd.exe set config \"${site}/${path}\" -section:system.webServer/security/ipSecurity /+\"[ipAddress=\'${ipaddress}\',allowed =\'true\']\" /commit:apphost",
    unless  => "cmd.exe /c \"appcmd.exe list config \"${site}/${path}\" -section:system.webServer/security/ipSecurity | find.exe \"${ipaddress}\"\"",
  }

}
