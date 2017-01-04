define appcmd::httpresponseheader(
  $nameHttp,
  $value,
  $siteName,
  $appName
){
  include appcmd
  exec { "httpresponseheader ${appName}": 
    command => "appcmd set config \"${siteName}/${appName}\" /section:httpProtocol /+customHeaders.[name='${nameHttp}',value='${value}']", 
    unless => "cmd.exe /c \"appcmd.exe list config \"${siteName}\" -section:httpProtocol | findstr.exe /I \"name=\"\"${name}\"\"\"\""
  }
}





