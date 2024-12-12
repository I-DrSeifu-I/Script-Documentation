#Enter drive letter. For example 'C'
$driveLetter = "F"

#Enter number for the count of the top largest items. For example '10' , which would be top ten biggest files
#by default, its set to top 10 files
$results = 10

if(Test-Path "$($driveLetter):\"){
    try{
        Write-Host "Querying drive: $($driveLetter) ......" -ForegroundColor Blue
        $query_drive = Get-ChildItem "$($driveLetter):\" -Recurse
        Write-Host "Successfully queried for drive: $($driveLetter)" -ForegroundColor Green
    }catch{
        Write-Error -Message "Unable to query $($driveLetter). $($_)" 
    }
}else{
    Write-Warning -Message "The specified drive is not found: $($driveLetter)"
    exit
}

if($query_drive){
    
    $query_drive | Sort-Object Length -Descending | Select-Object -First $results | Format-Table Length, FullName

}else{
    Write-Warning -Message "No files were retireved from $($driveLetter)"
}
