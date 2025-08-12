
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
[System.Environment]::SetEnvironmentVariable("PnP_Client_Id_lab", $PnPAppId, [EnvironmentVariableTarget]::Machine)
site=Connect-PnPOnline -URL 1x4bs0.sharepoint.com  #mainsite

Function Connect-PnP {
param(
    $siteurl="https://1x4bs0.sharepoint.com",
    $clientId="$env:PnP_Client_Id_lab"

)
Connect-PnPOnline -url $siteurl -Interactive -clientId $clientId

}

connect-PnP -siteurl (Get-OneDrivepnp -upn "alexw@1x4bs0.onmicrosoft.com")
 
function get-onedrivepnp {
    <#
    .NOTES
       pnp app needs user.read.all for this
    #>
    
 param (
    $adminurl="https://1x4bs0.sharepoint.com",
    [Parameter(Mandatory=$true)]
    $upn,
    $clientid=$env:PnP_Client_Id)

#app needneeds User.Profile.readall
 Connect-PnPOnline -url $adminurl -Interactive -clientId $clientid
 (Get-PnPUserProfileProperty -Account $upn).PersonalUrl
}


function get-pnpinventory { 
    
    param (
        $documentlibrary="/Documents",
        [string]$clientId=$env:PnP_Client_Id_lab,
        [switch]$siteurl,
        [switch]$groupname,
        [switch]$upn
    )
    switch ($PSBoundParameters.Keys){

$siteurl{
 Connect-PnPOnline -url $siteurl -Interactive -ClientId $clientId
}
$groupname{
 Get-PnPGroup -Identity $groupname 
}
$upn{

}



    }

$all= Get-PnPListItem -list $documentlibrary -PageSize 1000
$audit=[System.Collections.ArrayList]::new()
$all | % {
#[string]$contenttypeid= $_.FieldValues.ContentTypeId
#$contenttypeId.Startswith("0x0120")? "folder": "document"
   
$audit.Add([PSCustomObject]@{
   Name = $_.FieldValues.FileLeafRef
   path= $_.FieldValues.Fileref
   ParentFolder=$_.FieldValues.FileDirRef
   folderswithin= $_.FieldValues.FolderChildCount
   fileswithin= $_.FieldValues.ItemChildCount 
   #type= $contenttypeId.Startswith("0x0120")? "folder": "document"
   type= ($_.FieldValues.FSObjType -eq '0')? "file" : "folder"
   

}) | out-null

}
$audit
}


