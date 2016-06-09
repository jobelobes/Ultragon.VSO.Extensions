[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $ConnectedServiceName,

    [String] [Parameter(Mandatory = $true)]
    $WebSiteName,

    [String] [Parameter(Mandatory = $false)]
    $WebSiteLocation,

    [String] [Parameter(Mandatory = $true)]
    $OriginSlot,

    [String] [Parameter(Mandatory = $true)]
    $DestinationSlot
)

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"


# adding System.Web explicitly, since we use http utility
Add-Type -AssemblyName System.Web

Write-Verbose "Entering script Swap-AzureWebDeployment.ps1"

Write-Host "ConnectedServiceName= $ConnectedServiceName"
Write-Host "WebSiteName= $WebSiteName"
Write-Host "OriginSlot= $OriginSlot"
Write-Host "DestinationSlot= $DestinationSlot"

$azureWebSiteError = $null
$publishAzureWebSiteError = $null;

#Get website
Write-Host "Get-AzureWebSite -Name $WebSiteName -ErrorAction SilentlyContinue -ErrorVariable azureWebSiteError -Slot $DestinationSlot"
$azureWebSite = Get-AzureWebSite -Name $WebSiteName -ErrorAction SilentlyContinue -ErrorVariable azureWebSiteError -Slot $DestinationSlot
if($azureWebSiteError) {
    $azureWebSiteError | ForEach-Object { Write-Warning $_.Exception.ToString() }
}

#Swap websites
if($azureWebSite)
{
    Write-Host "WebSite '$($azureWebSite.Name)' found."

    $azureCommand = "Switch-AzureWebsiteSlot"
    $azureCommandArguments = "-Name `"$WebSiteName`" -Slot1 `"$OriginSlot`" -Slot2 `"$DestinationSlot`" -Force -ErrorVariable publishAzureWebsiteError"

    $finalCommand = "$azureCommand $azureCommandArguments"
    Write-Host "$finalCommand"
    Invoke-Expression -Command $finalCommand

    $matchedWebSiteName = $azureWebSite.EnabledHostNames | Where-Object { $_ -like '*.scm*azurewebsites.net*' } | Select-Object -First 1
    if ($matchedWebSiteName) {
        
    }
}
else
{
    Write-Host "WebSite '$WebSiteName' not found. Cannot swap website without one existing."
}

Write-Verbose "Leaving script Swap-AzureWebDeployment.ps1"