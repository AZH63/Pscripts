@{
    RootModule        = ''
    NestedModules     = @('Test365.psm1', 'Reporting365.psm1','AzureTools.psm1')
    ModuleVersion     = '1.0.0'
    GUID              = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    Author            = 'Azaria Horton'
    Description       = 'AzureTools with Test365 and Reporting365 modules'
    FunctionsToExport = @('*')  # Export all functions or specify
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
