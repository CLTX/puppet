class smtpwinserver()
{

  exec{'Install SMTP Server':
    command => "ServerManagerCmd.exe -install \"SMTP-Server\"",
    unless  => "cmd.exe /c \"powershell.exe -ExecutionPolicy bypass -Command \"get-service | where-object {\$_.Name -eq \'SMTPSVC\'}\" | findstr.exe \"SMTPSVC\"\""
  }

  service { "SMTPSVC":
    ensure => 'running',
    enable => true,
    require => Exec['Install SMTP Server']
  }
}
