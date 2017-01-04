define perlwindows::addmodule(
  $module = $title
){

$ppmpath = 'C:\Perl\bin\PPM.bat'

if $module != "none"
{
  exec { "$module":
    command => "${ppmpath} install ${module}",
    path    => 'C:\windows\system32;C:\Perl\bin;C:\Perl',
    unless => "cmd.exe /c \"${ppmpath} list | findstr.exe /I \"${module}\""
  }
}
}
