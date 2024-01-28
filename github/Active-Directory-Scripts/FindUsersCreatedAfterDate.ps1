$OU = "OU=Students,OU=All Users,DC=howardu,DC=net"
$whencreated = ((Get-Date).AddDays(-1)).Date

#{(enabled -eq $true) -and ($whencreated -ge $whencreated)}

get-aduser -Filter {($whencreated -ge $whencreated)} -SearchBase $OU -Properties extensionattribute1, givenname, surname, samaccountname, userprincipalname |1
 select extensionattribute1, givenname, surname, samaccountname, userprincipalname 