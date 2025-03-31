
#LastUserActionTime #last action performed by user -- deprecated
#LastInteractionTime # near real time, updated independently but possible influenced by background assistants
#LastLogonTime #ran MFA didn't seem to change, maybe it can be trusted
#
Get-MgBetaUser | Where { $_.EmployeeType -ne "ServiceAccount" -and $_.EmployeeId -ne $null}
Function get-Unusedmbs {
  param(
   [CmdletBinding()]
  [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [object[]]$users,
   [switch]$week,
   [switch]$nouserinteraction, #either find an alt or add description that its technically deprecated..making this excersise kinda useless
   [switch]$month,
   [switch]$nologon
   

)
 begin {
 
}
 process {
   write-host "checking user- $_ entered"
   $emails=$users | % {
      if ($_ -notlike "*@*") {
        write-verbose "not a UPN, checking "
         try {
            write-verbose "searching by displayname"
           $res= Get-MgBetaUser -Search "DisplayName:$_" -ConsistencyLevel eventual -ea Stop
         # $res= Get-AzureADuser -searchstring "$_"
          write-output "$($res.UserPrincipalName)"
          
      }
      catch {
         write-verbose "good ole where-object"
        $res= Get-MgUSer | Where { $_.Name -like "*$_*" }
        
        write-output "$($res.UserPrincipalName)"
       
      
         }
     
     }
     else {
        write-verbose "$_ all good here" 
        write-output "$_"
         }
     
      }
      
$mbstats= foreach ($email in $emails) {
   try {
      Write-Host "grabbing mailbox statistics"
 $stats= Get-MailboxStatistics -identity $email | Select LastInteractionTime, LastUserActionTime, LastLogonTime -ErrorAction stop -ErrorVariable err
 
            [PSCustomObject]@{
                Name       = $email
                LastLogonTime       = $stats.LastLogonTime
                LastInteractionTime = $stats.LastInteractionTime
                LastUserActionTime= $stats.LastUserActionTime
            }
        
        [datetime]$date= Get-Date
      }
      catch {
          $err 

      }
   }
}

end 
{

switch ($PSBoundParameters.keys) {
   
   'week' {
      
      $nologonweek= $mbstats | Where-Object { $_.LastLogonTime -and $_.LastLogonTime -lt $date.AddDays(-7) }
      if (!$nologonweek) {
           write-host "value is null"
           
      }
      else {
      $nologonweek | export-csv -path $env:UserProfile\Downloads\nologonweek.csv
      }
       
   }
   'month' {
    $nologonmonth = $mbstats | Where-Object { $_.LastLogonTime -and $_.LastLogonTime -lt $date.AddDays(-30)  }
    if (!$nologonmonth) {
       write-host "value is null"
      
    }
    else {
    $nologonmonth | export-csv -path $env:UserProfile\Downloads\nologonweek.csv
    }
   }
   'nologon' { $nologon= $mbstats | Where-Object { !$_.LastLogonTime } 
    if (!$nologon) {
           write-host "value is null"
           
    }
    
    else {
   $nologon | export-csv -path $env:UserProfile\Downloads\nologon.csv
    }

}

   'nouserinteraction' {
      $nouserinteraction= $mbstats | Where-Object {!$_.LastUserActionTime}
      if (!$nouserinteraction) {
          write-host "value is null"
         
      }
      else {
      $nouserinteraction | export-csv -path $env:UserProfile\Downloads\nouserinteraction.csv
      }
   }
   default {    
      write-verbose "$mbstats here"
     $mbstats | export-csv -path $env:UserProfile\Downloads\mbstats.csv  
  
   }

  
   }
   
}
}

$JL= import-csv -path $env:UserProfile\downloads\user_list.csv

$JL.Email | get-Unusedmbs  



#add connect-exchangeonline cause...



























$activeusers= get-mgbetauser | Where { $_.AccountEnabled -eq $true} | select -ExpandProperty UserPrincipalName
# $activeusers |% { Get-MgUserLicenseDetail -userid $_} 
$mbstats= @{}
forEach ($user in $activeusers) {
try {
    $currentUser++
    Write-Progress -Activity "Processing Users" -Status "User $currentUser of $totalUsers" -PercentComplete (($currentUser / $totalUsers) * 100)
$stats= Get-MailboxStatistics  -identity $user -erroraction stop 
$mbstats[$user]= @{
  Name = $user
  LastLogon= $stats.LastLogonTime
  LastUserAction= $stats.LastUserActionTime 
 
}

}
catch {
    $message= $_
write-warning " failed to get data for user $message"

}
}

$mbstats["AlexW@1x4bs0.onmicrosoft.com"]["LastLogon"]

Get-MgReportRootTeamsUserActivityUserDetail



















Get-Module -Name MicrosoftTeams -ListAvailable | Select-Object Name, Version


Install-Module -Name PowerShellGet -Force -AllowClobber





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





Connect-MgGraph -Scopes "AuditLog.Read.All","User.Read.All", "UserActivity.ReadWrite.CreatedByApp","Reports.Read.All"
$properties= @("UserPrincipalName","DisplayName","SignInActivity")
$AllUsers= Get-MgBetaUser -All -Property $properties

$AllUsers.SignInActivity.LastSignInDateTime

Invoke-MgBetaRecentUserActivity -UserId "yoohooo@1x4bs0.onmicrosoft.com" # UserActivity.ReadWrite.CreatedByApp




# Define the URL for the user activity report
$url = "https://graph.microsoft.com/v1.0/reports/getOffice365ActiveUserDetail(period='D7')" # "Reports.Read.All" #most likely winner

# Define the output file path
$outputFilePath = "$env:UserProfile\Downloads\report.csv"

# Make the request to the Graph API and save the response to a file
Invoke-MgGraphRequest -Method GET -Uri $url -OutputFilePath $outputFilePath

Function Get-TeamsLastDate {

param (
    $OutputPath="$env:UserProfile\Downloads\report.csv",
    $days="7"
    
    
)
Connect-MgGraph -Scopes "Reports.Read.All","User.ReadWrite.All"
$url = "https://graph.microsoft.com/beta/reports/getOffice365ActiveUserDetail(period='D30')"
$report= Invoke-MgGraphRequest -Method GET -Uri $url -OutputFilePath $OutputPath 
$stats= import-csv -path $OutputPath
write-output "$stats"
}
# requires UPNs to be unscrambled in admin center setting

GET 


$userid="AlexW@1x4bs0.onmicrosoft.com"
$url = "https://graph.microsoft.com/beta/reports/getMailboxUsageDetail(period='D30')"
$report=Invoke-MgGraphRequest -Method GET -Uri $url -OutputFilePath $env:USERPROFILE\Downloads\outlook.csv


$url="https://graph.microsoft.com/beta/me/messages?$filter=mentionsPreview/isMentionedeqtrue&$select=subject,sender,receivedDateTime"
Invoke-MgGraphRequest -Method GET -Uri $url -OutputFilePath $env:USERPROFILE\Downloads\msg.csv 

# user data is jumbled by default: https://learn.microsoft.com/en-us/microsoft-365/admin/activity-reports/activity-reports?view=o365-worldwide#show-user-details-in-the-reports
# https://learn.microsoft.com/en-us/graph/api/resources/adminreportsettings?view=graph-rest-beta&preserve-view=true

$url= GET https://graph.microsoft.com/beta/admin/reportSettings

# Get-MgBetaAdminReportSetting {ReportSettings.Read.All, ReportSettings.ReadWrite.All} (get the displayconcealednamesvalue)
#module Import-Module Microsoft.Graph.Beta.Reports

$params = @{
	displayConcealedNames = $false
}

Update-MgBetaAdminReportSetting -BodyParameter $params


#Find-MgGraphCommand -command
#Find-MgGraphCommand -Uri '/users/{id}'

 https://graph.microsoft.com/v1.0/reports/getTeamsUserActivityUserDetail(period='D7')



https://ourcloudnetwork.com/how-to-manage-microsoft-entra-sign-in-logs-with-powershell/

get-mgauditlogsignin

$inbox=Get-MgUserMailFolder -UserId $user | Where { $_.DisplayName -eq "Inbox"} | Select -ExpandProperty Id
Get-MgUserMailFolder -UserId $user -MailFolderId $inbox | Select AdditionalProperties

$uri="https://graph.microsoft.com/v1.0/users/mailFolders/dfb56165-6def-46a7-8b9a-a0fb5ed07830
/mailFolders/AAMkADQ3MzM1YmQ2LTNkMTAtNDY4ZC04ZjlkLWViN2ExMWM5YTI4MwAuAAAAAABbjjLR1DCUS5BQIL0iW2CMAQBj1B6VlgjUTK7YeJmGqrbGAAAAAAEIAAA="
Invoke-MgGraphRequest -Method GET -uri $uri

#check totalitemcount and unreaditemcount
$scopes= @("Mail.Read.Shared", "email" ,"openid","profile","User.Read", "email")

$sent= Get-MgUserMailFolder -UserId $user | Where { $_.DisplayName -eq "Sent Items"} | Select -ExpandProperty Id
Get-MgUserMailFolder -UserId $user -MailFolderId $sent | Select TotalItemCount, UnreadItemCount




$mbs= import-csv $env:OneDrive\mbstatsJM.csv

$statscombined= $mbs | % {
   $userobj= get-mgbetauser -UserId $_.Name | select JobTitle, Manager, EmployeeId, Department
   [PSCustomObject]@{
      Name = $_.Name
      LastLogonTime= $_.LastLogonTime
      LastUserActionTime= $_.LastUserActionTime
      JobTitle = $userobj.JobTitle 
      Manager= $userobj.Manager
      EmpId= $userobj.EmployeeId
      Dept= $userobj.Department
      
   }


}

$objects=@{
ReferenceObject= (import-csv -path $env:USERPROFILE\Downloads\user_list.csv) #James List <=
DifferenceObject= (import-csv -path $env:USERPROFILE\Downloads\UnifiedLogs.csv)

}

Compare-Object @objects -PassThru

$objects=@{
   ReferenceObject= (import-csv -path $env:USERPROFILE\Downloads\UnifiedLogs.csv)
   DifferenceObject= (import-csv -path $env:USERPROFILE\Downloads\user_list.csv) #James List <=
   
   }
   
   Compare-Object @objects -PassThru