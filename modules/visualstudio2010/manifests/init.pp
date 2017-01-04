class visualstudio2010 () {

$pathVS2010 = '\\yourdomain.mycompany.com\installers\Shared-Apps\Microsoft\Visual_Studio\Visual_Studio_2010'

  exec{'Install MS Visual Studio 2010':
    command => "${pathVS2010}\\setup\\setup.exe /q /full /norestart",
	unless  => "cmd.exe /c \"reg.exe query  \"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\10.0\Setup\VS\Pro\" | findstr.exe /I \"Visual Studio 10.0\"\"",
	timeout => 0,
  }
}