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

$json = $audit | ConvertTo-Json -Depth 3 

python -c "import pandas as pd"
python -c "import json"
python -c "data = json.loads(json_str)"
python -c "df = pd.json_normalize(data)"












$audit | export-csv -path $env:UserProfile\Downloads\auditmay.csv


$month= (Get-Date).Month



(Get-Date).Year + $() + (Get-Date).Day



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
