Get-MgBetaUser -All | Tee-Object -Variable users

$users | % {
  if (($_.Mail -ne $null) -and ($_.EmployeeType -like "*terminated*")) {
    set-mailbox -identity $($_.UserPrincipalName) -CustomAttribute1 "disabled"
" user flagged as termed $($_.UserPrincipalName) $($_.EmployeeType)"
  
  }
elseif (($_.Mail -ne $null) -and ($_.EmployeeType -notlike "*terminated*") -and ($_.EmployeeId -ne $null)) {

  "user $($_.UserPrincipalName) is $($_.EmployeeType)"
 set-mailbox -identity $_.UserPrincipalName -CustomAttribute1 $null
    
}
}


forEach ($term in $termed) {
" user $term"
 Get-Mailbox -Identity $term | select PrimarySmtpAddress, CustomAttribute1

}