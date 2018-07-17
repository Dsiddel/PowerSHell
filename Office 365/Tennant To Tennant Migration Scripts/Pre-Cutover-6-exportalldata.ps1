$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication  Basic -AllowRedirection
Import-PSSession $session

$Mail = Get-mailbox -ResultSize unlimited
foreach ($mb in $mail) {
    $json = ConvertTo-Json $mb
    $json | Set-Content "C:\Curraghcutover\fullexport\$($mb.userprincipalname).json"
}