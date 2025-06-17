

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
