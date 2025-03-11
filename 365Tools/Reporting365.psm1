

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
          [Parameter(Mandatory, ValueFromPipeline=$true)]
          [string[]]$Searchstr
      )
      
      Begin {
          Write-Verbose "Initializing variables and validating input..."
          $Results = [System.Collections.ArrayList]::new()

          $CSVName = Read-Host "Enter the name for the resulting CSV file (without extension)"
      }
  
      Process {
          foreach ($Search in $Searchstr) {
              Write-Verbose "Searching for groups with search string: $Search"
              
              $Groups = Get-DistributionGroup -ResultSize Unlimited  -filter " DisplayName -like '*$Search*'"
              
              if ($Groups) {
                  Write-Host "Groups found for '$Search': $($Groups)" -ForegroundColor Green
                  
                  foreach ($Group in $Groups) {
                      Write-Verbose "Processing group: $($Group.DisplayName)"
                      
                      $Members = Get-DistributionGroupMember -Identity $Group.Name | Select-Object -ExpandProperty PrimarySmtpAddress
                      
                      $Results.Add( [PSCustomObject]@{
                          GroupName    = $Group.PrimarySmtpAddress
                          GroupTypes   = $Group.GroupType
                          Hidden       = $Group.HiddenFromAddressListsEnabled
                          CreatedDate  = $Group.WhenCreated
                          LastChanged  = $Group.WhenChanged
                          ManagedBy    = ($Group.ManagedBy | ForEach-Object { $_.DisplayName }) -join ', '
                          Members      = $Members -join ', '
                      })
                  }
              } else {
                  Write-Host "No groups found for '$Search'." -ForegroundColor Yellow
              }
          }
      }
  
      End {
          if ($Results) {
              $OutputPath = "$env:USERPROFILE\Downloads\$CSVName.csv"
              Write-Host "Exporting results to $OutputPath" -ForegroundColor Green
              $Results | Export-Csv -Path $OutputPath -NoTypeInformation
              Start-Process -FilePath $OutputPath
          } else {
              Write-Host "No results to export." -ForegroundColor Red
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
       $mbstats | export-csv -path $env:UserProfile\Downloads\mbstats.csv  
    
     }
  
    
     }
     
  }
  }
  
  
  
  



Function Get-TraceOld { 
    
    param (
        [Parameter(ValueFromPipeline = $true)]
        [object[]]$Groups
        )

$Results= $Groups | % {
    $PrimarySmtpAddress = $_.PrimarySmtpAddress
  try { $trace=Get-MessageTrace -RecipientAddress $($_.PrimarySmtpAddress) -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) 
  }
  catch {
            
    $trace=Get-MessageTrace -RecipientAddress $_ -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) 
}
  }
     [PSCustomObject]@{
       TraceFor = $PrimarySmtpAddress
        received= $trace.received
        SenderAddress= $trace.SenderAddress
        
    
}
return $Results


 }

 Function Get-TraceNew{ 
    # messagetrace not rlly wkg too nicely in either vers there has to be a better way
    param (
        [parameter(Mandatory, ValueFromPipeline=$true)]
        
        [string[]]$Groups
        )
begin {
    $GroupsTrace=[System.Collections.Generic.List[object]]::new()
   
}
process {
    try {
        try { $trace=Get-MessageTrace -RecipientAddress $($_.PrimarySmtpAddress) -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) -Verbose
           Start-Sleep -Milliseconds 500 
             $GroupsTrace.Add([PSCustomObject]@{
               TraceFor = $Groups
               received= $trace.received
               SenderAddress= $trace.SenderAddress
           }) 
        }
        catch {
            $trace=Get-MessageTrace -RecipientAddress $_ -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) -Verbose
            Start-Sleep -Milliseconds 500  
            $GroupsTrace.Add([PSCustomObject]@{
                TraceFor = $Groups
                received= $trace.received
                SenderAddress= $trace.SenderAddress
                    })
           }
        }
           catch {
             Write-Warning "dunno" 
      
    }
  
   
    }

    
    end { $GroupsTrace
    }
 }
