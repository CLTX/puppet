class confirmit::authoringconfig () {

include confirmit::config
include folderpermission
include appcmd
include ftpserver

if $hostname == 'pvusaPFW01' or $hostname =='pvusaPFW02' or $hostname =='pvusaTFD01' or $hostname =='pvusaDBA04'{
  
    sharefolder::create{'CCL_Authoring':
      sharename => 'CCL_Authoring',
      path => 'D:\confirmit\prog\web\confirm_authoring\bin\CustomCode',
      user => 'Everyone',
      rights => 'Read',
	  user2 => 'yourdomain\daewebuser',
      rights2 => 'Change',
	  user3 => 'yourdomain\daebuilduser',
      rights3 => 'Change',
	  user4 => 'appname05techevents@mydomain.mycompany.com',
      rights4 => 'Change',
	  singleuser => 'false'
    }

	file {'D:\confirmit':
	  ensure => appname03ory,
    }	
	
	file {'D:\confirmit\data':
	  ensure => appname03ory,
	  require => File['D:\confirmit'],
    }	
	
	file {'D:\confirmit\data\shared':
	  ensure => appname03ory,
	  require => File['D:\confirmit\data'],
    }
	
    file {'D:\confirmit\data\shared\ftp':
	  ensure => appname03ory,
	  require => File['D:\confirmit\data\shared'],
    }

	folderpermission::changeowner{ "Changing the Owner on ${physicalPath}":
      path => 'D:\confirmit\data\shared\ftp',
      user => 'Administrators',
    }

    folderpermission::rights{ "Giving rights to Everyone on ${siteName}":
      path       => 'D:\confirmit\data\shared\ftp',
      user       => 'Everyone',
      rights     => 'FullControl',
      permission => 'Allow',
    }
  
    appcmd::createftpsite { 'setup FTP site':
	  ftpSiteName  => "confirmit",
	  physicalPath => "D:\\confirmit\\data\\shared\\ftp",
	  authentication => "anonymous",
	  accesstype    => "Read,Write",
	  require      => File['D:\confirmit\data\shared\ftp']
    }
  }
}