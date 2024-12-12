#Enter drive letter. For example 'C'
$driveLetter = ""

try{
    $query_drive = Get-ChildItem "$($driveLetter):\" -Recurse -ErrorAction SilentlyContinue 
    Write-Host "Successfully queried $($driveLetter)" -ForegroundColor Green
}catch{
    Write-Error -Message "Unable to query $($driveLetter)." -Exception "$($driveLetter)"
}

if($query_drive){
    
    $query_drive | Sort-Object Length -Descending | Select-Object -First 10 | Format-Table Length, FullName
}else{
    Write-Warning -Message "No files were retireved from $($driveLetter)"
}
