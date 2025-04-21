


#or use graph 
$teamsreport= import-csv -path $env:USERPROFILE\downloads\TeamsReport.csv
$emailreport= import-csv -path $env:USERPROFILE\downloads\EmailReport.csv
#find name of parameter used to identify users which will be used 
$Eidentifier= $emailreport  | Where {$_.Name -like "*User Principal Name*" -or $_.Name -like "*UserPrincipalName*" -or $_.Name -like "*UPN*" }
$Tidentifier= $teamsreport | Where {$_.Name -like "*User Principal Name*" -or $_.Name -like "*UserPrincipalName*" -or $_.Name -like "*UPN*" }


#arraylist to store obj and let us use Add method
$unifiedAudit= [System.Collections.ArrayList]::new()

foreach ($em in $emailreport){
 
    $match= $teamsreport | Where {  $em.'User Principal Name' -match $_.'User Principal Name' } | Select * 


    # $match, "data pulled from teams"   # sanity check
  # $em ,"corresponding email report user" #sanity check
  $unifiedAudit.Add([PSCustomObject]@{
        UPN = $em.'User Principal Name'
        "Exo last activity date"=$em."Last Activity Date" 
        "Teams Last activity date"= $match."Last Activity Date"
        "Team Chat Message Count"= if ($match) {$match.'Team Chat Message Count'} else { "no stats for this one in teams audit"} 
        "Private Chat Message Count"= if ($match) { $match."Private Chat Message Count"} else { "no stats for this one in Exo audit" }
        "Call Count"= $match."Call Count"
        "Meetings Attended"= $match."Meetings Attended Count"
        "Assigned Plans"= $match."Assigned Products"
        "Send Count"= $em."Send Count"
        "Receive Count"= $em."Receive Count"
        "Exch Meeting Count"= $em."Meeting Count"
        "Read mails"= $em."Read Count"

     }) | Out-Null

}


$unifiedAudit | export-csv -path $env:UserProfile\downloads\UnifiedAudit.csv -NoTypeInformation
start  $env:UserProfile\downloads\UnifiedAudit.csv

((Get-Date).AddDays(1)).Day


"TeamsUserActivityCounts$((Get-Date).Month)_$(((Get-Date).AddDays(1)).Day)_$((Get-Date).Year"




