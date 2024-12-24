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
    Authenticates to Microsoft 365 and Azure AD.

    .DESCRIPTION
    Connects to Microsoft Graph and Exchange Online.

    .EXAMPLE
    Connect-AZTools
    #>
    Connect-ExchangeOnline -ShowProgress $true
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Mail.ReadWrite"
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
}

function Disable-AzUser {
    param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName
    )
#reset password

$randomPassword = [System.Web.Security.Membership]::GeneratePassword(12, 2)



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





Function Update-DDLS {

    [CmdletBinding(SupportsShouldProcess)] #adds whatif or confirm
    param ( 
    [parameter(mandatory)]
    [string[]]$GroupsToSearch )
    
    
    ForEach ($group in $GroupsToSearch) {
    try {
    Get-DynamicDistributionGroup -identity $group -ErrorAction Stop
      
       }
     catch {
    write-warning "its probably a 365 group, switching commandlets"
         try {
         Get-UnifiedGroup -identity $group -ErrorAction Stop
         
         }
    catch {
        Write-Error -Message "nope, try again"
        }
    
}

    }










    
    }


Function Add-Forwarding {}

Function Convert-Shared{

}