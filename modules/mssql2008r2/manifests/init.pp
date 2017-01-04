class mssql2008r2 (
  # See http://msdn.microsoft.com/en-us/library/ms144259.aspx
  $media          = '\\csilfs01\apps\Microsoft_SQL_Dev_2008_R2',
  $instancename   = 'MSSQLSERVER',
  $features       = 'AS,RS,IS,Tools',
  $agtsvcaccount  = 'SQLAGTSVC',
  $agtsvcpassword = 'sqlagtsvc2008demo',
  $assvcaccount   = 'SQLASSVC',
  $assvcpassword  = 'sqlassvc2008demo',
  $rssvcaccount   = 'SQLRSSVC',
  $rssvcpassword  = 'sqlrssvc2008demo',
  $sqlsvcaccount  = 'SQLSVC',
  $sqlsvcpassword = 'sqlsvc2008demo',
  $instancedir    = "c:\\Program Files\\Microsoft SQL Server",
  $ascollation    = 'Latin1_General_CI_AS',
  $sqlcollation   = 'SQL_Latin1_General_CI_AS',
  $admin          = 'Administrator'
) {

  User {
    ensure   => present,
    before => Exec['install_mssql2008'],
  }

  user { 'SQLAGTSVC':
    comment  => 'SQL 2008 Agent Service.',
    password => $agtsvcpassword,
  }
  user { 'SQLASSVC':
    comment  => 'SQL 2008 Analysis Service.',
    password => $assvcpassword,
  }
  user { 'SQLRSSVC':
    comment  => 'SQL 2008 Report Service.',
    password => $rssvcpassword,
  }
  user { 'SQLSVC':
    comment  => 'SQL 2008 Service.',
    groups   => 'Administrators',
    password => $sqlsvcpassword,
  }

  file { 'C:\sql2008install.ini':
    content => template('mssql2008r2/config.ini.erb'),
  }

  dism { 'NetFx3':
    ensure => present,
  }

  exec { 'install_mssql2008':
    command   => "${media}\\setup.exe /Action=Install /IACCEPTSQLSERVERLICENSETERMS /QS /CONFIGURATIONFILE=C:\\sql2008install.ini /SQLSVCPASSWORD=\"${sqlsvcpassword}\" /AGTSVCPASSWORD=\"${agtsvcpassword}\" /ASSVCPASSWORD=\"${assvcpassword}\" /RSSVCPASSWORD=\"${rssvcpassword}\"",
    cwd       => $media,
    path      => $media,
    logoutput => true,
    creates   => $instancedir,
    timeout   => 1500,
    require   => [ File['C:\sql2008install.ini'],
                   Dism['NetFx3'] ],
  }
}
