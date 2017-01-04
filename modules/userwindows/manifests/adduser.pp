define userwindows::adduser (
  $domain = "null",
  $user,
  $localgroup
) {

include userwindows

exec { "Adding ${domain}\\${user} to ${localgroup}":
  command => "powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\addusertogroup.ps1 \"${localgroup}\" \"${domain}\" \"${user}\"",
  unless  => "cmd.exe /c \"net.exe localgroup \"${localgroup}\" | find.exe \"${user}\"\""
}

}
