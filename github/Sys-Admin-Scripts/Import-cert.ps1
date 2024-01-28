$filelocation = ""
$password = ""
$Pass = ConvertTo-SecureString -String $password -Force -AsPlainText
#leave as it is
$User = "noNeedToInput"
$Cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $Pass
Import-PfxCertificate -FilePath $filelocation `
-CertStoreLocation Cert:\LocalMachine\My `
-Password $Cred.Password