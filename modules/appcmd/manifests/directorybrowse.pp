define appcmd::appname03orybrowse (
  $sitePath,
  $state
) {
  include appcmd
	
  exec { "setting appname03oryBrowse as ${state} on ${sitePath}":
    command => "appcmd.exe set config \"${sitePath}\" /section:appname03oryBrowse /enabled:${state}",
    unless => "cmd.exe /c \"appcmd.exe list CONFIG | find.exe \"${sitePath}\" | find.exe \"section:appname03oryBrowse\" | find.exe \"enabled\"\"",
  }
}



