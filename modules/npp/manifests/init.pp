class npp()
{

$nppinstallversion = '6.69'

if $nppversion != $nppinstallversion {
  exec {'kill-notepad++':
    command => "powershell.exe -ExecutionPolicy ByPass -Command \"stop-process -processname notepad++ -erroraction silentlycontinue -Force\"",
    onlyif => "cmd.exe /C \"tasklist | find.exe \"notepad++.exe\"\""
  }
}

if $nppversion != $nppinstallversion {
  exec{'install-npp':
    command => "cmd.exe /c start \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Notepad++\\npp.6.6.9.Installer.exe /S",
	require => Exec['kill-notepad++'],
  }
}

}