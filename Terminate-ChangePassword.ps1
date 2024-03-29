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
Import-Module activedirectory

function New-Password
{
param
(
      [int]$length,
      [switch]$lowerCase,
      [switch]$upperCase,
      [switch]$numbers,
      [switch]$specialChars
)
 
BEGIN
{
      # Usage Instructions
      function Usage()
      {
            Write-Host ''
            Write-Host 'FUNCTION NAME: New-Password' -ForegroundColor White
            Write-Host ''
            Write-Host 'USAGE'
            Write-Host '    New-Password -length 10 -upperCase -lowerCase -numbers'
            Write-Host '    New-Password -length 10 -specialChars'
            Write-Host '    New-Password -le 10 -lo -u -n -s'
            Write-Host '    New-Password'
            Write-Host ''
            Write-Host 'DESCRIPTION:'
            Write-Host ' Generates a random password of a given length (-length parameter)'
            Write-Host ' comprised of at least one character from each subset provided'
            Write-Host ' as a switch parameter.'
            Write-Host ''
            Write-Host 'AVAILABLE SWITCHES:'
            Write-Host ' -lowerCase    : include all lower case letters'
            Write-Host ' -upperCase    : include all upper case letters'
            Write-Host ' -numbers      : include 0-9'
            Write-Host ' -specialChars : include the following- !@#$%^&*()_+-={}[]<>'
            Write-Host ''
            Write-Host 'REQUIREMENTS:'
            Write-Host ' You must provide the -length (four or greater) and at least one character switch'
            Write-Host ''
      }
 
      function generate_password
{
            if ($lowerCase)
            {
                  $charsToUse += $lCase
                  $regexExp += "(?=.*[$lCase])"
            }
            if ($upperCase)
            {
                  $charsToUse += $uCase
                  $regexExp += "(?=.*[$uCase])"
            }
            if ($numbers)
            {
                  $charsToUse += $nums
                  $regexExp += "(?=.*[$nums])"
            }
            if ($specialChars)
            {
                  $charsToUse += $specChars
                  $regexExp += "(?=.*[\W])"
            }
 
            $test = [regex]$regexExp
            #$rnd = New-Object System.Random
            $seed = ([system.Guid]::NewGuid().GetHashCode())
            $rnd = New-Object System.Random ($seed)
 
            do
            {
                  $pw = $null
                  for ($i = 0 ; $i -lt $length ; $i++)
                  {
                        $pw += $charsToUse[($rnd.Next(0,$charsToUse.Length))]
                        #Start-Sleep -milliseconds 20
                  }
            }
            until ($pw -match $test)
 
            return $pw
      }
 
      # Displays help
      if (($Args[0] -eq "-?") -or ($Args[0] -eq "-help"))
      {
            Usage
            break
      }
      else
      {
            $lCase = 'abcdefghijklmnopqrstuvwxyz'
            $uCase = $lCase.ToUpper()
            $nums = '1234567890'
            $specChars = '!@#$%^&*()_+-={}[]<>'
      }
}
 
PROCESS
{
      if (($length -ge 4) -and ($lowerCase -or $upperCase -or $numbers -or $specialChars))
      {
            $newPassword = generate_password
      }
      else
      {
            Usage
            break
      }
 
      $newPassword
}
 
END
{
}
}

#Generate Random Password
$Password = New-Password -le 25 -lo -u -n -s
$PWD = ConvertTo-SecureString -String $Password -AsPlainText -Force

#Submit ticket to Helpdesk for Telephony
$user = Get-ADUser -Identity $username -Properties OfficePhone,PhysicalDeliveryOfficeName
$phone = $user.OfficePhone
$fullname = $user.GivenName + " " + $user.surname
$office = $user.physicalDeliveryOfficeName

#Set Password
Set-ADAccountPassword -Identity $username -NewPassword $PWD -Reset

#Clear Account Fields
Set-ADUser -Identity $username -StreetAddress $null -POBox $null -City $null -State $null -PostalCode $null -HomeDirectory $null -ScriptPath $null -HomeDrive $null -Title $null -Department $null -Company $null -Office $null -OfficePhone $null

$DeleteDate = ((Get-Date).AddDays(30)).ToShortDateString()

Set-ADUser -Identity $username -Description "Delete $DeleteDate"

$SMTPSubject = "Automated Term Process Complete for $username"
$SMTPBody = "The Automated Term Process for $Username has completed.  The user account has been disabled."