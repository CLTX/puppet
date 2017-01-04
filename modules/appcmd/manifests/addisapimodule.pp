define appcmd::addisapimodule (
	$site,
  $appname = undef,
	$modName,
	$type,
	$preCondition
) {
	include appcmd
	
  if $appname == undef {
     exec { "Add ISAPI ${modName} to ${site}":
        command => "appcmd.exe add module /name:\"${modName}\" /type:\"${type}\" /preCondition:\"${preCondition}\" /app.name:\"${site}/\"",
        unless  => "cmd.exe /c \"appcmd.exe list module /app.name:\"${site}/\" | find.exe \"${type}\" | find.exe \"${modName}\" \" ",
     }
  } else {
     exec { "Add ISAPI ${modName} to ${appname}":
        command => "appcmd.exe add module /name:\"${modName}\" /type:\"${type}\" /preCondition:\"${preCondition}\" /app.name:\"${site}${appname}\"",
        unless  => "cmd.exe /c \"appcmd.exe list module /app.name:\"${site}${appname}\" | find.exe \"${type}\" | find.exe \"${modName}\" \" ",
     }
  }
}
