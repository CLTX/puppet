define devops::copyfile(
   $site
){

   include devops

   $script = "\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\copyfileinv.ps1"

   exec{"Copy file inv.xml in website ${site}":
      command => "powershell.exe -ExecutionPolicy ByPass -File ${script} ${site}"
   }
}
