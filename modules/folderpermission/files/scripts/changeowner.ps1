function changeOwner([string]$Path, [string]$NewOwner)
{
    $acl = get-Acl $Path
    $acl.SetOwner([System.Security.Principal.NTAccount] "$NewOwner")
    $acl| set-acl $Path
}

function Run([string]$PathFolder, [string]$NOwner)
{
	if (Test-path $PathFolder)
	{
		changeOwner -Path $PathFolder -NewOwner $NOwner
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
	write-host "Change the Owner to a folder";
    write-host "";
    write-host "Parameters:";
    write-host "";
    write-host "           -Path       Path to the folder to change the owner";
    write-host "           -Owner      Name of the user or group to be new owner ";
	write-host "";
	write-host "Usage: changeowner.ps1 [Path] [Owner]";
	exit;
}

if ($largo -eq 2)
	{ 
		Run -PathFolder $args[0] -NOwner $args[1]
	}
	else 
	{ 
		write-host "Usage: changeowner.ps1 [Path] [Owner]"
	}