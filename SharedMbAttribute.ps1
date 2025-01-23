
$Users= Get-AzureADUser -All $true |  Select ExtensionProperty, UserPrincipalName, Department, UserType

$info= $Users |
ForEach-Object {

    $propdata= $_.ExtensionProperty
    $employeeId= $propdata["employeeId"]
[PSCustomObject]@{
    UPN = $_.UserPrincipalName
    empId = $employeeId
    dept= $_.Department
    <# empId = if ($null -eq $employeeid) { "$null" } else { $_.empId }
    Dept = if ($null -eq $_.Department) { "$null" } else { $_.Department }#>
}

    
}
$info

$SharedMb= ($info | Where-Object {  $_.empId -le "1" -and $_.UserType -ne "Guest" } ).UPN
#($info | Where-Object { $null -eq $_.empId -and $null -eq $_.Dept} ).UPN

ForEach ( $Shared in $SharedMb) {

Set-AzureADUserExtension -ObjectId $Shared -ExtensionName "employeeId" -ExtensionValue "Shared Mailbox"
Set-AzureADUser -ObjectId $Shared -AccountEnabled $false


}

 