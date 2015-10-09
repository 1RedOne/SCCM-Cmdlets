<#
Purpose: Finds out if content has been distributed to DP or DP groups
Author: David O'Brien, david.obrien@gmx.de
Author: Stephen Owen, Stephen@foxdeploy.com - modified to emit PowerShell Objects instead, for easier filtering
#>

[CmdletBinding()]
param
(
[parameter(
	Position = 0, 
	Mandatory=$true )
	] 
	[Alias("SMS")]
    [ValidateScript({
        $ping = New-Object System.Net.NetworkInformation.Ping
        $ping.Send("$_", 5000)})]
	[ValidateNotNullOrEmpty()]
	[string]$SMSProvider=""
)


Function Get-SiteCode
{
    $wqlQuery = “SELECT * FROM SMS_ProviderLocation”
    $a = Get-WmiObject -Query $wqlQuery -Namespace “root\sms” -ComputerName $SMSProvider
    $a | ForEach-Object {
        if($_.ProviderForLocalSite)
            {
                $script:SiteCode = $_.SiteCode
            }
    }
return $SiteCode
}

$SiteCode = Get-SiteCode

[array]$AssignedToDPGroup = @()
[array]$AssignedToDP = @()
$i = $null
$Content = $null

$Content = Get-WmiObject -Class SMS_PackageContentServerInfo -Namespace Root\SMS\Site_$SiteCode

foreach ($i in $Content)
    {
        if ($i.ContentServerType -eq 2)
            {
               [array]$AssignedToDPGroup += $i
            }
        else 
            {
                [array]$AssignedToDP += $i
            }
    }

$Objects = Compare-Object -ReferenceObject $AssignedToDPGroup -DifferenceObject $AssignedToDP -Property ObjectID -PassThru | select -Unique -Property ObjectID, PackageType

if ([string]::IsNullOrEmpty($Objects))
    {
        Write-Verbose "No Objects in this site are distributed to DPs only." 
    }
else 
    {
        Write-Verbose "The following Objects are distributed to DPs only. Consider distributing them to DP Groups."
        foreach ($Object in $Objects)
            {
                switch ($Object.PackageType)
                    {
                        0 { 
                            [pscustomobject]@{Type= "Software Package";Name=(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name}
                            
                            
                          }
                        3 {
                            [pscustomobject]@{Type="Driver Package";Name=(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name}
                            
                            
                            }
                        4 {
                            [pscustomobject]@{Type='Task Sequence Package';Name=(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name}
                            
                            
                            }
                        5 {
                            [pscustomobject]@{Type="Software Update Package";Name=(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name}
                            
                            
                            }
                        6 {
                            [pscustomobject]@{Type="Content Package";Name=(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name}
                                                        
                            }
                        8 {
                            #Write-Host "Device Setting Package: " -ForegroundColor Magenta
                            #(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                            }
                        257 {
                            [pscustomobject]@{Type='Image Package';Name=(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name}
                            
                            
                            }
                        258 {
                            [pscustomobject]@{Type="Boot Image Package";Name=(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name}
                            
                            
                            }
                        259 {
                            [pscustomobject]@{Type="Operating System Package";Name=(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name}
                                                        
                            }
                        512 {
                            [pscustomobject]@{Type="Application Package";Name=(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name}
                                                        
                            }
                    }

    }