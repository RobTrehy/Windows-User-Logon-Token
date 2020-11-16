# Windows User Logon Token

A powershell script designed to be added to Group Policy logon/logoff events.
As a user logs onto a computer, a "token" will be generated. The token contains the username, computer name and date/time of the logon. When a user logs off, the token is removed.
Optionally, the user can be restricted to only one consecutive logon and will be notified and automatically logged off if they have exceeded this limit.

## Installation

Download the 3 required files (and optional `RestrictedLogon.ps1`, if required) and save them to a shared folder where a standard user can access them.
The scripts will be executed in the context of the logged on user, so if script restrictions are in place, these files must all be whitelisted.

Open the file `SharedCode.ps1` and modify the variable `$tokenPath` to point to your DataStore.
**You must include the trailing slash!**

```powershell
$tokenPath = "\\UNC\Path\To\DataStore\"
```
The DataStore location must have modify permissions for all users who have the logon script applied.
If you wanted additional security, you could set the permissions for creator owner. No support is provided for this.

## Group Policy Configuration

Create or edit a Group Policy Object to contain the logon scripts for the users who you wish to log (or restrict).

Navigate to User Configuration > Windows Settings > Scipts (Logon/Logoff) > Logon.
Add the `Logon.ps1` file, using the full UNC path. No parameters are required*.
*Add the `RestrictedLogon.ps1` file **instead**, if you wish to restrict the user to one consecutive logon.*

Navigate to User Configuration > Windows Settings > Scipts (Logon/Logoff) > Logoff.
Add the `Logoff.ps1` file, using the full UNC path. No parameters are required*.
The `Logoff.ps1` file is required for both unrestricted and restricted logon tokens.

\* Depending on your setup, you may need to use the parameter: `-ExecutionPolicy Bypass`

## Locating a logged on user
You can use the `LocateUser.ps1` file to locate all sessions where a user is currently logged on, according to their token.
When prompted, enter the username of the user you wish to locate. A table of all current logon sessions will be displayed.
If logon sessions are found, you will be receive an option to remotely log off a user from a session, enter `Y` or `N`.

If `Y` is entered, at the next prompt, enter the session ID from the table above of the session you wish to log off.
You will be prompted for the credentials of an administrative user on the remote computer. The user will be immediately logged off, without any warning.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Credits
[SMSAgent](https://smsagent.wordpress.com/2017/08/24/a-customisable-wpf-messagebox-for-powershell/) - For the customisable WPF message for powershell.

## License
[MIT](https://choosealicense.com/licenses/mit/)