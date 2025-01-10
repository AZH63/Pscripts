Test365Stuff.psm1
<#
.SYNOPSIS 
helpful tools for messing about




#>
Import-Module AzTools

Function Add-AllToGroups {



}

Function Remove-AllFromGroups {





}

$Groups=Get-MgGroup | Select MailEnabled,DisplayName, SecurityEnabled,GroupTypes,Id
ForEach ( $group in $Groups) {
if ($group.GroupTypes -ne "DynamicMembership") {
    if ( $group.GroupTypes -like "*Universal*" -or $group.SecurityEnabled -eq $false -or ( $group.SecurityEnabled -eq $true -and $group.MailEnabled -eq $false )) {
        Write-Host "365 or sec"
        Write-host "$($group.DisplayName) types $($group.GroupTypes) $($group.MailEnabled) $($group.SecurityEnabled )"

    }
    elseif ($group.MailEnabled -eq $true -and $group.SecurityEnabled -eq $true) {
        Write-Host "mesg or distro"
      Write-host "$($group.DisplayName) types $($group.GroupTypes) $($group.MailEnabled) $($group.SecurityEnabled )"
    }
}
    else { 
        write-host " $($group.DisplayName) is dynamic"
    }


    
}