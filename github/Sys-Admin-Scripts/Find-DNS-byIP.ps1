#THIS WILL ONLY WORK ON A DOMAIN CONTROLLER
$IP = '<IPv4 Address>'

$DNSinfo = Get-DnsServerZone | ForEach-Object {Get-DnsServerResourceRecord -ZoneName $_.ZoneName | select * } | where {$_.RecordData.IPv4Address -eq $IP } | select *

if($DNSinfo){
    
    Write-Output $DNSinfo

}else{
   Write-Host "No DNS entries found for $IP" -ForegroundColor Yellow
}
