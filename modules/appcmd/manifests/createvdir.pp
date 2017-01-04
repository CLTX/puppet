define appcmd::createvdir (
  $sitename,
  $physicalPath,
  $vdirname,
  $appName = undef
){

include appcmd

exec { "appcmdcreatevdir ${name}":
  command => "appcmd.exe add vdir /app.name:${sitename}/${appName} /path:/${vdirname} /physicalPath:${physicalPath}",
  unless => "powershell.exe -executionPolicy Bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\get-vdir.ps1 \"${sitename}\" \"${appName}\" \"${physicalPath}\" \"${vdirname}\"",
}

exec { "changing physicalPath to ${name}":	
  command => "appcmd.exe set vdir \"${sitename}/${vdirname}\" -physicalPath:${physicalPath}",
  unless => "cmd.exe /c \"appcmd.exe list VDIR | find.exe \"${sitename}\" | find.exe \"${vdirname}\" | find.exe \"${physicalPath}\" \"",
  require => Exec["appcmdcreatevdir ${name}"]
}	

}
