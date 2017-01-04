define appcmd::configapppool(
  $appName,
  $userName,
  $password,
){

include appcmd
	
exec { "appcmdconfigapppool ${name}":	
  command => "appcmd.exe set config /section:applicationPools /[name=\'$appName\'].processModel.identityType:SpecificUser /[name=\'$appName\'].processModel.userName:\"$userName\" /[name=\'$appName\'].processModel.password:$password",
  unless => "cmd.exe /c \"appcmd.exe list APPPOOL /apppool.name:\"${appName}\" /text:* | findstr.exe \"${userName} ${password}\"\"\"",
  }
}

