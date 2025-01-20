Function Get-GroupInfoExo {
<#
.SYNOPSIS 
Can enter in multiple searchStrings to get groupinfo including memberlist


#>
    param (
        [Parameter(mandatory)]
        [string[]]$Searchstr
    )
    
     $Groups=$Searchstr| % {
        $Search= $_
       Get-DistributionGroup | Where { $_.DisplayName -like "*$Search*" } 
       Write-host "Groups found: $($_)"
}
write-host "Groups captured $Groups"
$CSVName= Read-Host "name resulting CSV"

$Results= $Groups | % {
    
    $groupinfo= $_
   
    $members = Get-DistributionGroupMember -identity $($groupinfo.Name) | Select -ExpandProperty PrimarySmtpAddress
    [PSCustomObject]@{
        GroupName = $groupinfo.PrimarySmtpAddress
        GroupTypes= $groupinfo.GroupType
        Hidden= $groupinfo.HiddenFromAddressListsEnabled
        CreatedDate= $groupinfo.WhenChanged
        LastChanged= $groupinfo.WhenChanged
        ManagedBy= $($groupinfo.ManagedBy).DisplayName
        Members= $members -join ','
        
   }
   
 }

 #$messagetracehist= $Groups | % {  Get-MessageTrace -RecipientAddress $($_.PrimarySmtpAddress) -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) }
  
# write-host "$messagetracehist"
 $Results | Export-CSV -Path $env:USERPROFILE\Downloads\$CSVName.Csv

 Start-Process  $env:USERPROFILE\Downloads\$CSVName.Csv
 }

 




Function Get-Trace { 
    
    param (
        [Parameter(ValueFromPipeline = $true)]
        [object[]]$Groups
        )

$Results= $Groups | % {
    $PrimarySmtpAddress = $_.PrimarySmtpAddress
   $trace=Get-MessageTrace -RecipientAddress $($_.PrimarySmtpAddress) -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) 
    
     [PSCustomObject]@{
       TraceFor = $PrimarySmtpAddress
        received= $trace.received
        SenderAddress= $trace.SenderAddress
        
    
}
 


 }
return $Results
 
 }

