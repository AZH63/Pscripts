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
   [validateSet("january","february","march","april","may","june","july","august","september","october","november","december",IgnoreCase=$true)]
   [string]$month
 )
 $month= $month.ToLower()
 $months=$PSCmdlet.MyInvocation.MyCommand.Parameters["month"].Attributes.ValidValues
$monthnumber= $months.IndexOf("$month") + 1
Write-Verbose "$monthnumber"
     
}

$formatted = Get-Date -Year $year -Month $m -Day $day -Format 'MM/dd/yy'
