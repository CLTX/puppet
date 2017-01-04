define schedtasks::end(
  $tn
){

include schedtasks
	
exec { "Ending ${tn}":	
  command => "schtasks.exe /END /TN \"${tn}\"",
  onlyif  => "cmd.exe /c \"schtasks.exe /query /TN \"${tn}\" | findstr.exe /I \"ready\" \" "
 }
}