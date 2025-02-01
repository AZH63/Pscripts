
$Global:GitToken= $env:GitToken
$Global:BaseUri= "https://api.github.com"
$Global:headers=  @{
    
    'Authorization'= "Bearer $GitToken"
     'accept'= "application/vnd.github.text+json"
         'X-GitHub-Api-Version'= "2022-11-28"
        'ContentType'= "application/json"}


Function Connect-Github {

    $uri= "https://api.github.com/octocat" 

    Invoke-RestMethod -Uri $uri -headers $headers
}
 
Function Get-Issues {
    [parameter(Mandatory=$true)]
    [string]$body,
    [string]$owner="hootiehooo"
    [int]$maxPages="100"

    $uri= "$BaseUri/repos/$owner/$repo/issues?per_page=$maxPages&sort=created&direction=desc"
$Call = Invoke-RestMethod -Headers $headers -Uri "$uri" -Method Get 
return ( $Call | Select-Object Title, Body_Text, Created_at, Updated_at, State,assignee,Id) 


}







Function Create-Issue {
    param (
        [parameter(Mandatory=$true)]
        [string]$title,
        [parameter(Mandatory=$true)]
        [string]$body,
        [string]$owner="hootiehoooo",
        [string]$repo="PScripts",
        [ValidateSet("ToDo", "Priority", "enhancement","help wanted", "question", IgnoreCase = $true)]
        [string[]]$label
    )
    $issuebody=@{
        "title"= $title;
        "body"= $body;
        "labels"= $label
    
    
    }

$JsonBody= $issuebody | ConvertTo-Json -Depth 2
 Invoke-WebRequest -Headers $headers -uri "$($BaseUri)/repos/$($owner)/$($repo)/issues" -Method 'Post' -Body $JsonBody 

}

Function Edit-Issue {
    param (
        [string]$title,
        [string]$body,
        [string]$owner="hootiehoooo",
        [parameter(Mandatory=$true)]
        [integer]$Issueno,
        [integer]$repo="PSCripts"

    )
    
  
    $GET=Invoke-WebRequest -Headers $headers -uri "$(BaseUri)/repos/$($owner)/$repo\$Issueno"
    
    $issuebody=@{
        "title"= $title;
        "body"= $body;
        "labels"= $label
        "state_reason"=$statereason
    }


} 












































<# index matching unnecessary but save for later
$results= for ($i=0;$i -lt $Call.Status.Count; $i++) {
    [PSCustomObject]@{
        Title = $Call.title[$i]
        Body = $Call.body_text[$i]
        Created_at = $Call.Created_at[$i]
        Updated_at = $Call.Updated_at[$i]
        State = $Call.State[$i]
    }
} 
return $results
} #>




