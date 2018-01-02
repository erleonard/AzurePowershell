<#	
	=========================================================================================================================================
	 Created on:   	1/1/2018
     Created by:   	Frank Boucher (https://github.com/FBoucher/AzurePowerTools)
     Modified by: Eric Leonard
	 URL: http://erleonard.me 	
     Filename: Remove-AzureSubscriptionContent.ps1
     Description: Sample script to delete contents of Azure Subscription that is not the Cloud shell or Resource Groups that have locks.
	==========================================================================================================================================
#>

[CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        $SubscriptionName
    )

# Login
try
{
    Write-Host "Checking for active session" -ForegroundColor Cyan
    Get-AzureRmContext | Out-Null
}
catch [System.Management.Automation.PSInvalidOperationException]
{
    Write-Warning -Message 'No session detected. Prompting for login.'
    Login-AzureRmAccount
}
catch
{
    throw $_
}

Write-Host "You select the following subscription. (it will be display 15 sec.)" -ForegroundColor Cyan
Get-AzureRmSubscription -SubscriptionName $SubscriptionName | Select-AzureRmSubscription 

#Get all the resources groups, with the exception of the cloud shell
$allRG = Get-AzureRmResourceGroup | Where-Object ResourceGroupName -NotLike "*cloud-shell*"

#Gather all Resource Groups and check to see if there is a lock
$Results = foreach ($RG in $allRG) {
    $ResourceLocks = Get-AzureRmResourceLock -ResourceGroupName $RG.ResourceGroupName

    If ($ResourceLocks.count -eq 0) {
        $RGResourceLock = 'No'
    }
    else {
        $RGResourceLock = 'Yes'
    }

    [PSCustomObject]@{
        ResourceGroup = $RG.ResourceGroupName
        ResourceLock = $RGResourceLock
    }
}

$Results | FT -autosize

$lastValidation = Read-Host "Do you wich to delete ALL the resouces previously listed that are not locked? (YES/ NO)"

if($lastValidation.ToLower().contains("y")) {
    foreach ( $rg in $Results){

        If ($RG.ResourceLock -ne "Yes") {
            Write-Host "Deleting " $rg -ForegroundColor Cyan 
            Remove-AzureRmResourceGroup -Name $rg.ResourceGroup -Force -WhatIf
        }
    }
}else{
     Write-Host "Aborded. Nothing was deleted." -ForegroundColor Cyan
}