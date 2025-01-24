
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

$Resource= ($info | Where-Object {  $_.empId -le "1" -and $_.UserType -ne "Guest" } ).UPN
#($info | Where-Object { $null -eq $_.empId -and $null -eq $_.Dept} ).UPN

ForEach ( $reso in $Resource) {

Set-AzureADUserExtension -ObjectId $reso -ExtensionName "employeeId" -ExtensionValue "Resource"
Set-AzureADUser -ObjectId $reso -AccountEnabled $false


}

 (Get-AzureADUser -ObjectId "AlexW@1x4bs0.onmicrosoft.com").ExtensionProperty["extension_GUID_employeeType"]