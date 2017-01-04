define appcmd::deletewebapp (
	$siteName,
	$path,
){

include appcmd

exec { "appcmddeletewebapp ${name}":
  command => "appcmd.exe delete app ${siteName}${path}",
  onlyif => "cmd.exe /c \"appcmd.exe list APP | find.exe \"${siteName}\" | find.exe \"${path}\"\"",
}

}