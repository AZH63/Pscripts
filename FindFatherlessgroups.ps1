$365= Get-UnifiedGroup
$Dist= Get-DistributionGroup

$365 | Where {[string]::IsNullOrEmpty($_.ManagedBy) } | Select PrimarySMTPaddress, ManagedBy | Tee-Object -variable fatherless365
$Dist | Where { [string]::IsNullOrEmpty($_.ManagedBy)} | Select PrimarySMTPaddress, ManagedBy | Tee-Object -variable fatherlessdistro

$ownerless= $fatherless365 + $fatherlessdistro

$memberlistDist= $fatherlessdistro | % {
 $members=(Get-DistributionGroupMember -Identity $_.PrimarySMTPaddress ).PrimarySmtpAddress

 [PSCustomObject]@{
    groupname = $_
    members= $members -join ','
    
 }

}
$memberlist365= $fatherless365 | % {
    $members=(Get-UnifiedGroupLinks -Identity $_.PrimarySMTPaddress -LinkType members).PrimarySmtpAddress
    [PSCustomObject]@{
        Name = $_
        members= $members -join ','
    }
}

