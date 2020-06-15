#---- 
# CONFIGURATION
#----

# CutoffDays: Disable any machine that hasn't contacted the domain in this number of days.
$CutoffDays = 120

# SearchBase: Where to find computer objects. This will usually be OU=Workstations,DC=district,DC=ketsds,DC=net
$SearchBase = "OU=Workstations,DC=district,DC=ketsds,DC=net"

# TargetOU: Where to put inactivated computer objects. You must create this. Suggestion: create a new OU under Workstations called "Stale"
$TargetOU = "OU=Stale,OU=Workstations,DC=district,DC=ketsds,DC=net"

# MailFrom: email address the notification message comes from
$MailFrom = "cloudaccount@districtkyschools.onmicrosoft.com"

# MailTo: recipients of emal notification. Separate multiples with a comma.
$MailTo = "you@district.kyschools.us", "someone.else@district.kyschools.us"

# SMTPSvr: SMTP relay to use. Districts default to ketsmail.us
$SMTPSvr = "ketsmail.us"

# ----
# END CONFIGURATION
# Don't change anything below
# ----

# The Active Directory powershell module is required for this script
Import-Module ActiveDirectory

# Define the layout of the HTML report
$layout = "<style>"
$layout = $layout + "BODY{background-color:White;}"
$layout = $layout + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$layout = $layout + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:LightGrey}"
$layout = $layout + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:ForalWhite}"
$layout = $layout + "</style>"

# The cutoff days must be negative - take the absolute value and multiply by -1
$CutoffDaysNegative = [Math]::Abs($CutoffDays) * -1
$d = [DateTime]::Today.AddDays($CutoffDaysNegative) 

# Find computer objects with PasswordLastSet of before whatever date was CutoffDays days ago
$stale = Get-ADComputer -Filter  {(PasswordLastSet -le $d) -and (Enabled -eq 'True')} -SearchBase $SearchBase -properties PasswordLastSet 

#Disable all found computer objects
$stale | Set-ADComputer -Enabled $false

# Move disabled computer objects to the stale computers OU
$stale | Move-ADObject -TargetPath $TargetOU

# Generate HTML reporting to send in an email
$liststale = $stale | Sort Name | ConvertTo-HTML -Head $layout Name, DistinguishedName, PasswordLastSet -Body "<H2>The following machines have not contacted the domain in the past $CutoffDays days and have been disabled:</H2>"
$countstale = $stale | group-object computer | ConvertTo-HTML -Head $layout Count -Body "<H2>Total Stale Machine Count</H2>" 

# Send the email notification
$messageParameters = @{
    Subject = "Stale Computer Report from $env:ComputerName.$env:USERDNSDOMAIN - $((Get-Date).ToShortDateString())"
    Body = $countstale, $liststale | Out-String
    From = $MailFrom
    To = $MailTo
    SmtpServer = $SMTPSvr
}
Send-MailMessage @messageParameters -BodyAsHtml