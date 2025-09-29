

function rename-devices {
  [CmdletBinding()]
param(
[Parameter(Mandatory=$true)]
[string[]]$newname,
[parameter(Mandatory=$true)]
[string[]]$deviceids,
[string]$path="$env:userprofile\downloads\"
)
$succeslog=[System.Collections.ArrayList]::new()
$errorlog=[System.Collections.ArrayList]::new()
#if ($PSBoundParameters["$($([array]$PSBoundParameters.keys)[0])"].Count -ne $PSBoundParameters["$($([array]$PSBoundParameters.keys)[1])"].Count ){
if ($newname.Count -ne $deviceids.Count) {
write-warning "equal number of new names and device ids please"
return;

}
$hash=$PSBoundParameters | % {
    [ordered]@{
     "newname"= $_.newname
     "deviceid"=$_.deviceids
     
   
   
    }
   
   }


forEach ($device in $hash) {
    
    write-verbose "looking for device to rename to $($device.newname)"
    $dupe= Get-MgDeviceManagementManagedDevice -filter "deviceName eq '$($device.newname)'"
    if ($null -eq $dupe) {
        try {
          write-verbose "attempting rename"
            Set-MgBetaDeviceManagementManagedDeviceName -managedDeviceId $($device.deviceid) -DeviceName $($device.newname) -ErrorAction Stop
        Sync-MgBetaDeviceManagementManagedDevice -ManagedDeviceId $($device.deviceid)
        
        }
        catch {
              
            $errorlog.Add( "$($device.NewName) failed to rename $error[0]")

        }
        }
    else {

        "dupe detected, skipping"
          
        $errorlog.Add("$($device.newname)- is a dupe $($device.deviceid)")
        return
        
    }
    



}
$errorlogs | out-file -path "$path" +"errorlogs.txt"
$sucesslog | out-file -path "$path"+ "successlog.txt"

}





#doesn't exist in intune already
#


$testCsv=[ordered]@{
 "NewName"="TestRename1","TestRename2","TestRename3"
 "DeviceId"="592bfeb4-448f-4a87-83fb-8e824316a700","779e637a-9014-407e-a793-b17cabe92192"
  



}

  
$testCsv | % {



    
}

function Get-BoundParameters {

    param(

    [string[]]$param1="testval1",
    [string[]]$param2="testval2"
    )

$PSBoundParameters

}


$users=Get-MgBetauser -all 

$operations= $users | Where { $_.Department -like "*operations*" -or $_.Department -like "*Warehouse*" -or $_.Department -like "*420*" -and $_.EmployeeType -like "*Administrative*" }