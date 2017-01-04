class dotcover () {

$dotcoverInstallerPath = '\\yourdomain.mycompany.com\installers\Shared-Apps\dotcover\dotCoverSetup.2.6.608.466.msi'
$dotcoverExecPath = 'C:\Program Files (x86)\JetBrains\dotCover\v2.6\Bin'

  package {"JetBrains dotCover 2.6":
	ensure          => present, 
	source          => "${dotcoverInstallerPath}",
    install_options => {
		"LicenseAccepted" => "1"
    }
  }
  
  exec{'Adding dotCover path to System variable Path':
    command => "powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\add-path-dotcover.ps1",
    unless  => "cmd.exe /c \"reg.exe query  \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v Path /s | findstr.exe /i \"dotcover\"\"",
  }
}