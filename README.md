# SCCM-Cmdlets
Some helper PowerShell functions for SCCM, to allow you to jump into a remote SCCM client logs folder, or to reset-policy on a remote machine.  

The reset-Policy function includes [steps outlined here](https://social.technet.microsoft.com/Forums/systemcenter/en-US/1c1a640f-179c-4b72-bfe3-ab5d928454bf/software-update-error-0x80004005), to fix Software Update status unknown issues (0x8004005).

## What functions are here?

####Get-Logs

Opens the SCCM logs folder on a remote machine

    _> get-logs phx0695
      phx0695 Online, opening logs
      
      
####Reset-Policy

Removes a blocking Machine.Pol item if it exists (From Group Policy) and also triggers a remote policy refresh and application, with some error handling

    _> Reset-Policy msp1084
      msp1084 Online, deleting cached policy
      Connected to SMS
      Requesting remote Policy Request     [OK]
      Requesting remote Policy Application [OK]

More to come later
