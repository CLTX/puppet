define loopbackv2::setup (
  $lvsip = "127.0.0.1",
  $subnetmask = "255.255.255.255"
  ){
  
include loopbackv2

$script = "\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\new-add-loopbacknetwork.ps1"

exec{"loopback interface ${lvsip}":
  command => "powershell.exe -ExecutionPolicy ByPass ${script} ${lvsip} ${subnetmask}",
  unless => "cmd.exe /c \"ipconfig.exe /all | findstr.exe /i \"LVS Loopback\"\"",
  }

exec{"adding extra ip address ${lvsip} ":
  command => "netsh.exe int ip add address \"LVS Loopback\" $lvsip $subnetmask",
  unless  => "cmd.exe /c \"ipconfig.exe /all | findstr.exe /i \"${lvsip}\"\"",
  require => Exec["loopback interface ${lvsip}"]
  }
}
