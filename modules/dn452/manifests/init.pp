class dn452()
{

  exec{'Install .NET 4.5.2':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\dotNet\\Dotnet452-Full_x86-x64.exe /q /norestart",
    timeout => 0,
	unless  => "powershell.exe -ExecutionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\check_dotnet452.ps1"
  }
}
