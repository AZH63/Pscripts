
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
       
   
    
   Function Convert-GraphAttachment {
   
   param (
       [parameter(Mandatory)]
       [string]$path
   )
   $files= Get-ChildItem $path -file -recurse # file switch = -attributes !Directory
   
   $files | % {
    $file=($_.FullName).ToString() #was getting null charas errors otherwise
    $byteArray=[system.IO.file]::ReadAllBytes($file)
   $base64=[System.Convert]::ToBase64String($byteArray)
   
   @{
   
       "@odata.type"= "#microsoft.graph.fileAttachment"
                   name = ($_.FullName -split '\\')[-1]
                   contentBytes = $base64
   
   }
   
   }
   
   
   }
   
   
   Function Convert-Graphmail {
     param (
       [array[]]$email
   
     )
   
   $email | % {
   
       @{emailAddress= @{address=$_}}
   }
   
   
   }

Function Flood-inboxes {
$users= Get-MgUser | select -ExpandProperty UserPrincipalName
$upns= $users | Where { $_ -notlike "*EXT*" -and $_ -notlike "*_*" }
  $names | % {
        $name= $_
        1..5 | % {

    Send-Mail -sendAdd "yoohooo@1x4bs0.onmicrosoft.com" -recipients $name -subject "testmail $_"
        }
   }
  }

  Function Generate-Inbox {
    param (
      [string[]]$recipients,
      [string]$sendAdd,
      [int]$counter
    )
     
    1..$counter | % { Send-Mail -sendAdd $sendAdd -recipients $recipients }
  
    }
  
  
    # .3 mb every 10,000 w.o attachments lol
    # this is a nice trick to actually fill the senders mb with undeliverables from message limits, so task still accomplished?
    # exo recipient limit - 2k in 24 hrs
    # RX limit is 3600 from 1 sender is 1800?
    # # handy info: https://learn.microsoft.com/en-us/office365/servicedescriptions/exchange-online-service-description/exchange-online-limits

    @{RecipientFilter=((((((RecipientTypeDetails -eq 'UserMailbox') -and (Office -eq 'New York'))) -and (-not(CustomAttribute1 -eq 'Disabled')))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))}