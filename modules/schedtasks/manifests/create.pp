define schedtasks::create(
  $ruUsername,
  $rpPassword,
  $scFrequency,
  $tn,
  $tr,
  $stTime = NIL,
  $rl = 'HIGHEST'
  
){

include schedtasks

if $stTime != 'NIL' {	
    exec { "$title":	
      command => "schtasks.exe /create /RU $ruUsername /RP $rpPassword /SC $scFrequency /TN \"$tn\" /tr \"$tr\" /ST $stTime /RL $rl",
      unless  => "cmd.exe /c \"schtasks.exe /query /TN \"${tn}\" | findstr.exe /I \"${tn}\" \" "
     }
   } else {
    exec { "$title":	
      command => "schtasks.exe /create /RU $ruUsername /RP $rpPassword /SC $scFrequency /TN \"$tn\" /tr \"$tr\" /RL $rl",
      unless  => "cmd.exe /c \"schtasks.exe /query /TN \"${tn}\" | findstr.exe /I \"${tn}\" \" "
     }
   }
}