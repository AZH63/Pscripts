
#Requires -Modules "Microsoft.Online.SharePoint.PowerShell"
#Requires -version 5.1

Function Connect-SharePointSpo {
param (
    [parameter(HelpMessage="name of domain")]
    [string]$domain="1x4bs0",
    [parameter(HelpMessage="Whole name, add onmicrosoft.com for those with no vanity domain")]
    [string]$FQDN="1x4bs0.onmicrosoft.com"

    
)
# either use -useWindowsPowershell switch when importing or install only on 5.1, 
# had the issue where regardless of the switch I was stil authenticating with core on 1 device 
$tenantUrl="https://$domain-admin.sharepoint.com"
try {
    
    Connect-SPOService -Url $tenantUrl  -ModernAuth $true -AuthenticationUrl "https://login.microsoftonline.com/$FQDN" -ErrorAction Stop 
    
    
    }
    catch {

        $installed= Get-Module -ListAvailable -name "Microsoft.Online.SharePoint.PowerShell"
        
        if (!$installed){
          Install-Module Microsoft.Online.SharePoint.PowerShell
         
        }
        else  {
              write-verbose "installation detected"
              Import-Module Microsoft.Online.SharePoint.PowerShell  -verbose
            
           Connect-SPOService -Url $tenantUrl  -ModernAuth $true -AuthenticationUrl "https://login.microsoftonline.com/$FQDN" -ErrorAction Stop 

        }
    
    }


}

Function Get-OneDriveURL {

    param (
   [string]$DisplayName=" "
  
    )
    if ($PSBoundParameters["DisplayName"]) {
    Get-SPoSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/$DisplayName'" | Select -ExpandProperty Url 
    }
    else {
        write-host "no DisplayName entered grabbing all URLs"
        Get-SPoSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'" | Select -ExpandProperty Url 
    }
}

Function Remove-PeopleList {
 [CmdletBinding()]
    param (
        [parameter(mandatory=$true,HelpMessage="enter in UPN")]
        [string]$user,
        [switch]$all,
        [string]$domain="1x4bs0.ommicrosoft.com",
        [parameter(HelpMessage="enter in displayNames")]
        [string[]]$sharers,
        [parameter(mandatory=$true,HelpMessage="enter in displayname (no email at this moment pls) of administrator currently logged in for if permissions are required")]
        [string]$adminUser="yoohooo"
    )

    if ( $PSBoundParameters.ContainsKey('all')) {
           
    $sites= [System.Collections.ArrayList]::new()
    
    $sites.Add($(Get-OneDriveUrl))
    $displayname= $user.split("@")[0] 
    $end=$domain.replace(".","_")

    $sites.Remove($($sites | Where { $_ -like "*$($displayname)_$end"}))



    }
if ( $PSBoundParameters.ContainsKey('all')) {

    $urls= Get-OneDriveURL



}
else {
   
    $displayNames= $sharers | %{
        if ($_ -like "*@*") {
              ($_.Split("@"))[0]
        }
        else {
        $_
      
      
      }
      
      }
    

$urls= $displayNames | % {
        
      Write-Verbose "grabbing URLs"
        Get-OneDriveURL -DisplayName $_ 
    }
}
    write-verbose "sites grabbed: $urls"
   
    ForEach ($url in $urls) {
       
     try { write-verbose "attempting to remove user from $url with no site admin"
     Remove-SPOUser -site $url -loginname $user -ErrorAction stop
     write-verbose "success"


    }
    catch {
        write-verbose "permission issue, granting admin privs of user's personal site to admin"
        Set-SPOUser -Site $url -loginname $adminUser  -IsSiteCollectionAdmin $true   
    try {
        write-verbose "admin privs set reattempting $user removal from $url"
        Remove-SPOUser -site $url -loginname $user -ErrorAction Stop
        write-verbose "change successful, reverting permissions"
        Set-SPOUser -Site $url -loginname $adminUser  -IsSiteCollectionAdmin $false
    }
        catch {
            write-warning "there was an issue: $Error"
            write-verbose "ensuring admin is revoked"
            Set-SPOUser -Site $url -loginname $adminUser  -IsSiteCollectionAdmin $false 
        }
        
    }
     

    }

    
}

Function Get-OneDriveURLGraph {
  param (
    [string]$upn,
    [switch]$beta
    
  )
  if ($PSBoundParameters["beta"]) {
    $user= Get-MgBetaUser -filter "UserPrincipalName eq '$upn'" | select -expandProperty Id
  $url= Get-MgBetaUserDefaultDrive -UserId $user | select -ExpandProperty WebUrl
  return $url

  }
  else {
 $user= Get-MgUser -filter "UserPrincipalName eq '$upn'" | select -expandProperty Id
  $url= Get-MgUserDefaultDrive -UserId $user | select -ExpandProperty WebUrl
  return $url
  }


}

$sites=Get-SPOSite -Limit All

$days=180
$sites | Where { $_.LastContentModifiedDate -gt ((Get-Date).AddDays(-180)) } | Select Name, Owner, ResourceQuota

#Site recycle bin ( deleted sites)
#get-spodeletedsite

# how does site recycle bin affect storage
# site collection recycle bin
# compliance policies for sharepoint storage










