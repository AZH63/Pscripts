$audit= [System.Collections.ArrayList]::new()
$error.Clear()
Get-MgBetaAuditLogDirectoryAudit -All -filter "ActivityDisplayName eq 'Add user' "  | tee-object -variable newuserevents 

$newuserevents | % {

   try { 
    " checking existance of $($_.TargetResources.UserPrincipalName)"
    $check= Get-MgBetaUser -userid $($_.TargetResources.UserPrincipalName) -ErrorAction SilentlyContinue } catch { }
  [void]$audit.Add([PSCustomObject]@{
    ActivityDateTime = $_.ActivityDateTime
    ActivityDisplayName= $_.ActivityDisplayName
    "Target upn"= $_.TargetResources.UserPrincipalName
    Actor= $_.InitiatedBy.User.UserPrincipalName
    result= $_.Result
    Type=  ($check.EmployeeId -lt "0"  ) ? "service acct" : "user account" 
    
  }) 
}

$audit | export-csv -path $env:UserProfile\Downloads\auditmay.csv





function Get-NewUsers {
  [CmdletBinding()]
 param (
   [Param]
   [string]$startdate,
   [string]$endDate="$(get-date -format "MM/dd/yy")"
   
 )
 $startDateTime=[datetime]::ParseExact($startdate, "MM/dd/yy", $null)
 $startClean= $startClean.ToString('MM/dd/yy')
 
     
}

# $formatted = Get-Date -Year $year -Month $m -Day $day -Format 'MM/dd/yy'
# Find all users deleted- 
