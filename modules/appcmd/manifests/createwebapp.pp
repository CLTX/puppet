define appcmd::createwebapp (
	$siteName = undef,
	$physicalPath = undef,
	$path = undef,
	$document = 'default.aspx',
	$apppool = undef
){

include appcmd

exec { "Checking to Create Physical Path for ${name}" :
	command => "powershell.exe -ExecutionPolicy ByPass -command \"New-Item -Type appname03ory ${physicalPath}\"",
	timeout => 0,
	onlyif => "powershell.exe -ExecutionPolicy ByPass -command \"if (Test-Path ${physicalPath}) { exit 1;}  else { exit 0; }\""
}

exec { "appcmdcreatewebapp ${name}":
  command => "appcmd.exe add app /site.name:$siteName /path:$path /physicalPath:$physicalPath",
  unless  => "cmd.exe /c \"appcmd.exe list app | findstr.exe \"\\\"${siteName}${path}\\\"\"\""
}

if $document != 'default.aspx' {
  exec { "adding ${document} to ${path} on ${siteName}":
    command => "appcmd.exe set config \"${siteName}/${name}\" /section:defaultDocument /+files.[value=\'${document}\']",
    unless  => "cmd.exe /c \"appcmd.exe list config  \"${siteName}/${name}\" /section:defaultDocument | find.exe \"${document}\"\"",
	require => Exec["appcmdcreatewebapp ${name}"]
  }
}

if $apppool {
	appcmd::assignapppool { "Assigning ${path} to App Pool ${apppool} on ${siteName}":
	  appName     => "${siteName}${path}",
	  appPoolName => "${apppool}",
	  require     => Exec["appcmdcreatewebapp ${name}"]
	}
}

}
