define appcmd::impersonatecgi (

) {
	include appcmd
	
  exec { "Set ImpersonateUser CGI to $title":
    command => "appcmd.exe set config /section:cgi /createProcessAsUser:${title}",
    unless => "cmd.exe /c \"appcmd.exe list CONFIG /section:cgi | findstr.exe /I \"createprocessasuser=\"\"\"${title}\"\"\"\"\"",
  }

}