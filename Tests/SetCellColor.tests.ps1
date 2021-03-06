﻿#Set up
$ScriptPath = $PSScriptRoot

$StartHTML = @"
Server,Column1,Column2,Column3,Column4
Server1,1,2,3,4
Server2,1,1,2,4
Server3,1,1,1,1
Server4,test,one,two,three
Server5.test,4,4,4,4
.[?]\,4,3,2,1
"@ | ConvertFrom-Csv | ConvertTo-Html

Import-Module Pester

#Used for Appveyor
$ModulePath = Join-Path (Split-Path -Path $ScriptPath) -ChildPath PSHTMLTools
Import-Module $ModulePath


#Used for local testing
#$FunctionPath = Join-Path -Path (Split-Path -Path $ScriptPath) -ChildPath "Source\Public"
#. $FunctionPath\Set-GroupRowColorsByColumn.ps1
#. $FunctionPath\Set-PSHCellColor.ps1

Describe "Set-PSHCellColor testing" {
    It "Set a single cell to red" {
        $Test = $StartHTML | Set-PSHCellColor -Color Red -Filter "Column3 -eq 3" | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<title>HTML TABLE</title>"
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/><col/><col/></colgroup>"
            "<tr><th>Server</th><th>Column1</th><th>Column2</th><th>Column3</th><th>Column4</th></tr>"
            "<tr><td>Server1</td><td>1</td><td>2</td><td style=""background-color:Red"">3</td><td>4</td></tr>"
            "<tr><td>Server2</td><td>1</td><td>1</td><td>2</td><td>4</td></tr>"
            "<tr><td>Server3</td><td>1</td><td>1</td><td>1</td><td>1</td></tr>"
            "<tr><td>Server4</td><td>test</td><td>one</td><td>two</td><td>three</td></tr>"
            "<tr><td>Server5.test</td><td>4</td><td>4</td><td>4</td><td>4</td></tr>"
            "<tr><td>.[?]\</td><td>4</td><td>3</td><td>2</td><td>1</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String        
        $Test | Should Be $Result
    }

    It "Set multiple cells to red" {
        $Test = $StartHTML | Set-PSHCellColor -Color Red -Filter "Column1 -eq 1" | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<title>HTML TABLE</title>"
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/><col/><col/></colgroup>"
            "<tr><th>Server</th><th>Column1</th><th>Column2</th><th>Column3</th><th>Column4</th></tr>"
            "<tr><td>Server1</td><td style=""background-color:Red"">1</td><td>2</td><td>3</td><td>4</td></tr>"
            "<tr><td>Server2</td><td style=""background-color:Red"">1</td><td>1</td><td>2</td><td>4</td></tr>"
            "<tr><td>Server3</td><td style=""background-color:Red"">1</td><td>1</td><td>1</td><td>1</td></tr>"
            "<tr><td>Server4</td><td>test</td><td>one</td><td>two</td><td>three</td></tr>"
            "<tr><td>Server5.test</td><td>4</td><td>4</td><td>4</td><td>4</td></tr>"
            "<tr><td>.[?]\</td><td>4</td><td>3</td><td>2</td><td>1</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String
        $Test | Should Be $Result
    }

    It "Bad column Name" {
        { $StartHTML | Set-PSHCellColor -Color Red -Filter "nothingburger -eq 1" } | Should Throw
    }

    It "No matches" {
        $Test = $StartHTML | Set-PSHCellColor -Color Red -Filter "Column1 -eq 22" | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<title>HTML TABLE</title>"
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/><col/><col/></colgroup>"
            "<tr><th>Server</th><th>Column1</th><th>Column2</th><th>Column3</th><th>Column4</th></tr>" 
            "<tr><td>Server1</td><td>1</td><td>2</td><td>3</td><td>4</td></tr>"
            "<tr><td>Server2</td><td>1</td><td>1</td><td>2</td><td>4</td></tr>"
            "<tr><td>Server3</td><td>1</td><td>1</td><td>1</td><td>1</td></tr>"
            "<tr><td>Server4</td><td>test</td><td>one</td><td>two</td><td>three</td></tr>"
            "<tr><td>Server5.test</td><td>4</td><td>4</td><td>4</td><td>4</td></tr>"
            "<tr><td>.[?]\</td><td>4</td><td>3</td><td>2</td><td>1</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String
        $Test | Should Be $Result
    }

    It "Row highlight - with escaped characters" {
        $Test = $StartHTML | Set-PSHCellColor -Color Red -Filter "Column3 -eq 2" -Row | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<title>HTML TABLE</title>"
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/><col/><col/></colgroup>"
            "<tr><th>Server</th><th>Column1</th><th>Column2</th><th>Column3</th><th>Column4</th></tr>"
            "<tr><td>Server1</td><td>1</td><td>2</td><td>3</td><td>4</td></tr>"
            "<tr style=""background-color:Red""><td>Server2</td><td>1</td><td>1</td><td>2</td><td>4</td></tr>"
            "<tr><td>Server3</td><td>1</td><td>1</td><td>1</td><td>1</td></tr>"
            "<tr><td>Server4</td><td>test</td><td>one</td><td>two</td><td>three</td></tr>"
            "<tr><td>Server5.test</td><td>4</td><td>4</td><td>4</td><td>4</td></tr>"
            "<tr style=""background-color:Red""><td>.[?]\</td><td>4</td><td>3</td><td>2</td><td>1</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String
        $Test | Should Be $Result
    }

    It "Test 2 different filters - with escaped characters" {
        $Test = $StartHTML | Set-PSHCellColor -Color Red -Filter "Column3 -eq 2" 
        $Test = $Test | Set-PSHCellColor -Color Blue -Filter "Column4 -eq ""three""" | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<title>HTML TABLE</title>"
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/><col/><col/></colgroup>"
            "<tr><th>Server</th><th>Column1</th><th>Column2</th><th>Column3</th><th>Column4</th></tr>"
            "<tr><td>Server1</td><td>1</td><td>2</td><td>3</td><td>4</td></tr>"
            "<tr><td>Server2</td><td>1</td><td>1</td><td style=""background-color:Red"">2</td><td>4</td></tr>"
            "<tr><td>Server3</td><td>1</td><td>1</td><td>1</td><td>1</td></tr>"
            "<tr><td>Server4</td><td>test</td><td>one</td><td>two</td><td style=""background-color:Blue"">three</td></tr>"
            "<tr><td>Server5.test</td><td>4</td><td>4</td><td>4</td><td>4</td></tr>"
            "<tr><td>.[?]\</td><td>4</td><td>3</td><td style=""background-color:Red"">2</td><td>1</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String
        $Test | Should Be $Result
    }

    It "Two conditions in one filter" {
        $Test = $StartHTML | Set-PSHCellColor -Color Red -Filter "Column2 -gt 1 -and Column2 -lt 3" | Out-String
        $Result = @(
            "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">"
            "<html xmlns=""http://www.w3.org/1999/xhtml"">"
            "<head>"
            "<title>HTML TABLE</title>"
            "</head><body>"
            "<table>"
            "<colgroup><col/><col/><col/><col/><col/></colgroup>"
            "<tr><th>Server</th><th>Column1</th><th>Column2</th><th>Column3</th><th>Column4</th></tr>"
            "<tr><td>Server1</td><td>1</td><td style=""background-color:Red"">2</td><td>3</td><td>4</td></tr>"
            "<tr><td>Server2</td><td>1</td><td>1</td><td>2</td><td>4</td></tr>"
            "<tr><td>Server3</td><td>1</td><td>1</td><td>1</td><td>1</td></tr>"
            "<tr><td>Server4</td><td>test</td><td>one</td><td>two</td><td>three</td></tr>"
            "<tr><td>Server5.test</td><td>4</td><td>4</td><td>4</td><td>4</td></tr>"
            "<tr><td>.[?]\</td><td>4</td><td>3</td><td>2</td><td>1</td></tr>"
            "</table>"
            "</body></html>"
        ) | Out-String
        $Test | Should Be $Result
    }

    It "Two different columns, one filter (not allowed)" {
        { $StartHTML | Set-PSHCellColor -Color Red -Filter "Column3 -eq 2 -or Column4 -eq ""three""" } | Should Throw
    }
}

#$Test | Out-File C:\users\martin9700\Desktop\test.html
