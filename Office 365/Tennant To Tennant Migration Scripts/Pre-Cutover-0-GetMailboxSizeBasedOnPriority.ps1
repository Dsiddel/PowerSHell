Set-ExecutionPolicy RemoteSigned
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication  Basic -AllowRedirection
Import-PSSession $Session


$CSVLocation = "X.csv"                                                                 

    $csvdata = Get-Content $CSVLocation | select -skip 1
    $data = ConvertFrom-Csv $csvdata -Header ("DisplayName", "UserPrincipalName", "Classification", "Notes")
    $configure = foreach ($line in $data) { 
        $displayname = $line.DisplayName 
        $userprincipalname = $line.UserPrincipalName
        $classification = $line.Classification
        $notes = $line.Notes


        if ($classification -eq "Normal") {
        #$name = (Get-MailboxStatistics -Identity $displayname).displayname | Out-File "X.csv" -Append
        #$size = (Get-MailboxStatistics -Identity $displayname).totalitemsize | Out-File "X.csv"-Append
        Get-mailboxstatistics -identity $displayname | Select-Object DisplayName, @{name=”TotalItemSize (GB)”;expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1GB),2)}} | export-csv -Append "normal.csv"
        }
        if ($classification -eq "Priority") {
            #$name = (Get-MailboxStatistics -Identity $displayname).displayname | Out-File "X.csv" -Append
            #$size = (Get-MailboxStatistics -Identity $displayname).totalitemsize | Out-File "X.csv"-Append
            Get-mailboxstatistics -identity $displayname | Select-Object DisplayName, @{name=”TotalItemSize (GB)”;expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1GB),2)}} | export-csv -Append "priority.csv"
        }
    } 