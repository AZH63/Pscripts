

$test=Get-Mgbetaauditlogsignin -filter "AppDisplayName eq 'Windows Sign In'" | % {
[PSCustomObject]@{
    Name = $_.UserPrincipalName
    DeviceId= $_.DeviceDetail.DeviceId
    DeviceDisplayName= $_.DeviceDetail.DisplayName
} 
}






} 


$results= Get-Mgbetaauditlogsignin -filter "AppDisplayName eq 'Windows Sign In'" | % {
 
@{
   
Name = $_.UserPrincipalName
    DeviceId= $_.DeviceDetail.DeviceId
    DeviceDisplayName= $_.DeviceDetail.DisplayName


}
}


$results= Get-Mgbetaauditlogsignin -filter "AppDisplayName eq 'Windows Sign In'" -All | % {
 
[ordered]@{
   $userdetails= Get-mgbetauser -userid ($_.UserPrincipalName) | Select Jobtitle, Department
   $manager= Get-mgbetausermanager -userid ($_.UserPrincipalName)
Name = $_.UserPrincipalName
    DeviceId= $_.DeviceDetail.DeviceId
    DeviceDisplayName= $_.DeviceDetail.DisplayName
    Department= $userdetails.Department
    Jobtitle= $userdetails.Jobtitle
    Manager= $manager.UserPrincipalName


}
}

$results | export-csv -path $env:userprofile\downloads\results.csv
$resultsobj= import-csv -path $env:userprofile\downloads\results.csv