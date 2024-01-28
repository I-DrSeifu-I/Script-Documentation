# Replace the placeholders with actual values or variables
$reservationId = ""
$reservationOrderID = ""
$vmSize = "standard_b"

# Function to get the quantity of a specific reservation
function GetReservationInfo([string]$reservationId, [string]$orderID) {
    try{
        $reservationQuantity = (Get-AzReservationOrder -Id $orderID).OriginalQuantity
        Write-Host "Got quantity count! >> $($reservationQuantity)" -ForegroundColor Green
    }catch{
        write-host "Unable to get reservation quantity --Error:$($_)"
    }

    return $reservationQuantity
}

# Function to get the total sum of cores for all VMs of a certain size
function GetTotalCores([string]$vmSize) {

    write-host $vmSize
    $TotalCores = 0
    try{
        $runningVMs = Get-AzVM -Status | Where-Object { $_.HardwareProfile.VmSize -like "$vmSize*" -and $_.PowerState -eq "VM running" }
    }catch{
        write-host "Unable to get VMs --Error:$($_)"
    }

    foreach ($vmtocount in $runningVMs) {
        $size = $vmtocount.HardwareProfile.VmSize
        try{
            $Cores = (Get-AzVMSize -location "eastus" | Where-Object { $_.name -eq $size}).NumberOfCores
        }catch{
            write-host "Unable to get core counts for VM: ($($vmtocount.name)) --Error:$($_)"
        }
        $TotalCores += $Cores
    }
    return $totalCores
}

#set info
$quantity = GetReservationInfo -reservationId $reservationId -orderID $reservationOrderID
$totalCores = GetTotalCores -vmSize $vmSize

# Perform calculations
$result = (($quantity * 2) - $totalCores) / 2

# Display the result
Write-Host "|--------Reservation Quantity: $quantity" -ForegroundColor Blue
Write-Host "|--------Total Cores: $totalCores"  -ForegroundColor Blue
Write-Host "|--------Return: $result"  -ForegroundColor Blue
