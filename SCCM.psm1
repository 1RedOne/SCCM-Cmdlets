Function Get-Logs {Param($comp)
if (test-connection $comp -quiet -count 1){Write-Host "$comp Online, opening logs" -fore Green
start \\$comp\C$\Windows\CCM\Logs
 }
else{
write-warning "$comp Offline"
}
}



Function Reset-Policy {
param($computername)
if (test-connection $computername -quiet -count 1){
    Write-Host "$computername Online, deleting cached policy" -fore Green

    try {remove-item \\$computername\C$\Windows\system32\GroupPolicy\Machine\Registry.pol -force -ErrorAction STOP}
   catch{write-warning "Couldn't delete, maybe file isn't there?"}
    # Binding \\$srv\root\ccm:SMS_Client
    $SMSCli = [wmiclass] "\\$computername\root\ccm:SMS_Client"
 
    if($SMSCli){
            Write-host -foreground Cyan "Connected to SMS"
            #Invoking $actionName 
            write-host -NoNewLine "Requesting remote Policy Request"
            if ($SMSCli.RequestMachinePolicy().ReturnValue -eq $null){
                write-host -fore green "OK"}
                else{
                Write-host -fore Red "ERROR"
                }
            write-host -NoNewLine "Requesting remote Policy Application"
            if ($SMSCli.EvaluateMachinePolicy().ReturnValue -eq $null){
                write-host -fore green "OK"}
                else{
                Write-host -fore Red "ERROR"
                }
         }
        else{
            write-host "$srv, Could not bind WMI class SMS_Client"
        }

    }
else{
    write-warning "$computername Offline"
    }
}



write-host -fore Cyan "Get-Logs cmdlet available"
write-host -fore Cyan "Rest-Policy cmdlet available"