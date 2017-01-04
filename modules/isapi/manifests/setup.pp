class isapi::setup () {
require iiswebserver
require iiswebserver::iissetup
require isapi::files

  exec {'ISAPI-CGI-RestrictionsCSAUTH' :
    command => "appcmd.exe set config /section:isapiCgiRestriction /+[path=\'D:\mycompany\webpub\isapi\csauth-x64.dll\',description=\'csauth\',allowed=\'True\']",
    returns => ['0','183']
  }

}
