#Set up
$ScriptPath = $PSScriptRoot

$StartHTML = @"
Column1,column2,colum3
"test1 http://www.google.com","http://www.google.com test2","test3"
"test2:1","test2:2","test2:3"
"<a href=""http://www.google.com/bad"">Google</a>","This is a http://www.google.com/good","test3:3"
"@ | ConvertFrom-Csv | ConvertTo-Html

Import-Module Pester

#Used for Appveyor
$ModulePath = Join-Path (Split-Path -Path $ScriptPath) -ChildPath PSHTMLTools
Import-Module $ModulePath

#Used for local testing
#$FunctionPath = Join-Path -Path (Split-Path -Path $ScriptPath) -ChildPath "Source\Public"
#. $FunctionPath\Set-PSHLink.ps1

Describe "Set-PSHLink testing" {
    It "Test link creation" {
        $Test = $StartHTML | Set-PSHLink | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<title>HTML TABLE</title>"
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/></colgroup>"
            "<tr><th>Column1</th><th>column2</th><th>colum3</th></tr>"
            "<tr><td>test1 <a href=""http://www.google.com"">http://www.google.com</a></td><td><a href=""http://www.google.com"">http://www.google.com</a> test2</td><td>test3</td></tr>"
            "<tr><td>test2:1</td><td>test2:2</td><td>test2:3</td></tr>"
            "<tr><td>&lt;a href=&quot;<a href=""http://www.google.com/bad"">http://www.google.com/bad</a>&quot;&gt;Google&lt;/a&gt;</td><td>This is a <a href=""http://www.google.com/good"">http://www.google.com/good</a></td><td>test3:3</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String 
        $Test | Should Be $Result
    }

    It "Test link creation with new tab" {
        $Test = $StartHTML | Set-PSHLink -NewPage | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<title>HTML TABLE</title>"
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/></colgroup>"
            "<tr><th>Column1</th><th>column2</th><th>colum3</th></tr>"
            "<tr><td>test1 <a href=""http://www.google.com"" target=""_blank"">http://www.google.com</a></td><td><a href=""http://www.google.com"" target=""_blank"">http://www.google.com</a> test2</td><td>test3</td></tr>"
            "<tr><td>test2:1</td><td>test2:2</td><td>test2:3</td></tr>"
            "<tr><td>&lt;a href=&quot;<a href=""http://www.google.com/bad"" target=""_blank"">http://www.google.com/bad</a>&quot;&gt;Google&lt;/a&gt;</td><td>This is a <a href=""http://www.google.com/good"" target=""_blank"">http://www.google.com/good</a></td><td>test3:3</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String 
        $Test | Should Be $Result
    }
}