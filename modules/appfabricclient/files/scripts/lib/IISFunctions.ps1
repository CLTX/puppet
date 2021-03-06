Import-Module WebAdministration

function VerifyOrCreateAppPool($appPool)
{
    if(DoesAppPoolExist $appPool.name)
    {
        SetAppPoolConfiguration $appPool.name $appPool.version $appPool.identity $appPool.password $appPool.pipelineMode
    }
    else
    {
        CreateAppPool $appPool.name
        SetAppPoolConfiguration $appPool.name $appPool.version $appPool.identity $appPool.password $appPool.pipelineMode
    }
}

function DoesAppPoolExist([string]$appPoolName)
{
    if (Get-WebAppPoolState $appPoolName -ErrorAction SilentlyContinue)
    {
        return $true
    }
    return $false
}

function CreateAppPool([string]$appPoolName)
{
    New-WebAppPool $appPoolName
}

function SetAppPoolConfiguration([string]$appPoolName,[string]$version, [string]$identity, [string]$password, [string]$pipelineMode)
{
    $appPoolConfig = Get-Item IIS:\AppPools\$appPoolName
    $changed = $false
    
    if ($appPoolConfig.processModel.userName -ne $identity)
    {
        $appPoolConfig.processModel.userName = $identity
        $changed = $true
    }
    if ($appPoolConfig.processModel.password -ne $password)
    {
        $appPoolConfig.processModel.password = $password
        $changed = $true
    }
    if ($appPoolConfig.processModel.identityType -ne "SpecificUser")
    {
        $appPoolConfig.processModel.identityType = "SpecificUser"
        $changed = $true
    }
    if ($appPoolConfig.managedRuntimeVersion -ne $version)
    {
        $appPoolConfig.managedRuntimeVersion = $version
        $changed = $true
    }
    if ($appPoolConfig.managedPipelineMode -ne $pipelineMode)
    {
        $appPoolConfig.managedPipelineMode = $pipelineMode
        $changed = $true
    }
    if ($changed)
    {
        $appPoolConfig | Set-Item
        Write-Output "Changes Applied in AppPool $appPoolName"
    }
    else
    {
        Write-Output "No Changes Discovered for AppPool $appPoolName"
    }
}