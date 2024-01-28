#Example samaccountname
$username = "Rachel.Johnson1"

#Function to obtain a unique samaccountname
Function NewSamaccountname ($username){
    $count = 0
    do
    {
        #Scans through AD to find all users with the propsed samaccountname.
        #If a user is found, it will keep adding a number in incriments of one until the generated samaccountname is unique domain wide
        $user = $null
        try {$user = get-aduser -Identity $username}catch{}
        if ($user -ne $null)
        {
            $count++
            if ($username.substring($username.length - 1) -match "[0-9]")
            {
                $username = $username.substring(0,$username.length-1)
            }
            $username = $username + $count
        }    
    }while ($user -ne $Null)

    #returns newly generated unique samaccoutname
    return $username
}