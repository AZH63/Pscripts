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


Function Disable-SharedMb {

    $mbs= get-mailbox -filter " RecipientTypeDetails -eq 'SharedMailbox' " | Select -ExpandProperty  PrimarySmtpAddress
       write-verbose "shared mbs found: $mbs "

    $userobj= $mbs | % { Get-MgBetaUser -u
        serid $($_) | select AccountEnabled,Id,UserPrincipalName }
   Write-Verbose "user obj found in entra, $userobj"
    $bad= $userobj | Where AccountEnabled -eq $true
    write-verbose "these mbs are enabled: $bad"


     $param=@{AccountEnabled= $false}
    $bad | % {update-mgbetauser -userid $($_.id) -BodyParameter $param}
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
     
$User=Get-MgBetaUser -Filter "UserPrincipalName eq '$mail'"

$GroupIds= (Get-MgBetaUserMemberOf -UserId $($User.Id)).Id
$Groupinfo= $GroupIds | % { Get-MgBetaGroup -GroupId $_ | Select Mail,GroupTypes,MailEnabled,Id  } ## for some reason can't pull these from memberof

ForEach ($group in $GroupInfo) {

if ($null -ne $group.Mail) {

    if ($group.GroupTypes -cmatch "Unified" -and $group.GroupTypes -notcontains "DynamicMembership") {
        Write-verbose "$($group.Mail) is a 365 group with types: $($group.GroupTypes)"
        Remove-MgBetaGroupMemberByRef -GroupId $group.Id -DirectoryObjectId $user.Id
    } elseif ( $($group.MailEnabled) -eq $true  -and $group.GroupTypes -notcontains "DynamicMembership") {
        Write-verbose "$($group.Mail) is a mail-enabled security group MESG) with types: $($group.GroupTypes)"
    } else {
        Write-verbose "$($group.Mail) does not match any specific conditions."
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

function search-object {
    <#
    .DESCRIPTION
    filters based on property and searchterms

    #>
    param (
        [CmdletBinding(DefaultParameterSetName= 'Default')]
    [parameter(Mandatory=$true)]
      $term1,
      $term2,
      $term3,
      [parameter(Mandatory=$true)]
      [validateset("JobTitle","department","name")]
      [string] $property,
      [parameter(Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
      [object]$inputobject
      
    ) 
    
    begin {
$results= [System.Collections.ArrayList]::new()
    }
    process {
    $filterScript= {

        $_.$property -like "*$term1*" -or ($term2 -and $_.$property -like "*$term2*") -or ($term3 -and $_.$property -like "*$term3*")
    }

  $results.Add($($inputobject | Where-Object -FilterScript $filterScript)) | Out-Null
      
}
end {
$results
}
    }


Get-MgBetaUserMemberOf -UserId $upn


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

Function Remove-Groups {
param (
    [string]
)

}









Get-MgBetaGroupMemberOf




Invoke-MgGraphRequest -Method GET -uri $uri | ConvertTo-Json

$user
ForEach($use in $user) {

$uri = "https://graph.microsoft.com/v1.0/users/$((Get-MgBetaUser -userid "yoohooo@1x4bs0.onmicrosoft.com").Id)/memberOf"
invoke-MgGraphRequest -Method GET $uri $uri | convert-ToJson



}
<# Measure-Command {Get-MgUserMemberOf -UserId $User.Id | Select Id }

Measure-Command { (Get-MgUserMemberOf -UserId $user.id).id } (winner)

measure-command {$GroupIds | % { Get-MgGroup -GroupId $_ | Select Mail,GroupTypes  } } (slight winner)
measure-command { $GroupIds | % { Get-MgGroup -GroupId $_   } }



#>
