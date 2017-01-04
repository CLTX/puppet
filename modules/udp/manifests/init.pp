class udp()
{

include appcmd
include sharefolder
include installutil
include userwindows

file {'D:\mycompany':
  ensure  => appname03ory,
  owner   => 'Administrators',
}  
  
sharefolder::create{'mycompany':
  sharename  => 'mycompany',
  path       => 'D:\mycompany',
  user       => 'yourdomain\daewebuser',
  rights     => 'Full',
  user2      => 'Administrators',
  rights2    => 'Full',
  singleuser => 'false',
  require    => File['D:\mycompany']
}

installutil::run {'Installing UDP Service':
	serviceName => "cscudpprocessor",
	path => "D:\\mycompany\\services\\CommonUdpService\\bin\\mycompany.Common.UDP.exe",
	domain => "yourdomain",
	username => "daewebuser",
	password => "yourpassword",
	pathMustExist => "false"
}

if $udp_status == 'false' {
  service {"cscudpprocessor":
    ensure  => running,
    enable  => true,
    require => Installutil::Run['Installing UDP Service'],
  }
}

exec { "netsh to LAN":
  command => "cmd.exe /c \"netsh.exe interface ipv4 set interface \"Local Area Connection\" weakhostreceive=enabled\"",
  unless  => "cmd.exe /c \"netsh.exe interface ipv4 show interfaces interface=\"Local Area Connection\" level=verbose |findstr.exe /I \"Weak Host receives\" | findstr.exe /I \"enabled\"\"",
}
}
