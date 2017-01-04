class nginx()
{
require iiswebserver
include nginx::certificates

$size = 64
$nginxconf = 'D:\nginx\conf\nginx.conf'
$hostheaderscript ="\\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\nginx-hostheaders.ps1"

  file {'D:\nginx':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/nginx-1.7.4',
	ignore  => ['.pid'],
    recurse => true,
  }
  
  file {'D:\Nginx\logs':
    ensure  => appname03ory,
	owner   => 'Everyone',
	group   => 'Administrators',
	mode    => '0770',
    require => File['D:\nginx']
  }
    
  file {'D:\nginx\conf\ssl':
    ensure  => appname03ory,
	owner   => 'Everyone',
	group   => 'Administrators',
	mode    => '0770',
    require => File['D:\nginx']
  }
    
  file {'D:\nginx\wrapper':
    ensure  => appname03ory,
	owner   => 'Everyone',
	group   => 'Administrators',
	mode    => '0770',
    require => File['D:\nginx']
  }
  
  file {'D:\nginx\nginx_service.exe':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/nginx_service.exe',
	require => File['D:\nginx']
  }
	
  file {'D:\nginx\nginx_service.xml':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/nginx_service.xml',
	require => File['D:\nginx']
  }

  file {"${nginxconf}":
    ensure   => present,
    owner    => 'Everyone',
    group    => 'Administrators',
	mode     => '0770',
	content  => template("nginx/nginx.erb"),
	replace  => 'false',
    require  => File['D:\nginx']
  }
  
  exec { 'Add hostheader to nginx.conf':
    command     => "cmd.exe /c \"powershell.exe -ExecutionPolicy bypass ${hostheaderscript}\"",
	subscribe   => File["${nginxconf}"],
	refreshonly => true
  }

  service {'MsDepSvc':
    ensure => 'stopped'
  }
  
  exec { 'Install nginx':
    command     => 'D:\nginx\nginx_service.exe install',
	subscribe   => File['D:\nginx\nginx_service.exe'],
	returns     => ['0','2','16','23'],
	refreshonly => true,
	require     => File['D:\nginx']
  }
  
  service {'Nginx':
    ensure => 'running',
	require => [Exec['Install nginx'],File["${nginxconf}"]]
  }
  
  exec { 'restart Nginx':
    command     => 'D:\nginx\nginx_service.exe restart',
	path        => 'D:\nginx',
	subscribe   => [File['D:\nginx\conf\ssl\STAR_mycompany_com.pem'],File['D:\nginx\conf\ssl\STAR_mydomain_mycompany_com.pem'],File['D:\nginx\conf\ssl\STAR_securestudies_com.pem'],File['D:\nginx\conf\ssl\STAR_appname05-poll_com.pem'],File['D:\nginx\conf\ssl\STAR_voicefive_com.pem']],
	require     => [File['D:\nginx\nginx_service.exe'],File['D:\nginx\nginx_service.xml'],Exec['Add hostheader to nginx.conf']],
	refreshonly => true,
  }
}
