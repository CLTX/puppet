function grantpermission ([string]$Path="C:", [string]$User, [string]$Rights, [string]$Permission='Allow')
{
	$acl = Get-Acl $Path
	$acl.SetAccessRuleProtection($True, $False)
	$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$User","$Rights","ContainerInherit, ObjectInherit", "None", "Allow")
	$acl.AddAccessRule($accessRule)
	Set-Acl $Path $acl | Out-Null
}

function Run([string]$PathFolder, [string]$inUser, [string]$inPerm, [string]$inRights='Allow')
{
	if (Test-path $PathFolder)
	{
		grantpermission -Path $PathFolder -User $inUser -Permission $inPerm -Rights $inRights
	}
	else
	{
		write-Host "$PathFolder does not exist!";
		exit;
	} 	
}

# Main
$largo=$args.Length
if (($args[0] -eq "help") -or ($args[0] -eq "--help"))
{
	write-host "Set permission to a folder for a user";
    write-host "";
    write-host "Parameters:";
    write-host "";
    write-host "           -Path       Path to the folder to ser permissions";
    write-host "           -User       Name of the user (must include domain)";
	write-host "           -Rights     Rights to be set for the user, could be FullControl, Read, Write, Delete, Modify, etc.";
	write-host "           -Permission Permission to set (could be: Allow or Deny)";
    write-host "";
	write-host "Usage: permission.ps1 [Path] [User] [Rights] [Permission] ";
	exit;
}

if ($largo -eq 4)
	{ 
		Run -PathFolder $args[0] -inUser $args[1] -inRights $args[2] -inPerm $args[3]
	}
	else 
	{ 
		write-host "Usage: permission.ps1 [Path] [User] [Rights] [Permission]"
	}