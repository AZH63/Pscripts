Connect-MgGraph
$All=Get-MgBetaUser -All | Select Department, Id
$CostCenters=import-Csv -Path $env:USERPROFILE\Downloads\Costcenters.csv

$Concat= $CostCenters | % {   
    $($_.Department)+'-' + $($_.CostCenter) 
    
}



ForEach ($user in $All) {

$UserDept=$Concat| Where { $_ -like "$($user.Department)-*"} 
if ($UserDept) {
    $_
    Write-host "$($user.Id) $UserDept"
    Update-MgBetaUser -UserId "$($user.Id)" -Department $UserDept
    
}

}
#Get Users
#read csv
# make a new array of concatenated cost centers and depts 

# for each user match dept to Cost Center name