
#LastUserActionTime #last action performed by user -- deprecated
#LastInteractionTime # near real time, updated independently but possible influenced by background assistants
#LastLogonTime #ran MFA didn't seem to change, maybe it can be trusted

Function Get-UnUsedMbs {
  param(
   [switch]$logonweek,
   [switch]$nouserinteraction, #either find an alt or add description that its technically deprecated..making this excersise kinda useless
   [switch]$Week,
   [switch]$Month,
   [Parameter(ValueFromPipeline=$true)]
   [string[]]$users

)
 begin {
$mbStats= @{}


 }
 process {
foreach ($user in $users) {
 $stats= Get-MailboxStatistics -identity $user | Select LastInteractionTime, LastUserActionTime, LastLogonTime
 
            $mailboxStats[$user] = @{
                DisplayName         = $stats.DisplayName
                LastLogonTime       = $stats.LastLogonTime
                LastInteractionTime = $stats.LastInteractionTime
            }
        }

}




}
end 
{

switch ($PSBoundParameters.keys) {
   'logonweek' {

   }
   'logonmonth' {
    
     
   }
   'nologon' { }
   'nouserinteraction' {}
   default {
      write-warning "unhandled parameter --> $($_)"
   }
   }
   
}


$licensed= Get-AzureADUser | Where-Object { $_.AccountEnabled -eq $true -and $_.AssignedLicenses -ne $null}

$emails= $licensed | ForEach-Object {
    
    $stats=Get-MailboxStatistics -identity $($_.UserPrincipalName) | Select-Object DisplayName, LastLogonTime, LastInteractionTime
    # a date in the 17th century means null 
    $logonTime = if ($stats.LastLogonTime -lt [datetime]'1601-01-02') { $null } else { $stats.LastLogonTime }
    $lastinteracted= if ($stats.LastInteractionTime -lt [datetime]'1601-01-02' ) { $null } else { $stats.LastInteractionTime }
     [PSCustomObject]@{
        Name = $stats.DisplayName
        LastLogonTime= $logonTime
        LastInteractionTime= $lastinteracted
     }
     
}

$emails | export-csv -path $env:UserProfile\Downloads\MbLogonstats.csv
[datetime]$date= Get-Date 


$nologonsinaweek = $emails | Where-Object { $_.LastLogonTime -and $_.LastLogonTime -lt $date.AddDays(-7) } 
$noLogonsInaMonth = $emails | Where-Object { !$_.LastLogonTime -or $_.LastLogonTime -lt $date.AddDays(-30) }
$neverloggedIn= $emails | Where-Object { !$_.LastLogonTime}

$nointeractions= $emails | Where-Object { !$_.LastInteractionTime}

$nologonsinaweek | export-csv -path $env:USERPROFILE\Downloads\nologonsinaweek.csv
$noLogonsInaMonth | export-csv -path $env:USERPROFILE\Downloads\noLogonsInaMonth.csv
$neverloggedIn | export-csv -path $env:USERPROFILE\Downloads\neverloggedIn.csv
$nointeractions | export-csv -path $env:USERPROFILE\Downloads\nointeractions.csv


#grab relevant users or accept it thru pipeline, accepting has to be done in process block
# fill a table with relevant stats if using hashtable need to make sure no dupes ( its not allowed anyway right??)
#keys will instead be for timeframes 