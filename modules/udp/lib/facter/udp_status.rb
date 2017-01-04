Facter.add("udp_status") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy bypass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\check_udp.ps1')
  end
end