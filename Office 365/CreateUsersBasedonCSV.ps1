# ===============================================
#   Import Environment Specific Parameters
# ===============================================
param(
    [string]$ParamCloudUsername = "X",
    [string]$ParamCloudPassword = "X",
    [string]$ParamCSVLocation = "X",
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
    Write-Output "Could not log into Azure" + ($_.Exception.Message) | Out-File "$log" -Append
    }
}

function Configure-Users ($csvloc) {
    $csvdata = Get-Content $csvloc | select -skip 2
    $data = ConvertFrom-Csv $csvdata -Header ("First","Last","DisplayName", "UserPrincipalName", "ImmutableiD")
    $configure = foreach ($line in $data) { 
        $firstName = $line.First 
        $lastName = $line.Last 
        $displayName = $line.DisplayName
        $userPrincipalName = $line.UserPrincipalName
        $uPNFixed = $UserPrincipalName -replace "@curragh.com.au", "@curraghmine.onmicrosoft.com"
        $immutableiD = $line.ImmutableiD

        $userexists = Get-MsolUser -UserPrincipalName $UPNFixed -ErrorAction SilentlyContinue
        if ($userexists -ne $null) {
            Write-Output "User $UPNFixed exists skipping" | Out-File "$log" -Append
            }
            else {
                Write-Output "User $UPNFixed exist, creating user" | Out-File "$log" -Append
                Write-Output "Creating $UPNFixed user" | Out-File "$log" -Append
                try {
                    New-Msoluser -FirstName $FirstName -LastName $LastName -DisplayName $DisplayName -ImmutableId $immutableiD -UserPrincipalName $UPNFixed
                } Catch {
                    Write-Output "Creating $UPNFixed failed" | Out-File "$log" -Append
                }
                Write-Output "Created $UPNFixed user successfully" | Out-File "$log" -Append
            }

    } 

}


# ===============================================
#   Core Script
# ===============================================

Login-Azure -cloudcredentials $Cloudcreds

Configure-Users -csvloc $CSVLocation




