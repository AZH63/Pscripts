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
Function Disable-User {
    
    param(
        [Parameter(Mandatory)]
        [string[]]$UPN,
        [switch]$Graph
    )
Add-Type -AssemblyName 'System.Web'

if ($Graph) {


   $Users= forEach ($Up in $UPN) {
        if ($Up -like "*@*") {
       Get-MgBetaUser -filter " mail eq '$Up'" -ConsistencyLevel eventual 
        }
        else {
             Get-MgBetaUser -Search "DisplayName:$Up" -ConsistencyLevel eventual
        }
      

    }
    Write-Host "users grabbed: $($Users.UserPrincipalName)"
    Write-Verbose -message "generating new password"
ForEach ($user in $Users) {
$newpass= Generate-Password # same module
Write-Verbose -Message "resetting password"
$params=@{ newPassword= $newpass}
$authenticationMethodId= "28c10230-6103-485e-b985-444c60001490" #always
Reset-MgUserAuthenticationMethodPassword -UserId $($user.Id) -AuthenticationMethodId $authenticationMethodId -BodyParameter $params

}

}


    else {
$User= Get-AzureADUser -SearchString "$UPN"
Write-Verbose -message "generating new password"
$randomPassword = [System.Web.Security.Membership]::GeneratePassword(12, 2)
$newpass= $randomPassword | ConvertTo-SecureString -AsPlainText -Force
Write-Verbose -Message "resetting password"
Set-AzureADUserPassword -ObjectId $($User.ObjectId) -Password $newpass
Write-Verbose -Message "revoking sessions"
Revoke-AzureADUserAllRefreshToken -objectId $($User.ObjectId)
Write-Verbose -Message "disabling"
Set-AzureADUser -ObjectId $($User.UserPrincipalName) -AccountEnabled $false
}
}





<# Function Get-GroupMembership {
# any groups that are mail-enabled use the email address, no email Sec groups can use 
    [CmdletBinding()] 
    param ( 
    [parameter(mandatory, ValueFromPipeline)]
    [string[]]$GroupsToSearch )

begin {
    
 $Groups= $GroupsToSearch | ForEach-Object {
    if ($null -eq $_.) {
 }
}
 }

process {
       

}
end {
    
}
} 

#>



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


Function Add-Forwarding {}

Function Convert-Shared{

}

Function Disable-SharedMb {
 
    $Mbs= get-mailbox -filter " RecipientTypeDetails -eq 'SharedMailbox' " | Select  PrimarySmtpAddress, AccountEnabled
    $Bad= $Mbs | Where { $_.AccountEnabled -eq $true}
    $Bad | % { Set-AzureADUser -ObjectID $_.PrimarySmtpAddress  -AccountEnabled $false }
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

Function Remove-MailEnabledMg {
param (
[parameter(mandatory)]
[string[]]$mail
)
if ($mail  -notlike "*@*") {
    $mail= Read-Host "Please enter in an email no quotation marks needed" 
    }
    write-host "user is $mail" 
     
$User=Get-MgUser -Filter "UserPrincipalName eq '$mail'"

$GroupIds= (Get-MgUserMemberOf -UserId $($User.Id)).Id
$Groupinfo= $GroupIds | % { Get-MgGroup -GroupId $_ | Select Mail,GroupTypes,MailEnabled  } ## for some reason can't pull these from memberof

ForEach ($group in $GroupInfo) {

if ($null -ne $group.Mail) {

    if ($group.GroupTypes -cmatch "Unified" -and $group.GroupTypes -notcontains "DynamicMembership") {
        Write-Host "$($group.Mail) is a 365 group with types: $($group.GroupTypes)"
    } elseif ( $($group.MailEnabled) -eq $true  -and $group.GroupTypes -notcontains "DynamicMembership") {
        Write-Host "$($group.Mail) is a mail-enabled security group MESG) with types: $($group.GroupTypes)"
    } else {
        Write-Host "$($group.Mail) does not match any specific conditions."
    }


}
else {
    write-host "this group $($group)is not mail enabled"
  
  }
}
}

Function Remove-MailEnabledAzureAD {

    param (
        [parameter(mandatory)]
        [string]$mail
        )
     
        if ($mail  -notlike "*@*") {
        $mail= Read-Host "Please enter in an email no quotation marks needed" 
        }
        write-host "user is $mail" 
        
        $userid= (Get-AzureADUser -filter "UserPrincipalName eq '$mail'").ObjectId
        $Groups=Get-AzureADUserMembership -ObjectId $mail | Select ObjectId, DisplayName, MailEnabled, SecurityEnabled

        ForEach ($group in $Groups) {

         if ($group.MailEnabled -eq $true -and $group.SecurityEnabled -eq $false) {
          write-host " $($group.DisplayName) is 365"
          Remove-AzureADGroupMember -ObjectId $($group.ObjectId) -MemberId $userid
         }

         elseif ($group.MailEnabled -eq $true -and $group.SecurityEnabled -eq $true) {

         write-host " $($group.DisplayName) is mailEnabled"
         Remove-DistributionGroupMember -identity $($group.ObjectId) -member $mail -Confirm:$false -BypassSecurityGroupManagerCheck

        }
        else {
        write-host "$($group.DisplayName): a sec group"
        Remove-AzureADGroupMember -ObjectID $($group.ObjectId) -member $userid 

        }




}

}

<# Remove sec group menu driven function, maybe use indexes as switch choices #>



#

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





















<# Measure-Command {Get-MgUserMemberOf -UserId $User.Id | Select Id }

Measure-Command { (Get-MgUserMemberOf -UserId $user.id).id } (winner)

measure-command {$GroupIds | % { Get-MgGroup -GroupId $_ | Select Mail,GroupTypes  } } (slight winner)
measure-command { $GroupIds | % { Get-MgGroup -GroupId $_   } }



#>
