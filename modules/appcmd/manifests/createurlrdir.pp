define appcmd::createurlrdir(
  $url1,
  $url2,
  $childonly = false
){
include appcmd
	
exec { "appcmdcreateurlrdir ${name}":	
  command => "appcmd.exe set config \"${url1}\" -section:system.webServer/httpReappname03 -enabled:true /childOnly:$childonly -destination:${url2} -commit:url",
  unless => "cmd.exe /c \"appcmd.exe list CONFIG \"${url1}\" -section:system.webServer/httpReappname03 | find.exe \"${url2}\" | find.exe \"true\"\"",
 }
}