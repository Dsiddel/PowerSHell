    $csvloc = "X.csv"
    $csvdata = Get-Content $csvloc | select -skip 2
    $data = ConvertFrom-csv $csvdata -Header ("Identity","Alias","DisplayName", "WindowsEmailAddress")
    $configure = foreach ($line in $data) { 
        $Identity = $line.Identity 
        $Alias = $line.Alias 
        $DisplayName = $line.DisplayName
        $WindowsEmailAddress = $line.WindowsEmailAddress

        New-Mailbox -Shared -Name $Identity -DisplayName $DisplayName -Alias $alias -PrimarySmtpAddress $WindowsEmailAddress

    } 
