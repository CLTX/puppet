define appcmd::binding (
  $site,
  $port,
  $hostHeaderValue = ''
){

include appcmd

exec { "appcmdbingings ${name}":
  command => "appcmd.exe set site \"${site}\" /+bindings.[protocol='https',bindingInformation='*:443:${hostHeaderValue}']",
  unless  => "powershell -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\bindingcheck.ps1 \"${site}\" ${port}"
}
}
