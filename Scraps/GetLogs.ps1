Function Get-Logs {
[CmdletBinding(DefaultParameterSetName= 'Default')]
param (
    [Parameter(ParameterSetName='CSV')]
    [switch]$csv,
    [Parameter(ParameterSetName='CSV')]
    [string]$OutputPath="$env:UserProfile\Downloads\results.csv",
    [Parameter(ParameterSetName='CSV',Mandatory=$true)]
    [string]$inputFolder, 
    [Parameter(ParameterSetName='CSV')]
    [string]$teamsreport,
    [switch]$teams,
    [switch]$Exo
)

switch ($PSBoundParameters.Keys) {

'teams' {
"report for teams from graph"
break;
}
'exo ' {

}
'csv' {
    if ($PSBoundParameters.ContainsKey('teams')) {"teams report pulled from csv"
    break;}
    elseif($PSBoundParameters.ContainsKey('exo')) {"exo report pulled from csv"
    break;}
    else {
        "everything"
        break;
    }
}
default {
"all needed"
break;
}



}
}


$teamsreport= import-csv -path $env:USERPROFILE\downloads\TeamsUserActivityCounts4_1"6_2025 12_46_07 AM.csv"
$emailreport= import-csv -path $env:USERPROFILE\downloads\EmailReport.csv

$unifiedAudit= [System.Collections.ArrayList]::new()

$longer= (($teamsreport.'User Principal Name').Count -gt $emailreport.'User Principal Name' ) ? $emailreport : $teamsreport

forEach ($long in $longer ) {

$match=






}

function Get-NewUsers {
    [CmdletBinding()]
   param (
     [validateSet("january","february","march","april","may","june","july","august","september","october","november","december")]
     [string]$month
   )
   
   Measure-Command{ $Param= $PSCmdlet.MyInvocation.MyCommand.Parameters['month']
   $monthset= $param.Attributes.ValidValues 
     } 
    Measure-Command {$yurr=@("january","february","march","april","may","june","july","august","september","october","november","december")}
   
   }