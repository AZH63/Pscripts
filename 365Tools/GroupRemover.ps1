$Dist=Get-DistributionGroup | Select -ExpandProperty PrimarySMTPaddress
$Distros=$Dist | ForEach-Object {
   $Members= (Get-DistributionGroupMember -identity $_).PrimarySmtpAddress
  [PSCustomObject]@{
    group = $_
    Members= $Members
    MemberCount= $Members.Count
  }
}

$Distros | export-Csv -NoTypeInformation $env:USERPROFILE\Downloads\Distros.csv
$Emptygroups = [System.Collections.ArrayList]::new()
$Groupsremoved = [System.Collections.ArrayList]::new()

foreach ($distro in $Distros) {
    $validResponses = @('y', 'n', 'exit')
    
    do {
        Write-Host "Processing group: $($distro.group)" -ForegroundColor Green
        Write-Host "$($distro.group)'s members are `n $($distro.Members)"
        $try = Read-Host "Do you want to remove the members? (y/n/exit)"
        
        switch ($try.ToLower()) {
            'y' { 
                if ($null -eq $distro.Members) {
                    Write-Warning "Group '$($distro.group)' has no members"
                    [void]$Emptygroups.Add([PSCustomObject]@{
                        Group = $distro.group
                        Members = $null
                        DateChecked = Get-Date
                    })
                }
                else {
                    Write-Host "Current members: $($distro.Members)" -ForegroundColor Cyan
                    Write-Host "Members will be removed and logged to CSV" -ForegroundColor Yellow
                    
                    [void]$Groupsremoved.Add([PSCustomObject]@{
                        Group = $distro.group
                        Members = $distro.Members
                        DateChanged = Get-Date
                    })
                    try {
                     $($distro.Members) | % { Remove-DistributionGroupMember -identity $distro.group -member $_ }
                    }
                    catch {
                        $($distro.Members) | % { Remove-DistributionGroupMember -identity $distro.group -member $_ -BypassSecurityGroupManagerCheck}
                    }
                    
                }
                break
            }
            'n' {
                Write-Host "Skipping group '$($distro.group)'" -ForegroundColor Gray
                break
            }
            'exit' { 
                Write-Host "Exiting script..." -ForegroundColor Yellow
                return 
            }
            default { 
                Write-Host "Invalid choice. Please enter 'y', 'n', or 'exit'" -ForegroundColor Red
            }
        }
    } while ($try -notin $validResponses)
}

#in case no groups are removed
if ($Emptygroups.Count -gt 0) {
    $Emptygroups | Export-Csv -Path "EmptyGroups_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
}
if ($Groupsremoved.Count -gt 0) {
    $Groupsremoved | Export-Csv -Path "RemovedMembers_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
}