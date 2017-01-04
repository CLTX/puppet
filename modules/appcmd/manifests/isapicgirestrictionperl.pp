define appcmd::isapicgirestrictionperl (

) {
	include appcmd
	
exec { "Set isapiCgiRestriction for Perl to $title":
  command => "appcmd.exe set config /section:isapiCgiRestriction /+\"[path='C:\Perl\bin\perl.exe %22%s%22 %s',description='Perl',allowed='${title}']\"",
  unless => "cmd.exe /c \"appcmd.exe list CONFIG /section:isapiCgiRestriction | findstr.exe \"perl.exe\" | findstr.exe \"${title}\"\"",
}

}