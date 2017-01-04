class serverdb () {

	require iiswebserver::iissetup
		
	include serverdb::config
	
}
