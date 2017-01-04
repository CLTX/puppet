class curl() {

$unzip = 'C:\Program Files\7-Zip\7z.exe'
$urlSRC= '\\yourdomain.mycompany.com\installers\Shared-Apps\curl\curl-7.34.0-static-bin-w64.zip'
$pathCurl = 'C:\Program Files\curl'

  package {"7-Zip 9.20 (x64 edition)":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\7z\\7z920-x64.msi",
  }      

  exec{'Installing curl':
    command => "\"${unzip}\" x -o\"${pathCurl}\" ${urlSRC}",
    onlyif  => "cmd.exe /c if exist \"${pathCurl}\" (EXIT /B 1) ELSE (EXIT /B 0)",
  }
}