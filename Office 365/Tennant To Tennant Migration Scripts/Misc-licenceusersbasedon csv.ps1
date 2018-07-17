$CSVLocatoion = "X.csv"
$csvdata = Get-Content $CSVLocatoion
$data = ConvertFrom-Csv $csvdata
$sku = Get-MsolAccountSku | where {$_.AccountSkuId -eq "X:ENTERPRISEPACK"}

foreach ($line in $data) {
    $upn = $line.UPN
    try {
        Write-Host "Setting User $upn to location AU"
        Set-MsolUser -UserPrincipalName $upn -UsageLocation AU -ErrorAction Stop
        Write-Host "Setting User $upn to location AU Success"
    } Catch {
        Write-host "$upn failed to set as AU"
    } try {
        Write-Host "Seting User $upn licence"
         Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses "X:ENTERPRISEPACK" -ErrorAction Stop
        Write-Host "Seting User $upn licence SUCCESS"
    } Catch {
        Write-Host "$upn Failed getting a licence"
    }
}