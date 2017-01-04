class confirmit::config () {

include sslcerts
include folderpermission

$confirmitCachingService = {
  'pvusaPFW01' => 'true',
  'pvusaPFW02' => 'true',
  'pvusaPFW03' => 'false',
  'pvusaPFW04' => 'false',
  'pvusaPFA01' => 'false',
  'pvusaPFA02' => 'false',
  'pvusaPFA03' => 'false',
  'pvusaPFA04' => 'false'
}

$confirmitBitStreamService = { 
  'pvusaPFW01' => 'false',
  'pvusaPFW02' => 'false',
  'pvusaPFW03' => 'false',
  'pvusaPFW04' => 'false',
  'pvusaPFA01' => 'true',
  'pvusaPFA02' => 'true',
  'pvusaPFA03' => 'true',
  'pvusaPFA04' => 'false'
}

$confirmitTaskSystem = { 
  'pvusaPFW01' => 'false',
  'pvusaPFW02' => 'false',
  'pvusaPFW03' => 'false',
  'pvusaPFW04' => 'false',
  'pvusaPFA01' => 'true',
  'pvusaPFA02' => 'true',
  'pvusaPFA03' => 'true',
  'pvusaPFA04' => 'false'
}

if $confirmitCachingService[$hostname] == 'true'{
    service { 'Confirmit Caching Service':
      ensure => "running",
      enable => $confirmitCachingService[$hostname],
    } 
  }elsif $confirmitCachingService[$hostname] == 'false'{
    service { 'Confirmit Caching Service':
      ensure => "stopped",
      enable => $confirmitCachingService[$hostname],
    } 
  }
  
  if $confirmitBitStreamService[$hostname] == 'true'{
    service { 'Confirmit BitStream Service':
      ensure => "running",
      enable => $confirmitBitStreamService[$hostname],
    } 
  }elsif $confirmitBitStreamService[$hostname] == 'false'{
    service { 'Confirmit BitStream Service':
      ensure => "stopped",
      enable => $confirmitBitStreamService[$hostname],
    } 
  }

  if $confirmitTaskSystem[$hostname] == 'true'{
    service { 'Confirmit Task System':
      ensure => "running",
      enable => $confirmitTaskSystem[$hostname],
    } 
  }elsif $confirmitTaskSystem[$hostname] == 'false'{
    service { 'Confirmit Task System':
      ensure => "stopped",
      enable => $confirmitTaskSystem[$hostname],
    } 
  }

if $hostname == 'pvusaPFW03' or $hostname == 'pvusaPFW04' {

  sslcerts::run{'ssl-certs': 
    siteName      => "Default Web Site",
    pfxFile       => "STAR_securestudies_com.pfx",
    pathSite      => '/'
 }
} 

folderpermission::changeowner{ 'Changing the Owner on Confirmit':
  path       => 'D:\confirmit',
  user       => 'Administrators'
}

folderpermission::rights{ 'Giving rights to Everyone on Confirmit':
  path       => 'D:\confirmit',
  user       => 'Everyone',
  rights     => 'FullControl',
  permission => 'Allow'
  
}

folderpermission::rights{ ' Giving rights to Administrators on Confirmit':
  path       => 'D:\confirmit',
  user       => 'Administrators',
  rights     => 'FullControl',
  permission => 'Allow'
}
 
}
