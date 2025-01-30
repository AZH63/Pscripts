
 I want to try that new stuff I just learned about

Class ExoGroupInfo {
    [string]$GroupName
    [System.Collections.Generic.List[string]]$Members
    [hashtable]$GroupProperties 


 ExoGroupinfo([string[]]$groupname) {
   $this.Groupname= $groupname #binds method arg to property(parameter)
   $this.Members=@()
    foreach ($group in $groupname) {
   try {
     $groupData= Get-DistributionGroup -Identity $group | Select-Object * -ErrorAction Stop
     $this.GroupProperties = @{
        DisplayName = $groupData.DisplayName
        PrimarySmtpAddress = $groupData.PrimarySmtpAddress
        RequireSenderAuthenticationEnabled = $groupData.RequireSenderAuthenticationEnabled
        ManagedBy = $groupData.ManagedBy
        Members = $this.GetGroupMembers($this.GroupName)

      }
      $this.GroupProperties
    }
   catch {
      write-error "$_"
   }
}
  
  }
  [void] GetGroupMembers([string]$mail) {
    try{  
    $this.members= Get-DistributionGroupMember -Identity $mail | Select -ExpandProperty PrimarySMTPaddress
     
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






