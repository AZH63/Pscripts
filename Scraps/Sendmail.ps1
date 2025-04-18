
Function Send-Mail {

    param (
     [parameter(mandatory)] 
     [string]$sendAdd,
     [parameter(mandatory)]
     [string[]]$recipients,
     [object]$text,
     $type="HTML",
     [string]$subject,
    [bool] $save=$true,
    [switch]$attachments
   
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
        $files= Convert-GraphAttachment -folder $folder
        if ($files.Count -gt 0) {
   
           $mailbody['message']['attachments']= $files #adds attachments to message subtable
           
       }
   
   
   }
   Send-MgUserMail -UserId $sendAdd -BodyParameter $mailbody
    }
       
   
    
   Function Convert-GraphAttachment {
   
   param (
       [parameter(Mandatory)]
       [string]$folder
   )
   $files= Get-ChildItem $folder -file -recurse # file switch = -attributes !Directory
   
   $files | % {
   $encodedfile= [convert]::ToBase64String((Get-Content $_.FullName -Encoding byte))
   @{
   
       "@odata.type"= "#microsoft.graph.fileAttachment"
                   name = ($_.FullName -split '\\')[-1]
                   contentBytes = $encodedfile
   
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