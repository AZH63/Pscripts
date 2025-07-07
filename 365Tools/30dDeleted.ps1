
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
       
Function Get-DeletedLast {
  [CmdletBinding()]
  
param(
  [parameter(mandatory=$true)]
    [int]$number
  )
  write-verbose "days chosen= $($PSBoundParameters['number'])"
$audit= [System.Collections.ArrayList]::new()
$updates= Get-MgBetaAuditLogDirectoryAudit -All -filter "ActivityDisplayName eq 'Update user' "  
 # $termedactions= $updates | Where { ($_.InitiatedBy.App.DisplayName -eq "AzureAD") -and ($_.TargetResources.ModifiedProperties.NewValue -like "*Terminated*") }
#$appChanges[1].TargetResources.ModifiedProperties
 $termedactions= $updates | Where { ($_.TargetResources.ModifiedProperties.NewValue -like "*Terminated*") }

$dayselapsed=$termedactions | Where { $_.ActivityDateTime -lt (Get-Date).AddDays(-($($PSBoundParameters['number'])))}

$affected= $dayselapsed.TargetResources

$affected.UserPrincipalName


}



Get-DeletedLast -number 10 | tee-object -variable termed10d
$fatherlessusers= [System.Collections.ArrayList]::new()
$termed10d | % {
 $user=Get-MgBetaUser -userid $_ 

 If ($user.EmployeeType -like "*Salary*") {
  try {
  $manager=get-mgbetausermanager -userid $($user.UserPrincipalName)  -ErrorAction stop
  write-verbose "sending message to $($manager.AdditionalProperties.userPrincipalName) "
Send-mail -text "Hello, this person $($user.UserPrincipalName) will be deleted" -subject "Losing access to shared mailbox" -sendAdd $((Get-MgContext).Account) -recipients $($manager.AdditionalProperties.userPrincipalName)

 }
 catch {
write-warning "no manager adding to list"
$fatherlessusers.Add($($user.UserPrincipalName) )
 }
}
 else {

    Write-Host "$($user.UserPrincipalName) to be deleted"

 }

}







1..6 | % { $all | get-random } | tee-object -variable names
$types=@("Terminated Salary Administrative","Terminated Salary Warehouse","Terminated Hourly Administrative", "Terminated Hourly Warehouse" )
$names | % { $params=@{AccountEnabled=$false;EmployeeType=$($types | Get-random)}
Update-MgBetaUser -userid $($_.UserPrincipalName) -bodyparam $params } 