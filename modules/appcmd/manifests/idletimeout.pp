define appcmd::idletimeout (
	$apppool,
	$idletimeout  #format hh:mm:ss  ---> to set on 0 write 00:00:00
	
) {
	include appcmd
	
  exec { "${apppool} set to ${idletimeout}":
    command => "appcmd.exe set apppool \"${apppool}\" /processModel.idleTimeout:${idletimeout}",
	  unless  => "powershell -executionPolicy Bypass  -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\checkidletimeout.ps1 ${apppool} ${idletimeout}"
  }

}
