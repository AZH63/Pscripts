

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
  
Function Get-GroupInfo {
  param (
          [Parameter(Mandatory, ValueFromPipeline=$true)]
          [string[]]$Searchstr
      )
  begin {

  }
process {

}
end {

}


}
 




Function Get-Trace { 
    
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
    #mt not rlly wkg too nicely here
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
