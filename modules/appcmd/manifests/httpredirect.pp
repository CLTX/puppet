define appcmd::httpreappname03 (
  $enabled,
  $siteName,
  $reappname03Path,
  $exactDestination
) {
 
include appcmd 

if $enabled == "True" {
    exec { "${title} ${siteName}":
      command => "appcmd.exe set config \"${siteName}\" -section:system.webServer/httpReappname03 /enabled:\"${enabled}\" /destination:\"${reappname03Path}\" /exactDestination:\"${exactDestination}\"",
      unless  => "cmd.exe /c \"appcmd.exe list config \"${siteName}\" -section:system.webServer/httpReappname03 | findstr.exe /I \"enabled=\"\"${enabled}\"\"\" | findstr.exe /I \"destination=\"\"${reappname03Path}\"\"\" | findstr /I \"exactDestination=\"\"${exactDestination}\"\"\"\" "
    }
} else 
   {
    exec { "Disabling Reappname03 ${siteName}":
      command => "appcmd.exe set config \"${siteName}\" -section:system.webServer/httpReappname03 /enabled:\"${enabled}\"",
      unless  => "cmd.exe /c \"appcmd.exe list config \"${siteName}\" -section:system.webServer/httpReappname03 | findstr.exe /I \"enabled=\"\"${enabled}\"\"\"\""
    }
  }
}
