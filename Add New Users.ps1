# Path for new user file
$ADUsers = Import-csv C:\Powershell_Scripts\newusers.csv

foreach ($User in $ADUsers) {
 
    $Username = $User.username
    $Password = $User.password
    $Firstname = $User.firstname
    $Lastname = $User.lastname
    $OU = $User.ou
    $Description = $User.description
    $Group = $User.group
 
    #Check if the user account already exists in AD
    if (Get-ADUser -F { SamAccountName -eq $Username }) {
        #If user does exist, output a warning message
        Write-Warning "A user account $Username has already exist in Active Directory."
    }
    else {
        #If a user does not exist then create a new user account
           
        #Account will be created in the OU listed in the $OU variable in the CSV file
        New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@yourdomain.com" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -ChangePasswordAtLogon $True `
            -DisplayName "$Firstname $Lastname" `
            -Path $OU `
            -Description $Description `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)
    }
 
    # Add the users to their assigned groups
    foreach ($Group in $User.group.Split(';')) {
        Add-ADGroupMember -Identity $Group -Member (Get-ADUser $UserName)
    }
}
