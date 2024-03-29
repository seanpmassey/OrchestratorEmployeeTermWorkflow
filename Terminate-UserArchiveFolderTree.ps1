<#
	.SYNOPSIS
		Job to disable user account and move to terminated users OU.

	.DESCRIPTION
		This job is part of the automated user termination process.  It will disable a user account and move it to the terminated users OU.

	.PARAMETER  username
		The Active Directory Username of the account that is being terminated.

	.EXAMPLE
		PS C:\> Terminate-DisableUser.ps1 -username user1

	.NOTESipad1
		Additional information about the function go here.
#>

param($username)

$folderpath = "\\fileserver\Data\Backups"
$foldername = "$username-Waiting"

New-Item -Name $foldername -ItemType Directory -Path $folderpath -ErrorAction Continue

New-Item -Name C -ItemType Directory -Path $folderpath\$foldername -ErrorAction Continue
New-Item -Name H -ItemType Directory -Path $folderpath\$foldername -ErrorAction Continue
New-Item -Name Logs -ItemType Directory -Path $folderpath\$foldername -ErrorAction Continue

