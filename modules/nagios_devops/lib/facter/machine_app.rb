Facter.add("machine_app") do
  setcode do
  hnametmp = Facter.value('hostname')
  hname = hnametmp.upcase
  case hname
  when /^(pvusa[P|D|T|S|B])A.+/
    "appname01"
  when /^(pvusa[P|D|T|S|B])B.+/
    "DevOps"
  when /^(pvusa[P|D|T|S|B])C.+/
    "Clients"
  when /^(pvusa[P|D|T|S|B])D.+/
    "appname03"
  when /^(pvusa[P|D|T|S|B])E.+/
    "CMS"
  when /^(pvusa[P|D|T|S|B])F.+/
    "Confirmit"
  when /^(pvusa[P|D|T|S|B])G.+/
    "QA"
  when /^(pvusa[P|D|T|S|B])J.+/
    "DatamartDelivery"
  when /^(pvusa[P|D|T|S|B])K.+/
    "Marketer"
  when /^(pvusa[P|D|T|S|B])L.+/
    "Splunk"
  when /^(pvusa[P|D|T|S|B])M.+/
    "appname04"
  when /^(pvusa[P|D|T|S|B])N.+/
    "Finance"
  when /^(pvusa[P|D|T|S|B])O.+/
    "appname02"
  when /^(pvusa[P|D|T|S|B])P.+/
    "PlatfformTeam"
  when /^(pvusa[P|D|T|S|B])Q.+/
    "TechSQL"
  when /^(pvusa[P|D|T|S|B])R.+/
    "Marcom"
  when /^(pvusa[P|D|T|S|B])S.+/
    "appname05"
  when /^(pvusaCOM0).+/
    "appname05"
  when /^(ppusaCPM0).+/
    "appname05"
  when /^(ppusaADB0).+/
    "TechSQL"
  when /^(pvusaPZW0).+/
    "PlatfformTeam"
  when /^(pvusaDZW01)/
    "PlatfformTeam"
  when /^(pvusa[P|D|T|S|B])T.+/
    "Atlassian"
  when /^(pvusa[P|D|T|S|B])Z.+/
    "team01"
  else
    "Unknown"
  end
  end
end
