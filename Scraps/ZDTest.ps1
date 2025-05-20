
Function generate-password {
    param (
        
    [ValidateRange(12, 256)]
    [int]$length = 14
    )
    <#
    .Description 
    .Net Core doesn't have [system.web] :(
    #>
    $symbols= '!@#$%^&*'.ToCharArray()
    $charlist= 'a'..'z' + 'A'..'Z' + '0'..'9' + $symbols
    $password= -join (0..$length | % { $charlist | Get-Random })
    $newpass= $password | ConvertTo-SecureString -AsPlainText
    return $newpass
    }
function convert-users {
    [CmdletBinding()] 
param (
    [string[]]$upn,
    [switch]$removelicense
)
write-verbose "$upn"
$upn | % {  
write-verbose -Message "converting to shared mailbox $info"
Set-mailbox -identity $_ -Type Shared
$params=@{
    AccountEnabled=$false 
    EmployeeType="Shared Mailbox"
  passwordProfile=@{
    forceChangePasswordNextSignIn=$false
    password= $(Generate-Password)
  }
}
write-verbose "revoking sessions, resetting password and disabling "
Revoke-MgBetaUserSignInSession -UserId $_
Update-MgBetaUser -UserId $_ -BodyParameter $params

if ($PSBoundParameters.ContainsKey('removelicense')) {
    
  $license= Get-MgBetaUserLicenseDetail -UserId $_ | select -ExpandProperty SkuId
  if ($null -eq $license) {
    write-warning "no license found"

  }
  else {
  write-verbose "removing license found: $license"
  Set-MgBetaUserLicense -userid $_ -RemoveLicenses @($license) -AddLicenses @{}
  }

}


}

}









Get-Mailbox -filter "forwardingsmtpaddress -like '*zendesk.com'" | tee-object -variable weborders
$WebordersProgress=  [System.Collections.ArrayList]::new()

$weborders | % {

   $WebordersProgress.Add( [PSCustomObject]@{
        Name = $_.UserPrincipalName
        Converted= ($_.RecipientTypeDetails -eq "SharedMailbox") ? "converted" : "no"

    } )| Out-Null

}

#tee-obj won't overwrite a variable if output is null














function convert-sku {
    [CmdletBinding()]
param (
    [string]$upn,
    [parameter(Mandatory=$true)]
    [string]$skuname


)
  
$license= if ($PSBoundParameters.ContainsKey('upn')) {Get-MgBetaUserLicenseDetail -userId $upn | select *} {Get-MgBetaSubscribedSku}
write-verbose "$license" 

$licenseinfo= $license | Where { $_.SkuPartNumber -like "*$($PSBoundParameters["skuname"])*"} | select SkuPartNumber,SkuId 
if ($licenseinfo.Count -gt 1) {
write-warning "be more specific, here are the skus found $license"
return

}
else {
    write-verbose " Sku id found: $($licenseinfo.SkuId)"
New-Guid  "$($licenseinfo.SkuId)"
}

}

set-mgbetauserlicense -userid $_."Object Id" -RemoveLicenses @($teamsguid) -AddLicenses @{}



Get-MgBetauserlicenseDetail -userid "userweborders1@baldorfood.com"  | select -expandProperty SkuId | tee-object -variable test
s> set-mgbetauserlicense -userid "userweborders1@baldorfood.com" -RemoveLicenses @($test) -AddLicense @{}

Offboard-user {
 param (
    [string]$upn,
    [string]$delegate
 )
 
 set-mailbox -Identity $($PSBoundParameters["upn"]) -type Shared

if ($PSBoundParameters.ContainsKey('delegate')) {
 
  Add-MailboxPermission -Identity $PSBoundParameters["upn"]


}


}


$mbs= Get-Mailbox -filter "RecipientTypeDetails -eq 'UserMailbox' "

$records= [PSCustomObject]@{
    
}
$mbs[0..5] | % {
  Get-MessageTrace -SenderAddress $($_.PrimarySMTPaddress) -RecipientAddress ("*@Baldorfood.com*")
 $records | add-member -NotePropertyName "SenderAdd" -NotePropertyValue "$($_.PrimarySMTPaddress)" -Force
$records |add-member -NotepropertyName "Recipient" -NotePropertyValue "$($_.RecipientAddress)" -Force
}
$mbs[6..-1]



$users= Get-MgBetaUser -All
 $users | where { $_.employeetype -like "*terminated*"} | tee-object -variable term
$term | % {
 Set-mailbox -Identity $_.UserPrincipalName -Type Shared 
 $license=Get-MgBetaUserlicensedetail -userid $_.UserPrincipalName | select SkuId,SkuPartNumber
try {
    if ($license.Count -gt 0) {
        foreach ($lic in $license) {
            Set-MgBetaUserLicense -UserId $($_.UserPrincipalName) -RemoveLicenses @($lic) -AddLicenses @{}

        }
    }
    set-MgBetaUserLicense -userid $($_.UserPrincipalName) -RemoveLicenses @( $license.SkuId) -AddLicenses @{} -erroraction Stop
}
catch {
    write-warning "check $($_.UserPrincipalName)"
}

}

$e3Today= import-csv -path $env:USERPROFILE\Downloads\E3TOday.csv

$e3May= $e3Today | % {
      $entra= get-mgbetauser -userid $_.'User principal name' | select *
      $skus= Get-MgBetaUserLicenseDetail -userid $_.'User Principal Name' | select -ExpandProperty SkuId
   [PSCustomObject]@{
    Name= $_."User Principal Name"
    License= $_.AssignedProductSkus
    LicenseSku= $skus -join","
    status= $entra.EmployeeType
    jobtitle= $entra.JobTitle
    ForwardingAdd= (Get-Mailbox -Identity $_.'User Principal Name' | select ForwardingSmtpAddress)
    
   }
}

$servicee3= import-csv -path $env:OneDrive\ServiceAccountsE3.csv


$weborders= Get-Mailbox -filter "ForwardingSmtpAddress -like '*'" | select ForwardingSmtpAddress,PrimarySMTPaddress

$wbs= $weborders | % {
[PSCustomObject]@{
    Name = $_.PrimarySMTPaddress
    'ZD Add'= ($_.ForwardingSmtpAddress).Remove(0,6)
    triggers= Get-MessageTrace -SenderAddress $($_.PrimarySMTPaddress) -RecipientAddress $_.'ZD Add' -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) -PageSize 1 | start-sleep  -seconds 500 -Verbose
}
start-sleep -Milliseconds 500

}


 

