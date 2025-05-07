
$LicensedEnabled=[System.Collections.ArrayList]::new()
$LicensedDisabled=[System.Collections.ArrayList]::new()
$NonLicensed=[System.Collections.ArrayList]::new()
 
$AllUsers= Get-AzureADUser -filter "employeeId ge '123'" -All $true | Select UserPrincipalName,AccountEnabled, AssignedLicenses
$AllUsers | ForEach-Object {
if ( $_.AccountEnabled -eq $false -and $_.AssignedLicenses -ne "null") {

write-output " $($_.UserPrincipalName)  licensed and disabled $($_.AccountEnabled) "
Set-Mailbox -Identity $_.UserPrincipalName -CustomAttribute1 "Disabled"
[void]$LicensedDisabled.Add([PSCustomObject]@{
    Name = $_.UserPrincipalName
    License= $_.AssignedLicenses
    AccountEnabled= $_.AccountEnabled
    EmployeeType= $_.EmployeeType
})

}

elseif ( $_.AccountEnabled -eq $true -and $_.AssignedLicenses -ne "null") {
Write-Output " $($_.UserPrincipalName)  licensed and enabled $($_.AccountEnabled) "
Set-Mailbox -Identity $_.UserPrincipalName -CustomAttribute1 $null
[void]$LicensedEnabled.Add([PSCustomObject]@{
    Name = $_.UserPrincipalName
    License= $_.AssignedLicenses
    AccountEnabled= $_.AccountEnabled
    EmployeeType= $_.EmployeeType
})

}
else  {
Write-Output " $($_.UserPrincipalName) not licensed"
[void]$NonLicensed.Add([PSCustomObject]@{
    Name = $_.UserPrincipalName
    License= $_.AssignedLicenses
    AccountEnabled= $_.AccountEnabled
    EmployeeType= $_.EmployeeType
})

}


}

$LicensedEnabled | Export-Csv -Path $env:UserProfile\Downloads\LicensedEnabled.csv -NoTypeInformation
$LicensedDisabled| Export-Csv -Path $env:UserProfile\Downloads\LicensedDisabled.csv -NoTypeInformation
$NonLicensed | Export-Csv -Path $env:UserProfile\Downloads\NonLicensed.csv -NoTypeInformation

