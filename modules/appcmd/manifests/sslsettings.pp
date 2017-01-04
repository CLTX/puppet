define appcmd::sslsettings (
  $siteName
){

include appcmd 

exec { "appcmdReappname03ToHTTPS ${siteName}":
	command => "appcmd.exe set config \"${siteName}\" /section:system.webServer/rewrite/rules /+[name='Reappname03ToHTTPS',stopProcessing='True'] /commit:APPHOST",
	unless  => "powershell.exe -executionPolicy Bypass  -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\reappname03tohttps.ps1 \"${siteName}\""
}

exec { "appcmdReappname03ToHTTPSConfig ${siteName}":
	command => "appcmd.exe set config \"${siteName}\" /section:system.webServer/rewrite/rules /[name='Reappname03ToHTTPS',stopProcessing='True'].match.url:\"(.*)\" /+\"[name='Reappname03ToHTTPS',stopProcessing='True'].conditions.[input='{HTTPS}',pattern='^OFF$']\" /[name='Reappname03ToHTTPS',stopProcessing='True'].action.type:\"Reappname03\" /[name='Reappname03ToHTTPS',stopProcessing='True'].action.url:\"https://{HTTP_HOST}/{R:1}\" /[name='Reappname03ToHTTPS',stopProcessing='True'].action.reappname03Type:\"Permanent\" /commit:APPHOST",
	unless  => "powershell.exe -executionPolicy Bypass  -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\reappname03tohttpsconfig.ps1 \"${siteName}\"",
	require => Exec["appcmdReappname03ToHTTPS ${siteName}"]
}


}
