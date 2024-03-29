<#
	.SYNOPSIS
		Job to disable user account and move to terminated users OU.

	.DESCRIPTION
		This job is part of the automated user termination process.  It will disable a user account and move it to the terminated users OU.

	.PARAMETER  username
		The Active Directory Username of the account that is being terminated.

	.EXAMPLE
		PS C:\> Terminate-DisableUser.ps1 -username user1

	.NOTES
		Additional information about the function go here.
#>

param($username,$ForwardToUsername)

Import-Module ActiveDirectory
. 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchangeTest.ps1'
Connect-ExchangeServer -auto -allow-clobber

#Set Forwarding and email new recipient to test
$User = Get-ADUser $username -Properties mail
$FullName = $User.GivenName + " " + $User.Surname
$Email = $User.mail

$mailboxpresent = Get-Mailbox -Identity $username -ErrorAction SilentlyContinue

If($mailboxpresent -ne $null)
{
$ForwardingUser = Get-ADUser $ForwardToUsername -Properties mail
$ForwardToEmail = $ForwardingUser.mail

Set-Mailbox -Identity $username -ForwardingAddress $ForwardToEmail -Confirm:$false -Force

Start-Sleep 10

#Disable ActiveSync
Set-CASMailbox -Identity $username -ActiveSyncEnabled $false

#ExportEmail
$FolderPath = "\\fileserver\Data\Backups"
$TestFolder = Test-Path -Path "$FolderPath\$Username-Waiting"

If($TestFolder -ne $false)
	{
		New-MailboxExportRequest -Mailbox $username -FilePath "$folderpath\$username-waiting\$username.pst"
		Write-Output "The mailbox export request has been submitted.  The export file $username.pst will be placed in $folderpath\$username-waiting."
	}
Else
	{
		New-MailboxExportRequest -Mailbox $username -FilePath "$folderpath\$username.pst"
		Write-Output "The mailbox export request has been submitted.  The folder structure has not been created.  The export file $username.pst will be placed in $folderpath."
	}

}
