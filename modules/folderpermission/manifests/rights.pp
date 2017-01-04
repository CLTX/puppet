#Module to grant or deny prights into a folder/file for a specific user.
# the permited values for $rights could be: AppendData, ChangePermissions, Createappname03ories, CreateFiles, Delete, DeleteSubappname03oriesAndFiles, ExecuteFile, FullControl, Listappname03ory, Modify, Read, ReadAndExecute, ReadAttributes
# ReadData, ReadExtendedAttributes, ReadPermissions, Synchronize, TakeOwnership, Traverse, Write, WriteAttributes, WriteData, WriteExtendedAttributes

define folderpermission::rights (
  $path,
  $user,
  $rights,
  $permission
) {

$PSScript = '\\yourdomain.mycompany.com\PDFS\Shares\team01\DevOps\Scripts\powershell\permission.ps1'
$getpermission = '\\yourdomain.mycompany.com\PDFS\Shares\team01\DevOps\Scripts\powershell\getpermission.ps1'

include folderpermission
include appcmd

exec { "Changing rights on ${path} to user ${user} with ${rights} rights and grant ${permission}":
  command => "powershell.exe -ExecutionPolicy ByPass ${PSScript} \"${path}\" ${user} ${rights} ${permission}",
  onlyif  => "${folderpermission::powershellPath} -ExecutionPolicy Bypass ${getpermission} ${path} ${user} ${rights} ${permission}",
  }
}
