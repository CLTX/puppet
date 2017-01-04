define sslcerts::run(
	$siteName,
	$pathSite,
	$hostHeaderValue = '',
	$pfxFile = nil
){

include appcmd
include netsh

$passphrase  = 'b33dr1l'
$CertUtil = "C:\\Windows\\System32\\certutil.exe"

if $pfxFile == "STAR_securestudies_com.pfx" {
	if $star_securestudies_ssl_match != 0
	{
		exec { "deleteOldCert star_securestudies_com to ${siteName}":	
			command => "${CertUtil} -delstore My *.securestudies.com",
		}
	
		exec { "importNewCert star_securestudies_com to ${siteName}":
			command => "${CertUtil} -p ${passphrase} -importPFX \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\ssl\\STAR_securestudies_com.pfx",
			require => Exec["deleteOldCert star_securestudies_com to ${siteName}"]
		}
		
		netsh::deletesslcert { "DeleteCert to ${siteName}": 
			  ipPort   => "0.0.0.0",
			  siteName => "${siteName}",
			  require  => Exec["importNewCert star_securestudies_com to ${siteName}"]
		}
		
		netsh::addsslcert { "AddCert to ${siteName}": 
		  ipPort   => "0.0.0.0",
		  certHash => "${star_securestudies_ssl_match}",
		  appID    => "ab3c58f7-8316-42e3-bc6e-771d4ce4b201",
		  require  => Netsh::Deletesslcert["DeleteCert to ${siteName}"]
		}
	}
}
elsif $pfxFile == "STAR_voicefive_com.pfx" {
	if $star_voicefive_ssl_match != 0
	{
		exec { "deleteOldCert STAR_voicefive_com to ${siteName}":	
			command => "${CertUtil} -delstore My *.voicefive.com",
		}
	
		exec { "importNewCert STAR_voicefive_com to ${siteName}":
			command => "${CertUtil} -p ${passphrase} -importPFX \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\ssl\\STAR_voicefive_com.pfx",
			require => Exec["deleteOldCert STAR_voicefive_com to ${siteName}"]
		}
		
		netsh::deletesslcert { "DeleteCert to ${siteName}": 
			  ipPort   => "0.0.0.0",
			  siteName => "${siteName}",
			  require  => Exec["importNewCert STAR_voicefive_com to ${siteName}"]
		}
		
		netsh::addsslcert { "AddCert to ${siteName}": 
		  ipPort   => "0.0.0.0",
		  certHash => "${star_voicefive_ssl_match}",
		  appID    => "ab3c58f7-8316-42e3-bc6e-771d4ce4b201",
		  require  => Netsh::Deletesslcert["DeleteCert to ${siteName}"]
		}
	}
}
elsif $pfxFile == "STAR_appname05-poll_com.pfx" {
	if $star_appname05_poll_ssl_match != 0
	{
		exec { "deleteOldCert STAR_appname05-poll_com to ${siteName}":	
			command => "${CertUtil} -delstore My *.appname05-poll.com",
		}
	
		exec { "importNewCert STAR_appname05-poll_com to ${siteName}":
			command => "${CertUtil} -p ${passphrase} -importPFX \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\ssl\\STAR_appname05-poll_com.pfx",
			require => Exec["deleteOldCert STAR_appname05-poll_com to ${siteName}"]
		}
		
		netsh::deletesslcert { "DeleteCert to ${siteName}": 
			  ipPort   => "0.0.0.0",
			  siteName => "${siteName}",
			  require  => Exec["importNewCert STAR_appname05-poll_com to ${siteName}"]
		}
		
		netsh::addsslcert { "AddCert to ${siteName}": 
		  ipPort   => "0.0.0.0",
		  certHash => "${star_appname05_poll_ssl_match}",
		  appID    => "ab3c58f7-8316-42e3-bc6e-771d4ce4b201",
		  require  => Netsh::Deletesslcert["DeleteCert to ${siteName}"]
		}
	}
}
else {
	if $machine_env == "PRD" {
		if $star_mycompany_ssl_match != 0
		{
			exec { "deleteOldCert star_mycompany_com to ${siteName}":	
				command => "${CertUtil} -delstore My *.mycompany.com",
			}
		
			exec { "importNewCert star_mycompany_com to ${siteName}":
				command => "${CertUtil} -p ${passphrase} -importPFX \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\ssl\\STAR_mycompany_com.pfx",
				require => Exec["deleteOldCert star_mycompany_com to ${siteName}"]
			}
			
			netsh::deletesslcert { "DeleteCert to ${siteName}": 
			  ipPort   => "0.0.0.0",
			  siteName => "${siteName}",
			  require  => Exec["importNewCert star_mycompany_com to ${siteName}"]
			}
			
			netsh::addsslcert { "AddCert to ${siteName}": 
			  ipPort   => "0.0.0.0",
			  certHash => "${star_mycompany_ssl_match}",
			  appID    => "ab3c58f7-8316-42e3-bc6e-771d4ce4b201",
			  require  => Netsh::Deletesslcert["DeleteCert to ${siteName}"]
			}
		}
	} else {
		if $star_mydomain_mycompany_ssl_match != 0 {
			exec { "deleteOldCert star_mydomain_mycompany_com to ${siteName}":	
				command => "${CertUtil} -delstore My *.mydomain.mycompany.com",
			}
		
			exec { "importNewCert star_mydomain_mycompany_com to ${siteName}":
				command => "${CertUtil} -p ${passphrase} -importPFX \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\ssl\\STAR_mydomain_mycompany_com.pfx",
				require => Exec["deleteOldCert star_mydomain_mycompany_com to ${siteName}"]
			}
			
			netsh::deletesslcert { "DeleteCertmydomain to ${siteName}": 
			  ipPort   => "0.0.0.0",
			  siteName => "${siteName}",
			  require  => Exec["importNewCert star_mydomain_mycompany_com to ${siteName}"]
			}
			
			netsh::addsslcert { "AddCertmydomain to ${siteName}": 
			  ipPort   => "0.0.0.0",
			  certHash => "${star_mydomain_mycompany_ssl_match}",
			  appID    => "ab3c58f7-8316-42e3-bc6e-771d4ce4b201",
			  require  => Netsh::Deletesslcert["DeleteCertmydomain to ${siteName}"]
			}
		}
	}
}

	appcmd::binding { "Bindings HTTPS for ${siteName}":
	  site            => "${siteName}",
	  port            => "443",
	  hostHeaderValue => $hostHeaderValue,
	}

}
