# Check if AppFabric is installed on a server, if not, Install it.
#

#Must be into domain
$pathToDotNet="C:\Powershell-Scripts\Apps\WindowsServerAppFabricSetup_x64_6.1.exe"

function Check-dotNet4($computername)
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
  write-Host ".NET 4 isn't Installed.`n`nPlease install it!"
  exit;
}
 #.NET4(Server) exists?
 if($SubKeys -contains $keyversion) 
 {
    write-Host ".NET 4 is Installed."
 }
 else
 {
    write-Host ".NET 4 isn't Installed.`n`nPlease install it!"
    exit;
 }
 }


if (($args[0] -eq "help") -or ($args[0] -eq "--help"))
{
	write-host "Check/Install AppFabric";
	write-host "Usage: Install-AppFabric.ps1  ";
	exit;
} 

function Exists
{
 Write-Host "Checking prerequisite:"
 Check-dotNet4
 Write-host "Checking if AppFabric is installed..."
 
 if(Get-HotFix -id KB970622 -ErrorAction SilentlyContinue)
 {
    return $true
  }
  else
  {
    return $false
  }
}

function Run($computername){

   $mypath=("\\" + $computername + "\c$\temp")    
   if (-Not (Test-path $mypath)) {
        new-item $mypath -itemType appname03ory
    
    }
    
    Copy-Item -Path $pathTodotNet -Destination ("\\" + $computername + "\c$\temp")  -Force -Recurse
    (Get-WMIObject -Class Win32_Process -ComputerName localhost -List).Create("cmd.exe /c c:\temp\WindowsServerAppFabricSetup_x64_6.1.exe /i CacheClient /SkipUpdates")
    write-host "Installing AppFabric ..."
}


# Main
  #Does it have AppFabric?
  if(Exists)
  {
      write-Host "AppFabric already Installed.";
  }
  else { 
     
      Run("localhost") | Wait-Process ;
 }