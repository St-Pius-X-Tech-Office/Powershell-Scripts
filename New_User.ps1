Write-Host "Welcome to the new AD User maker!`n"

$User_FN = Read-Host -Prompt "First Name"
$User_LN = Read-Host -Prompt "Last Name"
$User_Email = (Read-Host -Prompt "Desired Email (do not include @stpiusx.org)").ToLower()
$Student_Path = 'OU=Accounts (Students), DC=Pius, DC=local'
$PT_Staff_Path = 'OU=Accounts (PT Faculty/Staff), DC=Pius, DC=local'
$FT_Staff_Path = 'OU=Accounts (Faculty & Staff), DC=Pius, DC=local'

while (Get-ADUser -F { SamAccountName -eq $User_Email }) {
    Write-Warning "A user account $User_Email already exists!"
    $User_Email = (Read-Host -Prompt "Please enter a new email address:").ToLower()
}

Write-Host "`nYou are creating an account for '$User_FN $User_LN', with email '$User_Email@stpiusx.org'`n"

# Since there are different OU and licenses, we have to determine the user type
$Staff_or_Student = (Read-Host -Prompt "Is the person a student (Y/N)").ToUpper()

if ($Staff_or_Student -eq "Y") {
    $Grad_Year = Read-Host -Prompt "What is the Grad Year?"
    $Student_PW = Read-Host -Prompt "Please enter a password for the student"

    # Make the user in AD
    New-ADUser `
        -SamAccountName $User_Email `
        -Name "$User_FN $User_LN" `
        -UserPrincipalName "$User_Email@stpiusx.org" `
        -GivenName $User_FN `
        -Surname $User_LN `
        -Enabled $true `
        -ChangePasswordAtLogon $false `
        -DisplayName "$User_FN $User_LN" `
        -Path $Student_Path `
        -AccountPassword (ConvertTo-SecureString $Student_PW -AsPlainText -Force)
}
else {

    $Part_Time = (Read-Host -Prompt "Is the person (FT/PT)?").ToUpper()

    if ($Part_Time -eq "FT") {
        New-ADUser `
            -Path $PT_Staff_Path
    }
    else: {
        New-ADUser `
            -Path $FT_Staff_Path
    }

    # Make the user in AD
    New-ADUser `
        -SamAccountName $User_Email `
        -Name "$User_FN $User_LN" `
        -UserPrincipalName "$User_Email@stpiusx.org" `
        -GivenName $User_FN `
        -Surname $User_LN `
        -Enabled $true `
        -ChangePasswordAtLogon $false `
        -DisplayName "$User_FN $User_LN" `
        -AccountPassword (ConvertTo-SecureString $Student_PW -AsPlainText -Force)
}


# Add the User to the proper AD Group(s)

# If the user is a student
if ($Staff_or_Student -eq "Y") {
    Add-ADGroupMember -Identity "Class of $Grad_Year" -Members (Get-ADUser "$User_Email")
    Add-ADGroupMember -Identity "students" -Members (Get-ADUser "$User_Email")
}

# If the user is NOT a student
else {
    Add-ADGroupMember -Identity "Class of $Grad_Year" -Members (Get-ADUser "$User_Email")
    Add-ADGroupMember -Identity "students" -Members (Get-ADUser "$User_Email")
}

