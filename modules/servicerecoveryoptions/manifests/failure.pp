define servicerecoveryoptions::failure (
  $service,
  $action1,
  $action2 = $action1,
  $action3 = $action1,
  $delay1,
  $delay2 = $delay1,
  $delay3 = $delay1
) {

include servicerecoveryoptions

exec { "Set failure actions to ${service}}":
  command => "sc.exe failure ${service} reset= 0 actions= ${action1}/${delay1}/${action2}/${delay2}/${action3}/${delay3}" ,
  unless  => "cmd.exe /c \"sc.exe qfailure ${service} | find.exe \"RESTART -- Delay = ${delay1} milliseconds.\"  | find.exe \"FAILURE_ACTIONS\" \" ",
}

}