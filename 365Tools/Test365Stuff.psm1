Test365Stuff.psm1
<#
.SYNOPSIS 
helpful tools for messing about




#>
Import-Module AzTools

Function Add-ToGroups {

param (
    [Parameter(ValueFromPipeline=$true)]
    [object[]]$Users,
    [object[]]$Groups,
    [switch]$All

    

)
begin {
    $Groups= Get-MgGroup -All -ConsistencyLevel eventual
}
process {
    $params= @ {

    }
    New-MgGroupMemberByRef -GroupId $Groups.Id -DirectoryObjectId 
    
    
}
end {

}
}




Set-DynamicDistributionGroup -Identity BB_Sales -IncludedRecipients MailboxUsers `
    -ConditionalDepartment "912", "Sales-912", "Sales" `
    -ConditionalCompany "Boston", "MA" `
    -ConditionalCustomAttribute1 "Disabled"


    Set-DynamicDistributionGroup -Identity BB_Sales -RecipientFilter "(RecipientTypeDetails -eq 'UserMailbox') -and (Office -eq 'Boston' -or Office -eq 'MA') -and (Department -eq '912' -or Department -eq 'Sales-912' -or Department -eq 'Sales') -and (CustomAttribute1 -ne 'Disabled')"









$Groups= Get-MGGroup '"DisplayName:GroupName"'  -ConsistencyLevel eventual
$AllGroups | % {Add-mgGroupMember -userid "$((Get-MgUser -filter " mail eq 'AdeleV@1x4bs0.onmicrosoft.com'").Id)" -Id  }



Function Remove-DistMemb {
    param (
       
    [parameter(Mandatory)]
    [string]$identity,
       [string[]]$member 
       )
    
    begin {$group= $identity | % {  Get-DistributionGroup -Identity $identity} }
    process {
    
        if ( $group)
    $members= if ($group) { 
    $group | % { Get-DistributionGroupMember -identity $_ | Select -ExpandProperty PrimarySmtpAddress }
    }
    else {
        write-warning "group not found" 
    }
    
    
    
    $members | % { remove-distributionGroupMember -identity $identity -member $_ -BypassSecurityGroupManagerCheck -Confirm:$false}
    
    }
    end { }
    }