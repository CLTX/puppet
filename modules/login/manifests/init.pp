class login () {

	require iiswebserver::iissetup
	include perlwindows
		
	include login::config
	
}
