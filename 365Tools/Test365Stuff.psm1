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
    [string[]]$identity
    )
    
    begin {$Groups= $identity | % {  try {(Get-DistributionGroup -identity $_).PrimarySmtpAddress }
    catch {
        Get-UnifiedGroup -identity $_
    }
    
    
    }
write-verbose "groups passed $Groups ( if any is missing its probably something else)"
}
    process {
    
    $Groups | % {
        if ($null -ne $_) {
         $group= $_
        write-host "group is $_"
        write-verbose "grabbing members"
      $members= (Get-DistributionGroupMember -identity $_ ).PrimarySMTPaddress
      write-verbose "members are $members from $group"
      forEach ( $mem in $members) {
        write-verbose "removing member $mem from $group"
      
       #  write-host "$_" 
        Remove-DistributionGroupMember -identity $group -member $mem -BypassSecurityGroupManagerCheck -Confirm:$false
      }
      }
      else {
        write-verbose "not a group or null "
      }
  
    } 
        }
        end { 
            $Groups | % {
                "Members are $((Get-DistributionGroupMember -identity $_).PrimarySmtpAddress)"
            }
        }
    }

   
      