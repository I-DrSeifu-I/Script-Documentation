Function writeOutLog {
    param(
        [parameter(Mandatory)]
        [string]$message,
        [parameter(Mandatory)]
        [string]$LogFile,
        [string]$status
    )


    if (-not $status -or $status -eq "") {
        $status = "info"
    }
    switch ($status.ToLower()) {
        "info" { 
            write-host "*[$(get-date -Format "MM-dd-yy | hh:mm:ss tt")] $($message)" -ForegroundColor cyan
            try { "*[$(get-date -Format "MM-dd-yy | hh:mm:ss tt")] $($message)" |`
             Out-File $LogFile -Append }catch {} 
        }
        "success" { 
            write-host "^[$(get-date -Format "MM-dd-yy | hh:mm:ss tt")] $($message)" -ForegroundColor green
            try { "^[$(get-date -Format "MM-dd-yy | hh:mm:ss tt")] $($message)" |`
             Out-File $LogFile -Append }catch {} 
        }
        "warning" { 
            write-host "![$(get-date -Format "MM-dd-yy | hh:mm:ss tt")] $($message)" -ForegroundColor Yellow
            try { "![$(get-date -Format "MM-dd-yy | hh:mm:ss tt")] $($message)" |`
             Out-File $LogFile -Append }catch {} 
        }
        "error" { 
            write-host "!!![$(get-date -Format "MM-dd-yy | hh:mm:ss tt")] $($message)" -ForegroundColor Red
            try { "!!![$(get-date -Format "MM-dd-yy | hh:mm:ss tt")] $($message)" |`
             Out-File $LogFile -Append }catch {} 
        }
    }
}