
#License Reshuffle
#pool: all licensed users
# what we want: e3 to e1
# e1 to teams essentials


# metrics: Last UseractionTime (exo)- get-mailboxfolderstatistics, 
$results= [system.Collections.ArrayList]::new()
$properties= @("UserPrincipalName","DisplayName","SignInActivity","EmployeeType","employeeID","JobTitle","Manager","Department","AccountEnabled")

$allUsers= Get-MgBetaUser -All  -Property $properties
$users=$allUsers | Where { $_.AccountEnabled -eq $true -and $_.EmployeeType -ne "Service Account" -and $_.EmployeeId -gt 123} 


  forEach ( $user in $users) {
    $license= Get-MgUserLicenseDetail -UserId $user.UserPrincipalName | select SkuPartNumber

    $stats= Get-MailboxStatistics -Identity $user.UserPrincipalName | select  LastUserActionTime,LastLogonTime,LastUserAction
   $results.Add( [PSCustomObject]@{
       Name  = $user.UserPrincipalName
       "Exo Last User action time"= $stats.LastUserActionTime
        EntraLastSignIn= $user.SignInActivity.LastSignInDateTime
        LicenseAssigned= $license 
        EmployeeType= $user.EmployeeType
        employeeId= $user.EmployeeId
        JobTitle= $user.JobTitle
        Manager= $user.Manager
    }) | out-null
    
}
$results
$results | export-csv -path $env:UserProfile\downloads\results.csv

start $env:UserProfile\downloads\results.csv



