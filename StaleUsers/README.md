# Stale User Search
There is a cmdlet in PowerShell that will allow you to search for user accounts that have not logged in for a period of time.

### Prerequisites
This script must run on a Windows workstation or server with the Active Directory PowerShell module installed. To install it, visit [this page on 4sysops](https://4sysops.com/wiki/how-to-install-the-powershell-active-directory-module/ "this page on 4sysops") for instructions tailored to the OS version you're running.

### How to Use
- Open PowerShell as a user that is allowed to query Active Directory. By default, any authenticated user can do this.
- Run the following PowerShell command:
`Search-ADAccount -AccountInactive -TimeSpan 90 -ResultPageSize 2000 -ResultSetSize $null | Where {$_.Enabled -eq $true} | Select-Object Name,SamAccountName,DistinguishedName | Export-Csv -Path "C:\Temp\InactiveUsers.csv" -NoTypeInformation`

### Caveats
- This script only searches your on-premises Active Directory. If a user only logs in via Azure AD or Office 365, the last logon timestamp will not be updated on the local directory.
- The -TimeSpan parameter of `Search-ADAccount` is used to specify the number of days that have passed since the account last logged on. In the example above, the value is 90 days. In practice, you may want to use 180 days (approximately 6 months), 365 days, or 730 days (2 years).