define appcmd::isapifilter (
	$site,
	$modName,
	$path,
	$preCondition
) {
	include appcmd
	
	exec { "appcmdsetisapifilter for ${site} - ${modName}":
		command => "appcmd.exe set config \"$site\" -section:system.webServer/isapiFilters /+[name=\'$modName\',path=\'$path\',preCondition=\'$preCondition\'] /commit:apphost",
		unless  => "cmd.exe /c \"appcmd.exe list CONFIG \"${site}\" -section:system.webServer/isapiFilters | find.exe \"${path}\" | find.exe \"${modName}\" \" ",
	}
}