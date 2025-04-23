
#Get groupmembers and display jobtitles store in object
# separate team leads and supes from the object , those in the object- remove from group and reassign.
# for the remainders just remove their mailenableds and store that in another obj then export


function Get-Groupmember {

    param (
       [string] $groupname
    )
    <#| Where-Object  { $_.AdditionalProperties."@odata.type" -eq "#microsoft.graph.user"}#> 
    $group=Get-MgbetaGroup -filter "displayname eq '$groupname'" | select -ExpandProperty id
    $members=Get-MgBetaGroupMember -GroupId $group -All | ForEach-Object {
       
        [PSCustomObject]@{
            DisplayName = $_.AdditionalProperties.displayName
            UserPrincipalName = $_.AdditionalProperties.userPrincipalName
            JobTitle = $_.AdditionalProperties.jobTitle
            EmployeeType = $_.AdditionalProperties.employeeType
            Id = $_.Id
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
      [object]$object
      
    ) 
    
    
    $filterScript= {

        $_.$property -like "*$term1*" -or ($term2 -and $_.$property -like "*$term2*") 
    }
    
  $object | Where-Object -FilterScript $filterScript
      
    
    }



$group= Read-Host "groupname pls"
$groupMembers= Get-Groupmember -groupname $group

$groupMembers | search-object -property "JobTitle" -term1 "lead" -term2 "Supervisor" 








