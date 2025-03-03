Function Generate-Password {
    param (
        
    [ValidateRange(12, 256)]
    [int]$length = 14
    )
    <#
    .Description 
    .Net Core doesn't have system.web
    #>
    $symbols= '!@#$%^&*'.ToCharArray()
    $charlist= 'a'..'z' + 'A'..'Z' + '0'..'9' + $symbols
    $password= -join (0..$length | % { $charlist | Get-Random })
    $newpass= $password | ConvertTo-SecureString -AsPlainText
    return $newpass
    }
    Function Create-Groups {
        param (
            [int]$count=3
        )
    
       for ( $i=$count;$i -le $count;$i++) {
       
       $params= @{
            description = "test group"
            DisplayName = "Test 365 Group $i"
            groupTypes=@("Unified")
            mailEnabled = $true
            mailNickName= "Test365$i"
            securityEnabled= $false   
       
        }
        $paramsSec=@{
          description= "test secgroup"
          DisplayName="TestSec$i"
          mailEnabled = $false
          groupTypes=@()
          mailNickName="TestSec$i"
          securityEnabled= $true
        }
        New-MgGroup -BodyParameter $params
        New-MgGroup -BodyParameter $paramsSec 
       
    New-DynamicDistributionGroup -name “All_Employees” -RecipientFilter “((((RecipientType -eq 'UserMailbox') -and (-not(CustomAttribute1 -eq 'Disabled')))) -and (-not(Name -like 'SystemMailbox{')) -and (-not(Name -like 'CAS_{')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))”
        write-host "$i"
    }
}
    
Function Create-Users {
 param (
    [parameter(mandatory)]
    [int]$Count,
    [int]$startingpt= 1,
    [string]$tenant= "vincentadamarisoutlook.onmicrosoft.com"
    
 )
$startingpt..$Count| ForEach-Object { $params= @{
 accountEnabled= $true
 displayName= "user$_"
 mailNickName= "user$_"
 userPrincipalName = "user$_@$tenant"
  PasswordProfile= @{
    forceChangePasswordNextSignIn = $true   
    password = (Generate-Password)
}
}
New-MgUser -BodyParameter $params
Update-MgBetaUser -userId "user$_@$tenant"   -EmployeeId $_
}
}


Function Disable-Half {
param (
    [parameter(mandatory=$true, HelpMessage=" Admin Users to Exclude")]
    [string[]]$AdminUsers
    
)
$All= Get-MgUser -All 
$Users= $All | Where { $_ -notlike "*$AdminUsers*"  }
$midpoint=[math]::Ceiling($Users.Count /2)
$disabledUsers= $Users[$midpoint..($Users.Count -1)]
$disabledUsers | % {
    write-verbose "disabling user $($_.UserPrincipalName)"
    Update-MgBetaUser -UserId "$($_.Id)" -AccountEnabled $false
}

}


        #ToDo:  make this a psm1 and add these to required
   <# Install-Module Microsoft.Graph.Authentication -Confirm:$false
    Install-Module Microsoft.Graph.Users -Confirm:$false
    Install-Module Microsoft.Graph.Groups -Confirm:$false
    Import-Module Microsoft.Graph.Authentication 
    Import-Module Microsoft.Graph.Users 
    Import-Module Microsoft.Graph.Groups #>
    
