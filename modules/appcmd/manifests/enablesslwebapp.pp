define appcmd::enablesslwebapp (
  $site,
  $path,
){

include appcmd

exec { "enabling SSL to ${name}":
  command => "appcmd.exe set config \"${site}${path}\" /section:access /sslFlags:Ssl /commit:apphost ",
  unless  => "cmd.exe /c \"appcmd.exe list config \"${site}${path}\" | find \"sslFlags=\"\"Ssl\"\"\" \""
}
}
