
#Get groupmembers and display jobtitles store in object
# separate team leads and supes from the object , those in the object- remove from group and reassign.
# for the remainders just remove their mailenableds and store that in another obj then export


function Get-Groupmember {

    param (
       [string] $groupname
    )
    <#| Where-Object  { $_.AdditionalProperties."@odata.type" -eq "#microsoft.graph.user"}#> 
    $groupresult=Get-MgbetaGroup -filter "displayname eq '$groupname'" | select -ExpandProperty id
    $members=Get-MgBetaGroupMember -GroupId $groupresult -All | ForEach-Object {
       
        [PSCustomObject]@{
            DisplayName = $_.AdditionalProperties.displayName
            UserPrincipalName = $_.AdditionalProperties.userPrincipalName
            JobTitle = $_.AdditionalProperties.jobTitle
            EmployeeType = $_.AdditionalProperties.employeeType
            Id = $_.Id
            groupid= $groupresult
            groupName=$groupname

        }
    }
   $members
}


function search-object {
    <#
    .DESCRIPTION
    filters based on property and searchterms

    #>
    param (
    [parameter(Mandatory=$true)]
      $term1,
      $term2,
      [parameter(Mandatory=$true)]
      [validateset("JobTitle","department","name")]
      [string] $property,
      [parameter(Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
      [object]$inputobject
      
    ) 
    
    begin {
$results= [System.Collections.ArrayList]::new()
    }
    process {
    $filterScript= {

        $_.$property -like "*$term1*" -or ($term2 -and $_.$property -like "*$term2*") 
    }

  $results.Add($($inputobject | Where-Object -FilterScript $filterScript)) | Out-Null
      
}
end {
$results
}
    }



$group= Read-Host "groupname pls"
$groupMembers= Get-Groupmember -groupname $group

$exceptions= $groupMembers | search-object -property "JobTitle" -term1 "lead" -term2 "Supervisor" 
export-csv -path $env:USERPROFILE\downloads\exceptions.csv
$exceptions | % {
 Remove-MgBetaGroupMemberByRef -GroupId $($groupMembers[0].groupid) -DirectoryObjectId $_.Id -WhatIf

} 








