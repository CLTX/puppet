define puppetwindowsconf::admins(
  $puser = $title,
  $pgroup
){

include userwindows

  userwindows::adduser { "$puser":
    user       => $puser,
    localgroup => $pgroup
   }
}
