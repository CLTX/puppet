define appcmd::createrdir(
  $url1,
  $url2,
){

include appcmd
	
exec { "appcmdcreaterdir ${name}":	
  command => "appcmd.exe set config \"${url1}/\" -section:system.webServer/httpReappname03 -enabled:true -destination:http://${url2} -commitpath:apphost",
  unless => "cmd.exe /c \"appcmd.exe list CONFIG \"${url1}\" -section:system.webServer/httpReappname03 | find.exe \"${url2}\" | find.exe \"true\"\"",
 }
}