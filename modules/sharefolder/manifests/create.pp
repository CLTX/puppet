#Module to grant or deny prights into a folder/file for a specific user.
# the permited values for $rights could be: AppendData, ChangePermissions, Createappname03ories, CreateFiles, Delete, DeleteSubappname03oriesAndFiles, ExecuteFile, FullControl, Listappname03ory, Modify, Read, ReadAndExecute, ReadAttributes
# ReadData, ReadExtendedAttributes, ReadPermissions, Synchronize, TakeOwnership, Traverse, Write, WriteAttributes, WriteData, WriteExtendedAttributes

define sharefolder::create (
  $sharename,
  $path,
  $user,
  $user2 = $user,
  $user3 = $user,
  $user4 = $user,
  $user5 = $user,
  $rights,
  $rights2 = $rights,
  $rights3 = $rights,
  $rights4 = $rights,
  $rights5 = $rights,
  $singleuser = 'true',
) {

include sharefolder

if $singleuser == 'true' {
  exec { "Creating Share ${sharename} on ${path} to user ${user} with ${rights} rights":
    command => "cmd.exe /C net share ${sharename}=${path} /GRANT:\"${user}\",${rights}",
    unless   => "cmd.exe /C net share | find.exe \"${sharename}\"", 
  }

} else {
  exec { "Creating Share ${sharename} on ${path} to users":
    command => "cmd.exe /C net share ${sharename}=${path} /GRANT:\"${user}\",${rights} /GRANT:\"${user2}\",${rights2} /GRANT:\"${user3}\",${rights3} /GRANT:\"${user4}\",${rights4} /GRANT:\"${user5}\",${rights5}  ",
    unless   => "cmd.exe /C net share | find.exe \"${sharename}\"", 
  }
}

}
