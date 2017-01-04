#Change the ownership to a folder or a file, $path must be the full path to change the ownership, and $user must be the user or the group to 
define folderpermission::changeowner (
  $path,
  $user,
) {

$PSScript = '\\yourdomain.mycompany.com\PDFS\Shares\team01\DevOps\Scripts\powershell\changeowner.ps1'
$getownerpermission = '\\yourdomain.mycompany.com\PDFS\Shares\team01\DevOps\Scripts\powershell\getownerpermission.ps1'

include folderpermission

exec { "Changing Ownership to ${path} with user ${user}":
  command => "powershell.exe -ExecutionPolicy Bypass ${PSScript} ${path} ${user}",
  onlyif  => "powershell.exe -ExecutionPolicy Bypass ${getownerpermission} ${path} ${user}",
  }
}
