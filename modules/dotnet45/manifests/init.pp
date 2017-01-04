class dotnet45() {

  exec{'Install .NET 4.5':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\dotNet\\dotNetFx45_Full_setup.exe /q /norestart",
    timeout => 0,
	  unless  => "powershell.exe -ExecutionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\check_dotnet45.ps1"
  }
}
