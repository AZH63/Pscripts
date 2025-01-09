# AZTools.psm1
<#
.SYNOPSIS
AZTools module for automating onboarding and offboarding processes.

.DESCRIPTION
Contains functions to create users, assign licenses, manage groups, 
disable users, convert mailboxes, and more.

.AUTHOR
Azaria Horton
#>
function Connect-AZTools {
    <#
    .SYNOPSIS
    Authenticates to exchange online and entra.

    .DESCRIPTION
    Connects to Microsoft Graph and Exchange Online.

    .EXAMPLE
    Connect-AZTools
    #>

    do {
    $choice= Read-Host "make sure roles are activated and choose a module to login  1. graph 2. exchange. 3. AzureAD 4. exit"
    Switch ($choice) {
    1 {Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Mail.ReadWrite"}
    2 {Connect-ExchangeOnline }
    3 {Connect-AzureAD }
    4{break}
    }
}
    while ($choice -ne 4) 
}

function set-EmailForwarding {
    param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory)]
        [string]$ForwardingAddress
    )

    Set-Mailbox -Identity $UserPrincipalName -ForwardingSmtpAddress $ForwardingAddress `
        -DeliverToMailboxAndForward $true



}
function Convert-MailboxToShared {
    param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName
    )

    Set-Mailbox -Identity $UserPrincipalName -Type Shared
    #remove license
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
function Disable-AzUser {
    param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName
    )
#reset password

$randomPassword = [System.Web.Security.Membership]::GeneratePassword(12, 2)

#revokesessions

# disable acct


}

Function Get-GroupMembership {
# any groups that are mail-enabled use the email address, no email Sec groups can use 
    [CmdletBinding(SupportsShouldProcess)] #adds whatif or confirm
    param ( 
    [parameter(mandatory)]
    [string[]]$GroupsToSearch )

ForEach ($group in $GroupsToSearch) {

   try {
    Get-AzureADGroup -ObjectID $group -ErrorAction Stop
   }
   catch {
    Write-Warning " not a sec group"
    try {
        Get-DistributionGroup -Identity $group  -ErrorAction Stop
    }
    catch {
        try {
        Get-UnifiedGroupLinks -Identity $group   
        }
        catch {
           write-error -message "does this thing even exist??"
        }
    }
   }

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
    accepts email, displayname or full name as argument- for multiple arguments call as so: update-Primarysmtpaddress -User "Test Azaria", "testaz"
    
    
    #>

param ( 
    [Parameter(mandatory)]
    [string[]] $User,
    [string]$domain= "baldorfood.com"
)

ForEach ($person in $User) {
    $CleanStr= $person.Trim()
$mb= if ($person -notlike "*@*") {

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



Function Search-MailboxesExport{
<#
 .SYNOPSIS
 search mailboxes, enter as argument the words the mailbox must contain ex. "testAz", "onmicrosoft.com", function willyyy

#>
param (
    [string] $Searchstr
)
write-host "searching for users"
$AddsToCorr= Get-Mailbox | Where-Object { $_.PrimarySMTPaddress -like "*$Searchstr*" -and $_.RecipientType -eq "UserMailbox" -and $_.DisplayName -notlike "*DiscoverySearchMailbox*"} | Select PrimarySMTPaddress, displayName
Write-host " these users need correcting $AddsToCorr , csv will be sent to your profile's download folder"
$AddsToCorr | Export-Csv -path $env:UserProfile\Downloads\AddsToCorr.csv    -NoTypeInformation
}

 Function Fix-Primarysmtp {
   write-host "do you want to 1. enter users yourself or 2. grab from a csv"
    $choice= read-host "pick a choice?"
   switch ( $choice) {
1{  $Users= Read-Host " what users are you looking to update? enter like "
    Update-PrimarySmtpAddress -User $Users  }

2 {    
     $Searchstr= "onmicrosoft.com"
     Search-MailboxesExport -Searchstr $Searchstr
     $Users= import-Csv -Path $env:USERPROFILE\Downloads\AddsToCorr.csv | Select -ExpandProperty PrimarySmtpAddress
     Update-PrimarySmtpAddress -User $Users
    
}

   }

}

Function Remove-MailEnabledMg {
param (
[parameter(mandatory)]
[string]$mail
)
if ($mail  -notlike "*@*") {
    $mail= Read-Host "Please enter in an email no quotation marks needed" 
    }
    write-host "user is $mail" 
     Connect-AZTools

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
         Connect-AZTools
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
        write-host " $($group.DisplayName): a sec group"

        }




}

}

<# Remove sec group menu driven function, maybe use indexes as switch choices #>



#






















<# Measure-Command {Get-MgUserMemberOf -UserId $User.Id | Select Id }

Measure-Command { (Get-MgUserMemberOf -UserId $user.id).id } (winner)

measure-command {$GroupIds | % { Get-MgGroup -GroupId $_ | Select Mail,GroupTypes  } } (slight winner)
measure-command { $GroupIds | % { Get-MgGroup -GroupId $_   } }


#>
