Get-Mailbox -filter "RecipientTypeDetails -eq 'SharedMailbox'" | Tee-Object -Variable SharedMbs

$SharedMbs | % {
     Get-MgBetaUser -userid $_.UserPrincipalName | select UserPrincipalName, EmployeeType, JobTitle,EmployeeId   } | Tee-Object -Variable entrainfo
     
     $params=@{AccountEnabled=$false;EmployeeType="Shared Mailbox";  }
     $entrainfo | % {  }
