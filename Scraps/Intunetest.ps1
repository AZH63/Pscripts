

function rename-devices {

param(
[Parameter(Mandatory=$true)]
[string[]]$newname,
[parameter(Mandatory=$true)]
[string[]]$deviceids
)


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
}


forEach ($device in $hash) {
    
    write-verbose "looking for device to rename to $($device.newname)"
    Get-MgDeviceManagementManagedDevice -filter "deviceName eq '$($device.newname)'"




}


#doesn't exist in intune already
#


$testCsv=[ordered]@{
 "NewName"="TestRename1","TestRename2","TestRename3"
 "DeviceId"="592bfeb4-448f-4a87-83fb-8e824316a700","779e637a-9014-407e-a793-b17cabe92192"
  



}

  


function Get-BoundParameters {

    param(

    [string[]]$param1="testval1",
    [string[]]$param2="testval2"
    )

$PSBoundParameters

}