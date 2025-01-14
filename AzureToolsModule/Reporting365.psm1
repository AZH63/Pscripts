Function Get-GroupInfo {

    param (
        [Parameter(mandatory)]
        [string]$Searchstr
    )
    
    
    $Group= Get-DistributionGroup -Identity $SearchStr
    $CSVName= Read-Host "name the resulting CSV, which will be placed in your downloads folder"
    
    $Results= $Group | % {
    
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
    
   