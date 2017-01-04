define appcmd::errorcodereappname03 (
  $site,
  $reappname03Path,
  $errorCode
){

include appcmd

	exec { "Enabling Reappname03 to ${errorCode} for ${name}":
	  command => "appcmd.exe set config \"${site}\" /section:httpErrors /[statusCode='${errorCode}'].responseMode:ExecuteURL",
	  unless  => "cmd.exe /c \"appcmd.exe list config \"${site}\" | find.exe \"${errorCode}\" | find.exe \"ExecuteURL\"\""
	}
	
	exec { "Setting Reappname03 to ${errorCode} for ${name}":
	  command => "appcmd.exe set config \"${site}\" /section:httpErrors /[statusCode='${errorCode}'].path:${reappname03Path}",
	  unless  => "cmd.exe /c \"appcmd.exe list config \"${site}\" | find.exe \"${errorCode}\" | find.exe \"${reappname03Path}\"\""
	}
	
	exec { "Setting PrefixPath to ${errorCode} for ${name}":
	  command => "appcmd.exe set config \"${site}\" /section:httpErrors /[statusCode='${errorCode}'].prefixLanguageFilePath:\"\"",
	  unless  => "cmd.exe /c \"appcmd.exe list config \"${site}\" | find.exe \"${errorCode}\" | find.exe \"${reappname03Path}\"\""
	}
}