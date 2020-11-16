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


# This powershell script should be set as a user logon script via Group Policy
# It will get the current username and computername and store this in a specified directory in an base64 encoded file

###################################################################################
# This version of the script will restrict the user to only one concurrent logon. #
###################################################################################
# DO NOT EDIT BELOW THIS LINE													  #
###################################################################################

. .\SharedCode.ps1


# Get the logged on username and encode it, stripping any "=" characters
$user = EncodeString -String $env:username
$user = $user -replace '[=]'

# Get the current computer and encode it
$computer = EncodeString -String $env:computername

# Set the token path
$userToken = "$($tokenPath)$($user).tok"


$tokenSet = Test-Path $userToken	
If($tokenSet) {
	# User has an open token, get contents and decode
	$tokenData = Get-Content $userToken
	$tokenData = DecodeString -String $tokenData | ConvertFrom-Json

	# Check if the computer is the same
	If ($tokenData.computer -eq $computer) {
		# This is the same computer - update logon time in token
		Create-LogonToken -EncodedComputer $computer
	} else {
		$Content = "You are only allowed to logon to one computer at a time.                                            
You must log off from the computer $(DecodeString -String $tokenData.computer) before you can logon here.
                                                                                                                
This computer will log off automatically in 30 seconds."
 
		$Params = @{
			Title = "Logons Exceeded"
			TitleFontSize = 30
			TitleTextForeground = 'Red'
			TitleFontWeight = 'Bold'
			CornerRadius = 0
			ButtonType = 'None'
			Timeout = 30
		}
		New-WPFMessageBox @Params -Content $Content

		Write-Host "logoff command"
		shutdown -L
	}
} Else {
	Create-LogonToken -EncodedComputer $computer
}

