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

# This powershell script should be set as a user logoff script via Group Policy
# It will get the current username and computername and store this in a specified directory in an base64 encoded file

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
	Clear-LogonToken -EncodedComputer $computer
}

