define appcmd::customerrors (
  $statuscode,
  $siteName,
  $reappname03Path,
  $responseMode,
) {
 
include appcmd 

  exec { "${title} ${siteName}":
    command => "appcmd.exe set config \"$siteName\" /section:httpErrors /[statusCode=\'${statuscode}\'].path:\"${reappname03Path}\" /[statusCode=\'${statuscode}\'].responseMode:\"${responseMode}\"",
	unless  => "cmd.exe /c \"appcmd.exe list config \"${siteName}\" /section:httpErrors | findstr.exe /I \"statusCode=\"\"${$statuscode}\"\"\" | findstr.exe /I \"path=\"\"${reappname03Path}\"\"\" | findstr.exe /I \"responseMode=\"\"${responseMode}\"\"\"\""
  }
}