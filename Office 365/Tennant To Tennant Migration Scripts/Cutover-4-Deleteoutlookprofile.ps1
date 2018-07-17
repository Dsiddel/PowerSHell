Get-Process 'Outlook' | Stop-Process -Force

Start-Sleep -s 2

$User = [Environment]::UserName
$path = "C:\Outlook\" + "$User"
$ClearOutlook = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles"
$ClearOutlook2016 = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles"
$ClearOutlook2013 = "HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles"
$ClearOutlook2010 = "HKCU:\Software\Microsoft\Office\14.0\Outlook\Profiles"
$ClearOutlook2007 = "HKCU:\Software\Microsoft\Office\13.0\Outlook\Profiles"
$ClearOutlook2003 = "HKCU:\Software\Microsoft\Office\12.0\Outlook\Profiles"
If(-not(Test-Path -Path $path))
  {
   del $ClearOutlook -force -Recurse
   del $ClearOutlook2016 -force -Recurse
   del $ClearOutlook2013 -force -Recurse
   del $ClearOutlook2010 -force -Recurse
   del $ClearOutlook2007 -force -Recurse
   del $ClearOutlook2003 -force -Recurse
   New-Item -Path $path -type directory
   }
else {
Write-Host "already deleted"
} 
