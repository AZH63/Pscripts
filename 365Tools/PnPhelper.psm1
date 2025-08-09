function install-pnp {
$classic=Get-Module SharePointPnPPowerShellOnline -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending

if ($classic) {

    Uninstall-Module SharePointPnPPowerShellOnline -Force -AllVersions

} 

else {

    Install-Module PnP.PowerShell 

}

try {	
Register-PnPEntraIDAppForInteractiveLogin -ApplicationName "PnP PowerShell" -SharePointDelegatePermissions "AllSites.FullControl" -Tenant "1x4bs0.onmicrosoft.com" -Interactive -ErrorAction Stop
#  if not GA do Register-PnPManagementShellAccess -ShowConsentUrl and share Url with GA
#get TenantId= Get-PnPTenntID
}
catch {
 write-warning "either not GA or App already"
 return


}

#add env. variable
$PnPAppId= Get-MgbetaApplication -filter "displayname eq 'PnP Powershell'" | select -expandProperty AppId
[System.Environment]::SetEnvironmentVariable("PnP_Client_Id", $PnPAppId, [EnvironmentVariableTarget]::Machine)
site=Connect-PnPOnline -URL 1x4bs0.sharepoint.com  #mainsite
}
Function Connect-PnP {
param(
    $siteurl="https://1x4bs0.sharepoint.com",
    $clientId=$env:PnP_Client_Id

)
Connect-PnPOnline -url $siteurl -Interactive -clientId $clientId

}

function get-onedrivepnp {
 param (
    $adminurl="https://1x4bs0.sharepoint.com",
    [Parameter(Mandatory=$true)]
    $DisplayName,
    $clientid=$env:PnP_Client_Id
    )


 Connect-PnPOnline -url $adminurl -Interactive -clientId $clientid
}