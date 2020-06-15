# Adapted from a script by Eric Schewe

# Configure here
$mailTo = "you@district.kyschools.us", "someone@district.kyschools.us"
$mailFrom = "CloudOnlyAccount@districtkyschools.onmicrosoft.com"
$SMTPSvr = "ketsmail.us"
 
# FQDN of your district's D1 controller
$domainController = "edXXXaddc1.district.ketsds.net"
 
# Specify your LDAP search base. This will usually be DC=district,DC=ketsds,DC=net
$searchBase = "DC=district,DC=ketsds,DC=net"
 
# Script run interval (in minutes)
# If you're running this script every 4 hours set this to 240 (minutes). This way when the script runs again in 4 hours
# you won't get double notifications
$scriptRunInterval = 10
 
# End configuration, don't change anything below
 
 
# Get the launch time of this script
$compareDateTime = get-date -Format s

$scriptRunIntervalNegative = $scriptRunInterval * -1
 
# Empty arrays to populate with found users
$usersFound = @()
# Start the ordered list
$usersFound += "<ul>"
$usersFoundDL = @()

# Counter to help determine if we need to send an e-mail or not
$userCount = 0
 
# Get the information we need about all users in the domain
$userinfo = Get-ADuser -SearchBase $searchBase -Filter * -properties SamAccountName,PasswordLastSet,displayname,UserPrincipalName -Server $domainController


foreach ($user in $userinfo) {

    if ($user.PasswordLastSet -ne $null) {
 
        # Get the amount of minutes between the run time of this script and the last password change time
        $timeDiff = (New-TimeSpan $user.PasswordLastSet $compareDateTime).TotalMinutes
 
        # If the password has been changed in the last 4 hours
        if ($timeDiff -le $scriptRunInterval) {
 
            $usersFound += "<li>" + $user.displayname  + " - " + $user.UserPrincipalName + " - password changed " + $user.PasswordLastSet + "</li>"
            $usersFoundDL += $user.UserPrincipalName + ";"
            $userCount++

        }

    }
 
}
 
# End the ordered list
$usersFound += "</ul>"

# Determine if we need to send an e-mail or not

if ($userCount -ne 0) {
 
    # Craft the e-mail based on the user information gathered
    $emailSubject = "[Password Change Notificaton] for $compareDateTime"
    $emailBody = "The following users have changed their password in the last $scriptRunInterval minutes from $compareDateTime `n`r$usersFound `n`r"
 
    # Send a notification for each user who has changed their password
    Send-MailMessage -To $mailTo -Subject $emailSubject -Body $emailBody -SmtpServer $SMTPSvr -From $eailFrom -BodyAsHtml
 
}
