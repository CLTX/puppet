# put it on D:\Program Files (x86)\Puppet Labs\Puppet\facter\lib\facter 
# this fact return true when the udp service is running on a machine
Facter.add("machine_env") do
  setcode do
	hname = Facter.value('hostname')
	case hname
	when /^CS.+/
		"PRD"
	when /^pvusaD.+/
		"INT"
	when /^pvusaT.+/
		"TST"
	when /^pvusaS.+/
		"STAG"
	when /^pvusaB.+/
		"PRD"
  when /^pvusaP.+/
		"PRD"
  when /^pvusaQ.+/
		"PRD"
	else
		"INT"
	end
  end
end

Facter.add("getip") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\getip.ps1')
  end
end

Facter.add("nppversion") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -Command (Get-Command \"C:\\Program Files (x86)\\Notepad++\\notepad++.exe\").FileVersionInfo.ProductVersion')
  end
end

Facter.add("gitversion") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\gitversion.ps1')
  end
end

Facter.add("authmoduleversion") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\authmoduleversion.ps1')
  end
end

Facter.add("unitypresent") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\unitypresent.ps1')
  end
end

Facter.add("today") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\today.ps1')
  end
end

Facter.add("sslpresent") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\sslpresent.ps1')
  end
end

Facter.add("perlversion") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\perlversion.ps1')
  end
end

Facter.add("spfrunning") do
  setcode do
    Facter::Util::Resolution.exec('C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\check_splunkforwarder.ps1')
  end
end

Facter.add("psremoting_enabled") do
  setcode do
  host = Facter.value('hostname').upcase
  pp = "C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\test-psremoting.ps1 "+host+" "
  Facter::Util::Resolution.exec(pp)
  end
end

Facter.add("ps_executionpolicy") do
  setcode do
  host = Facter.value('hostname').upcase
  pp = "C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -Command Get-ExecutionPolicy"
  Facter::Util::Resolution.exec(pp)
  end
end
