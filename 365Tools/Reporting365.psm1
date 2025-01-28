Function Get-GroupInfoExo {
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
          $Results = @() # Initialize the results array
          $CSVName = Read-Host "Enter the name for the resulting CSV file (without extension)"
      }
  
      Process {
          foreach ($Search in $Searchstr) {
              Write-Verbose "Searching for groups with search string: $Search"
              
              $Groups = Get-DistributionGroup | Where-Object { $_.DisplayName -like "*$Search*" }
              
              if ($Groups) {
                  Write-Host "Groups found for '$Search': $($Groups.Count)" -ForegroundColor Green
                  
                  foreach ($Group in $Groups) {
                      Write-Verbose "Processing group: $($Group.DisplayName)"
                      
                      $Members = Get-DistributionGroupMember -Identity $Group.Name | Select-Object -ExpandProperty PrimarySmtpAddress
                      
                      $Results += [PSCustomObject]@{
                          GroupName    = $Group.PrimarySmtpAddress
                          GroupTypes   = $Group.GroupType
                          Hidden       = $Group.HiddenFromAddressListsEnabled
                          CreatedDate  = $Group.WhenCreated
                          LastChanged  = $Group.WhenChanged
                          ManagedBy    = ($Group.ManagedBy | ForEach-Object { $_.DisplayName }) -join ', '
                          Members      = $Members -join ', '
                      }
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

 
 Write-Verbose "Getting the distribution groups and generating csv"
 $Dist=Get-DistributionGroup | Select -ExpandProperty PrimarySMTPaddress
 $Distros=$Dist | ForEach-Object {
    $Members= (Get-DistributionGroupMember -identity $_).PrimarySmtpAddress
   [PSCustomObject]@{
     group = $_
     Members= $Members
     MemberCount= $Members.Count
   }
 }
 write-verbose " csv will be labled Distros and located in your profile's downloads folder"
 $Distros | export-Csv -NoTypeInformation $env:USERPROFILE\Downloads\Distros.csv
 
 $Groupsremoved =[System.Collections.Generic.List[object]]::new()

 $Emptygroups= [System.Collections.Generic.List[object]]::new()

 
 foreach ($distro in $Distros) {
  $validResponses = @('y', 'n', 'exit')
 do {
  Write-Host "`nProcessing group: $($distro.group)" -ForegroundColor Green
  $try=Read-host " do you want to remove the members (y/n/exit)?"
 switch ($try.ToLower()) {
 "y"{ 
  Write-host "members are $($distro.Members)" -ForegroundColor Cyan
  if ( $null -eq $distro.Members) {
    write-host "no members wtf is this group for?" -ForegroundColor Yellow
    $Emptygroups=[PSCustomObject]@{
      Group = $distro.group
      Members= $distro.Members
      DateChecked= Get-Date
    }
    $Emptygroups.Add($nomem)
  }
  else {
    write-host "members: $members, will be removed and stored in csv"
    $lowmem=[PSCustomObject]@{
      Group = $distro.group
      Members= $distro.Members
      DateChanged= (Get-Date)
    }
    $Groupsremoved.Add($lowmem) 
  }
  break
 }
 "n" {
 write-host "skipping"
 break
 }
 "exit" { break}
 default { write-host "pick a valid choice"
 }
 

 }
 
 }
 while ($try -ne "y" -and $try -ne "n")
 
 
 
 }

 $Groupsremoved | Export-Csv -path "$env:UserProfile\Downloads\GroupsRemoved.Csv"
 $Emptygroups | Export-Csv -path "$env:UserProfile\Downloads\EmptyGroups.Csv"
 
 
 
 