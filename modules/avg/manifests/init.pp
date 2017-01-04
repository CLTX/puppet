class avg () {

    $pathAvg = "C:\\Temp\\CAVG2013\\AvgSetup.bat"
    $RegPath ="HKLM:\\SOFTWARE\\AVG\\AVG2013"
    $basePath = "C:\\Temp"
    $source = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\AVG\\CAVG2013"
    $destination = "C:\\Temp\\CAVG2013"
    $options = "/E /MIR /XO"
    $successcode = [0, 1]

   file {"C:\\Temp\\CAVG2013":
     ensure => appname03ory,
   }
   
   exec{"copy avg":
    command => "robocopy.exe ${source} ${destination} ${options}",
    timeout => 0,
    returns => $successcode,
    onlyif => "powershell.exe -ExecutionPolicy ByPass -command \"if ((Test-Path ${RegPath}) -and (${status_avg} -eq 1)) { exit 1;}  else { exit 0; }\"",
    require => File["C:\\Temp\\CAVG2013"]
    }

    exec{'Install AVG':
      command => "cmd.exe /c ${pathAvg}",
      onlyif => "powershell.exe -ExecutionPolicy ByPass -command \"if ((Test-Path ${RegPath}) -and (${status_avg} -eq 1)) { exit 1;}  else { exit 0; }\"",
      require => [File["C:\\Temp\\CAVG2013"],Exec["copy avg"]]
    }
}		
