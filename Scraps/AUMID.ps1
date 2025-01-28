reg query HKCU\Software\Classes\ /s /f AppUserModelID | find "REG_SZ"


Function Get-AUMID {

    param (
        [string[]]$AppChoice
    )
begin {
    $Apps=Get-StartApps 
    $AppChoice
}

process {
    write-host "$_"
  ($AppID= $Apps | Where { $_.Name -like "*$AppChoice*"}).AppID
}
end {
    return 
    $AppID
}

}