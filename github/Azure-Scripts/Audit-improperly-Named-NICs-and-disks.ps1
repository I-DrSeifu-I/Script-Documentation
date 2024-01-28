#Connect-AzAccount

$osDiskNamingConvention = "*-osDisk*"
$dataDiskNamingConvention = "*-datadisk*"
$nicNamingConvention = "*-NIC01"

$exportLocationDisk = "c:\temp\Export-ImproperlyNamedDisks($(get-date -Format "yyyy-MM-dd")).csv"
$exportLocationNic = "c:\temp\Export-ImproperlyNamedNic($(get-date -Format "yyyy-MM-dd")).csv"

#Choose to specify certain subs or remove the where statement
$allsubs = Get-AzSubscription | ?{`
    $_.Name -eq "SUB NAME"}

$importlyNamedDisksObj = @()
$importlyNamedNicsObj = @()

foreach($sub in $allsubs){

    Set-AzContext -SubscriptionId $sub.Id
    try{
        $improperlyNamedDisks = Get-Azdisk | ?{($_.Name -notlike $osDiskNamingConvention) -and ($_.Name -notlike $dataDiskNamingConvention)} | Select-Object Name
        write-host "Successfully queried for all improperly disks" -ForegroundColor Green
    }catch{
        write-host "Unable to get all disks. Error: $($_)" -ForegroundColor Red
    }
    try{
        $improperlyNamedNics = Get-AzNetworkInterface | ?{$_.Name -notlike $nicNamingConvention} | Select-Object Name
        write-host "Successfully queried for all improperly nics" -ForegroundColor Green
    }catch{
        write-host "Unable to get all Nics. Error: $($_)" -ForegroundColor Red
    }

    if($improperlyNamedDisks){
        foreach($disk in $improperlyNamedDisks){
            $importlyNamedDisksObj += [PSCustomObject]@{
                DiskName = $disk.Name
                Subscription = $sub.Name
            }
            Write-Host "Found improperly named disk($($disk.Name)) in $($sub.Name)" -ForegroundColor Blue
        }
    }else{
        Write-Host "There were no improperly named disks in $($sub.Name)" -ForegroundColor Blue
    }
    if($improperlyNamedNics){
    foreach($nic in $improperlyNamedNics){
        $importlyNamedNicsObj += [PSCustomObject]@{
            NicName = $nic.Name
            Subscription = $sub.Name
        }
        Write-Host "Found improperly named Nics($($nic.Name)) in $($sub.Name)" -ForegroundColor Blue
    }
    }else{
        Write-Host "There were no improperly named Nics in $($sub.Name)" -ForegroundColor Blue
    }

}

$importlyNamedDisksObj | export-csv $exportLocationDisk -NoTypeInformation
$importlyNamedNicsObj | export-csv $exportLocationNic -NoTypeInformation

