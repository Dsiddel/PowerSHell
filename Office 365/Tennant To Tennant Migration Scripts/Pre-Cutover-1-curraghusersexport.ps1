# ===============================================
#   Import Environment Specific Parameters
# ===============================================
param(
    [string]$ParamCloudUsername = "X",
    [string]$ParamCloudPassword = "X",
    [string]$ParamCSVLocation = "X.csv",
    [string]$ParamLogDir = "X"

)
# ===============================================
#   Set Variables
# ===============================================
$CloudUserName = $ParamCloudUsername
$CloudPassword = ConvertTo-SecureString -String $ParamCloudPassword -AsPlainText -Force
$Cloudcreds = New-Object System.Management.Automation.PSCredential -ArgumentList $ParamCloudUsername, $CloudPassword
$CSVLocation = $ParamCSVLocation                                                                   
$LogDir = $ParamLogDir																			                                                                                  
$Date = Get-Date -Format yyyy-MM-dd																			                                                                             
$Now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"																                                                                              
$Log = "$LogDir\$Date.txt"	


# ===============================================
#   Functions
# ===============================================

function Login-Azure ($cloudcredentials) {
    Try {
        Connect-MsolService -Credential $cloudcredentials -ErrorAction stop
    } Catch {
    Write-Output "Could not log into Azure" + ($_.Exception.Message) | Out-File "$Log" -Append
    }
}

function Export-Users ($csvloc) {
    try {
        Get-MsolUser -all | Where-Object { $_.isLicensed -eq "TRUE" } | select FirstName, LastName, DisplayName, UserprincipalName, immutableiD,@{Name="ProxyAddresses";Expression={$_.ProxyAddresses}} | Export-Csv $csvloc -NoTypeInformation -ErrorAction Continue
    } Catch {
        Write-Output "Could not get list of users" + ($_.Exception.Message) | Out-File "$Log" -Append
    }
}


# ===============================================
#   Core Script
# ===============================================

Login-Azure -cloudcredentials $Cloudcreds

Export-Users -csvloc $CSVLocation




