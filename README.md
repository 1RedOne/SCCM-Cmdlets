# SCCM-Cmdlets
Some helper PowerShell functions for SCCM, to allow you to jump into a remote SCCM client logs folder, or to reset-policy on a remote machine.  

The reset-Policy function includes [steps outlined here](https://social.technet.microsoft.com/Forums/systemcenter/en-US/1c1a640f-179c-4b72-bfe3-ab5d928454bf/software-update-error-0x80004005), to fix Software Update status unknown issues (0x8004005).  It also includes the PowerShell steps for a remote WMI reset, [as outlined by Tompa on his blog](http://tompaps.blogspot.com/2012/12/machine-policy-retrieval-sccm.html).

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

####MoveAllContent.ps1

A modified version of Nikolaj's awesome [Update the content path of all Apps ins ConfigMgr with PowerShell tool](http://www.scconfigmgr.com/2013/07/25/update-the-content-path-of-all-applications-in-configmgr-2012-with-powershell/).  It now detectes a directory first, before changing content path, and then creates and moves files into the directory.

####Get-ContentTarget

A modified version of David O'Brien's [Find Content not on a DP Group tool](http://www.david-obrien.net/2013/10/configmgr-find-content-distributed-dp-groups/).  It will not emit PowerShell objects for easy sorting, to determine what kind of content may not be targeting a DP Group.

    $packages = Get-ContentTarget.ps1
    $packages | Where Type -eq "Boot Image Package"
    
    Type                                        Name                                                                                                                 
    ----                                        ----                                                                                                                 
    Boot Image Package                          MDT Boot x64 - TLA                                                                                                   
    Boot Image Package                          Embedded_x64 - TLA                                                                                                 
    Boot Image Package                          HPClientBootImage8815f669 - TLA                                                                                      
    Boot Image Package                          HPClientBootImage73cd3d1 - TLA                                                                                       
    Boot Image Package                          Boot image (x86)                                                                                    
    Boot Image Package                          Boot image (x64)                                                                                                     
    Boot Image Package                          B&B Standard Boot Image                                                                                              
    Boot Image Package                          DESKTOPS, Standard Boot Image}
