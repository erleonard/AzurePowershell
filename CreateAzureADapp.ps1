<#	
	========================================================================================
	 Created on:   	9/6/2017
	 Created by:   	Eric Leonard
	 URL: http://erleonard.me 	
     Filename: CreateAzureADapp.ps1
     Description: Sample script to create Azure AD application for Commvault Azure Client
	========================================================================================
#>

try
{
    Write-Output "Checking for active session"
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


#Get subscription information
$azureSubscription = Get-AzureRmContext
$tenantId = $azureSubscription.Tenant.TenantId
$id = $azureSubscription.Subscription.SubscriptionId


#Create a new AD Application
$AzureADAppName = "CVSAMPLE"
$AzureADAppURI = "http://$AzureADAppName"
$AzureADAppPW = "YourComplexPassw0rd"

Write-Output "Creating a new Application in AAD"
$AzureADApp = New-AzureRmADApplication -DisplayName $AzureADAppName -HomePage $AzureADAppURI  -IdentifierUris $AzureADAppURI -Password $AzureADAppPW
$AzureADAppId = $AzureADApp.ApplicationId

Write-Output "Creating Service Principal Name for Azure AD Application"
$AzureADAppSPN = New-AzureRmADServicePrincipal -ApplicationId $AzureADAppId

#Waiting 20 seconds to ensure the new SPN is created and registered
Start-Sleep -Seconds 20

#Role assignment did not work#
Write-Output "Assigning role Contributor to $AzureADAppName ($AzureADAppId)"
$AzureADAppRBAC = New-AzureRmRoleAssignment -Scope /subscriptions/$id -RoleDefinitionName Contributor -ServicePrincipalName $AzureADAppId

Write-Output "Azure AD Application creation for Commvault"
Write-Output "***************************************************************************"
Write-Output "Subscription Id: $id"
Write-Output "Tenant Id: $tenantId"
Write-Output "Application Id: $AzureADAppId"
Write-Output "Application Password: $AzureADAppPW"
Write-Output "***************************************************************************"