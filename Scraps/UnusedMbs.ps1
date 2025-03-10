
#LastUserActionTime #last action performed by user -- deprecated
#LastInteractionTime # near real time, updated independently but possible influenced by background assistants
#LastLogonTime #ran MFA didn't seem to change, maybe it can be trusted

Function get-Unusedmbs {
  param(
   [CmdletBinding()]
  [Parameter(Position=0,ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [string[]]$users,
   [switch]$logonweek,
   [switch]$nouserinteraction, #either find an alt or add description that its technically deprecated..making this excersise kinda useless
   [switch]$Week,
   [switch]$month,
   [switch]$nologon,
   [switch]$all
   

)
 begin {
   
$emails=$users | % {
 if ($_ -notlike "*@*") {
   write-host "searching"
    try {
     # $res= Get-MgUser -Search "DisplayName:$_" -ConsistencyLevel eventual -ea Stop
     $res= Get-AzureADuser -searchstring "$_"
      write-output "$($res.UserPrincipalName)"
 }
 catch {
   # $res= Get-MgUSer | Where { $_.Name -like "*$_*" }
   $res= Get-AzureADuser -searchstring "$_"
    write-output "$($res.UserPrincipalName)"
  
 
    }

}
else {
   write-host "$_ all good here" 
   write-output "$_"
    }

 } 
}
 process {
$mbstats= foreach ($email in $emails) {
 $stats= Get-MailboxStatistics -identity $email | Select LastInteractionTime, LastUserActionTime, LastLogonTime
 
            [PSCustomObject]@{
                Name       = $email
                LastLogonTime       = $stats.LastLogonTime
                LastInteractionTime = $stats.LastInteractionTime
                LastUserActionTime= $stats.LastUserActionTime
            }
        }
        [datetime]$date= Get-Date

}

end 
{

switch ($PSBoundParameters.keys) {
   
   'logonweek' {
      
      $nologonweek= $mbstats | Where-Object { $_.LastLogonTime -and $_.LastLogonTime -lt $date.AddDays(-7) }
      if (!$nologonweek) {
           write-host "value is null"
           break;
      }
      else {
      $nologonweek | export-csv -path $env:UserProfile\Downloads\nologonweek.csv
      }
       
   }
   'logonmonth' {
    $nologonmonth = $mbstats | Where-Object { $_.LastLogonTime -and $_.LastLogonTime -lt $date.AddDays(-30)  }
    if (!$nologonmonth) {
       write-host "value is null"
       break;
    }
    else {
    $nologonmonth | export-csv -path $env:UserProfile\Downloads\nologonweek.csv
    }
   }
   'nologon' { $nologon= $mbstats | Where-Object { !$_.LastLogonTime } 
    if (!$nologon) {
           write-host "value is null"
           break;
    }
    else {
   $nologon | export-csv -path $env:UserProfile\Downloads\nologon.csv
    }

}

   'nouserinteraction' {
      $nouserinteraction= $mbstats | Where-Object {!$_.LastUserActionTime}
      if (!$nouserinteraction) {
          write-host "value is null"
          break;
      }
      else {
      $nouserinteraction | export-csv -path $env:UserProfile\Downloads\nouserinteraction.csv
      }
   }
   'all' {    
     $mbstats | export-csv -path $env:UserProfile\Downloads\mbstats.csv  
  
   }

   default {
      write-warning "unhandled parameter --> $($_)"
   }
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