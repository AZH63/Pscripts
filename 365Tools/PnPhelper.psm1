
$classic=Get-Module SharePointPnPPowerShellOnline -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending

if ($classic) {

    Uninstall-Module SharePointPnPPowerShellOnline -Force -AllVersions

} 

else {

    Install-Module PnP.PowerShell 

}




try {	
Register-PnPEntraIDAppForInteractiveLogin -ApplicationName "PnP PowerShell" -SharePointDelegatePermissions "AllSites.FullControl", "User.Read.All" -Tenant "1x4bs0.onmicrosoft.com" -Interactive -ErrorAction Stop
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
        [switch]$upn
    )
    switch ($PSBoundParameters.Keys){

$siteurl{
 Connect-PnPOnline -url $siteurl -Interactive -ClientId $clientId
}
$upn{
 Connect-PnP -siteurl (Get-OneDrivepnp -upn $upn)
}



    }

$all= Get-PnPListItem -list $documentlibrary -PageSize 1000
$audit=[System.Collections.ArrayList]::new()
$all | % {
#[string]$contenttypeid= $_.FieldValues.ContentTypeId
#$contenttypeId.Startswith("0x0120")? "folder": "document"
$parsedata= $_.FieldValues.MetaInfo | Convert-MetaInfoString -ErrorAction SilentlyContinue
   
$audit.Add([PSCustomObject]@{
   Name = $_.FieldValues.FileLeafRef
   path= $_.FieldValues.Fileref
   ParentFolder=$_.FieldValues.FileDirRef
   folderswithin= $_.FieldValues.FolderChildCount
   fileswithin= $_.FieldValues.ItemChildCount 
   #type= $contenttypeId.Startswith("0x0120")? "folder": "document"
   type= ($_.FieldValues.FSObjType -eq '0')? "file" : "folder"
   sharedWith=  $parsedata._activity.FileActivityUsersOnPage.Id
  
   

}) | out-null

}
$audit
}


function Convert-MetaInfoString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$MetaInfo
    )

    begin {
        # map short type codes to converters
        $typeMap = @{
            'IR' = { param($s) [int]$s }                    # integer
            'TR' = { param($s) [datetime]$s }               # time
            'SR' = { param($s) [string]$s }                 # string
            'SW' = { param($s) [string]$s }                 # string (often wraps JSON)
            'UR' = { param($s) [string]$s }                 # url/string
            'BL' = { param($s) [bool]$s }                   # bool (seen occasionally)
        }
        $lineRegex = '^(?<key>[^:]+):(?<type>[^|]+)\|(?<val>.*)$'
    }

    process {
        if (-not $MetaInfo) { return $null }

        $out = [ordered]@{}
        # MetaInfo lines are newline-separated; handle CRLF/LF and stray blanks
        foreach ($line in ($MetaInfo -split "`r?`n" | Where-Object { $_ -ne '' })) {

            if ($line -notmatch $lineRegex) { continue }

            $key  = $Matches.key
            $type = $Matches.type
            $val  = $Matches.val

            # convert by declared type if we know it; else keep string
            if ($typeMap.ContainsKey($type)) {
                try   { $val = & $typeMap[$type] $val } catch { }
            }

            # If the value *looks* like JSON, try to parse it
            if ($val -is [string] -and $val.TrimStart() -match '^[\{\[]') {
                try { $val = $val | ConvertFrom-Json -ErrorAction Stop } catch { }
            }

            $out[$key] = $val
        }

        # emit PSCustomObject
        [PSCustomObject]$out
    }
}
