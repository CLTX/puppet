class confirmit::machineconfig () {
if $machine_env == 'PRD' {
  if $machine_app == 'Confirmit' and $machine_role == 'Application And Services'
  {
    file { 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config':
      ensure  => 'file',
	  content => template('confirmit/pfa/PFA.v2.x86.machine.config')
    }
  
    file { 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config':
      ensure  => 'file',
	  content => template('confirmit/pfa/PFA.v2.x64.machine.config')
    }

    file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
      ensure  => 'file',
      content => template('confirmit/pfa/PFA.v4.x64.machine.config')
    }
			
    file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
      ensure  => 'file',
	  backup  => 'false',
      content => template('confirmit/pfa/PFA.v4.x86.machine.config')
    }
  }

  if $machine_app == 'Confirmit' and $machine_role == 'Web'
  {
    file { 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config':
      ensure  => 'file',
      content => template('confirmit/pfw/PFW.v2.x86.machine.config')
    }
  
    file { 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config':
      ensure  => 'file',
      content => template('confirmit/pfw/PFW.v2.x64.machine.config')
    }

    file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
      ensure  => 'file',
      content => template('confirmit/pfw/PFW.v4.x64.machine.config')
    }
			
    file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
      ensure  => 'file',
      content => template('confirmit/pfw/PFW.v4.x86.machine.config')
    }
  }
}

if $hostname == 'pvusaTFD01' or $hostname == 'pvusaDBA01' 
  {
    file { 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config':
    ensure  => 'file',
    content => template('confirmit/tfd/tfd.v2.x86.machine.config')
    }

    file { 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config':
    ensure  => 'file',
    content => template('confirmit/tfd/tfd.v2.x64.machine.config')
    }

    file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
    ensure  => 'file',
    content => template('confirmit/tfd/tfd.v4.x64.machine.config')
    }

    file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
    ensure  => 'file',
    content => template('confirmit/tfd/tfd.v4.x86.machine.config')
    }
	
	exec{'Copy chrome.browser file':
      command => "cmd.exe /c \"copy C:\Windows\Microsoft.NET\Framework\v4.0.30319\Config\Browsers\chrome.browser C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\.\"",
      unless  => "powershell.exe -ExecutionPolicy ByPass -command \"if (Test-Path -path \'C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\chrome.browser\') { exit 0;}  else { exit 1; }\"",
    }
		
	exec{'Backup mozilla.browser file':
      command => "cmd.exe /c \"copy C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\mozilla.browser C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\mozilla.browser.BAK \"",
      unless  => "powershell.exe -ExecutionPolicy ByPass -command \"if (Test-Path -path \'C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\mozilla.browser.BAK\') { exit 0;}  else { exit 1; }\"",
    }
	
	file { 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\mozilla.browser':
      ensure  => 'file',
      content => template('confirmit/tfd/mozilla.browser'),
	  require => Exec['Backup mozilla.browser file']
    }
	
	file { 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\webkit.browser':
      ensure  => 'file',
      content => template('confirmit/tfd/webkit.browser'),
	  require => Exec['Backup mozilla.browser file']
    }
	
	exec {"Registering mozilla.browser":
      command    => "C:\Windows\Microsoft.NET\Framework\v2.0.50727\aspnet_regbrowsers.exe -i",
	  subscribe  => File['C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\mozilla.browser'],
      refreshonly => true,
    }
  }
}
