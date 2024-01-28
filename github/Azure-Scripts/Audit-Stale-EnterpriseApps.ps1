############################LAST LOGON AAD APP AUTHENTICATION########################################
$clientID = "--"
$tenantID = "--"
$ClientSecret = "--"

$BaseURL = "https://graph.microsoft.com/v1.0"

#Enter the Timefram in Days for the Usage
$TimeFrameInDays = 30

#Build a Dateformat for the Filter
$TimeFrameDate = Get-Date -format yyyy-MM-dd  ((Get-Date).AddDays(-$TimeFrameInDays))

#Auth MS Graph API and Get Header
$tokenBody = @{  
    Grant_Type    = "client_credentials"  
    Scope         = "https://graph.microsoft.com/.default"  
    Client_Id     = $clientID  
    Client_Secret = $Clientsecret  
}   
try{
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $tokenBody
}catch{
    Write-Host "Unable to retrieve token. Error: $($_)" -ForegroundColor Red
    exit
}
$headers = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}

#Get all Enterprise Apps
$URLGetApplications = "$BaseURL/servicePrincipals"

$allapps = $Null

While ($URLGetApplications -ne $Null) #Perform pagination if next page link (odata.nextlink) returned.
{
    try{
        $Applications = Invoke-RestMethod -Method GET -Uri $URLGetApplications -Headers $headers
    }catch{
        Write-Host "Unable to retrieve applications. Error: $($_)" -ForegroundColor Red
    }

    $allapps += $Applications.value

    $URLGetApplications=$Applications.'@odata.nextlink'

}
$entApps = ($allapps | ? {$_.tags -contains "WindowsAzureActiveDirectoryIntegratedApp"})

Write-Host "Got all apps"

#Build Array to store PSCustomObject
$Array = @()


foreach ($App in $entApps) {

    Write-Host $App.displayName

    try{
        $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $tokenBody
        }catch{
            Write-Host "Unable to retrieve token. Error: $($_)" -ForegroundColor Red
            exit
        }
        $headers = @{
            "Authorization" = "Bearer $($tokenResponse.access_token)"
            "Content-type"  = "application/json"
        }

    try{
        $SignIns = Invoke-RestMethod -Method GET  -Uri "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=appid eq '$($App.appId)' and createdDateTime gt $TimeFrameDate" -Headers $headers
    }catch{
        Write-Host "Unable to retrieve sign-in logs for $($app.displayName).Error: $($_)" -ForegroundColor Red
    }
    Start-Sleep -Seconds 1

    #Get Owners
    $URLGetOwner = "$BaseURL/applications/$($App.id)/owners"
    try{
        $Owner = Invoke-RestMethod -Method GET -Uri $URLGetOwner -Headers $headers
    }catch{
        
    }
    
    if ($Owner) {
        foreach ($O in $Owner.value) {

            $Array += [PSCustomObject]@{
                "App ID"           = $App.id
                "App AppID"        = $App.appId
                "App Name"         = $App.displayName
                "Owner UPN"        = $o.userprincipalname
                "Owner Name"       = $o.displayName
                "Owner ID"         = $o.id
                "Usage Count"      = ($SignIns.value ).count
            }

        }
    }
    else {
        $Array += [PSCustomObject]@{
            "App ID"           = $App.id
            "App AppID"        = $App.appId
            "App Name"         = $App.displayName
            "Owner UPN"        = "NONE"
            "Owner Name"       = "NONE"
            "Owner ID"         = "NONE"
            "Usage Count"      = ($SignIns.value ).count
        }
    }

    Write-host "$($app.displayName), Usage Count:$(($SignIns.value).count)"
}

$Array | Select-Object -Property "App Name", "Owner UPN", "Usage Count" | Sort-Object -Property "Usage Count" -Descending

$Array | Select-Object -Property "App Name", "Owner UPN", "Usage Count" | `
export-csv -path "c:\temp\$(Get-Date -Format "yyyy-MM-dd")ListOfapps-1.csv" -NoTypeInformation
