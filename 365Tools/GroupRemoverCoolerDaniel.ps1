
 #I want to try that new stuff I just learned about

Class ExoGroupInfo {
    [psobject]$GroupName
    [System.Collections.Generic.List[string]]$Members
    [hashtable]$GroupProperties 
    
    

 ExoGroupinfo([psobject[]]$groupname) {
   $this.Groupname= $groupname #binds method arg to property(parameter)
   $this.Members=[System.Collections.Generic.List[string]]::new()
   $this.GroupProperties= @{}
   
   
   foreach ($group in $groupname) {
  
   try {
     
    $groupData= Get-DistributionGroup -Identity $group | Select-Object * -ErrorAction Stop
     

     $this.GroupProperties[$group] = @{  
        DisplayName = $groupData.DisplayName
        PrimarySmtpAddress = $groupData.PrimarySmtpAddress
        RequireSenderAuthenticationEnabled = $groupData.RequireSenderAuthenticationEnabled
        ManagedBy = $groupData.ManagedBy
        Members = $this.GetGroupMembers($group)

      }
      
    }
   catch {
      write-error "$_"
   }
}
$result= $this.GroupProperties
  
  }
  [string[]]GetGroupMembers([string]$groupname) {
    
    $this.GroupName= $groupname


    try{  
    
    $memberlist= Get-DistributionGroupMember -Identity $groupname | Select -ExpandProperty PrimarySMTPaddress
    return $memberlist

}
catch {
    write-error "$_"
    return $null
}
       
 }
 
 
 }


 



<#instantiate group obj
 $Test=[ExoGroupInfo]::new("test")
access properties
$Test.GroupProperties["Test"]

 #>