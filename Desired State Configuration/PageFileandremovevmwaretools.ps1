configuration CloudLiftDSCConfig {
    Script SetPageFile {
        SetScript = {
            $DL = $null
            $del = $null
            Get-WmiObject -class win32_volume | ?{$_.Label -eq "Temporary Storage"} | %{$DL = $_.Name}
            if ($DL -eq $null)
            {
                    Throw "no drive letter found"
            }
            $AS = "pagefile.sys"
            $PF = "$DL$AS"
            Set-WMIInstance -Class Win32_PageFileSetting -Arguments @{ Name = $PF; InitialSize = 0; MaximumSize = 0; }
            $del = Get-WmiObject -Class win32_pagefilesetting | ?{$_.Name -ne $PF} 
            $del | Remove-WmiObject
        }
        GetSCript = {
            $DL = $null
            Get-WmiObject -class win32_volume | ?{$_.Label -eq "Temporary Storage"} | %{$DL = $_.Name}
            if ($DL -eq $null)
            {
                    Throw "no drive letter found"
            }
            $AS = "pagefile.sys"
            $PF = "$DL$AS"
        }
        TestScript = {
            $DL = $null
            $pagefile = $null
            Get-WmiObject -class win32_volume | ?{$_.Label -eq "Temporary Storage"} | %{$DL = $_.Name}
            if ($DL -eq $null)
            {
                Throw "no drive letter found"
            }
            $AS = "pagefile.sys"
            $PF = "$DL$AS"

            Get-WmiObject -Class win32_pagefilesetting | ?{$_.Name -eq $PF} | %{$pagefile = $_.Name}
            if ($pagefile -eq $PF)
            {
                return $true
            }
                else
            {
                return $False
            }
        }
    }
    Script RemoveVMwareTools {
        SetScript = {
            $APP = $null
            $APP = get-wmiobject Win32_Product | select name, IdentifyingNumber | where {$_.name -eq "VMWare Tools"}
            if ($DL -eq $null)
            {
                    Throw "VMware Tools Not Installed"
            }
            else
            {
                msiexec.exe /x $APP.IdentifyingNumber /qn
            }
        }
        GetSCript = {
            get-wmiobject Win32_Product | select name, IdentifyingNumber | where {$_.name -eq "VMWare Tools"}
        }
        TestScript = {
            $APP = $null
            $APP = get-wmiobject Win32_Product | select name, IdentifyingNumber | where {$_.name -eq "VMWare Tools"}
            if ($app -eq $null)
            { 
                return $true
            }
            Else
            {
                Return $false
            }
        }
    }
}
TestingDSC