#Enter drive letter. For example 'C'
$driveLetter = "C"

#Enter number for the count of the top largest items. For example '10' , which would be top ten biggest files
#by default, its set to top 10 files
$results = 10

try{
    Write-Host "Querying drive: $($driveLetter) ......" -ForegroundColor Blue
    $query_drive = Get-ChildItem "$($driveLetter):\" -Recurse -ErrorAction Stop
    Write-Host "Successfully queried for drive: $($driveLetter)" -ForegroundColor Green
}catch{
    Write-Error -Message "Unable to query $($driveLetter). $($_)" 
}

if($query_drive){
    
    $query_drive | Sort-Object Length -Descending | Select-Object -First $results | Format-Table Length, FullName

}else{
    Write-Warning -Message "No files were retireved from $($driveLetter)"
}
