define appcmd::handlermappings (
  $name,
  $paTh,
  $verb,
  $modules,
  $scriptProcessor
) 
{
  include appcmd

  exec { "Handler Mappings ${name}":
    command => "appcmd.exe set config /section:handlers \"/+[name='$name',path='$paTh',verb='$verb',modules='$modules',scriptProcessor='$scriptProcessor']\" /commit:apphost",
    unless  => "cmd.exe /c \"appcmd.exe list CONFIG /section:handlers | find.exe \"${name}\" | find.exe \"path\"\"",
  }
}
