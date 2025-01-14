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
        CreatedDateUTC= $groupinfo.WhenChangedUTC
        LastChanged= $groupinfo.WhenChangedUTC
        ManagedBy= $($groupinfo.ManagedBy).DisplayName
        Members= $members -join ','
   }
   
 }
 $Results | Export-CSV -Path $env:USERPROFILE\Downloads\$CSVName.Csv


}



   