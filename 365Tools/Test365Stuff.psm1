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













$Groups= Get-MGGroup '"DisplayName:GroupName"'  -ConsistencyLevel eventual
$AllGroups | % {Add-mgGroupMember -userid "$((Get-MgUser -filter " mail eq 'AdeleV@1x4bs0.onmicrosoft.com'").Id)" -Id  }
