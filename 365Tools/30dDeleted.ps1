DeletedUsers 
Function Send-Mail {

    param (
     [parameter(mandatory)] 
     [string]$sendAdd,
     [parameter(mandatory)]
     [string]$recipients,
     [object]$text,
     $type="HTML",
     [string]$subject,
    [bool] $save=$true,
    [switch]$attachments,
    [string]$path
    
    
   
   )
    Try {
       Connect-MgGraph -Scopes 'Mail.Send', 'Mail.Send.Shared' -ea stop
    }
    catch {
      write-warning "nop"
   
    }
    
    #initialize main hash
    $mailbody= @{
        message=@{
     subject= $subject
     body=@{
       contentType= $type
       content=$text
      
   
     }
     toRecipients= @( #array of recipients with their addresses as nested hashtables cause graph
     $recipients| % { @{
           emailAddress= @{
               address= $_
           }
     
     }
   }
     )
    
   
   
        }
        saveToSentItems= $save
    }
    
    if ($attachments) {
      write-verbose "converting to a graph attachment"
        $files= Convert-GraphAttachment -path $path
        if ($files.Count -gt 0) {
   write-verbose "mailbody param looks like this: $mailbody"
           $mailbody['message']['attachments']= $files #adds attachments to message subtable
           
       }
   
   
   }
   Send-MgUserMail -UserId $sendAdd -BodyParameter $mailbody
    }
       


$audit= [System.Collections.ArrayList]::new()
Get-MgBetaAuditLogDirectoryAudit -All -filter "ActivityDisplayName eq 'Update user' "  | tee-object -variable updates
 # $termedactions= $updates | Where { ($_.InitiatedBy.App.DisplayName -eq "AzureAD") -and ($_.TargetResources.ModifiedProperties.NewValue -like "*Terminated*") }
#$appChanges[1].TargetResources.ModifiedProperties
 $termedactions= $updates | Where { ($_.TargetResources.ModifiedProperties.NewValue -like "*Terminated*") }

$30dayselapsed= $termedactions | Where { $termedactions.ActivityDateTime -lt (Get-Date).AddDays(-30) }

$affected= $30dayselapsed.TargetResources.UserPrincipalName
$30dayselapsed | % {
    #check SharedMb
     Get-Mailbox -identity $($_.TargetResources.UserPrincipalName) | Select PrimarySMTPaddress,RecipientTypeDetails

    
}


