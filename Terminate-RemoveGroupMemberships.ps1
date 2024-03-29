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

param([string]$username)

Import-Module ActiveDirectory

$GroupList = Get-ADPrincipalGroupMembership -Identity $username -Server DC01.homedomain.private
$Groups = $GroupList | Select-Object Name

ForEach($Group in $Groups)
{
	$GroupName = $Group.Name
	If($GroupName -ne "Domain Users")
	{
		Remove-ADGroupMember -Identity $Groupname -Members $username -Server DC01.homedomain.private -Confirm:$false
	}
}

