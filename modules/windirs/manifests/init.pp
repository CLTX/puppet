class windirs (){

file {'C:\installs':
        ensure => appname03ory,
    }

file {'C:\Powershell-Scripts':
         ensure => appname03ory,
    }
		
file {'C:\Powershell-Scripts\Apps':
	      ensure => appname03ory,
    }

file {'C:\Powershell-Scripts\scripts':
	   ensure => appname03ory,
	}
}
