class confirmit::batchconfig () {

include confirmit::config
include confirmit::common
  
  sharefolder::create{'SMTPSink':
    sharename => 'SMTPSink',
    path => 'D:\SMTPSink',
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

  
  sharefolder::create{'CCL_Batch':
    sharename => 'CCL_Batch',
    path => 'D:\confirmit\prog\Services\Tasks\CustomCode',
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
}