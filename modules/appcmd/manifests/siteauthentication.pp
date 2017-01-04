define appcmd::siteauthentication (
	$siteName = Undef,
	$anonymous = 'false',
	$basic = 'false',
	$digest = 'false',
	$windows = 'false',
	$aspnet = 'false',
	$forms = 'false',
){

include appcmd

if $anonymous == 'true' {
  exec { "Enabling AnonymousAuthentication for ${siteName}":
    command => "appcmd set config \"${siteName}\" /section:anonymousAuthentication /enabled:${anonymous} /commit:apphost",
    unless  => "cmd /c \"appcmd list config ${siteName} | findstr /I  \"anonymousAuthentication\" | findstr /I \"${anonymous}\"\"",
  }
} else
{
  exec { "Disabling AnonymousAuthentication for ${siteName}":
    command => "appcmd set config \"${siteName}\" /section:anonymousAuthentication /enabled:${anonymous} /commit:apphost",
    unless  => "cmd /c \"appcmd list config ${siteName} | findstr /I  \"anonymousAuthentication\" | findstr /I \"${anonymous}\"\"",
  }
}

if $basic == 'true' {
  exec { "Enabling BasicAuthentication for ${siteName}":
    command => "appcmd set config \"${siteName}\" /section:basicAuthentication /enabled:${basic} /commit:apphost",
    unless  => "cmd /c \"appcmd list config ${siteName} | findstr /I  \"basicAuthentication\" | findstr /I \"${basic}\"\"",
  }
} else{
  exec { "Disabling BasicAuthentication for ${siteName}":
    command => "appcmd set config \"${siteName}\" /section:basicAuthentication /enabled:${basic} /commit:apphost",
    unless  => "cmd /c \"appcmd list config ${siteName} | findstr /I  \"basicAuthentication\" | findstr /I \"${basic}\"\"",
  }
}

if $digest == 'true' {
  exec { "Enabling DigestAuthentication for ${siteName}":
    command => "appcmd set config \"${siteName}\" /section:digestAuthentication /enabled:${digest} /commit:apphost",
    unless  => "cmd /c \"appcmd list config ${siteName} | findstr /I  \"digestAuthentication\" | findstr /I \"${digest}\"\"",
  }
} else {
  exec { "Disabling DigestAuthentication for ${siteName}":
    command => "appcmd set config \"${siteName}\" /section:digestAuthentication /enabled:${digest} /commit:apphost",
    unless  => "cmd /c \"appcmd list config ${siteName} | findstr /I  \"digestAuthentication\" | findstr /I \"${digest}\"\"",
  }
}

if $windows == 'true' {
  exec { "Enabling WindowsAuthentication for ${siteName}":
    command => "appcmd set config \"${siteName}\" /section:windowsAuthentication /enabled:${windows} /commit:apphost",
    unless  => "cmd /c \"appcmd list config ${siteName} | findstr /I  \"windowsAuthentication\" | findstr /I \"${windows}\"\"",
  }
} else {
  exec { "Disabling WindowsAuthentication for ${siteName}":
    command => "appcmd set config \"${siteName}\" /section:windowsAuthentication /enabled:${windows} /commit:apphost",
    unless  => "cmd /c \"appcmd list config ${siteName} | findstr /I  \"windowsAuthentication\" | findstr /I \"${windows}\"\"",
  }
}

if $aspnet == 'true' {
  exec { "Enabling ASP.NET impersonate for ${siteName}":
    command => "appcmd set config \"${siteName}\" -section:system.web/identity /impersonate:\"${aspnet}\"",
    unless  => "cmd /c \"appcmd list config ${siteName} -section:system.web/identity | findstr /I  \"impersonate=\"\"${aspnet}\"\"",
  }
} else {
  exec { "Disabling ASP.NET impersonate for ${siteName}":
    command => "appcmd set config \"${siteName}\" -section:system.web/identity /impersonate:\"${aspnet}\"",
    unless  => "cmd /c \"appcmd list config ${siteName} -section:system.web/identity | findstr /I  \"impersonate=\"\"${aspnet}\"\"",
  }
}

if $forms == 'true' {
  exec { "Enabling Forms Authentication for ${siteName}":
    command => "appcmd set config \"${siteName}\" -section:system.web/authentication /mode:Forms",
    unless  => "cmd /c \"appcmd list config ${siteName} -section:system.web/authentication | findstr /I  \"mode=\"Forms\"\" ",
  }
}

}