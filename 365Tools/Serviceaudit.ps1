$firstpass=[System.Collections.ArrayList]::new()
$jameslist.email | % { 

$mbstats= Get-mailboxstatistics -identity $_
$entrainfo= Get-Mgbetauser -userid $_
$mbinfo= Get-mailbox -identity $_
$firstpass.Add([PSCustomObject]@{
    email = $_                       
    RecipientType= $mbinfo.RecipientTypeDetails
    ForwardingStatus= (($mbinfo.ForwardingSMtpAddress -or $mbinfo.ForwardingAddress) -eq "$null" ) ? "none" : "$($mbinfo.ForwardingSmtpAddress), $($mbinfo.forwardingAddress)"
    JobTitle= $entrainfo.JobTitle
    EmployeeType= $entrainfo.EmployeeType
    "storage used"=[math]::Round(($mbstats.TotalItemSize.ToString().Split('(')[1].Split(' ')[0].Replace(',','')/1MB),2)
    "Storage cap"= $mbstats.ProhibitSendQuota
    LicenseAssigned= $([string] ((Get-MgBetaUserLicenseDetail -userid $_).SkuPartNumber) -join (','))
    Litigationholdenable= $mbinfo.Litigationholdenabled
    Retentionpolicy= $mbinfo.Retentionpolicy

    
})


}
$firstpass | export-csv -path $env:UserProfile\downloads\Serviceacctaudit.csv
start $env:UserProfile\downloads\Serviceacctaudit.csv