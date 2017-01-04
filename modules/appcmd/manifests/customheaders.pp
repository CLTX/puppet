define appcmd::customheaders (
  $name,
  $value,
  $site
) 
{
  include appcmd

  exec { "Custom HTTP Headers ${name}":
    command => "appcmd.exe set config \"${site}\" /section:httpProtocol \"/+customHeaders.[name=\'${name}\',value=\'${value}\']\"",
    unless  => "cmd.exe /c \"appcmd.exe list CONFIG \"${site}\" /section:httpProtocol | findstr.exe \"${name}\" | findstr.exe \"${value}\"\"",
  }
}
