<#	
	========================================================================================
	 Created on:   	10/12/2017
	 Created by:   	Eric Leonard
	 URL: http://erleonard.me 	
     Filename: ASR-EmailNotification.ps1
     Description: Sample script to send email notifications in ASR Recovery Plans
	========================================================================================
#>

param ( 
    [Object]$RecoveryPlanContext
)

$MailParameters = @{
    From       = ''
    To         = ''
    SmtpServer = 'smtp.office365.com'
    Port       = '587'
    Credential = Get-AutomationPSCredential -Name "AutomationAccount"
    UseSsl     = $true
}

$RecoveryPlanName = $RecoveryPlanContext.RecoveryPlanName
$GroupID = $RecoveryPlanContext.GroupID

switch ($RecoveryPlanContext.FailoverType)
{
"Test" {
    $MailParameters.add("Subject","Test Failover for $RecoveryPlanName")
    $MailParameters.add("Body","$GroupID is now running.")
}
"Planned" {
    $MailParameters.add("Subject","Planned Failover for $RecoveryPlanName")
    $MailParameters.add("Body","$GroupID is now running.")
 }
"Unplanned" { 
    $MailParameters.add("Subject","Unplanned Failover for $RecoveryPlanName")
    $MailParameters.add("Body","$GroupID is now running.")
 }
default { Write-Output ("Runbook aborted because there no failover type was specified") }
}

Send-MailMessage @MailParameters