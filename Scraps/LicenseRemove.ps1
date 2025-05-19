$e1= import-csv -Path $env:OneDrive\E1ToRemove.csv
$TeamsGroup= Get-MgBetaGroup -filter "DisplayName eq 'ALL_M365_Licenses_TeamsEssentials'" | select -expandProperty Id
$alreadyin= [System.Collections.ArrayList]::new()
$userobj= $e1 | % { Get-mgBetauser -userid $_.Column1 | select UserPrincipalName, Id, JobTitle,SignInActivity  }
$e1SKu= "e364bdc9-5d68-46fc-bc83-70952e13c2db_18181a46-0d4e-45cd-891e-60aabd171b4e"

forEach ($user in $userobj) {

   try {
        $params=@{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/{$($user.Id)}"}
       New-MgBetaGroupMemberByRef -GroupId $TeamsGroup -BodyParameter $params -ErrorAction stop
       Get-MgBetaUserLicenseDetail -UserId $user.Id | Tee-Object -Variable license
    $standard=($license.SkuPartNumber -contains "STANDARDPACK") ? $true : $false
       if ($standard) {
               " user $($user.UserPrincipalName) el included"
               write-host "STANDARD"
          $license | Where-Object { $_.SkuPartNumber -eq "STANDARDPACK"} | Select SkuId | Tee-Object -variable $E1Sku

          "removing license for user $($user.UserPrincipalName)"
          set-mgbetauserlicense -userid $user.Id -RemoveLicenses @($E1guid) -AddLicenses @{}

       }
       else {
          " user $($user.UserPrincipalName) $($license | select * )" 
       }

       
        # Set-MgBetaUserLicense -UserId $user -AddLicenses @() -RemoveLicenses @{SkuId=$(e364bdc9-5d68-46fc-bc83-70952e13c2db_18181a46-0d4e-45cd-891e-60aabd171b4e)}
     
    }
   catch {
    $alreadyin.Add($user)
     }
}

#if forgot to add organization.ReadAll, convert the string to a guid obj using new-guid  

$teams= import-csv -path $env:userprofile\downloads\TeamsEssentials.csv
$alreadyin= [System.Collections.ArrayList]::new()
$teamsUsers= $teams | % { 
     $exoplan= $license.ServicePlans | Where ServicePlanName -eq  Exchange_S_DESKLESS 
$license= Get-MgBetaUserLicenseDetail -UserId $_."UserPrincipalName"
 [PSCustomObject]@{
     Name = $_s."User PrincipalName"
     License= $license.SkuPartNumber
     LicenseSkuId= $license.SkuId
     DirAssigned= ($exoplan.ProvisioningStatus -eq "Disabled") ? "No" : "Yes"

 }




}

$teams= import-csv -path $env:userprofile\downloads\TeamsEssentials.csv
$alreadyin= [System.Collections.ArrayList]::new()
$TeamsGroup= Get-MgBetaGroup -filter "DisplayName eq 'ALL_M365_Licenses_TeamsEssentials'" | select -expandProperty Id
$usersattempted= [System.Collections.ArrayList]::new()

$teams | % {

     $license= Get-MgBetaUserLicenseDetail -UserId $_."User Principal Name"
     $teamsstring=$license | Where-Object { $_.SkuPartNumber -eq "TEAMS_ESSENTIALS_AAD"} | Select -expandProperty SkuId 
     $teamsguid= New-GUID -inputObject "$teamsstring"
     $exoplan= $license.ServicePlans | Where ServicePlanName -eq  Exchange_S_DESKLESS 

     if ($exoplan.ProvisioningStatus -ne "Disabled") {
          "user $($_.'User principal name') might be wrong"
          $usersattempted.Add($_.'User principal name')

          Remove-MgBetaGroupMemberByRef -GroupId $TeamsGroup -DirectoryObjectId $_.'Object Id'
          set-mgbetauserlicense -userid $_."Object Id" -RemoveLicenses @($teamsguid) -AddLicenses @{}
          $params=@{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/{$($_.'Object id')}"}
          New-MgBetaGroupMemberByRef -GroupId $TeamsGroup -BodyParameter $params
          


      <#   try { 
          $params=@{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/{$($_.'Object id')}"}
          New-MgBetaGroupMemberByRef -GroupId $TeamsGroup -BodyParameter $params -ErrorAction stop

          "removing explicit license for user $($user.UserPrincipalName)"
        
          set-mgbetauserlicense -userid $user.Id -RemoveLicenses @($teamsguid) -AddLicenses @{}


     }
     catch {
          "already in group"
     } #>
     }
     else {
    "user $($_.'User Principal Name') is all set"

     }
}


$username="yoohooo@1x4bs0.onmicrosoft.com"
$password=""