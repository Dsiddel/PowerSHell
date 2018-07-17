$UPNs = Get-MsolUser
foreach ($u in $UPNs) {
    $origionalupn = $u.userprincipalname
    $fixedupn = $origionalupn -replace "@X", "@Y"
    Set-MsolUserPrincipalName -UserPrincipalName $origionalupn -NewUserPrincipalName $fixedupn
}