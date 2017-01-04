class keysdaebuilder()
{

  scheduled_task { 'Set daebuilduser SSH GIT environments':
    ensure    => present,
    enabled   => true,
	user      => "yourdomain\daebuilduser",
	password  => "yourpassword",
    command   => '\\yourdomain.mycompany.com\installers\Shared-Apps\Git\sshkeys.bat',
    arguments => '',
    trigger   => {
      schedule   => daily,
      every      => 1,            # Defaults to 1
      start_date => "$today", # Defaults to 'today' format YYYY-MM-DD
      start_time => '08:00',      # Must be specified
    }
  }
  
  exec { "Execute ST":
    command => "schtasks /Run /TN \"Set daebuilduser SSH GIT environments\" ",
	onlyif  => "cmd.exe /c if exist \"C:\\Users\\daebuilduser\\.ssh\" (EXIT /B 1) ELSE (EXIT /B 0)",
	require => Scheduled_task['Set daebuilduser SSH GIT environments']
  }
  
  file { 'C:\.ssh':
    ensure  => absent,
	force   => true,
	recurse => true,
	require => Exec['Execute ST']
  }
}
