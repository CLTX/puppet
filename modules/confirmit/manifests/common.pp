class confirmit::common () {

include sharefolder

if $hostname != 'pvusaPFW01' and $hostname !='pvusaPFW02' {
  
    sharefolder::create{'confirmitdata':
      sharename => 'confirmitdata',
      path => 'D:\confirmit\data',
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
}
