Function SearchKB($KBID)
{
    $found = $false            

    # Get all the info using WMI 
    $results = Get-WmiObject `
                -class “Win32_QuickFixEngineering” `
                -namespace "root\CIMV2"            

    foreach ($objItem in $results)
    {
        if ($objItem.HotFixID -match $KBID)
        {
            $found = $true
            break
        }
    }            

    $found
}

# Purpose: To check whether a service is installed and status.
function CheckSvcStatus()
{
    param([string]$ComputerName="localhost",[string]$svcName="")
    Clear-Host
    $service = Get-Service -ComputerName $ComputerName -name $svcName -ErrorAction SilentlyContinue
    if ( ! $service )
        { 
            Write-Host "$svcName is not installed on this computer. `n"
            Write-Host "Did you really mean?: $svcName" 
            return $false
        }
    else { 
        Write-Host $service.Name "'s status is: " $service.Status 
        return $true
        }
}

# Function to start a named service
function Start-Svc()
{
    param([string]$ComputerNAme="localhost",[string]$svcName="")
    
    $servicePrior = Get-Service $svcName
    #Set-Service $svcName -startuptype manual
    
    $val=CheckSvcStatus -svcName $svcName
    if( $val )
    {
        Start-Service $svcName
        $serviceAfter = Get-Service $svcName
        "$svcName is now " + $serviceAfter.status
    }
}

#Purpose: Stop a service
function Stop-Svc()
{
    param([string]$ComputerName="localhost",[string]$svcName="")
    $servicePrior = Get-Service $svcName
    $val=CheckSvcStatus -svcName $svcName
    if( $val )
    {
        Stop-Service $svcName -Force
        $serviceAfter = Get-Service $svcName
        "$svcName is now " + $serviceAfter.status
    }
}

#Purpose: restart a service
function ReStart-Svc()
{
    param([string]$ComputerName="localhost",[string]$svcName="")
    $servicePrior = Get-Service $svcName
    $val=CheckSvcStatus -svcName $svcName
    if( $val )
    {
        #(Get-WmiObject Win32_Service -ComputerName $ComputerName -Filter "Name='$svcName'").StopService()
        #(Get-WmiObject Win32_Service -ComputerName $ComputerName -Filter "Name='$svcName'").StartService()
        Stop-Svc -svcName $svcName
        Write-Host "Trying to start $svcName"
        Start-Svc -svcName $svcName
        #$serviceAfter = Get-Service $svcName
        #"$svcName is now " + $serviceAfter.status
    }
}

#Purpose: Check is a machine is Alive
function IsAlive($Machine)
{
    #param([string]$Machine);
    
    $Pinged = Get-WmiObject Win32_PingStatus -f "Address='$Machine'"
    if($Pinged.StatusCode -eq 0) 
    {
             #write-host "IS ALIVE!"
             return $true
    }
     else
     {
        #write-host "IS DEAD!"
        return $false
     }
}

#Purpose: reboot a machine
function reStart()
{
   param([string]$Machine,[string]$credentials);
 
 if(!$credentials)
 {  
   Write-Host "Rebooting Machine: $Machine";
   #(gwmi win32_operatingsystem -ComputerName $Machine).Win32Shutdown(6);
   restart-computer -computername $Machine -force # -throttlelimit 1
 }
    else{ 
        Write-Host "Rebooting Machine: $Machine";
        Write-host "using user: $credentials";
        restart-computer -computername $Machine -force -credential $credentials
        }
}


#Purpose: ask a password as input
function Get-Password()
{ 
    read-host -assecurestring | convertfrom-securestring | out-file .\cred.txt
    $password = Get-Content .\cred.txt | Convertto-SecureString
    [String]$stringValue = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password));
    return $stringValue;
}



Function Get-ScheduledTask
	{
	param([string]$ComputerName = "localhost")
	Write-Host "Computer: $ComputerName"
    $val=IsAlive($ComputerName)
    if ($val)
    {
        if ($ComputerName -eq "localhost")
            {
                $Command = "schtasks.exe /query"
	           Invoke-Expression $Command
            }
            
        if ($ComputerName -ne "localhost")
        {
            $Command = "schtasks.exe /query /s $ComputerName"
	        Invoke-Expression $Command
	        Clear-Variable Command -ErrorAction SilentlyContinue
	        Write-Host "`n"
            }
     }
     else
     {
            write-host "$args is dead or doesn't exist, Check the server name";
     }
     
    }
 
# EXAMPLE: Get-ScheduledTask -ComputerName mparra-a230 
 
Function Remove-ScheduledTask
	{
	param(
	[string]$ComputerName = "localhost", [String]$User,[string]$TaskName = "blank"
	)
    $val = IsAlive($ComputerName)
    if($val)
    {
	   If ((Get-ScheduledTask -ComputerName $ComputerName ) -match $TaskName)
		{
		    $Command = "schtasks.exe /delete /s $ComputerName /tn $TaskName /F"
			Invoke-Expression $Command
			Clear-Variable Command -ErrorAction SilentlyContinue
		}
	   Else
		  {
		      Write-Warning "Task $TaskName not found on $ComputerName"
		  }
	   }
       else
       {
            Write-Host "usage: Remove-ScheduledTask -ComputerName computer -TaskName taskname"
       }
    }
 
# EXAMPLE: Remove-ScheduledTask -ComputerName Server01 -TaskName MyTask
 
Function Create-ScheduledTask
	{
	param(
	[string]$ComputerName = "localhost",
    [string]$RunAsUser = "SYSTEM",
	[string]$TaskName = "Defrag",
	[string]$TaskRun = "c:\windows\system32\defrag.exe  /C /H",
	[string]$Schedule = "Weekly",
	[string]$Days = "SAT",
	[string]$StartTime = "00:00",
	[string]$EndTime = "07:00",
	[string]$User="SYSTEM"
	)
	if(IsAlive($ComputerName))
        {
           $Command = "schtasks.exe /create /s $ComputerName /ru `"$RunAsUser`" /tn `"$TaskName`" /tr `"$TaskRun`" /sc $Schedule /d `"$Days`" /st $StartTime /et $EndTime /F"
           Invoke-Expression $Command;
	       Clear-Variable Command -ErrorAction SilentlyContinue
	       Write-Host "`n"
       }
	       
    }
 
# EXAMPLE: Create-ScheduledTask -ComputerName mparra-a230 -User certificacl\mparra -TaskName "defrag1" -TaskRun "c:\windows\system32\defrag.exe /C /H" -Schedule Weekly -Days MON -StartTime "00:00"