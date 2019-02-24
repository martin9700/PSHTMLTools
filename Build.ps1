[CmdletBinding()]
Param()

# Grab nuget bits, install modules, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

#Now PSGallery
Import-Module PowerShellGet -ErrorAction Stop
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Pester,PSScriptAnalyzer,PSModuleBuild




#Build the module
$ModuleInformation = @{
    Path            = "$ENV:APPVEYOR_BUILD_FOLDER\Source"
    TargetPath      = "$ENV:APPVEYOR_BUILD_FOLDER\PSHTMLTools"
    ModuleName      = "PSHTMLTools"
    ReleaseNotes    = (git log -1 --pretty=%s) | Out-String
    Author          = "Martin Pugh (@TheSurlyAdm1n)"
    ModuleVersion   = $ENV:APPVEYOR_BUILD_VERSION
    Company         = "www.thesurlyadmin.com"
    Description     = "Simple functions to make your HTML from ConvertTo-HTML look a lot better"
    ProjectURI      = "https://github.com/martin9700/PSHTMLTools"
    LicenseURI      = "https://github.com/martin9700/PSHTMLTools/blob/master/LICENSE"
    #IconURI         = "https://pughspace.files.wordpress.com/2017/01/pspublishmodule-icon.png"
    PassThru        = $true
}
Invoke-PSModuleBuild @ModuleInformation




#Analyze the script
Write-Verbose "$(Get-Date): Analyzing script..." -Verbose
$Results = Invoke-ScriptAnalyzer -Path "$ENV:APPVEYOR_BUILD_FOLDER\PSHTMLTools" -Severity "Warning" -Recurse
$Results | Format-Table

$Errors = $Results | Where-Object Severity -eq "Error"
If ($Errors)
{
    Write-Error "$(Get-Date): One or more Script Analyzer errors/warnings where found. Build cannot continue!" -ErrorAction Stop
}

Write-Verbose "$(Get-Date): Script passed"



#Run tests
$TestResults = Invoke-Pester -PassThru -OutputFormat NUnitXml -OutputFile ".\TestResults.xml"
(New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",(Resolve-Path ".\TestResults.xml"))
    
If ($TestResults.FailedCount -gt 0)
{
    $TestResults | Format-List *
    Write-Error "$(Get-Date): Failed '$($TestResults.FailedCount)' tests, build failed" -ErrorAction Stop
}



#Publish module
If ($ENV:APPVEYOR_FORCED_BUILD -eq "True")
{
    $PublishInformation = @{
        Path            = "$ENV:APPVEYOR_BUILD_FOLDER\PSHTMLTools"
        Force           = $true
        NuGetApiKey     = $ENV:PSGalleryAPIKey
    }

    Try {
        Write-Verbose "$(Get-Date):" -Verbose
        Write-Verbose "$(Get-Date): Publishing to Microsoft" -Verbose
        Publish-Module @PublishInformation -ErrorAction Stop -Verbose
        Write-Host "`n`nPublish to PSGallery successful" -ForegroundColor Green
    }
    Catch {
        Write-Error "Publish to PSGallery failed because ""$_""" -ErrorAction Stop
    }
}