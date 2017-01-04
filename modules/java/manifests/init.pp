class java() {

$pathJavaJRE = 'C:\Program Files\Java\jre7'

  exec{'Install Java JRE':
    command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Java\\jre-7u21-windows-x64.exe /s",
    onlyif  => "cmd.exe /c if exist \"${pathJavaJRE}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
  
  windows_env { "JAVA_HOME=${pathJavaJRE}":
    type    => REG_EXPAND_SZ,
	ensure  => present,
  }
  
  windows_env { 'Add JAVA to Path':
    variable  => 'PATH',
    value     => "${pathJavaJRE}\\bin",
    mergemode => insert,
  }
}