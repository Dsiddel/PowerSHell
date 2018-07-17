$APP = get-wmiobject Win32_Product | select name, IdentifyingNumber | where {$_.name -eq "mRemoteNG"}
msiexec.exe /x $APP.IdentifyingNumber /qn