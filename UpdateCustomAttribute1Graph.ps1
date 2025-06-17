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

Get-MgBetaUser -All | Tee-Object -Variable users
$termed= $users | Where { $_.EmployeeType -like "*Terminated*"}
$termed | % {
   try { 
  Set-mailbox -Identity $($_.Mail) -CustomAttribute1 "disabled" -ErrorAction Stop
  write-host"attribute set to disabled"
   }
   catch {
  write-warning "no mailbox for user $($_.Mail)"
   }
}
$active= $users | Where { $_.EmployeeType -like "*Active*"}
$active | % {
  try {
  Set-Mailbox -identity $($_.Mail) -CustomAttribute1 "$null" -ErrorAction Stop
  write-host "attribute set to null"
  }
  catch {
write-warning "no mailbox for user $($_.Mail)"
  }

}




forEach ($term in $termed) {
" user $term"
Get-Mailbox -Identity $term | select PrimarySmtpAddress, CustomAttribute1

}
