
$Users= Get-AzureADUser -All $true |  Select ExtensionProperty, UserPrincipalName

$info= $Users |
ForEach-Object {

    $propdata= $_.ExtensionProperty
    $employeeId= $propdata["employeeId"]
[PSCustomObject]@{
    UPN = $_.UserPrincipalName
    empId = $employeeId
    
}

    
}
$info

$SharedMb= ($info | Where  { $null -eq $_.empId } ).UPN

ForEach ( $S in $SharedMb) {

Set-AzureADUserExtension -ObjectId $S -ExtensionName "employeeId" -ExtensionValue "Shared Mailbox"


}

 