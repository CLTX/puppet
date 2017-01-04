define schedtasks::changestatus(
  $status = $title,
  $tn
){

include schedtasks
	
exec { "$title":	
  command => "schtasks.exe /change /TN \"${tn}\" /${status}",
  unless  => "cmd.exe /c \"schtasks.exe /query /TN \"${tn}\" | findstr.exe /I \"${status}\" \" "
 }
}