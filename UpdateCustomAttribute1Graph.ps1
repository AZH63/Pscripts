Get-MgBetaUser -All | Tee-Object -Variable users

$users | % {
  if (($_.AssignedLicenses -ne $null) -and ($_.EmployeeType -like "*terminated*")) {
    set-mailbox -identity $($_.UserPrincipalName) -CustomAttribute1 "disabled"
" user flagged as $($_.UserPrincipalName) $($_.EmployeeType)"
  Get-MgBetaUserLicensedetail -userid $($_.UserPrincipalName) | select SkuPartNumber
  }
elseif (($_.AssignedLicenses -ne $null) -and ($_.EmployeeType -notlike "*terminated*") -and ($_.EmployeeId -ne $null)) {

  "user $($_.UserPrincipalName) is $($_.EmployeeType)"
 set-mailbox -identity $_.UserPrincipalName -CustomAttribute1 $null
    
}
}
