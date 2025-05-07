$365= Get-UnifiedGroup
$Dist= Get-DistributionGroup

$365 | Where {[string]::IsNullOrEmpty($_.ManagedBy) } | Select PrimarySMTPaddress, ManagedBy | Tee-Object -variable fatherless365
$Dist | Where { [string]::IsNullOrEmpty($_.ManagedBy)} | Select PrimarySMTPaddress, ManagedBy | Tee-Object -variable fatherlessdistro

$ownerless= $fatherless365 + $fatherlessdistro

$OrphanlistDist= $fatherlessdistro | % {
 $members=(Get-DistributionGroupMember -Identity $_.PrimarySMTPaddress ).PrimarySmtpAddress

 [PSCustomObject]@{
    name = $_.PrimarySMTPaddress
    members= $members -join ','
    
 }

}
$Orphanlist365= $fatherless365 | % {
    $members=(Get-UnifiedGroupLinks -Identity $_.PrimarySMTPaddress -LinkType members).PrimarySmtpAddress
    [PSCustomObject]@{
        Name = $_.PrimarySMTPaddress
        members= $members -join ','
    }
}

$OrphanlistDist | % {
  write-host ""

}

#group expired no manager
# find the members
#search the members grab dept and title
# if title says 'manager' 
   # list 
      # if only 1 promote
# if more than 1...  
