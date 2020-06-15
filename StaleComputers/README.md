# StaleComputers.ps1
This script scans your AD domain for computers that have not been turned on in a configurable length of time (default 4 months). Run it as a scheduled task and it will disable computer objects that have not been used in that length of time.

### Prerequisites
This script must run on a Windows workstation or server with the Active Directory PowerShell module installed. To install it, visit [this page on 4sysops](https://4sysops.com/wiki/how-to-install-the-powershell-active-directory-module/ "this page on 4sysops") for instructions tailored to the OS version you're running.

### Configuration
There are a few variables you need to change for this script to work. They're all at the top of the script. Open it with a text editor and change the following:
- **CutoffDays** - the number of days for a disused computer to be considered "stale". Defaults to 120 days.
- **SearchBase** - Where to search for computer objects. You will probably want your district's Workstations OU.
- **TargetOU** - Where to move disabled computer objects to.
- **MailFrom** - The email address you want the notification to appear from. I suggest using a no-reply address or a mailbox you've set up only in your cloud provider, like your district's GA account.
- **MailTo** - The email address to send notifications to. You can specify more than one address, separated by a comma.
- **SMTPSvr** - This will almost always be left as the default of *ketsmail.us*.

### How to use
Create a scheduled task on your Windows server to run this script once you edit it. Use the following parameters:
- **General:** Run whether user is logged on or not
- **Triggers:** Run on a schedule. Monthly at 6:00 AM on day 1 of all months.
- **Actions:** Start a program. 
Program/script: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
Arguments: `-File "C:\path\to\StaleComputers.ps1`

When you save the scheduled task, be sure to enter a service account that is allowed to modify computer objects in Active Directory when asked for credentials. This service account must be in `DIST Workstation Admins` or `DIST Support Admins` to modify computer objects.