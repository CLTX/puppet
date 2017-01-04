class dfs::deploying_DFS()
{


include dfs

	exec 	{ 
		"Verify File-Services":
			command => "powershell.exe -executionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\Role_install.ps1 File-Services",
			}

	exec 	{ 
			"Verify FS-DFS":
				command => "powershell.exe -executionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\Role_install.ps1 FS-DFS",
			}
			
	exec 	{ 
			"Verify FS-Resource-Manager":
				command => "powershell.exe -executionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\Role_install.ps1 FS-Resource-Manager",
			}

	exec 	{ 
			"Verify FS-NFS-Services":
				command => "powershell.exe -executionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\Role_install.ps1 FS-NFS-Services",
			}

	exec 	{ 
			"Verify FS-Search-Service":
				command => "powershell.exe -executionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\Role_install.ps1 FS-Search-Service",
			}

}      
