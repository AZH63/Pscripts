# PScripts

Contains Modules with functions I use in the day to day, scripts I use semi frequently, code for Azure Automation projects and
works in progress.



## Getting Started

Extract the folder containing .psm1 files to any valid PowerShell module path. Use $env:PSModulePath -split ";" to view your available paths.

### Prerequisites
* Windows system with PowerShell 7 installed (for Graph SDK)
* Administrator access required for system-wide installations
* Internet connectivity for downloading modules from the PowerShell Gallery
  #### Requirements for the functions and scripts:
* ExchangeOnlineManagement vers 3.6 ( vers. 3.7 suffers from a reoccuring bug when authenticating)
* AzureAD ( *deprecated*)
* Microsoft.Graph ( basic support for 5.1 but you'll have a better time on Powershell Core)

## Azure Automation info
* Runbooks use 5.1 ( Graph scripts use simple GET/POST requests)
### Modules used:
* AzureAD (custom)
* ExchangeOnlineManagement(gallery)
* Azure Automation (gallery)
* Microsoft.Graph ( gallery)
