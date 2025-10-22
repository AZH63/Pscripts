

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

function Get-Logs {
 
 [Parameter(Mandatory=$true)]
 [string]$reportpath,
 [integer]$days

$devices = import-csv -path $reportpath



}




# commented out queries run too long so getting ntwk timeouts, plan to 

$devices= import-csv -path "C:\Users\User\Downloads\Devices Joined + No MDM.csv"

$30d= (Get-Date).AddDays(-30) | format 
$signinlogs= Get-Mgbetaauditlogsignin -filter "AppDisplayName eq 'Windows Sign In'" -All | % {
 #$userdetails= try {Get-mgbetauser -userid ($_.UserPrincipalName) | Select Jobtitle, Department -ErrorAction Stop} catch {"there was an error"}

# $manager= try {Get-mgbetausermanager -userid ($_.UserPrincipalName) -erroraction Stop } catch { write-warning "user has no manager"}
[pscustomobject]@{

    userPrincipalName = $_.UserPrincipalName
    DeviceId= $_.DeviceDetail.DeviceId
    DeviceDisplayName= $_.DeviceDetail.DisplayName
    #Department= ($userdetails -eq "there was an error" )? "null": $userdetails.Department
    #Jobtitle= ($userdetails -eq "there was an error" )? "null": $userdetails.Jobtitle 
    #Manager= ($manager -eq $null -or $manager -eq "user has no manager")? "user has no manager": $manager.AdditionalProperties.UserPrincipalName
    date= $_.CreatedDateTime


}
}
$devices=import-csv -path "C:\Users\User\Downloads\DevicesJoined.csv"
$signinlogs= import-csv -path "C:\Users\User\Downloads\signinlogs10_6.csv"
$moreinfo= forEach ($device in $devices) {
   $users=$signinlogs | Where {$_.DeviceId -eq $device.deviceId} | select userPrincipalName, DeviceDisplayName, DeviceId,date

   $users | % {
$userinfo= try {Get-MgBetaUser -userid $($_.userPrincipalName) | select Department, Jobtitle, OfficeLocation -erroraction SilentlyContinue } catch { "offboarded"}
$manager= try  {get-mgbetausermanager -userid $($_.userPrincipalName) -errorAction SilentlyContinue} catch { "null"} 
[pscustomObject]@{

  upn= ($userinfo -eq "offboarded")? "offboarded":$_.userPrincipalName
  dept= ($userinfo -eq "offboarded")? "offboarded":$userinfo.department
  manager=($manager -eq "null")? "null": $manager.AdditionalProperties.userPrincipalName   
  deviceused= $_.DeviceDisplayName
  Deviceid= $_.DeviceId
  date= $_.date
  officelocation= $userinfo.OfficeLocation
}

   }
} 

Invoke-MgGraphRequest -Uri  "https://graph.microsoft.com/beta/auditLogs/signIns$filter=CreatedDateTime ge $30d " -method GET

#doesn't exist in intune already
#


$testCsv=[ordered]@{
 "NewName"="TestRename1","TestRename2","TestRename3"
 "DeviceId"="592bfeb4-448f-4a87-83fb-8e824316a700","779e637a-9014-407e-a793-b17cabe92192"
  



}

  
$testCsv | % {




}

$groups | % {

[pscustomobject]@{

 email= $_
 MessageTrace=  Get-messagetracev2 -RecipientAddress $_ -StartDate (Get-date).AddDays(-10) -EndDate (Get-date)



}


} | Tee-Object -variable messages




function Get-BoundParameters {

    param(

    [string[]]$param1="testval1",
    [string[]]$param2="testval2"
    )

$PSBoundParameters

}


$users=Get-MgBetauser -all 

$operations= $users | Where {( $_.Department -like "*operations*" -or $_.Department -like "*413*" -or $_.Department -like "*414*" -or   $_.Department -like "*415*" -or $_.Department -like "*420*" -or $_.Department -like "*418*" -or $_.Department -like "*419*" ) -and ( $_.EmployeeType -like "*Salary*" -or $_.Jobtitle -like "*supervisor*" -or $_.Jobtitle -like "*manager*" -or $_.EmployeeType -like "*Administrative*" )}


$operations = $users | Where-Object {
    ($_.Department -match "operations|413|414|415|418|419|420|399") -and
    ($_.EmployeeType -match "Salary|Administrative" -or $_.JobTitle -match "supervisor|manager")
} | select UserPrincipalName, DisplayName


$logs= import-csv -path $env:USERPROFILE\downloads\Devicessigninlogs.csv

$operations= import-csv -path $env:userprofile\downloads\ops.csv
$operations | % {

[pscustomobject]@{
DisplayName= $_.Employees
UserPrincipalName = $_.UPN
DeviceID= ($logs | Where { $_.Name -eq $_.UPN} ).DeviceId
 DeviceDisplayName=($logs | Where { $_.Name -eq $_.UPN}).DeviceDisplayName
  


}

} | tee-object -variable test


