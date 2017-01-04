class git () {

$PathGIT = "C:\\Program Files (x86)\\Git\\bin"

  if $gitversion != "${gitactualversion}" {
    exec{'Install GIT':
      command => "cmd.exe /c \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Git\\Git-1.8.3-preview20130601.exe  /verysilent",
    }
  }

}
