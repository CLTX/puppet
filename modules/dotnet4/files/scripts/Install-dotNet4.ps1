# Check if .Net4 is installed on a server, if not, Install it.
#

# Import MParra functions
$executingScriptappname03ory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent;
Import-Module $executingScriptappname03ory\lib\MainFunctions.ps1;

#Must be into domain
$pathToDotNet="D:\Powershell-Scripts\Apps\dotNetFx40_Full_x86_x64.exe"


if (($args[0] -eq "help") -or ($args[0] -eq "--help"))
{
	write-host "Check/Install .NET 4";
	write-host "Usage: Install-dotNET4.ps1  ";
	exit;
} 



function Exists($computername)
{

 # Branch of the Registry 
 $Branch='LocalMachine' 
 
 
 # if are going to check if exist dotNet client, change "Full" for "Client"
 $keyversion="Full" 
try
{
 $SubBranch="SOFTWARE\\Microsoft\\NET Framework Setup\\NDP\\v4" 
 $registry=[microsoft.win32.registrykey]::OpenRemoteBaseKey($Branch,$computername) 
 $registrykey=$registry.OpenSubKey($Subbranch) 
 $SubKeys=$registrykey.GetSubKeyNames() 
}
catch
{
  return 0
}

 #.NET4(Server) exists?
 if($SubKeys -contains $keyversion) {return 1}
 return 0
}


function Run($computername){

   $mypath=("\\" + $computername + "\c$\temp")    
   if (-Not (Test-path $mypath)) {
		new-item $mypath -itemType appname03ory
	
	}
	
	
	Copy-Item -Path $pathTodotNet -Destination ("\\" + $computername + "\c$\temp")  -Force -Recurse
	(Get-WMIObject -Class Win32_Process -ComputerName localhost -List).Create("cmd.exe /c c:\temp\dotNetFx40_Full_x86_x64.exe  /q /norestart")
	write-host "Installing .Net ..."
	}


# Main

#Is the server responding?

if(IsAlive("localhost")) {
  #Does it have .Net4?
  if  (Exists("localhost")) {
	write-Host "dotNet4 already Installed."
  }
  else { 
	Run("localhost")
 }
}

