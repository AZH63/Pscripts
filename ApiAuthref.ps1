ApiAuthref.Ps1


$Cred=Get-Credential

$databaseid= "3a561597986949198c2ee2a4c18f29e6"
$uri="https://api.notion.com/v1/databases/$databaseid"

$headers= @{

Authorization= 'Basic'


}


Invoke-RestMethod -uri $uri $header -Credential $Cred
#Bearer auth
$token= "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"
$databaseId= "3a561597986949198c2ee2a4c18f29e6"
$uri="https://api.notion.com/v1/databases/$databaseid"
$headers=@{
'Authorization'= "Bearer $token"
'Content-Type'='application/json'
'Notion-Version'= '2022-06-28'

}
$result=Invoke-RestMethod -Uri $uri -Headers $headers
$result | ConvertTo-Json
#Api token
$parameters=@{

    Method= 'PUT'
    Uri= 'https://api.notion.com/v1/databases/$databaseid'
   Headers= @ {

    "X-ApiKeys" = "accessKey=$($accessKey); secretKey=$($secretKey)"
   }
   ContentType= 'application/json'

}
Invoke-RestMethod @parameters


# other method:



$token="$env:ZDKey"

$uri= "https://d3v-newcomp.zendesk.com/api/lotus/assignables/autocomplete.json"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Basic hazariaaorton@gmail.com/token:$token")
$response = Invoke-RestMethod $uri -Headers $headers 
$response | ConvertTo-Json





$token="$env:ZDKey"

$user= 'hazariaaorton@gmail.com'
$pass= $env:ZDPass

$pair= "$User




$Cred=Get-Credential

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Basic $Cred")

$response = Invoke-RestMethod 'https://example.zendesk.com/api/lotus/assignables/autocomplete.json?name=<string>' -Method 'GET' -Headers $headers
$response | ConvertTo-Json