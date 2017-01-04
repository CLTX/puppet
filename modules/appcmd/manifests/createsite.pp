define appcmd::createsite (
  $siteName,
  $physicalPath,
  $bindings = 'http/*:80:',
  $apppool = undef,
  $document = 'default.aspx',
  $userName = "yourdomain\daewebuser",
  $password = "yourpassword"
) {
 
include appcmd 
include robocopy
include folderpermission
require iiswebserver::iissetup
include akamaisureroute

$nagiosPath = "D:\\mycompany\\web-applications\\nagios\\"

exec { "Checking to Create Physical Path for ${siteName}" :
  command => "powershell.exe -ExecutionPolicy ByPass -command \"New-Item -Type appname03ory ${physicalPath}\"",
  timeout => 0,
  onlyif => "powershell.exe -ExecutionPolicy ByPass -command \"if (Test-Path ${physicalPath}) { exit 1;}  else { exit 0; }\""
}

exec { "appcmdCreateSite ${siteName}":
  command => "appcmd.exe add site /name:$siteName /physicalPath:$physicalPath /bindings:$bindings",
  unless => "cmd.exe /c \"appcmd.exe list site | find.exe \"SITE \"\"${siteName}\"\"\" \""
}

exec { "set user for ${siteName}":
  command => "appcmd.exe set site \"$siteName\" -virtualappname03oryDefaults.userName:\"${userName}\" -virtualappname03oryDefaults.password:${password} ",
  unless  => "cmd.exe /c \"appcmd.exe list vdir /UserName:$=\"$userName\" /PhysicalPath:$=\"$physicalPath\" /XML | appcmd.exe list site /IN | find.exe \"$siteName\"\"",
  require => Exec["appcmdCreateSite ${siteName}"],
}

if $siteName != "my.securestudies.com" {
  file { "$physicalPath\\favicon.ico":
    ensure => file,
    owner  => "Everyone",
    content => template("appcmd/favicon.ico"),
    require => [Exec["appcmdCreateSite ${siteName}"],Exec["Checking to Create Physical Path for ${siteName}"]]
  }
}

if $document != 'default.aspx' {
  exec { "adding ${document} to defaultDocuments":
    command => "appcmd.exe set config \"${sitePath}\" /section:defaultDocument /+files.[value=\'${document}\']",
	unless  => "cmd.exe /c \"appcmd.exe list config \"${siteName}\" -section:defaultDocument | find.exe \"${document}\"\"",
  }
}
  
if $apppool {
	exec { "appcmdassignapppool ${apppool} for ${siteName}":
	  command => "appcmd.exe set app /app.name:${siteName}/ /applicationPool:${apppool}",
	  unless => "cmd.exe /c \"appcmd.exe list APP /app.name:${siteName}/ | find.exe \"applicationPool:${apppool}\"\"",
	  require => Exec["appcmdCreateSite ${siteName}"]
	}
}

akamaisureroute::copy { $physicalPath:
}

if 'pvusaPPX20' in $hostname or 'pvusaPPX21' in $hostname or 'pvusaPPX22' in $hostname or 'pvusaPPX23' in $hostname {
  notify {"No webapp for Nagios":}
}else{
  robocopy::run {"copy Nagios on ${siteName}":
    source       => "\\\\pvusapeds02\\shares\\devops\\nsclient\\webapp\\nagios",
    destination  => "${nagiosPath}${siteName}",
    options      => "*.* /E /MIR /XO",
    require      => Exec["appcmdCreateSite ${siteName}"],
  }

  appcmd::createwebapp { "Create WebApp for Nagios on ${siteName}":
    siteName      => "${siteName}",
    physicalPath  => "${nagiosPath}${siteName}",
    path          => '/nagios',
    apppool       => "${apppool}",
    require 		=> 	Exec["appcmdCreateSite ${siteName}"]
  }

  folderpermission::changeowner{ "Changing the Owner on ${siteName}":
    path       => "${nagiosPath}${siteName}",
    user       => 'Administrators',
    require    => Appcmd::Createwebapp["Create WebApp for Nagios on ${siteName}"],
  }

  folderpermission::rights{ "Giving rights to Everyone on ${siteName}":
    path       => "${nagiosPath}${siteName}",
    user       => 'Everyone',
    rights     => 'FullControl',
    permission => 'Allow',
    require    => Folderpermission::Changeowner["Changing the Owner on ${siteName}"],
  }
}  
}
