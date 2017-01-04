define puppetwindowsconf::noadmins(
  $puser = $title,
  $pgroup
){

include userwindows

  userwindows::deluser { "$puser":
    user       => $puser,
    localgroup => $pgroup
   }
}
