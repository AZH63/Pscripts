function Convert-weborders 
{
param (
    [string]$domain
)
Get-Mailbox -filter "ForwardingSmtpAddress -like '$domain*'" |Select -expandProperty PrimarySmtpAddress tee-object -variable mbs
$mbs | % {  
write-verbose "converting to shared mailboxes"
Set-mailbox -identity $_ -Type Shared
#add it to csv and update csv with each iteration to track changes 
}
}

function Convert-sku {
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
New-Guid  "$($licenseinfo.SkuId)"
}

}

function offboard-user {

   param (
    [object[]]$upn
    
   )

   $weborders= [System.Collections.ArrayList]::new()
  
Get-Mailbox -filter "ForwardingSmtpAddress -like '$domain*'" |Select -expandProperty PrimarySmtpAddress tee-object -variable mbs
 $weborders.Add( [PSCustomObject]@{
    mail = $_
    Licenses= $license.SkuPartNumber
    licensesku= $license.SkuId
  })




     } 


}






