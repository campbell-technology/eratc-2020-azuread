#PCN.ps1
This script scans your AD domain for users who have changed their password within a specified interval. Run it as a scheduled task and it will email you when a user's password is changed.

###Prerequisites
This script must run on a Windows workstation or server with the Active Directory PowerShell module installed. To install it, visit [this page on 4sysops](https://4sysops.com/wiki/how-to-install-the-powershell-active-directory-module/ "this page on 4sysops") for instructions tailored to the OS version you're running.

###Configuration
There are a few variables you need to change for this script to work. They're all at the top of the script. Open it with a text editor and change the following:
- **mailTo** - The email address to send notifications to. You can specify more than one address, separated by a comma.
- **mailFrom** - The email address you want the notification to appear from. I suggest using a no-reply address or a mailbox you've set up only in your cloud provider, like your district's GA account.
- **SMTPSvr** - This will almost always be left as the default of *ketsmail.us*.
- **domainController** - Your district's D1 controller. 
- **searchBase** - Where to search for accounts.
- ** scriptRunInterval** - Set this to the same frequency as the script is run via scheduled task. This is so you don't get two notifications for the same account.

###How to use
Create a scheduled task on your Windows server to run this script once you edit it. Use the following parameters:
- **General:** Run whether user is logged on or not
- **Triggers:** Run at system startup. Repeat task every *n* minutes for a duration of Indefinitely. (where *n* is the same number of minutes you configured in **scriptRunInterval** inside the script)
- **Actions:** Start a program. 
Program/script: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
Arguments: `-File "C:\path\to\PCN.ps1`

When you save the scheduled task, be sure to enter a service account that is allowed to query Active Directory when asked for credentials.