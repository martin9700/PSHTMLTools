Function Set-CellColor
{   <#
    .SYNOPSIS
        Function that allows you to set individual cell colors in an HTML table
    .DESCRIPTION
        To be used inconjunction with ConvertTo-HTML this simple function allows you
        to set particular colors for cells in an HTML table.  You provide the criteria
        the script uses to make the determination if a cell should be a particular 
        color (property -gt 5, property -like "*Apple*", etc).
        
        You can add the function to your scripts, dot source it to load into your current
        PowerShell session or add it to your $Profile so it is always available.
        
        To dot source:
            .".\Set-CellColor.ps1"
              
    .PARAMETER Color
        Name or 6-digit hex value of the color you want the cell to be
    .PARAMETER InputObject
        HTML you want the script to process.  This can be entered directly into the
        parameter or piped to the function.
    .PARAMETER Filter
        Specifies a query to determine if a cell should have its color changed.  $true
        results will make the color change while $false result will return nothing.
        
        Syntax
        <Property Name> <Operator> <Value>
        
        <Property Name>::= the same as $Property.  This must match exactly
        <Operator>::= "-eq" | "-le" | "-ge" | "-ne" | "-lt" | "-gt"| "-approx" | "-like" | "-notlike" 
            <JoinOperator> ::= "-and" | "-or"
            <NotOperator> ::= "-not"
        
        The script first attempts to convert the cell to a number, and if it fails it will
        cast it as a string.  So 40 will be a number and you can use -lt, -gt, etc.  But 40%
        would be cast as a string so you could only use -eq, -ne, -like, etc.  
    .PARAMETER Row
        Instructs the script to change the entire row to the specified color instead of the individual cell.
    .INPUTS
        HTML with table
    .OUTPUTS
        HTML
    .EXAMPLE
        get-process | convertto-html | set-cellcolor -Propety cpu -Color red -Filter "cpu -gt 1000" | out-file c:\test\get-process.html

        Assuming Set-CellColor has been dot sourced, run Get-Process and convert to HTML.  
        Then change the CPU cell to red only if the CPU field is greater than 1000.
        
    .EXAMPLE
        get-process | convertto-html | set-cellcolor -color red -filter "cpu -gt 1000 -and cpu -lt 2000" | out-file c:\test\get-process.html
        
        Same as Example 1, but now we will only turn a cell red if CPU is greater than 1000 
        but less than 2000.
        
    .EXAMPLE
        $HTML = $Data | sort server | ConvertTo-html -head $header | Set-CellColor -Color red -Filter "cookedvalue -gt 1"
        PS C:\> $HTML = $HTML | Set-CellColor Server green -Filter "server -eq 'dc2'"
        PS C:\> $HTML | Set-CellColor Path Yellow -Filter "Path -like ""*memory*""" | Out-File c:\Test\colortest.html
        
        Takes a collection of objects in $Data, sorts on the property Server and converts to HTML.  From there 
        we set the "CookedValue" property to red if it's greater then 1.  We then send the HTML through Set-CellColor
        again, this time setting the Server cell to green if it's "dc2".  One more time through Set-CellColor
        turns the Path cell to Yellow if it contains the word "memory" in it.
        
    .EXAMPLE
        $HTML = $Data | sort server | ConvertTo-html -head $header | Set-CellColor -Color red -Filter "cookedvalue -gt 1" -Row
        
        Now, if the cookedvalue property is greater than 1 the function will highlight the entire row red.
        
    .NOTES
        Author:             Martin Pugh
        Twitter:            @thesurlyadm1n
        Spiceworks:         Martin9700
        Blog:               www.thesurlyadmin.com
          
        Changelog:
            2.1             Fix bug with escaped characters
            2.0             Major rewrite, now only replaces the column you specify (finally). Property parameter has been eliminated. 
            1.5             Added ability to set row color with -Row switch instead of the individual cell
            1.03            Added error message in case the $Property field cannot be found in the table header
            1.02            Added some additional text to help.  Added some error trapping around $Filter
                            creation.
            1.01            Added verbose output
            1.0             Initial Release
    .LINK
        http://community.spiceworks.com/scripts/show/2450-change-cell-color-in-html-table-with-powershell-set-cellcolor
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position=0)]
        [string]$Filter,

        [Parameter(Mandatory,Position=0)]
        [string]$Color,

        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]$InputObject,
        
        [switch]$Row
    )
    
    Begin {
        Write-Verbose "$(Get-Date): Function Set-CellColor begins"
    }
    
    Process {
        $InputObject = $InputObject -split "`r`n"
        ForEach ($Line in $InputObject)
        {   
            If ($Line.IndexOf("<tr><th") -ge 0)
            {   
                Write-Verbose "$(Get-Date): Processing headers..."
                $Search = $Line | Select-String -Pattern '<th ?.*?>(.*?)<\/th>' -AllMatches
                
                $Index = 0
                $Property = $null
                ForEach ($Header in $Search.Matches)
                {   
                    If ($Filter -match $Header.Groups[1].Value)
                    {   
                        $Property = $Header.Groups[1].Value
                        Break
                    }
                    $Index ++
                }

                If (-not $Property)
                {
                    Write-Error "$(Get-Date): Unable to locate the column in your filter.  Filter: $Filter" -ErrorAction Stop
                }
                Else
                {
                    $Filter = $Filter -replace $Property,"`$Value"
                    Try {
                        $Oper = [scriptblock]::Create($Filter)
                    }
                    Catch {
                        Write-Error "$(Get-Date): ""$Filter"" invalid because ""$_""" -ErrorAction Stop
                    }
                }
                Write-Verbose "$(Get-Date): $Property column found at index: $Index"
            }

            If ($Line -match "<tr ?.*?><td ?.*?>(.*?)<\/td><\/tr>")
            {   
                $Search = $Line | Select-String -Pattern '<td ?.*?>(.*?)<\/td>' -AllMatches
                #Determine if the column value is a number
                Try {
                    [double]$Value = $Search.Matches[$Index].Groups[1].Value
                }
                Catch {
                    #Nope, treat it like a string
                    [string]$Value = $Search.Matches[$Index].Groups[1].Value
                }

                If (Invoke-Command $Oper)
                {   
                    If ($Row)
                    {   
                        Write-Verbose "$(Get-Date): Criteria met!  Changing row to $Color..."
                        If ($Line -match "<tr style=""background-color:(.+?)"">")
                        {   
                            $Line = $Line -replace "<tr style=""background-color:$($Matches[1])","<tr style=""background-color:$Color"
                        }
                        Else
                        {   
                            $Line = $Line.Replace("<tr>","<tr style=""background-color:$Color"">")
                        }
                    }
                    Else
                    {   
                        Write-Verbose "$(Get-Date): Criteria met!  Changing cell to $Color..."
                        $Count = 0
                        $Pattern = ".*?"
                        ForEach ($Column in $Search.Matches)
                        {
                            $Pattern = "$Pattern$([RegEx]::Escape($Column.Groups[1].Value))</td>.*?"
                            If ($Count -eq $Index - 1)
                            {
                                Break
                            }
                            $Count ++
                        }
                        $null = $Line -match $Pattern
                        $StartsWith = $Matches.Values
                        $NewLine = $Line -replace ([RegEx]::Escape($StartsWith)),''
                        $NewLine = $NewLine -replace '^<td ?(style="background-color:.*")?>.*?<\/td>',"<td style=""background-color:$Color"">$Value</td>"
                        $Line = "$StartsWith$($NewLine)"
                    }
                }
            }
            Write-Output $Line
        }
    }
    
    End {
        Write-Verbose "$(Get-Date): Function Set-CellColor completed"
    }
}
