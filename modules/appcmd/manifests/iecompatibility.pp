define appcmd::iecompatibility (
  $ie,
  $site

) {
  include appcmd

case $ie {
  IE7: { $value = "EmulateIE7" }
  IE8: { $value = "EmulateIE8" }
  default: { fail("Unknow value for interntet explorer version") }
}  

exec {"enabling $ie Compatibility" :
    command => "appcmd.exe set config \"$site\" -section:system.webServer/httpProtocol /+\"customHeaders.[name=\'X-UA-Compatible\',value=\'IE=$value\']\" ",
	unless  => "cmd.exe /c \" appcmd.exe list config \"$site\" | find.exe \"IE=Emulate$ie\" \""
  }

}
