class iiswebserver::windowsfeatures{

dism { 'IIS-WebServerRole':
      ensure => present,
    }

dism { 'IIS-WebServer':
      ensure => present,
    }

dism { 'IIS-ApplicationDevelopment':
      ensure => present,
    }

dism { 'IIS-DefaultDocument':
      ensure => present,
    }
	
dism { 'IIS-Performance':
      ensure => present,
    }

dism { 'IIS-ISAPIFilter':
      ensure => present,
    }

dism { 'IIS-ISAPIExtensions':
      ensure => present,
    }

dism { 'IIS-RequestFiltering':
      ensure => present,
    }

dism { 'IIS-NetFxExtensibility':
      ensure => present,
    }

dism { 'IIS-ASPNET':
      ensure => present,
    }

dism { 'IIS-ASP':
      ensure => present,
    }

dism { 'IIS-BasicAuthentication':
      ensure => present,
    }
	
dism { 'IIS-DigestAuthentication':
      ensure => present,
    }

dism { 'IIS-CGI':
      ensure => present,
    }

dism { 'IIS-CommonHttpFeatures':
      ensure => present,
    }

dism { 'IIS-WindowsAuthentication':
      ensure => present,
    }

dism { 'IIS-IIS6ManagementCompatibility' :
        ensure => present
}

dism { 'IIS-ManagementScriptingTools' :
        ensure => present
}

dism { 'IIS-WMICompatibility' :
        ensure => present
}

dism { 'IIS-Metabase' :
        ensure => present
}

dism { 'NetFx3':
      ensure => present,
    }
	
dism { 'IIS-ClientCertificateMappingAuthentication':
      ensure => present,
    }

dism { 'IIS-IISCertificateMappingAuthentication':
      ensure => present,
    }

dism { 'IIS-ServerSideIncludes':
      ensure => present,
    }	
	
dism { 'IIS-ManagementService':
      ensure => present,
    }	
	
dism { 'IIS-ODBCLogging':
      ensure => present,
    }	
	
dism { 'IIS-HttpLogging':
      ensure => present,
    }	
	
dism { 'IIS-HttpReappname03':
      ensure => present,
    }	
	
dism { 'IIS-HttpErrors':
      ensure => present,
    }	
	
dism { 'IIS-appname03oryBrowsing':
      ensure => present,
    }	
	
dism { 'IIS-RequestMonitor':
      ensure => present,
    }	
	
dism { 'IIS-HttpTracing':
      ensure => present,
    }	
	
dism { 'IIS-CustomLogging':
      ensure => present,
    }	
	
dism { 'IIS-StaticContent':
      ensure => present,
    }	
	
dism { 'IIS-LoggingLibraries':
      ensure => present,
    }	
	
dism { 'IIS-HttpCompressionStatic':
      ensure => present,
    }	
	
dism { 'IIS-HttpCompressionDynamic':
      ensure => present,
    }	
	
dism { 'IIS-WebServerManagementTools':
      ensure => present,
    }	
	
dism { 'IIS-URLAuthorization':
      ensure => present,
    }	

dism { 'IIS-IPSecurity':
      ensure => present,
    }		

Dism['IIS-WebServerRole'] -> Dism['IIS-WebServer'] -> Dism['IIS-ApplicationDevelopment'] -> Dism['IIS-Performance'] -> Dism['IIS-DefaultDocument'] -> Dism['IIS-ISAPIFilter'] -> Dism['IIS-ISAPIExtensions'] -> Dism['IIS-RequestFiltering'] -> Dism['IIS-NetFxExtensibility'] -> Dism['IIS-ASPNET'] -> Dism['IIS-ASP'] -> Dism['IIS-BasicAuthentication'] -> Dism['IIS-DigestAuthentication'] -> Dism['IIS-CGI'] -> Dism['IIS-CommonHttpFeatures'] -> Dism['IIS-HttpReappname03'] -> Dism['IIS-WindowsAuthentication'] -> Dism['NetFx3'] -> Dism['IIS-StaticContent'] -> Dism['IIS-HttpCompressionStatic'] -> Dism['IIS-HttpLogging'] -> Dism['IIS-ManagementService'] -> Dism['IIS-ODBCLogging'] -> Dism['IIS-HttpCompressionDynamic'] -> Dism['IIS-ClientCertificateMappingAuthentication'] -> Dism['IIS-IISCertificateMappingAuthentication'] -> Dism['IIS-ServerSideIncludes'] -> Dism['IIS-WebServerManagementTools'] -> Dism['IIS-IIS6ManagementCompatibility'] -> Dism['IIS-ManagementScriptingTools'] -> Dism['IIS-WMICompatibility']-> Dism['IIS-Metabase']  -> Dism['IIS-IPSecurity'] -> Dism['IIS-URLAuthorization']

}
