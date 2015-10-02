[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null

$SiteServer = "clasccm01"
$SiteCode = "law"
$CurrentContentPath = "clasccm02"
$UpdatedContentPath = "clasccm01"

$Applications = Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS\site_$SiteCode -class SMS_Application | Where-Object {$_.IsLatest -eq $True}
$ApplicationCount = $Applications.Count

Write-Output ""
Write-Output "INFO: A total of $($ApplicationCount) applications will be modified`n"
Write-Output "INFO: Value of current content path: $($CurrentContentPath)"
Write-Output "INFO: Value of updated content path: $($UpdatedContentPath)`n"
Write-Output "# What would you like to do?"
Write-Output "# ---------------------------------------------------------------------"
Write-Output "# 1. Verify first - Verify the applications new path before updating"
Write-Output "# 2. Update now - Update the path on all applications"
Write-Output "# ---------------------------------------------------------------------`n"
$EnumAnswer = Read-Host "Please enter your selection [1,2] and press Enter"

switch ($EnumAnswer) {
    1 {$SetEnumAnswer = "Verify"}
    2 {$SetEnumAnswer = "Update"}
    Default {$SetEnumAnswer = "Verify"}
}

if ($SetEnumAnswer -like "Verify") {
    Write-Output ""
    $Applications | ForEach-Object {
        $CheckApplication = [wmi]$_.__PATH
        $CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($CheckApplication.SDMPackageXML,$True)
        foreach ($CheckDeploymentType in $CheckApplicationXML.DeploymentTypes) {
            $CheckInstaller = $CheckDeploymentType.Installer
            $CheckContents = $CheckInstaller.Contents[0]
            $CheckUpdatedPath = $CheckContents.Location -replace $($CurrentContentPath).ToLower(),$($UpdatedContentPath).ToLower()
            Write-Output "INFO: Current content path for $($_.LocalizedDisplayName):"
            Write-Host -ForegroundColor Green "$($CheckContents.Location)"
            if (test-path $CheckUpdatedPath){
            Write-Output "UPDATE: Updated content path will be:"
            Write-Host -ForegroundColor Cyan "$($CheckUpdatedPath)`n"
            }
            ELSE{
            Write-Warning "Check path exists for $CheckUpdatedPath"
            }
        }
    }
}

if ($SetEnumAnswer -like "Update") {
    Write-Output ""
    $Applications | ForEach-Object {
        $Application = [wmi]$_.__PATH
        $ApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($Application.SDMPackageXML,$True)
        foreach ($DeploymentType in $ApplicationXML.DeploymentTypes) {
            $Installer = $DeploymentType.Installer
            $Contents = $Installer.Contents[0]
            $UpdatePath = $Contents.Location -replace "$($CurrentContentPath)","$($UpdatedContentPath)"
            if (test-path $UpdatePath){
                if ($UpdatePath -ne $Contents.Location) {
                    $UpdateContent = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentImporter]::CreateContentFromFolder($UpdatePath)
                    $UpdateContent.FallbackToUnprotectedDP = $True
                    $UpdateContent.OnFastNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
                    $UpdateContent.OnSlowNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::DoNothing
                    $UpdateContent.PeerCache = $False
                    $UpdateContent.PinOnClient = $False
                    $Installer.Contents[0].ID = $UpdateContent.ID
                    $Installer.Contents[0] = $UpdateContent
                }else{'this app is up to date'}
                }

                else {#if the path isn't valid
                "skipping $Installer because $UpdatePath isn't valid"
                }
        }
        $UpdatedXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToString($ApplicationXML, $True)
        $Application.SDMPackageXML = $UpdatedXML
        $Application.Put() | Out-Null
        Write-Output "INFO: Updated content path for $($_.LocalizedDisplayName)"
    }
}
