# ===============================================
#   Set Variables
# ===============================================
 
$Onpremsecpasswd = ConvertTo-SecureString "X" -AsPlainText -Force                                          # Set password value for on prem account
$Cloudsecpasswd = ConvertTo-SecureString "X" -AsPlainText -Force                                                # Set password value for cloud account
$Cloudcreds = New-Object System.Management.Automation.PSCredential ("X", $Cloudsecpasswd)      # Set credentials for cloud
$Onpremcreds = New-Object System.Management.Automation.PSCredential ("X", $Onpremsecpasswd)    # Set credentials for on prem
$SearchBase = "X"                                                                        # Set SearchBaseOU Active Directory Search
$OnPremExchangePSRemoting = "X"                                               # On Prem exchange server connection
$CloudExchangePSRemoting = "X"                                                        # On Prem exchange server connection
$LogDir = "C:\Program Files\Office365Provisioning\Logs"                                                                                        # Set Output Log Directory
$Date = Get-Date -Format "yyyy-MM-dd"                                                                                  # Get current Date for log file name
$Now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"                                                                          # Get current Date and Time for script run.  24 hour format, server time
$Log = "$LogDir\$Date.txt"                                                                                             # Set Log file
$RoutingDomain = "X"                                                                   # Sets routing domain
$SMTPServer = "X"                                                                            # Sets SMTP Server
$ToAddress = "X"                                                                                       # Sets to address for email
$FromAddress = "X"                                                                      # Sets From Address
$ReplyToAddress = "X"                                                                   # Sets ReplyToAddress
$LicenceGroup = "X"                                                                               # Sets LicenceGroup for O365 Licences
$errorvalue = $null

 
# ===============================================
#   Set Functions
# ===============================================
 
#Function to email results or errors
function Send-Mail ($MsgSub, $Attach, $SMTP, $FunFromAddress, $FunReplyToAddress, $FuntoAddress)
{
Send-MailMessage -To $FuntoAddress -From $FunFromAddress -Subject $MsgSub -Attachments $Attach -SmtpServer $SMTPServer
}
 
#Function to add users to security group if they have a remote mailbox and are not licenced
function Set-O365Licence ($SB, $LicGroup) {
    Login-Azure
    try {
        $users = Get-MsolUser -LicenseReconciliationNeededOnly -ErrorAction Stop
        Write-Output "Successfully found list of users who need licences" | Out-File "$log" -Append
    } catch {
        Write-Output "Error getting list of unlicenced users" | Out-File "$log" -Append
    }
    foreach ($upnuser in $users) {
        try {
            $adupn = Get-ADUser -Filter { UserPrincipalName -Eq $upnuser.UserPrincipalName} -SearchBase $SB
            Write-Output $upnuser "Found Username of user in local active directory" | Out-File "$log" -Append
        } catch {
            Write-Output "Error finding username in local active directory" | Out-File "$log" -Append
        }
        if (!$adupn) {
            Write-Output $adupn.UserPrincipalName "does not need a licence as it is a terminated user or shared mailbox" | Out-File "$log" -Append
        } else {
            try {
                Add-ADGroupMember -Identity $LicGroup -Members $adupn -ErrorAction stop
                Write-Output $adupn.userprincipalname "added to the licence group" | Out-File "$log" -Append
            } catch {
                Write-Output "Failed to add" $adupn.UserPrincipalName "to group, likely due to it already being in the group." | Out-File "$log" -Append
            }
        }
    }
}
 
#Function to set remote mailbox if user has no mailbox or an on prem mailbox
function Set-RemoteMailbox {
    Try {
        Login-Onprem -OnPremPSRemoting $OnPremExchangePSRemoting -OnPremiseCredentials $Onpremcreds
        Write-Output "Logged into Exchange Online" | Out-File "$Log" -Append
    } catch {
        Write-Output "Error Logging into Exchange Online" | Out-File "$Log" -Append
    } try {
        $noremote = Get-ADUser -LDAPFilter '(!mailnickname=*)(!UserAccountControl:1.2.840.113556.1.4.803:=2)' -searchBase $SearchBase -Properties mailnickname,proxyaddresses -ErrorAction stop
            if ($noremote) {
                
            } else {
                Write-Output "No Users without remote mailboxes" | Out-File "$Log" -Append
            }
    } Catch {
        $MsgSubject = "Error getting list of users without remote mailboxes"
        Write-Output "Error Getting list of users withour remote mailboxes" + ($_.Exception.Message) | Out-File "$Log" -Append
        $errorvalue = 1
    } foreach ($mailbox in $noremote) {
        Try {
            Write-Output "-----------------------" | Out-File "$Log" -Append
            Write-Output "Attempting to enable remote mailbox for" $mailbox.userprincipalname | Out-File "$Log" -Append 
            Enable-RemoteMailbox -Identity $($mailbox.UserPrincipalName) -RemoteRoutingAddress "$($mailbox.SamAccountName)@$($RoutingDomain)" -ErrorAction Stop
            Write-Output "Mailbox Enabled for" $mailbox.userprincipalname | Out-File "$Log" -Append
        } Catch {
            $MsgSubject = "Error Enabling remote mailbox for $($mailbox)"
            Write-Output "Cloud not enable remote mailbox due to the following error" + ($_.Exception.Message) | Out-File "$Log" -Append
            $errorvalue = 1
        }
    }
    $resultcount = $noremote | Measure-Object
    Write-Output "Number of accounts without remote mailboxes is $resultcount" | Out-File "$Log" -Append
}  
                                                                                                                
 
#Function to apply legal hold to all users
function Set-LegalHold {                                                                                                                       
    Login-ExchangeOnline -cloudcredentials $Cloudcreds
    Try {
        $nolegalholdlist = get-mailbox -ResultSize unlimited | where-object {$_.litigationholdenabled -eq $false} -ErrorAction Stop
        Write-Output "Created list of accounts without legal hold" | Out-File "$Log" -Append
        if (!$nolegalhostlist) {
                Write-Output "No Users without legalhold" | Out-File "$Log" -Append
            }
    } Catch {
        $MsgSubject = "Error getting list of accounts without legal hold"
        Write-Output "Error getting list of accounts without legal hold" + ($_.Exception.Message) | Out-File "$Log" -Append
        $errorvalue = 1
    }
    foreach ($legalholdmissing in $nolegalholdlist) {
        Try {
            Write-Output "-----------------------" | Out-File "$Log" -Append    
            Write-Output "Attempting to enable legal hold for" $legalholdmissing.userprincipalname  | Out-File "$Log" -Append
            Set-Mailbox -Identity $legalholdmissing.UserPrincipalName -LitigationHoldEnabled $true -ErrorAction stop
            Write-Output "Legal Hold Enabled for" $legalholdmissing.userprincipalname  | Out-File "$Log" -Append
        } Catch {
            $MsgSubject = "Error Applying Legal Hold for $($legalholdmissing)"
            Write-Output "Cloud not enable legal hold due to the following error" + ($_.Exception.Message)# | Out-File "$Log" -Append
            $errorvalue = 1
        }
    }
}
 
#function to log into exchange online
function Login-ExchangeOnline ($Cloudcredentials) {
    Try {
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri “https://ps.outlook.com/powershell/” -Credential $Cloudcredentials -Authentication Basic -AllowRedirection
        Import-PSSession $session -AllowClobber
        Write-Output "Succesfully Logged into Exchange Online" | Out-File "$Log" -Append
    } Catch {
        $MsgSubject = "Error logging into Exchange Online"
        Write-Output "Cloud not log into Exchange Online due to the following error" + ($_.Exception.Message)  |  Out-File "$Log" -Append
        $errorvalue = 1
    }  
}     
                                                                                                           
 
#Function to log into on prem exchange server
function Login-Onprem ($OnPremPSRemoting, $OnPremiseCredentials){
    Try {
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $OnPremPSRemoting -Credential $OnPremiseCredentials -Authentication Basic –AllowRedirection -ErrorAction Stop
        Import-PSSession $session -AllowClobber
    } Catch {
        $MsgSubject = "Error logging into on prem Exchange" | Out-File "$Log" -Append
        Write-Output "Cloud not log into on prem Exchange due to the following error" + ($_.Exception.Message) | Out-File "$Log" -Append
        $errorvalue = 1
    }
 
} 
#Function to log into azure
function Login-Azure ($Azurelicencecreds) {
    try {   
        Connect-MsolService -Credential $Cloudcreds -ErrorAction Stop
        Write-Output "Logged into O365" | Out-File "$log" -Append
    } catch {
        Write-Output "Error Logging into Office 365" | Out-File "$log" -Append
        $errorvalue = 1
    }
}
# ===============================================
#   Import Modules
# ===============================================
 

 
Import-Module MSOnline
Import-Module ActiveDirectory
 
# ===============================================
#   Core Script
# ===============================================

Write-Output "-----------------------------Commencing script $Now -------------------------------" | Out-File "$Log" -Append 
#Run function that gets list of users withour a remote mailbox runs through each entityand enable it for any that fail email the account name and "failed to enable remote mailbox"
Set-RemoteMailbox
 
#Get list of licencereconciliation needed in 365 accounts and add to security group to be licenced
Set-O365Licence -SB $SearchBase -LicGroup $LicenceGroup

#Get list of accounts without litigation hold and enables it for each account.
 
Set-LegalHold
 
#Send email if script completed without errors
if ($errorvalue = 1) {
    $MsgSubject = "Script has errors please see log file"
    Send-Mail -MsgSub $MsgSubject -Attach $Log -SMTP $SMTPServer -FunFromAddress $FromAddress -FunReplyToAddress $ReplyToAddress -FuntoAddress $ToAddress
} else {
    $MsgSubject = "Script completed successfully"
    Send-Mail -MsgSub $MsgSubject -Attach $Log -SMTP $SMTPServer -FunFromAddress $FromAddress -FunReplyToAddress $ReplyToAddress -FuntoAddress $ToAddress
}