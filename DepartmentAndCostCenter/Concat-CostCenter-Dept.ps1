Connect-MgGraph
$All=Get-MgBetaUser -All | Select Department, Id, Mail
$CostCenters=import-Csv -Path $env:USERPROFILE\Downloads\Costcenters.csv
$WrongData= @()
$Concat= $CostCenters | % {   
    $($_.Department)+'-' + $($_.CostCenter) 
    
}



ForEach ($user in $All) {

$UserDept= $Concat| Where { $_ -like "*$($user.Department)*"} 
$UserDept
#$UserDept.GetType()

if ($UserDept) {
    $_
    Write-host "$($user.Id) $UserDept"
    Update-MgBetaUser -UserId "$($user.Id)" -Department $UserDept
    
    
}
 else {
    write-warning "no match found for $($user.Mail)'s dept"
    
    $data=[PSCustomObject]@{
        departmentlisted = $($user.Department)
        user = $($user.Mail)
    }
 $WrongData+= $data
}

}
#Get Users
#read csv
# make a new array of concatenated cost centers and depts 

# for each user match dept to Cost Center name

