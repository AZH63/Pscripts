
<#
.Synopsis
User returns after many moons and no matter how many times they try cannot access OneDrive files shared with them from employees who worked with a user
with a coincadentally similar name...
.Description
Removing cached GUID from select personal sharepoint site


#>
Function Connect-SharePointSpo {
param (
    [parameter(HelpMessage="name of domain")]
    [string]$domain="1x4bs0",
    [parameter(HelpMessage="Whole name, add onmicrosoft.com for those with no vanity domain")]
    [string]$FQDN="1x4bs0.onmicrosoft.com"

    
)


$tenantUrl="https://$domain-admin.sharepoint.com"
try {
    
    Connect-SPOService -Url $tenantUrl  -ModernAuth $true -AuthenticationUrl "https://login.microsoftonline.com/$FQDN" -ErrorAction Stop 
    
    
    }
    catch {
        if (!"C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell"){
          Install-Module Microsoft.Online.SharePoint.PowerShell
         
        }
        else  {
              
           Import-Module Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell -verbose
           Connect-SPOService -Url $tenantUrl  -ModernAuth $true -AuthenticationUrl "https://login.microsoftonline.com/$FQDN" -ErrorAction Stop 

        }
    
    }


}

Function Get-OneDriveURL
{

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

    param (
        [parameter(mandatory=$true,HelpMessage="enter in UPN")]
        [string]$user,
        [parameter(mandatory=$true,HelpMessage="enter in displayNames")]
        [string[]]$sharers,
        [string]$adminUser
    )

    
$urls= $sharers | % {
        
      Write-Verbose "grabbing URLs"
        Get-OneDriveURL -DisplayName $_ }

    write-verbose "sites grabbed: $urls"
    ForEach ($share in $sharers) {
       
     try { write-verbose "attempting to remove user"
     Remove-SPOUser -site $share -loginname $user -ErrorAction stop
    }
    catch {
        write-verbose "setting ownership of site"
        Set-SPOSite -site $share -loginname $adminUser -IsSiteCollectionAdmin $true
    try {
        Remove-SPOUser -site $share -loginname $user
        Set-SPOSite -site $share -loginname $adminUser -IsSiteCollectionAdmin $true
    }
        catch {
            write-warning "there was an issue" $Error
            Set-SPOSite -site $share -loginname $adminUser -IsSiteCollectionAdmin $true # for if last remove failed and caught here
        }
        
    }
     

    }

    
}






# Get the person's site/OneDriveURL
#set yourself as admin of the personal site-- Set-SPOUser -Site $lee -loginname "yoohooo@1x4bs0.onmicrosoft.com"  -IsSiteCollectionAdmin $true
#remove affected user: Remove-SpOUser -Site $lee -loginName "DiegoS@1x4bs0.onmicrosoft.com"
#This will remove the person from the peoplelist
#remove yourself as admin














Connect-SharePointSpo -domain "1x4bs0" -FQDN "1x4bs0.onmicrosoft.com"
Get-OneDriveUrl -DisplayName "AdeleV"

Remove-SPOUser -Site https://$domain.sharepoint.com/sites/sc1 -LoginName "leeG"


$paths= $modules | % {

    $string= $_
    $string.Insert(-1,';')

}

$offender="C:\Users\YAWW\OneDrive\Documents\PowerShell\Modules;"

$Env:PSModulePath.replace("$offender","")

https://1x4bs0-my.sharepoint.com/personal/leeg_1x4bs0_onmicrosoft_com1/_layouts/15/people.aspx?MembershipGroupId=0


Remove-SpOUser -Site $lee -loginName "DiegoS@1x4bs0.onmicrosoft.com"