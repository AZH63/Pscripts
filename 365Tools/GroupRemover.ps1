$Emptygroups = [System.Collections.ArrayList]::new()
$Groupsremoved = [System.Collections.ArrayList]::new()


$Dist=Get-DistributionGroup | Select -ExpandProperty PrimarySMTPaddress
$Distros=$Dist | ForEach-Object {
   $Members= (Get-DistributionGroupMember -identity $_).PrimarySmtpAddress
  [PSCustomObject]@{
    group = $_
    Members= $Members
    MemberCount= $Members.Count
  }
}
 $Filter= $Distros | Where {$_.MemberCount -le 5 } 
     $Groups= $Filter | % { [pscustomobject]@{
        Name= $PSItem.Group
        Members= $PSItem.Members -join ','
        MemberCount= $PsItem.MemberCount
        
         } }
$Filter| export-Csv -path  $env:USERPROFILE\Downloads\GroupsLowCountUnchanged.csv -NoTypeInformation

foreach ($distro in $Filter) {
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
                    
                     write-warning "trying with -bypasssecuritygroupmanager switch"
                    write-host " attempting $($distro.group) with switch"
                  $($distro.Members) | % { Remove-DistributionGroupMember -identity $distro.group -member $_ -BypassSecurityGroupManagerCheck -Confirm:$false }
                    
                
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

<#check so that no csv generated if no changes logged #>
if ($Emptygroups.Count -gt 0) {
    $Emptygroups | Export-Csv -Path "EmptyGroups_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
}
if ($Groupsremoved.Count -gt 0) {
    $Groupsremoved | Export-Csv -Path "RemovedMembers_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
}




     
