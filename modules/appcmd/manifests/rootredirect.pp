define appcmd::rootreappname03 (
  $siteName,
  $reappname03Path
) {
 
include appcmd 

exec { "appcmdRootReappname03 ${siteName}":
	command => "appcmd set config \"${siteName}\" /section:system.webServer/rewrite/rules /+[name='RootReappname03',stopProcessing='True']",
	unless  => "powershell -executionPolicy Bypass  -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\rootreappname03.ps1 ${siteName}"
}

exec { "appcmdRootReappname03Config ${siteName}":
	command => "appcmd set config \"${siteName}\" /section:system.webServer/rewrite/rules /[name='RootReappname03',stopProcessing='True'].match.url:\"^$\" /[name='RootReappname03',stopProcessing='True'].action.type:\"Reappname03\" /[name='RootReappname03',stopProcessing='True'].action.url:\"${reappname03Path}\" /[name='RootReappname03',stopProcessing='True'].action.reappname03Type:\"Found\"",
	unless  => "powershell -executionPolicy Bypass  -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\rootreappname03config.ps1 ${siteName}",
	require => Exec["appcmdRootReappname03 ${siteName}"]
}

}
