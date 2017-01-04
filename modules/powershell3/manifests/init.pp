class powershell3()
{

exec{'install-wmf3':
  command => "cmd.exe /c start \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\WMF3\\Windows6.1-KB2506143-x64.msu /quiet /norestart",
  unless  => "cmd.exe /c \"powershell.exe -command \"if(\$PSVersiontable.PSVersion.Major -eq 3) {exit 0} else {exit 1}\"\""
  }
}
