
Connect-AzureAD
Connect-ExchangeOnline
$AllUsers=Get-AzureADUser -Filter "employeeId ge '0'" -All $true | Select UserPrincipalName,AccountEnabled, AssignedLicenses

$Results= $AllUsers | ForEach-Object {
if ( $_.AccountEnabled -eq $false -and $_.AssignedLicenses -ne "null") {

write-output " $($_.UserPrincipalName)  licensed and disabled $($_.AccountEnabled) "
Set-Mailbox -Identity $_.UserPrincipalName -CustomAttribute1 "Disabled"

}

elseif ( $_.AccountEnabled -eq $true -and $_.AssignedLicenses -ne "null") {
Write-Output " $($_.UserPrincipalName)  licensed and enabled $($_.AccountEnabled) "
Set-Mailbox -Identity $_.UserPrincipalName -CustomAttribute1 $null

}
else  {
Write-Output " $($_.UserPrincipalName) not licensed"

}
[PSCustomObject]@{
    Name = $_.UserPrincipalName
    License= $_.AssignedLicenses
    AccountEnabled= $_.AccountEnabled
}

}
return $Results | Export-Csv -Path $env:UserProfile\Downloads -NoTypeInformation


