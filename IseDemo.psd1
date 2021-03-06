@{
    RootModule            = 'IseDemo.psm1'
    ModuleVersion         = '1.0'
    GUID                  = 'fb935a2c-4896-4f14-a6d0-6086296debdb'
    Author                = 'Dave Wyatt'
    CompanyName           = 'Home'
    Copyright             = '(c) 2015 Dave Wyatt. All rights reserved.'
    PowerShellVersion     = '3.0'
    PowerShellHostName    = 'Windows PowerShell ISE Host'
    PowerShellHostVersion = '3.0'
    FunctionsToExport     = 'Start-IseDemo', 'Invoke-NextIseDemo', 'Invoke-PreviousIseDemo'
    AliasesToExport       = 'sid', 'nid', 'pid'

    PrivateData = @{
        PSData = @{
            # Tags = @()
            LicenseUri = 'https://www.apache.org/licenses/LICENSE-2.0.html'
            ProjectUri = 'https://github.com/dlwyatt/IseDemo'
            # IconUri = ''
            # ReleaseNotes = ''
        }
    }
}

