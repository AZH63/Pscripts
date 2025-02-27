$Groups= Get-DistributionGroup -Resultsize Unlimited 
$List= [System.Collections.ArrayList]::new()

ForEach ($group in $Groups) {

 $members= Get-DistributionGroupMember -Identity $group.PrimarySmtpAddress | Select -ExpandProperty PrimarySMTPaddress

 $List.Add( [PSCustomObject]@{
    group = $group.PrimarySmtpAddress
    members= $members -join ','
    ManagedBy = $group.ManagedBy
    WhenChanged= $group.WhenChanged
    WhenCreated= $group.WhenCreated
    GroupType= $(if ($group.GroupType -like "*SecurityEnabled*") { write-output "Mesg" }
    else { write-output "Distro"} )
 } ) | Out-Null

}
$List | Export-Csv "$env:UserProfile\Downloads\DistroMesg.csv"

$LowCountMesgOrDistro= $List | Where { $_.members -le 5}
$LowCountMesgOrDistro | Export-csv "$env:UserProfile\Downloads\LowCountMesg.csv"


$List | Export-Csv "$env:UserProfile\Downloads\list.csv"


<# $Teams= Get-AzureADGroup -All $true | Where {$_.MailEnabled -eq $true }

$teamsexpo= $Teams | % { 

 $members= (Get-AzureADGroupMember -All $true -ObjectId $_.ObjectId).Mail

    [PSCustomObject]@{
        group = $_.Mail
        members= $members -join ','
        ManagedBy = $_.ManagedBy
        WhenChanged= $_.WhenChanged
        WhenCreated= $_.WhenCreated


}

}

$teamsexpo | Export-Csv -path $env:UserProfile\Downloads\365_2_6_25.csv
Not sure why I felt the need for this
#> 
