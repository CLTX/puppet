class confirmit::deploymentconfig () {

include confirmit::config
include confirmit::common
include schedtasks

  sharefolder::create{'CCL_Deployment':
    sharename => 'CCL_Deployment',
    path => 'D:\confirmit\prog\web\wix\bin\CustomCode',
    user => 'yourdomain\daewebuser',
    rights => 'Change',
		user2 => 'yourdomain\daewebuser',
    rights2 => 'Change',
	user3 => 'yourdomain\daebuilduser',
    rights3 => 'Change',
	user4 => 'appname05techevents@mydomain.mycompany.com',
    rights4 => 'Change',
	singleuser => 'false'
  }

if $hostname == 'pvusaPFW03' or $hostname =='pvusaPFW04' {

    sharefolder::create{'mycompany_root':
      sharename => 'mycompany_root',
      path => 'D:\mycompany_root',
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
	
	service { 'SMTPSVC':
	  ensure => 'running',
	  enable => true
    }	

  }
  
  schedtasks::create {'Adding schedule tasks for IIS log rotation':
    ruUsername  => 'yourdomain\daebuilduser',
    rpPassword  => 'yourpassword',
    scFrequency => 'DAILY',
    tn          => 'Cleaning IIS logfiles older than 30 days',
    tr          => 'powershell.exe -ExecutionPolicy Bypass -File \\yourdomain.mycompany.com\PDFS\Shares\team01\DevOps\Scripts\powershell\IIS_logcleanup.ps1',
    stTime      => '23:00',
    rl          => 'HIGHEST',
  }
}
