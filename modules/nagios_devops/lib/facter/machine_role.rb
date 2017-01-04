Facter.add("machine_role") do
  setcode do
  hrole = Facter.value('hostname').upcase
  case hrole
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|J|G|K|L|M|N|O|P|Q|R|S|T|Z])A.+/
  "Application And Services"
  when /^(pvusaCOM0).+/
  "Application And Services"
  when /^(ppusaCPM0).+/
  "Database"
  when /^(ppusaADB0).+/
  "Database"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])B.+/
  "Build"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])C.+/
  "Clustered Server"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])D.+/
  "Database"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])F.+/
  "File Server"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])I.+/
  "Linux Clustered Server"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])J.+/
  "Linux Web Server"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])K.+/
  "Linux Database Server"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])L.+/
  "Linux Application Server"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])M.+/
  "Memory Caching"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])O.+/
  "OLP DB"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])R.+/
  "Report Running DB"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])S.+/
  "Storage"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])W.+/
  "Web"
  when /^(pvusa[P|D|T|S|B])([A|B|C|D|F|G|J|K|L|M|N|O|P|Q|R|S|T|Z])X.+/
  "Client - Web APIs"
  else
  "Unknown"
  end
  end
end

Facter.add("match_techsql") do
  setcode do
  host = Facter.value('hostname').upcase
  url = 'http://intranet/segdbsupportwebproject/ServerList.aspx'
  pp = "C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\matchurl.ps1 "+host+" "+url
  Facter::Util::Resolution.exec(pp)
  end
end


Facter.add("techsql_contact") do
  setcode do
  pp = "C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\techsql_PD_contact.ps1"
  Facter::Util::Resolution.exec(pp)
  end
end

Facter.add("puppet_enabled") do
  setcode do
  host = Facter.value('hostname').upcase
  pp = "C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\puppetAgentTask_verifier.ps1 "+host+" puppetTask_enabled_check"
  Facter::Util::Resolution.exec(pp)
  end
end

Facter.add("puppet_lastruntime") do
  setcode do
  host = Facter.value('hostname').upcase
  pp = "C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\puppetAgentTask_verifier.ps1 "+host+" puppetTask_LastRunTime_check"
  Facter::Util::Resolution.exec(pp)
  end
end

Facter.add("puppet_lastresult") do
  setcode do
  host = Facter.value('hostname').upcase
  pp = "C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\puppetAgentTask_verifier.ps1 "+host+" puppetTask_LastTaskResult_check"
  Facter::Util::Resolution.exec(pp)
  end
end

Facter.add("status_avg") do
  setcode do
  pp = "C:\\Windows\\Sysnative\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\statusService.ps1 avgwd"
  Facter::Util::Resolution.exec(pp)
  end
end
