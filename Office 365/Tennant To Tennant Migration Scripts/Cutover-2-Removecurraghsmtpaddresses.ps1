Set-ExecutionPolicy RemoteSigned
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication  Basic -AllowRedirection
Import-PSSession $Session

$mailbox = Get-Mailbox
foreach ($mb in $mailbox) {
    $emailaddresslist = (get-mailbox -Identity $mb.UserPrincipalName).emailaddresses
    $emails = $emailaddresslist
    foreach ($em in $emails) {
        if ($em.EndsWith("@X")) {
            echo $mb.UserPrincipalName
            Set-Mailbox -Identity $mb.UserPrincipalName -EmailAddresses @{remove="$em"}
        }
    }

}



