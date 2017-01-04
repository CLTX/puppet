class authmodule () {

require dotnet_451

$authinstallerPath = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\mycompany\\Platform\\SSO\\Release\\mycompany SingleSignOn - Release.msi"

  package {"mycompany SingleSignOn - Release":
	ensure => present, 
	source => "${authinstallerPath}",
  }
  #remove isapi csauth
  exec { "Removing ISAPI csauth old":
    command => "cmd.exe /C \"appcmd.exe set config /section:isapiCgiRestriction /-[path=\'D:\mycompany\webpub\isapi\csauth-x64.dll\',description=\'csauth\',allowed=\'True\']\"",
    unless  => "cmd.exe /C \"appcmd.exe list config /section:isapiCgiRestriction | find.exe \"D:\\mycompany\\webpub\\isapi\\csauth-x64.dll\" | find.exe \"description=\"\"csauth\"\"\" \"",
  }

}
