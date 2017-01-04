class nginx::certificates()
{
include nginx
  

  file {'D:\nginx\conf\ssl\STAR_mycompany_com.key':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/certificates/STAR_mycompany_com.key',
	require => File['D:\nginx']
  }
  
  file {'D:\nginx\conf\ssl\STAR_mycompany_com.pem':
   ensure  => present,
   owner   => 'Everyone',
   group   => 'Administrators',
   mode    => '0770',
   source  => 'puppet:///modules/nginx/certificates/STAR_mycompany_com.pem',
   require => File['D:\nginx']
 }
 
  file {'D:\nginx\conf\ssl\STAR_mydomain_mycompany_com.key':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/certificates/STAR_mydomain_mycompany_com.key',
	require => File['D:\nginx']
  }
  
  file {'D:\nginx\conf\ssl\STAR_mydomain_mycompany_com.pem':
   ensure  => present,
   owner   => 'Everyone',
   group   => 'Administrators',
   mode    => '0770',
   source  => 'puppet:///modules/nginx/certificates/STAR_mydomain_mycompany_com.pem',
   require => File['D:\nginx']
 }
 
  file {'D:\nginx\conf\ssl\STAR_securestudies_com.key':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/certificates/STAR_securestudies_com.key',
	require => File['D:\nginx']
  }
  
  file {'D:\nginx\conf\ssl\STAR_securestudies_com.pem':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/certificates/STAR_securestudies_com.pem',
    require => File['D:\nginx']
  }

  file {'D:\nginx\conf\ssl\STAR_appname05-poll_com.key':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/certificates/STAR_appname05-poll_com.key',
	require => File['D:\nginx']
  }
  
  file {'D:\nginx\conf\ssl\STAR_appname05-poll_com.pem':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/certificates/STAR_appname05-poll_com.pem',
    require => File['D:\nginx']
  }
  
  file {'D:\nginx\conf\ssl\STAR_voicefive_com.key':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/certificates/STAR_voicefive_com.key',
	require => File['D:\nginx']
  }
  
  file {'D:\nginx\conf\ssl\STAR_voicefive_com.pem':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/nginx/certificates/STAR_voicefive_com.pem',
    require => File['D:\nginx']
  }
  
}