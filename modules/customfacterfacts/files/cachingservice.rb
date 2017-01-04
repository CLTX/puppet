Facter.add("AppFabric_Installed") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy remotesigned -command "& { . \\\\pvusatst02\installshares\AutomationScripts\FacterLib\appfabric_service.ps1; Service-Installed }"')
  end
end

Facter.add("AppFabric_Running") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy remotesigned -command "& { . \\\\pvusatst02\installshares\AutomationScripts\FacterLib\appfabric_service.ps1; Service-Running }"')
  end
end