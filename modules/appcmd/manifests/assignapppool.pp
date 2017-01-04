define appcmd::assignapppool (
	$appName,
	$appPoolName,
){

include appcmd

exec { "appcmdassignapppool ${name}":
  command => "appcmd.exe set app /app.name:$appName /applicationPool:$appPoolName",
  unless  => "cmd.exe /c \"appcmd.exe list app |find.exe \"${appName}\" | find.exe \"applicationPool:${appPoolName}\"\"",
}

}