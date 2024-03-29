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

Param([string]$username)

Import-Module ActiveDirectory

Set-ADUser -Identity $username -Enabled:$false -Server DC01.homedomain.private

Get-ADUser -identity $username | Move-ADObject -TargetPath "ou=Disabled Accounts,dc=homedomain,dc=private" -Server DC01.homedomain.private
