$Mbs=Get-Mailbox -InactiveMailboxOnly -ResultSize Unlimited | Select  DisplayName,PrimarySMTPAddress,WhenSoftDeleted, WhenChanged, SKUAssigned, RetentionPolicy,LitigationHoldEnabled,IsMailboxEnabled
$Mbs | export-csv -path $env:UserProfile\Downloads\InactiveMbs.Csv -notypeinformation
$Users= $Mbs.PrimarySMTPAddress

$Users | % { Get-AzureADUser -ObjectId $_ | Select UserPrincipalName, AccountEnabled}
 $Users | % {


    Get-Mailbox -identity $_ | Select DisplayName, LitigationHoldEnabled
 }
