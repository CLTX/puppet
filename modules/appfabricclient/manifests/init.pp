class appfabricclient() {

$pathScript = "\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell"

	exec {'Install-AppFabric' :
			command => "powershell.exe -ExecutionPolicy bypass -File ${pathScript}\\Install-AppFabric.ps1",
			timeout => 500,
	}
	
}
