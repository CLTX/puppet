class dotnet_451() {

  exec{'Install .NET 4.5.1':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\dotNet\\Dotnet451-Full-x86-x64.exe /q /norestart",
    timeout => 0,
	  unless  => "powershell.exe -ExecutionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\check_dotnet451.ps1"
  }
}
