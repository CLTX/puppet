class scriptcerts (){

if $appfabric_installed != true {
exec{'install-certificates':
	command => 'cmd.exe /c \\pvusatst02\installshares\AutomationScripts\Certificate\ps_publisher_cert.cer',
	path	=> 'C:\\windows\\system32\\'
	}		
}


}

