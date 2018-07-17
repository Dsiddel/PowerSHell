$mailbox = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited | Select Identity,Alias,DisplayName, EmailAddresses, WindowsEmailAddress

foreach ($mb in $mailbox) {
    $add = $mb.EmailAddresses
    foreach ($ad in $add) {

    $Object = New-Object PSObject -Property @{            
        Mailbox       = $mb.Identity             
        Email         = $ad
    }  
    $Object | Select-Object Mailbox, Email | Export-csv "X.csv" -Append
    }
}