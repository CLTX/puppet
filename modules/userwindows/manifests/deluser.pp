define userwindows::deluser (
  $user,
  $localgroup
) {

include userwindows

exec { "Deleting ${user} from ${localgroup}":
  command => "net.exe localgroup $localgroup ${user} /DELETE",
  onlyif  => "cmd.exe /c \"${userwindows::netPath} localgroup \"${localgroup}\" | find.exe \"${user}\"\""
}

}
