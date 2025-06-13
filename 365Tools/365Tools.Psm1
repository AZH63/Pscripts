# AZTools.psm1
<#
.SYNOPSIS
AZTools module for automating onboarding and offboarding processes.

.DESCRIPTION
Contains functions to create users, assign licenses, manage groups, 
disable users, convert mailboxes, and more.


#>
function Connect-AZTools {
    <#
    .SYNOPSIS
    Authenticates to exchange online and entra.

    .DESCRIPTION
    Connects to Microsoft Graph, AzureAD and Exchange Online.

    .EXAMPLE
    Connect-AZTools
    #>

    do {
    $choice= Read-Host "make sure roles are activated and choose a module to login `n 1. graph 2. exchange. 3. AzureAD 4. exit"
    Switch ($choice) {
    1 {Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Mail.ReadWrite"}
    2 {Connect-ExchangeOnline }
    3 {Connect-AzureAD }
    4{break}
    }
}
    while ($choice -ne 4) 
}




Function Update-CustomAttribute1 {
    #have the other fx return email
param (
    [parameter(mandatory)]
    [string[]]$Users
)
$AzureInfo= $Users | ForEach-Object {
    $User= $_  # assigns the pipeline to the $User variable for convenience
    
    $AzureUser = Get-AzureADUSER -filter "UserPrincipalName eq '$User'" | Select-Object  AccountEnabled, UserPrincipalName
     if ($AzureUser) {
        $AzureUser
     }
    else {
    write-warning " User $User not found in Azure "
    
    }
    
    }
    
$AzureInfo | ForEach-Object {
    if ( $_.AccountEnabled -eq $false) {
     write-verbose " $($_.UserPrincipalName) is disabled"
    }
  else { write-verbose " $($_.UserPrincipalName) is enabled" }
  
    
    }
    }



Function Update-DDLSAzureAD {

    
    param ( 
    [parameter(mandatory)]
    [string[]]$GroupsToSearch )
    
    
    ForEach ($group in $GroupsToSearch) {
        $groupstr= $Group.Trim()
    try {
    $distmembers=Get-DynamicDistributionGroupMember -identity $groupstr | Select -ExpandProperty PrimarySmtpAddress
    write-verbose "group $groupstr has these members:$( $distmembers | format-table)"
    Update-CustomAttribute1 -Users $distmembers
       }
     catch {
    write-warning "check grouptype"
     }
       
    
    }
    $AzureInfo= $distmembers | ForEach-Object {Get-AzureADUser -identity $_.PrimarySmtpAddress | Select AccountEnabled, UserPrincipalName }
    $AzureInfo
    
}


Function Update-PrimarySmtpAddress {
    <#
    .Synopsis 
    changes primary address from fallback domain (onmicrosoft) to proper one. Domain is defaulted to baldorfood.com so doesn't need to be mentioned
    
    .Description
    accepts email, displayname or full name as argument- 
    for multiple arguments call as so: update-Primarysmtpaddress -User "Test Azaria", "testaz"
    Use update-primarysmtp for more options such as  upload via csv
    #>

param ( 
    [Parameter(mandatory)]
    [string[]] $User,
    [string]$domain= "1x4bs0.onmicrosoft.com"
)

ForEach ($person in $User) {
    $CleanStr= $person.Trim()
$mb=if ($person -notlike "*@*") {

 Get-Mailbox -anr $CleanStr | Select-Object -ExpandProperty PrimarySMTPaddress
}

else {
Get-mailbox -identity $CleanStr | Select-Object -ExpandProperty PrimarySMTPaddress
}
$splitemail="$mb".split('@')
$username=$splitemail[0]
$CurrDomain= $splitemail[-1]
write-host " the current primary email for $($person) is $($mb)"
if ( $CurrDomain -like "*onmicrosoft.com*") {

    set-mailbox $username -WindowsEmailAddress "$($username)@$($domain)" # -MicrosoftOnlineServicesID '$($username)@domain'
    write-host "Primary address changed to $(Get-mailbox -identity $username | Select-Object -ExpandProperty PrimarySMTPaddress)"
}
else {
write-host "domain is correct"
$mb

}



}

}



Function Search-MailboxesExport{
<#
 .SYNOPSIS
 search mailboxes, enter as argument the words the mailbox must contain ex. "testAz", "onmicrosoft.com", function wil
#>
param (
    [string] $Searchstr
)
write-host "searching for users"
$FoundBoxes= Get-Mailbox | Where-Object { $_.PrimarySMTPaddress -like "*$Searchstr*" -and $_.RecipientType -eq "UserMailbox" -and $_.DisplayName -notlike "*DiscoverySearchMailbox*"} | Select PrimarySMTPaddress, displayName
Write-host " these users were found $($FoundBoxes.DisplayName) , csv will be sent to your profile's download folder"
$choice= Read-host "Do you want to export the list of users y/n"
if ($choice -eq "y") {
    $FoundBoxes | Export-Csv -path $env:UserProfile\Downloads\FoundBoxes.csv   -NoTypeInformation
}
else {
write-host " no export, here are the users again: $($FoundBoxes | Format-Table)"

}



}

 Function Update-Primarysmtp {
    $choice=  read-host "choose a number choice: `n 1. enter users yourself or 2. run a search, generate csv and update adds 3. just search and grab CSV"
   switch ( $choice) {
1{  $Users= Read-Host " what users are you looking to update? enter email "
    Update-PrimarySmtpAddress -User $Users  }

2 {    
     $Searchstr= "onmicrosoft.com"
     Search-MailboxesExport -Searchstr $Searchstr
     $Users= import-Csv -Path $env:USERPROFILE\Downloads\FoundBoxes.csv | Select -ExpandProperty PrimarySmtpAddress
     Update-PrimarySmtpAddress -User $Users
    
}
3 {
    
    $Searchstr= "onmicrosoft.com"
    Search-MailboxesExport -Searchstr $Searchstr
    start-Process  $env:USERPROFILE\Downloads\AddstoCorr.csv

}
   }

}


Function Remove-groups {
   [CmdletBinding()]
 param (
    [string[]]$mail
 )

 forEach ( $m in $mail) {
$userid= Get-mgBetaUser -UserId $m | select -ExpandProperty Id
$groups= get-mgBetaUserMemberOf -userid ($m)
 
$groups | % {
    $groupid= $_.Id
   if ($_.GroupTypes -notlike "*DynamicMembership*") {      
 write-verbose  " not dynamic $($_.AdditionalProperties.mail) $groupid "
 try {
    write-verbose "attempting to remove $($m) from $($_.AdditionalProperties.mail)"
 Remove-DistributionGroupMember -Identity $($groupid) -Member $($userid) -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop 

 }
catch {
    "this is in the pipeline rn $($_)"
    write-warning "odds are its a 365 or smth $groupid"
try { Remove-MgBetaGroupMemberByRef -GroupId $($groupid) -DirectoryObjectId $($userid) -ErrorAction Stop }

catch {
  Remove-UnifiedGroupLinks -identity $($groupid) -LinkType Members -links $($userid) -Confirm:$false

}

}

   }
    else {
       
  "no can do, dynamic group"

    }



}
 


 }



}


Function Generate-Password {
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
Function Get-GroupId {
    [CmdletBinding()]
param(
    [string] $groupname

)
    $groupresult= ($groupname -like "*@*") ? (Get-MgBetaGroup -filter "Mail eq '$groupname'" | select -ExpandProperty id): (Get-MgbetaGroup -filter "displayname eq '$groupname'" | select -ExpandProperty id)

    if ($null -eq $groupresult ) {
       Write-Warning "result not found check groupname"
       return
    }
   elseif (($groupresult.GetType()).Name -ne "String") {
        write-warning "possibly Ambiguous result be more specific..."
       $groupresult | % {
                 
            Get-MgBetaGroup -GroupId $_ | select DisplayName, Mail, Id
        } 
        
        return
    }
write-verbose "group fed:$groupname, result found:$groupresult type: $($groupresult.GetType())"
$groupresult
}
function Get-GroupmemberMg {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
       [string] $groupname
       
    )
    <#| Where-Object  { $_.AdditionalProperties."@odata.type" -eq "#microsoft.graph.user"}#> 
    
        $groupresult= ($groupname -like "*@*") ? (Get-MgBetaGroup -filter "Mail eq '$groupname'" | select -ExpandProperty id): (Get-MgbetaGroup -filter "displayname eq '$groupname'" | select -ExpandProperty id)

         if ($null -eq $groupresult ) {
            Write-Warning "result not found check groupname"
            break
         }
         if (($groupresult.GetType()).Name -ne "String") {
             write-warning "possibly Ambiguous result be more specific..."
             $groupresult
             break
         }
    
   

    write-verbose "group fed:$groupname, result found:$groupresult type: $($groupresult.GetType())"

  
    $members=Get-MgBetaGroupMember -GroupId $groupresult -All | ForEach-Object {
       
        [PSCustomObject]@{
            DisplayName = $_.AdditionalProperties.displayName
            UserPrincipalName = $_.AdditionalProperties.userPrincipalName
            JobTitle = $_.AdditionalProperties.jobTitle
            EmployeeType = $_.AdditionalProperties.employeeType
            Id = $_.Id
            groupid= $groupresult
            groupName=$groupname

        }
    }
   $members
}







Function Add-GroupMember {
param (
    [string]$upns,
    [string]$group    
)

foreach ( $u in $upn) {
    $params = @{
        "@odata.id" = 
    "https://graph.microsoft.com/v1.0/directoryObjects/{$((Get-MgUser -userid $upn).id)}"     
    }
    write-verbose "addin"
    New-MgGroupMemberByRef -GroupId $groupId -BodyParameter      
    $params
    }
    

}

function convert-users {
    [CmdletBinding()] 
param (
    [string[]]$upn,
    [switch]$removelicense,
    [switch]$service
)
write-verbose "$upn"
$upn | % {  
write-verbose -Message "converting to shared mailbox"
Set-mailbox -identity $_ -Type Shared
$params=@{
    AccountEnabled=$false 
    EmployeeType=($PSBoundParameters.ContainsKey('service'))?"Shared Mailbox": "$(Get-MgBetaUser -userid $_ | select -ExpandProperty EmployeeType)"
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