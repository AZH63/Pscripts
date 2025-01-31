
 I want to try that new stuff I just learned about

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
        Members = $this.GetGroupMembers($this.GroupName)

      }
      
    }
   catch {
      write-error "$_"
   }
}
$result= $this.GroupProperties
  
  }
  [void] GetGroupMembers([string]$groupname) {
    
    $this.GroupName= $groupname


    try{  
    
     Get-DistributionGroupMember -Identity $this.GroupName | Select -ExpandProperty PrimarySMTPaddress
     
    ForEach ($mem in $this.members) {
         $this.Members.Add($mem)
    }
    write-output "got $($this.Members)"
}
catch {
    write-error "$_"
}
       
 }
 
 
 }






