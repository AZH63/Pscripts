OffBoardScript.ps1



while ($true) {
    $choice = Read-Host "Enter 4 to exit or any other key to continue to the main menu"
    
    
    if ($choice -eq '4') {
        Write-Host "Exiting the script..."
        break
    }

 
    $Mail = Read-Host "Enter the UPN"
    $UPN = $Mail.Trim()

    
    $path = Read-Host "Pick a choice:`n1. Disable, reset password, and revoke sessions`n2. Remove mail-enabled groups`n3. Remove security groups`n4. Exit"

  
    switch ($path) {
        1 {
            Disable-AzUser -UPN $UPN
            $AzResults = Get-AzureADUser -ObjectId $UPN | Select-Object UserPrincipalName, AccountEnabled
            Write-Output $AzResults
        }
        2 {

            Write-Host "Removing mail-enabled groups for $UPN..."
           
            Remove-MailEnabledMg -mail $UPN
        }
        3 {
            Write-Host "Removing security groups for $UPN..."
            
            Remove-SecurityGroups -UPN $UPN
        }
        4 {
            
            Write-Host "Exiting the script..."
            break
        }
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
}
