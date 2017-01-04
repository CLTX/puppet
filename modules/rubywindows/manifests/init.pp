class rubywindows()
{
$apSource = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Ruby\\rubyinstaller-1.9.3-p545.exe"
$pathRuby = 'c:\Ruby'

exec{"Installing Ruby":
    command => "$apSource /VERYSILENT /NORESTART /DIR=\"C:\Ruby\"",
	unless  => "cmd.exe /c \"powershell.exe -Command \"if (test-path \\\"${pathRuby}\\bin\\ruby.exe\\\" -erroraction silentlycontinue) { exit 0} else {exit 1}\"\"",
  }

windows_env { 'Ruby':
  variable  => 'PATH',
  value     => "${pathRuby}\\bin",
  mergemode => insert
}
}