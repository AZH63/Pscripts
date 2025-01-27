OffBoardScript.ps1



do {
    $Mail= Read-Host "Enter the UPN"
    $UPN= $Mail.Trim()
$path= read-host "pick a choice 1. disable, reset pw and revoke sessions 2. remove mail enabled groups"
switch ($path) {
  1 { 
    
    DisableAzUser -UPN $
  }
  2 {}
  3 {} 
}


}
while ( $choice -ne 4)