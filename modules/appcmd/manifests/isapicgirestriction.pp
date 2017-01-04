define appcmd::isapicgirestriction (
  $path,

) {
	include appcmd
	
	exec { "appcmdsetisapifilter ${name}":
		command => "appcmd.exe set config /section:isapiCgiRestriction /[path=\'$path\'].allowed:True",
		unless  => "cmd.exe /c \"appcmd.exe list CONFIG /section:isapiCgiRestriction | find.exe \"${path}\" | find.exe \"true\"\"",
	}
}