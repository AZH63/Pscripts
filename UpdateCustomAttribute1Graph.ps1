

Get-MgBetaUser -All | Tee-Object -Variable users
$termed= $users | Where { $_.EmployeeType -like "*Terminated*"}
$termed | % {
   try { 
  Set-mailbox -Identity $($_.Mail) -CustomAttribute1 "disabled" -ErrorAction stop -ErrorVariable $Error  
  write-host"attribute set to disabled"
   }
   catch {
    $Error
  #write-warning "no mailbox for user $($_.Mail)"
   }
}
$active= $users | Where { $_.EmployeeType -like "*Active*"}
$active | % {
  try {
  Set-ExoMailbox -identity $($_.Mail) -CustomAttribute1 "$null" -ErrorAction Stop
  write-host "attribute set to null"
  }
  catch {
write-warning "no mailbox for user $($_.Mail)"
  }

}

Set-DynamicDistributionGroup -identity NYALL_employees -forcemembershiprefresh
Set-DynamicDistributionGroup -identity PFALL_employees -forcemembershiprefresh
Set-DynamicDistributionGroup -identity DCALL_employees -forcemembershiprefresh
Set-DynamicDistributionGroup -identity BBALL_employees -forcemembershiprefresh



