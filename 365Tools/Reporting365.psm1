

Function Get-GroupInfoExport {
  <#
  .SYNOPSIS 
  Allows input of multiple search strings to get group information, including member lists, and exports the results to a CSV.
  
  .DESCRIPTION
  This function retrieves information about distribution groups matching specified search strings, gathers details about group members, and exports the data to a CSV file.
  
  .PARAMETER Searchstr
  An array of search strings used to find distribution groups.
  
  .EXAMPLE
  Get-GroupInfoExo -Searchstr "Team", "Project"
  #>
      [CmdletBinding()]
      param (
          [Parameter(ValueFromPipeline=$true)]
          [string[]]$searchstr,
          [switch]$messages
          

      )
      
      Begin {
          $results = [System.Collections.ArrayList]::new()

          $csvname = Read-Host "Enter the name for the resulting CSV file (without extension)"
      }
  
      Process {
        if ( $null -eq $searchstr){
            write-warning "searching for all"
            $groups= Get-DistributionGroup -ResultSize unlimited
         
         
         }
         else {
          $groups= $searchstr | % {
              Get-distributiongroup -filter "displayName -like '*$_*'" 
         
         
           }
         
         }
              if ($null -ne $groups ) {
                  Write-verbose "Groups found for '$searchstr': $($groups)" 
                   
                  foreach ($group in $groups) {
                      Write-Verbose "Processing group: $($($group.DisplayName))"
                      
                      if ($PSBoundParameters.ContainsKey('messages') ){
                        $trace= try {get-messagetracev2 -RecipientAddress $group.PrimarySmtpAddress -StartDate (( get-date).AddDays(-10)) -EndDate (Get-date) -ResultSize 10 -ErrorAction Stop
                          Start-Sleep -Milliseconds 500
                        }
                        catch {
                           write-warning " unable to trace $group  $($Error[0])" 
                        }
                      }
                    $members=Get-distributiongroupmember -Identity $group.PrimarySmtpAddress | select -ExpandProperty PrimarySmtpAddress
                  
                      $Results.Add( [PSCustomObject]@{
                          GroupName    = $group.PrimarySmtpAddress
                          GroupTypes   = $group.GroupType
                          Hidden       = $group.HiddenFromAddressListsEnabled
                          CreatedDate  = $group.WhenCreated
                          LastChanged  = $group.WhenChanged
                          ManagedBy    = ($group.ManagedBy | ForEach-Object { $_.DisplayName }) -join ', '
                          Members      = $members -join ', '
                          messageslast10= ($trace)? $trace.Count : "trace option not selected"
                          
                      }) | Out-Null
                  }
              } else {
                  Write-warning "No groups found for '$Search'."
          }
        }
  
      End {
          if ($Results) {
              $OutputPath = "$env:USERPROFILE\Downloads\$CSVName.csv"
              Write-Host "Exporting results to $OutputPath" -ForegroundColor Green
              $Results | Export-Csv -Path $OutputPath -NoTypeInformation
              Start-Process -FilePath $OutputPath
          } else {
              Write-Host "No results to export." 
          }
      }
    }
    function get-groupinfo {
      param (
          [Parameter(ValueFromPipeline=$true)]
          [string[]]$searchstr,
          [switch]$messages
  
      )
  
      
     $groups= $searchstr | get-distributiongroup -ErrorAction SilentlyContinue
  
  if ($null -eq $groups) {
  
  write-verbose "no groups found"
  return 
  
  }
  
  if ($groups -ne $searchstr) {
  
      $comp=Compare-Object -ReferenceObject $searchstr -DifferenceObject $groups
     $diff= $comp | Where { $_.SideIndicator -eq "=>" }
  
  write-verbose "missing groups are $diff"
  }
  
  $exoresults= $groups | Get-distributiongroup | select PrimarySMTPaddress, GroupType,HiddenFromAddressListsEnabled,ManagedBy,LastChanged
  
  
  $completed= $exoresults | % { 
    [PSCustomObject]@{
      GroupName    = $_.PrimarySmtpAddress
      GroupTypes   = $_.GroupType
      Hidden       = $_.HiddenFromAddressListsEnabled
      CreatedDate  = $_.WhenCreated
      LastChanged  = $_.WhenChanged
      ManagedBy    = ($_.ManagedBy | ForEach-Object { $_.DisplayName }) -join ', '
      Members      = Get-distributiongroupmember -identity $($_.PrimarySmtpAddress) | select -ExpandProperty PrimarySmtpAddress
    }
  
  } 
}
   



  
  

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
             $res= Get-MgUser -Search "DisplayName:$_" -ConsistencyLevel eventual -ea Stop
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
             Write-Warning "value is null"
             
        }
        else {
        $nologonweek | export-csv -path $env:UserProfile\Downloads\nologonweek.csv
        start $env:UserProfile\Downloads\nologonweek.csv
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
       $mbstats | export-csv -path $env:UserProfile\Downloads\mbstats.csv  
    
     }
  
    
     }
     
  }
  }
# just use admin center reports, looking for the magical endpoint currently


  
  
  
  



