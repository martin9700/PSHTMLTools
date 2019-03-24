#Set up
$ScriptPath = $PSScriptRoot

$Header = @(
    "<style>"
    "TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
    "TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}"
    "TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}"
    ".odd  { background-color:#ffffff; }"
    ".even { background-color:#dddddd; }"
    "</style>"
) | Out-String

$StartHTML = @"
Server,Column1,Column2,Column3,Column4
Server1,1,2,3,4
Server1,1,1,2,4
Server2,1,1,1,1
Server2,test,one,two,three
Server3,test,four,five,six
"@ | ConvertFrom-Csv | ConvertTo-Html -Head $Header

Import-Module Pester

#Used for Appveyor
$ModulePath = Join-Path (Split-Path -Path $ScriptPath) -ChildPath PSHTMLTools
Import-Module $ModulePath


#Used for local testing
#$FunctionPath = Join-Path -Path (Split-Path -Path $ScriptPath) -ChildPath "Source\Public"
#. $FunctionPath\Set-PSHGroupRowColorsByColumn.ps1   



Describe "Set-PSHGroupRowColorsByColumn testing" {
    It "Test group coloring by pipeline" {
        $Test = $StartHTML | Set-PSHGroupRowColorsByColumn -ColumnName Server -CSSEvenClass even -CSSOddClass odd | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<style>"
            "TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
            "TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}"
            "TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}"
            ".odd  { background-color:#ffffff; }"
            ".even { background-color:#dddddd; }"
            "</style>"
            ""
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/><col/><col/></colgroup>"
            "<tr><th>Server</th><th>Column1</th><th>Column2</th><th>Column3</th><th>Column4</th></tr>"
            "<tr class=""even""><td>Server1</td><td>1</td><td>2</td><td>3</td><td>4</td></tr>"
            "<tr class=""even""><td>Server1</td><td>1</td><td>1</td><td>2</td><td>4</td></tr>"
            "<tr class=""odd""><td>Server2</td><td>1</td><td>1</td><td>1</td><td>1</td></tr>"
            "<tr class=""odd""><td>Server2</td><td>test</td><td>one</td><td>two</td><td>three</td></tr>"
            "<tr class=""even""><td>Server3</td><td>test</td><td>four</td><td>five</td><td>six</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String
        $Test | Should Be $Result
    }

    It "Test group coloring by parameter" {
        $Test = Set-PSHGroupRowColorsByColumn -InputObject $StartHTML -ColumnName Server -CSSEvenClass even -CSSOddClass odd | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<style>"
            "TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
            "TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}"
            "TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}"
            ".odd  { background-color:#ffffff; }"
            ".even { background-color:#dddddd; }"
            "</style>"
            ""
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/><col/><col/></colgroup>"
            "<tr><th>Server</th><th>Column1</th><th>Column2</th><th>Column3</th><th>Column4</th></tr>"
            "<tr class=""even""><td>Server1</td><td>1</td><td>2</td><td>3</td><td>4</td></tr>"
            "<tr class=""even""><td>Server1</td><td>1</td><td>1</td><td>2</td><td>4</td></tr>"
            "<tr class=""odd""><td>Server2</td><td>1</td><td>1</td><td>1</td><td>1</td></tr>"
            "<tr class=""odd""><td>Server2</td><td>test</td><td>one</td><td>two</td><td>three</td></tr>"
            "<tr class=""even""><td>Server3</td><td>test</td><td>four</td><td>five</td><td>six</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String
        $Test | Should Be $Result
    }

    It "Bad column name" {
        { $StartHTML | Set-PSHGroupRowColorsByColumn -ColumnName nothingburger -CSSEvenClass even -CSSOddClass odd } | Should Throw
    }
}