
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
        [parameter(mandatory=$true,HelpMessage="enter in UPN of administrator currently logged in for if permissions are required")]
        [string]$adminUser
    )

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
        Get-OneDriveURL -DisplayName $_ }

    write-verbose "sites grabbed: $urls"
    ForEach ($url in $urls) {
       
     try { write-verbose "attempting to remove user from with no site admin"
     Remove-SPOUser -site $url -loginname $user -ErrorAction stop
    }
    catch {
        write-verbose "permission issue, granting admin privs of user's personal site to admin"
        Set-SPOUser -Site $url -loginname $adminUser  -IsSiteCollectionAdmin $true   
    try {
        write-verbose "admin privs set reattempting user remove"
        Remove-SPOUser -site $url -loginname $user -ErrorAction Stop
        write-verbose "change successful, reverting permissions"
        Set-SPOUser -Site $url -loginname $adminUser  -IsSiteCollectionAdmin $false
    }
        catch {
            write-warning "there was an issue" $Error
            write-verbose "ensuring admin is revoked"
            Set-SPOUser -Site $url -loginname $adminUser  -IsSiteCollectionAdmin $false 
        }
        
    }
     

    }

    
}



# Get the person's site/OneDriveURL
#set yourself as admin of the personal site-- Set-SPOUser -Site $lee -loginname "yoohooo@1x4bs0.onmicrosoft.com"  -IsSiteCollectionAdmin $true
#remove affected user: Remove-SpOUser -Site $lee -loginName "DiegoS@1x4bs0.onmicrosoft.com"
#This will remove the person from the peoplelist
#remove yourself as admin

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


Try {
    Connect-MgGraph -Scopes "Directory.ReadWrite.All", "Sites.ReadWrite.All", "Files.ReadWrite.All" -ErrorAction Stop

}
catch {
   

}



$installed=Get-Module -ListAvailable -name "PnP.PowerShell"
if (!$installed) {
Install-Module -Name "PnP.PowerShell" -Verbose
Import-Module "PnP.PowerShell" -Verbose
}
else {
    Import-Module "PnP.PowerShell" -Verbose

}
#check for app registration
#











<#
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


Remove-SpOUser -Site $lee -loginName "DiegoS@1x4bs0.onmicrosoft.com" #>