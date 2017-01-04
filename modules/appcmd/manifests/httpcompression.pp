define appcmd::httpcompression (
) {
	include appcmd
	
	exec { "enabling httpCompression":
		command => "appcmd.exe set config /section:httpCompression /dynamicTypes.[mimeType=\'*/*\'].enabled:\"true\"  /commit:apphost",
		#unless  => "cmd.exe /c \"appcmd.exe list CONFIG  /section:httpCompression | find.exe \"mimeType=\"\"*/*\"\"\" | find.exe \"enabled=\"\"false\"\"\"\"",
	}
}