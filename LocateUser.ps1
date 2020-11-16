<#
	Copyright 2020 Rob Trehy
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
	(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, 
	merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
	IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

# This powershell script is to be used by administrators to find out which computer(s) a user is logged onto
# It will get the current username and computername and store this in a specified directory in an base64 encoded file

#######################################################################################
# DO NOT EDIT BELOW THIS LINE														  #
#######################################################################################

. .\SharedCode.ps1

# Request the username from the user
$username = Read-Host "Please enter the username of the user you would like to find"

# Get the logged on username and encode it, stripping any "=" characters
$EncodedUser = EncodeString -String $username
$user = $EncodedUser -replace '[=]'
# Set the token path
$userToken = "$($tokenPath)$($user).tok"


$tokenSet = Test-Path $userToken	
If($tokenSet) {
	Write-Host "User has been located on the following computers:"
	$computers = @()

	# Get the current content
	$TokenData = Get-Content $userToken
	$TokenData = DecodeString -String $TokenData
	$TokenData = $TokenData | ConvertFrom-Json

	if ($TokenData.length -eq $null) {
		# Single Logon Exists
		$computers += [pscustomobject]@{'Session' = 0; 'Computer' = DecodeString -String $TokenData.computer;'Logon Time' = $TokenData.date}
	} else {
		$TokenData = $TokenData | ConvertFrom-Json
		# Loop through all records and add to session list
		for($i = 0; $i -lt $TokenData.Length; $i++)
		{
			$computers += [pscustomobject]@{'Session' = $i; 'Computer' = DecodeString -String $TokenData[$i].computer;'Logon Time' = $TokenData[$i].date}
		}
	}

	$computers | Format-Table Session, Computer, "Logon Time"

	$Logoff = Read-Host "Would you like to log the user off one of these sessions? (Y/N)"
    Switch ($Logoff) 
     { 
       Y { 
		   $session = Read-Host "Enter the Session ID from the above table to log off"
		   Remote-Logoff -EncodedComputer $TokenData[$session].computer -EncodedUser $EncodedUser
		 } 
       Default { Pause } 
     } 
} Else {
	Write-Host "User does not currently have any active logon sessions."
	Pause
}