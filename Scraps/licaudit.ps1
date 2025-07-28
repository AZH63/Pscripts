
#Get groupmembers and display jobtitles store in object
# separate team leads and supes from the object , those in the object- remove from group and reassign.
# for the remainders just remove their mailenableds and store that in another obj then export


function Get-GroupmemberMg {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
       [string] $groupname
       
    )
    <#| Where-Object  { $_.AdditionalProperties."@odata.type" -eq "#microsoft.graph.user"}#> 
    
        $groupresult= ($groupname -like "*@*") ? (Get-MgBetaGroup -filter "Mail eq '$groupname'" | select -ExpandProperty id): (Get-MgbetaGroup -filter "displayname eq '$groupname'" | select -ExpandProperty id)

         if ($null -eq $groupresult ) {
            Write-Warning "result not found check groupname"
            break
         }
    
   

    write-verbose "group fed:$groupname, result found:$groupresult"

  
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
        [CmdletBinding(DefaultParameterSetName= 'Default')]
    [parameter(Mandatory=$true)]
      $term1,
      $term2,
      $term3,
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

        $_.$property -like "*$term1*" -or ($term2 -and $_.$property -like "*$term2*") -or ($term3 -and $_.$property -like "*$term3*")
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











 
$bostonisr=@("PDivas@baldorfood.com",
"WAndrade@baldorfood.com",
"JThibeau@baldorfood.com",
"MMartinez@baldorfood.com",
"JaPerez@baldorfood.com",
"RAndrade@baldorfood.com",
"MCora@baldorfood.com")

