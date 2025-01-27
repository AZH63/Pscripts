OffBoardScript.ps1



while ($true) {
    # Display menu and get user choice
    $choice = Read-Host "Enter 4 to exit or any other key to continue to the main menu"
    
    # Exit the loop if the user chooses to exit
    if ($choice -eq '4') {
        Write-Host "Exiting the script..."
        break
    }

    # Get the User Principal Name (UPN)
    $Mail = Read-Host "Enter the UPN"
    $UPN = $Mail.Trim()

    # Display action menu
    $path = Read-Host "Pick a choice:`n1. Disable, reset password, and revoke sessions`n2. Remove mail-enabled groups`n3. Remove security groups`n4. Exit"

    # Perform action based on user choice
    switch ($path) {
        1 {
            # Disable user, reset password, and revoke sessions
            Disable-AzUser -UPN $UPN
            $AzResults = Get-AzureADUser -ObjectId $UPN | Select-Object UserPrincipalName, AccountEnabled
            Write-Output $AzResults
        }
        2 {
            # Remove mail-enabled groups
            Write-Host "Removing mail-enabled groups for $UPN..."
            # Call your function or logic here
            Remove-MailEnabledMg -mail $UPN
        }
        3 {
            # Remove security groups
            Write-Host "Removing security groups for $UPN..."
            # Call your function or logic here
            Remove-SecurityGroups -UPN $UPN
        }
        4 {
            # Exit the script
            Write-Host "Exiting the script..."
            break
        }
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
}
