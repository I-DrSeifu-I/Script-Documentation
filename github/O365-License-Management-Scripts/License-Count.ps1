##Check line 51 and change to match preferred email address to send email to
Function SendMonthlyReport{

    param(
        $O365Licenses
    )

    #AAD Email App Authentication
    $AppId = "--"
    $AppSecret = "--"
    $TenantId = "--"

    # Construct URI and body needed for authentication
    $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $body = @{
        client_id     = $AppId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $AppSecret
        grant_type    = "client_credentials"
    }

    #HTML table formatting
    $DateForEmail = Get-Date -Format "MM/dd/yy"
    $htmlformat = '<title>All O365 Licenses</title>'
    $htmlformat += '<style type="text/css">'
    $htmlformat += 'TABLE{border-width: 3px;border-style: solid;border-color: black;border-collapse: collapse;}'
    $htmlformat += 'TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:#ffffff}'
    $htmlformat += 'TD{border-width: 1px;padding: 8px;border-style: solid;border-color: black;background-color:#ffffff}'
    $htmlformat += '</style>'
    $bodyformat = '<h2>All O365 Licenses</h2>'

    $O365LicensesEmail = $O365Licenses | ConvertTo-Html -Head $htmlformat -Body $bodyformat

                      
    #Token request from AAD app
    try{
        $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
    }catch{
        Write-Output "Unable to send web request for emailing. Error:$($_)"
        exit
    }
    # Unpack Access Token
    $token = ($tokenRequest.Content | ConvertFrom-Json).access_token
    $Headers = @{
        'Content-Type'  = "application\json"
        'Authorization' = "Bearer $Token" 
    }

    #Specify email to send from
    $MsgFrom = ""
        
    # Define attachment to send to users
    $EmailRecipient1 = ""



    $MsgSubject = "Monthly License Report - All O365 Licenses ($(get-date -Format "MM-dd-yy"))"


    #Email body
    $htmlbody = "
                
                <br>Hello All,<br>
    
                <br>
                For today ($(get-date -Format "MM/dd/yy")), please see the table below for all O365 licenses.
                <br>

                $O365LicensesEmail <br>

                
                <br>Sincerely,<br>

                <br>Automated License Report<br>
                 

                "
        
    $HtmlMsg = $HtmlHead + $HtmlBody
    # Create message body and properties and send
    $MessageParams = @{
        "URI"         = "https://graph.microsoft.com/v1.0/users/$MsgFrom/sendMail"
        "Headers"     = $Headers
        "Method"      = "POST"
        "ContentType" = 'application/json'
        "Body"        = (@{
                "message" = @{
                    "subject"      = $MsgSubject
                    "body"         = @{
                        "contentType" = 'HTML'
                        "content"     = $htmlMsg 
                    }
                    "toRecipients" = @(
                        @{
                            "emailAddress" = @{"address" = $EmailRecipient1 }
                        }
                         ) 
                        
                }
            }) | ConvertTo-JSON -Depth 6
    }   # Send the message
    Invoke-RestMethod @Messageparams

    Write-Output "Email sent successfully to $($EmailRecipient1)!"


    return $O365Licenses
}

############################LAST LOGON AAD APP AUTHENTICATION########################################
$clientID = "--"
$tenantID = "--"
$ClientSecret = "--"
$resource = "https://graph.microsoft.com/"
$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 
#############################################################################################

try{
    $TokenResponse = (Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody).access_token
}catch{
    Write-Output "Unable to retrieve token request. Error: $($_)"
}

#Form request headers with the acquired $AccessToken
$headers = @{'Content-Type'="application\json";'Authorization'="Bearer $TokenResponse"}
#This request get users list with signInActivity.
$ApiUri = 'https://graph.microsoft.com/v1.0/subscribedSkus'



While ($ApiUri -ne $Null) #Perform pagination if next page link (odata.nextlink) returned.
{
    try{
        $Response =  Invoke-RestMethod -Method GET -Uri $ApiUri -ContentType "application\json" -Headers $headers
    }catch{
        Write-Output "Unable to retieve query response for enterprise apps. Error: $($_)"
    }

    if($Response.value){
    
        $licenses = $Response.value
        $LicensesInfo = @()
        ForEach($license in $licenses){


            $LicensesInfo += New-Object PSObject -property $([ordered]@{
                LicenseName = $license.skuPartNumber
                LicenseID = $license.id
                ConsumedUnits = $license.ConsumedUnits
                prepaidUnits = $license.prepaidUnits.enabled
                AvailableLicenses = ($license.prepaidUnits.enabled) - ($license.consumedUnits)
            })
          }
        }
        $ApiUri=$Response.'@odata.nextlink'
}


If($LicensesInfo){
    Write-Output "Licenses were gathered. Sending email report"
    SendMonthlyReport -O365Licenses $LicensesInfo
}else{
    Write-Output "No licenses found to send emails with. Check if the graph api query is able to get all licenses "
}