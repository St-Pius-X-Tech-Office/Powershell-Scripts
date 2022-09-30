# Set path for user file
$ADUsers = Import-csv C:\Powershell_Scripts\remove_users.csv

foreach ($User in $ADUsers) {

    $Username = $User.Email

    Remove-ADUser -Identity $Username -Confirm:$false
}
