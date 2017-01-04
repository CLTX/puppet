class puppetwindowsconf () {

include userwindows
include schedtasks

$latestpuppetversion = '3.0.2'
$puppetmsipath = '\\yourdomain.mycompany.com\installers\Shared-Apps\Puppet-Labs\puppet-3.0.2.msi' 
$puppetmaster  = 'pvusappm01.mydomain.mycompany.com'
$run_random = fqdn_rand(15) + 15
$users = hiera_array('adminusers')
$atlassianusers = hiera_array('atlassianadmusers')
$noadmusers = hiera_array('noadminusers')
$group1  = hiera('localgroup')

$atlassian_admins = split(inline_template("<%= (atlassianusers).join(',') %>"),',')
$all_admins = split(inline_template("<%= (users).join(',') %>"),',')
$removeusers = split(inline_template("<%= (noadmusers).join(',') %>"),',')

if $machine_app == "Atlassian" {
  puppetwindowsconf::admins{$atlassian_admins:
      pgroup  => $group1
    }
  
  puppetwindowsconf::noadmins{$removeusers:
      pgroup  => $group1
    }
} else {
  puppetwindowsconf::admins{$all_admins:
      pgroup  => $group1
    }
}

if $unitypresent == 'true' {
  exec { 'Moving unity.dll to C:\Temp':
   command => "cmd.exe /C \"move \"C:\\Program Files\\VMware\\VMware Tools\\plugins\\vmusr\\unity.dll\" C:\\temp\\.\"",
  }
  
  exec { 'Restarting VMTools Service':
    command => "cmd.exe /C \"net stop VMTools && net start VMTools\"",
    require => Exec['Moving unity.dll to C:\Temp'],
  }
}
  
if $puppetversion != "${latestpuppetversion}" {
exec { "Upgrading to puppet agent version ${latestpuppetversion}":
  command => "cmd.exe /C \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Puppet-Labs\\puppet-upgrade.bat ${puppetmsipath}\"", 
}
}

  schedtasks::end { 'Kill job':
    tn => "Microsoft\\Windows\\Defrag\\ScheduledDefrag"
  }

  schedtasks::changestatus { "DISABLE":
    tn => "Microsoft\\Windows\\Defrag\\ScheduledDefrag",
	require => Schedtasks::End['Kill job']
  }
  
  service { 'defragsvc':
    ensure => 'stopped',
    enable => 'false',
    require => Schedtasks::Changestatus["DISABLE"]
  }

  package {"Puppet":
	ensure          => present, 
	source          => "${puppetmsipath}",
    install_options => {
      "PUPPET_MASTER_SERVER" => "${puppetmaster}",
      },
  }

  service { 'puppet':
    name => 'puppet',
    ensure => 'stopped',
    enable => 'manual',
	require => Package["Puppet"],
  } 
 
  file { 'C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf':
    ensure => 'file',
    content => template("puppetwindowsconf/puppet.conf"),
  }

  file { 'C:\kickstart':
    ensure => 'absent',
	recurse => true,
	force => true
  }
  
  if $machine_env == 'INT' {
		exec { 'Puppet Agent Task Create':
		command => "cmd.exe /C schtasks /create /tn \"Puppet Agent\" /xml \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Puppet-Labs\\development\\PuppetAgentTask.xml\"",
		unless  => "cmd.exe /c \"schtasks /Query /tn \"Puppet Agent\" /xml | find.exe \"2012-09-24T10:41:20.3327822\"\"",
		require => Service['puppet'],
	  }
  }
  elsif $machine_env == 'TST' {
	exec { 'Puppet Agent Task Create':
		command => "cmd.exe /C schtasks /create /tn \"Puppet Agent\" /xml \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Puppet-Labs\\test\\PuppetAgentTask.xml\"",
		unless  => "cmd.exe /c \"schtasks /Query /tn \"Puppet Agent\" /xml | find.exe \"2012-09-24T10:41:20.3327822\"\"",
		require => Service['puppet'],
	}
  }
  elsif $machine_env == 'STAG' {
	exec { 'Puppet Agent Task Create':
		command => "cmd.exe /C schtasks /create /tn \"Puppet Agent\" /xml \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Puppet-Labs\\stage\\PuppetAgentTask.xml\"",
		unless  => "cmd.exe /c \"schtasks /Query /tn \"Puppet Agent\" /xml | find.exe \"2012-09-24T10:41:20.3327822\"\"",
		require => Service['puppet'],
	}
  }
  elsif $machine_env == 'PRD' {
	exec { 'Puppet Agent Task Create':
		command => "cmd.exe /C schtasks /create /tn \"Puppet Agent\" /xml \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Puppet-Labs\\production\\PuppetAgentTask.xml\"",
		unless  => "cmd.exe /c \"schtasks /Query /tn \"Puppet Agent\" /xml | find.exe \"2012-09-24T10:41:20.3327822\"\"",
		require => Service['puppet'],
	}
  }
  else {
	exec { 'Puppet Agent Task Create':
		command => "cmd.exe /C schtasks /create /tn \"Puppet Agent\" /xml \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Puppet-Labs\\development\\PuppetAgentTask.xml\"",
		unless  => "cmd.exe /c \"schtasks /Query /tn \"Puppet Agent\" /xml | find.exe \"2012-09-24T10:41:20.3327822\"\"",
		require => Service['puppet'],
	}
  }

  exec { 'Puppet Agent Task':
    command => "cmd.exe /C schtasks /change /tn \"Puppet Agent\" /RI ${run_random} /RU \"yourdomain\\cspatchuser\" /RP \"Ba11ParK\"",
	unless  => "cmd.exe /c \"schtasks /Query /tn \"Puppet Agent\" /v /FO LIST | find.exe \"Repeat: Every:\" | find.exe \"0 Hour(s), 15 Minute(s)\"\"",
	require => Exec['Puppet Agent Task Create'],
	}
	
  exec { 'Puppet Agent Task Enabler':
    command => "cmd.exe /C schtasks /change /tn \"Puppet Agent\" /ENABLE /RU \"yourdomain\\cspatchuser\" /RP \"Ba11ParK\"",
	onlyif  => "cmd.exe /c \"schtasks /Query /tn \"Puppet Agent\" /v /FO LIST | find.exe \"Next Run Time:\" | find.exe \"Disabled\"\"",
	require => Exec['Puppet Agent Task'],
	}
	
  schedtasks::create {'Check for puppet lock file':
    ruUsername  => 'yourdomain\daebuilduser',
    rpPassword  => 'yourpassword',
    scFrequency => 'DAILY',
    tn          => 'Check if file lock exist without puppet agent running',
    tr          => "powershell.exe -ExecutionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\checkpuppetlock.ps1",
    stTime      => '02:00',
    rl          => 'HIGHEST',
	require     => package["Puppet"],
  }
  
  if $machine_env == "PRD" {
    schedtasks::create {"Puppet on startup":
      ruUsername  => "yourdomain\\cspatchuser",
      rpPassword  => "Ba11ParK",
      scFrequency => "ONSTART",
      tn          => "Puppet on startup",
      tr          => "C:\\windows\\system32\\cmd.exe /C \"\"\"puppet agent --test --logdest=C:\\PuppetLogs\\%date:~-4,4%%date:~-7,2%%date:~-10,2%-log.txt \"\"\"",
      rl          => "HIGHEST",
	  require     => Package["Puppet"],
    }
  } else {
    case $machine_env {
	"INT" : {
              schedtasks::create {"Puppet on startup":
                ruUsername  => "yourdomain\\cspatchuser",
                rpPassword  => "Ba11ParK",
                scFrequency => "ONSTART",
                tn          => 'Puppet on startup',
                tr          => "C:\\windows\\system32\\cmd.exe /C \"\"\"puppet agent --test --environment=development --logdest=C:\\PuppetLogs\\%date:~-4,4%%date:~-7,2%%date:~-10,2%-log.txt\"\"\"",
                rl          => "HIGHEST",
	            require     => Package["Puppet"],
              }
	        }
    "TST" : {
	          schedtasks::create {"Puppet on startup":
                ruUsername  => "yourdomain\\cspatchuser",
                rpPassword  => "Ba11ParK",
                scFrequency => "ONSTART",
                tn          => "Puppet on startup",
                tr          => "C:\\windows\\system32\\cmd.exe /C \"\"\"puppet agent --test --environment=test --logdest=C:\\PuppetLogs\\%date:~-4,4%%date:~-7,2%%date:~-10,2%-log.txt\"\"\"",
                rl          => "HIGHEST",
	            require     => Package["Puppet"],
              }
	        }
	"STAG": {
		      schedtasks::create {"Puppet on startup":
                ruUsername  => "yourdomain\\cspatchuser",
                rpPassword  => "Ba11ParK",
                scFrequency => "ONSTART",
                tn          => "Puppet on startup",
                tr          => "C:\\windows\\system32\\cmd.exe /C \"\"\"puppet agent --test --environment=stage --logdest=C:\\PuppetLogs\\%date:~-4,4%%date:~-7,2%%date:~-10,2%-log.txt \"\"\"",
                rl          => "HIGHEST",
	            require     => Package["Puppet"],
              }
	        }
    }
  }
  
}
