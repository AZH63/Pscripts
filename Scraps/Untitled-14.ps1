# $teams=Get-AzureADSubscribedSku | Where { $_.SkuPartNumber -like "*Essentials*" }
# $TeamsEssentials= import-csv -path "$env:OneDrive\TeamsEss.csv"
$e1= import-csv -Path $env:OneDrive\E1ToRemove.csv
$TeamsGroup= Get-AzureADGroup -filter "DisplayName eq 'ALL_M365_Licenses_TeamsEssentials'" | select -expandProperty ObjectId
$alreadyin= [System.Collections.ArrayList]::new()

forEach ( $team in $e1) {
    Add-AzureADGroupMember -ObjectId $TeamsGroup -RefObjectId $team."column1" -ErrorAction Stop -ErrorVariable $err -Verbose 
}
try {
Add-AzureADGroupMember -ObjectId $TeamsGroup -RefObjectId $team."column1" -ErrorAction Stop -ErrorVariable $err -Verbose 
Write-Host "member added, attempting license removal"
$licensedUser= Get-AzureADUSer -ObjectID $team."column1"
$license= New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense 
$license.SkuId= $licensedUser.AssignedLicenses.SkuId
$licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$licenses.RemoveLicenses= $license.SkuId
Set-AzureAdUserLicense -objectId $team."column1"  -AssignedLicenses $licenses


}
catch {
    Write-Host "nope"
    $alreadyin.Add( $team."column1") | out-null
 
}
}


<# $licensedUser= Get-AzureADUSer -ObjectID "testaz@baldorfood.com "
$license= New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense 
$license.SkuId= $licensedUser.AssignedLicenses.SkuId
$licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$licenses.RemoveLicenses= $license.SkuId
Set-AzureAdUserLicense -objectId "testAZ@baldorfood.com" -AssignedLicenses $licenses #>