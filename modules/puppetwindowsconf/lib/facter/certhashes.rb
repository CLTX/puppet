Facter.add("star_mycompany_ssl_match") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\sslupdatecheck.ps1')
  end
end

Facter.add("star_mydomain_mycompany_ssl_match") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\sslmydomainupdatecheck.ps1')
  end
end

Facter.add("star_securestudies_ssl_match") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\sslsecurestudiesupdatecheck.ps1')
  end
end

Facter.add("star_voicefive_ssl_match") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\sslvoicefiveupdatecheck.ps1')
  end
end

Facter.add("star_appname05_poll_ssl_match") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\sslappname05-pollupdatecheck.ps1')
  end
end