        


$mbs= $emails | % {
try {
    $stats=get-mailboxfolderstatistics -identity $_.UserPrincipalName | Select LastUserActionTime, LastLogonTime, LastInteractionTime

    [PSCustomObject]@{
        Name = $stats.Identity
        LastLogonTime       = $stats.LastLogonTime
        LastInteractionTime = $stats.LastInteractionTime
        LastUserActionTime= $stats.LastUserActionTime
    }
}
catch {

    write-warning " not found on exo"
}
}
[datetime]$date= Get-Date
$mbs | export-csv $env:UserProfile\Downloads\mbs.csv
Start-Process $env:UserProfile\Downloads\mbs.csv 
$thirty= $mbs | Where { $_.LastSentDate -lt $date.AddDays(-30) }
$thirty | export-csv $env:UserProfile\Downloads\thirty.csv
start $env:UserProfile\Downloads\thirty.csv





$users=$All | Where { $_.EmployeeType -ne "Service Account" -and $_.Name -notlike "*SalesDesk*" -and $_.AccountEnabled -eq $true -and $_.AssignedLicenses -ne $null } | Select UserPrincipalName, EmployeeType, AccountEnabled, AssignedLicenses

$subset= import-csv -Path $env:Downloads\NoAction.csv

$users=$subset.Name | % {
  Get-MgBetaUser -Search "DisplayName:$_" -ConsistencyLevel eventual| Select UserPrincipalName, EmployeeType, AccountEnabled


}


$emails | 