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