Import-CSV "XXXXX" | ForEach {
    if ($_.Email.Endswith("@X.onmicrosoft.com")){
        Continue;
    }
    if ($_.Email.Endswith("@X.mail.onmicrosoft.com")){
        Continue;
    }
    Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.Email};
}