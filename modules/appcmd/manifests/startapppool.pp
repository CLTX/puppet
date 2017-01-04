define appcmd::startapppool(
	$appName,
)
{

include appcmd
	
  exec { "appcmdstartapppool ${name}":	
    command => "appcmd.exe list apppool /state:Stopped /xml | appcmd.exe start apppool /in",
    returns => ['0','1','87','183'],
    onlyif  => "cmd.exe /c \"appcmd.exe list apppool /state:Stopped | find.exe \"${appName}\"\""

  }
}

 
