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

Param($username)

Import-Module ActiveDirectory

$user = Get-ADUser $username -Properties homeDirectory
$HomeDirectory = $user.homedirectory

$ArchiveFolder = "\\fileserver\Data\Backups\$username-Waiting\H"
If($HomeDirectory -ne $null)
{
If((Test-Path -Path $ArchiveFolder) -eq $true)
{
Robocopy $HomeDirectory $ArchiveFolder /Copy:DATO /MIR /ZB /R:3 /W:15 /Log:C:\ProgramData\Robocopy\$username-H.log /TEE

Copy-Item -Path C:\ProgramData\Robocopy\$username-H.log -Destination \\fileserver\Data\Backups\$username-waiting\logs

Start-Sleep 10

	Remove-Item $HomeDirectory -Recurse -Force

}
Else
{
Write-Error "The Archive Folder does not exist."
}
}
Else
{
Write-Error "The user does not have an H drive."
}