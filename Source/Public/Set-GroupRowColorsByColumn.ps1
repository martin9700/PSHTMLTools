Function Set-GroupRowColorsByColumn {
    <#
    .SYNOPSIS
        Set rows to alternating colors based on the value of a cell
    .DESCRIPTION
        Rows will alternate color in a HTML table. 
        
        **This is designed for use with ConvertTo-HTML and other HTML tables may not work 
        with it.**

        I recommend sorting your data by the column you intend to use as a trigger.

    .PARAMETER InputObject
        Your HTML input, either specified directly or through pipeline.

    .PARAMETER ColumnName
        This is the column that you will trigger off of. Whenever this column changes the
        script will flip to the other color.

    .PARAMETER CSSEvenClass
        The Even color used in the report. This will be the starting color.

    .PARAMETER CSSOddClass
        The alternate color in the report.

    .EXAMPLE
        $Data = @"
        "From","To","LastRepliationAttempt","LastReplicationResult","LastReplicationSuccess"
        "corpdc101","CORPDC102","2/11/2015 12:57:47 PM","0","2/11/2015 12:57:47 PM"
        "corpdc101","CORPDC103","2/11/2015 12:57:45 PM","0","2/11/2015 12:57:45 PM"
        "corpdc101","CORPDC701","2/11/2015 12:50:36 PM","0","2/11/2015 12:50:36 PM"
        "corpdc101","CORPDC001","2/11/2015 12:50:36 PM","0","2/11/2015 12:50:36 PM"
        "corpdc101","CORPDC202","2/11/2015 12:50:35 PM","0","2/11/2015 12:50:35 PM"
        "corpdc102","CORPDC103","2/11/2015 12:57:48 PM","0","2/11/2015 12:57:48 PM"
        "corpdc102","CORPDC101","2/11/2015 12:57:44 PM","0","2/11/2015 12:57:44 PM"
        "corpdc102","CORPDC301","2/11/2015 12:54:49 PM","0","2/11/2015 12:54:49 PM"
        "corpdc102","CORPDC402","2/11/2015 12:54:45 PM","0","2/11/2015 12:54:45 PM"
        "CORPRODC101","CORPDC102","2/11/2015 12:50:41 PM","0","2/11/2015 12:50:41 PM"
        "CORPRODC102","CORPDC102","2/11/2015 12:53:40 PM","0","2/11/2015 12:53:40 PM"
        "corpdc401","CORPDC402","2/11/2015 12:57:50 PM","0","2/11/2015 12:57:50 PM"
        "corpdc402","CORPDC401","2/11/2015 12:57:52 PM","0","2/11/2015 12:57:52 PM"
        "corpdc402","CORPDC102","2/11/2015 12:54:59 PM","0","2/11/2015 12:54:59 PM"
        "corpdc201","CORPDC202","2/11/2015 12:57:51 PM","0","2/11/2015 12:57:51 PM"
        "corpdc103","CORPDC102","2/11/2015 12:57:50 PM","0","2/11/2015 12:57:50 PM"
        "corpdc103","CORPDC101","2/11/2015 12:57:47 PM","0","2/11/2015 12:57:47 PM"
        "CORPDC202","CORPDC201","2/11/2015 12:57:43 PM","0","2/11/2015 12:57:43 PM"
        "CORPDC202","CORPDC101","2/11/2015 12:51:53 PM","0","2/11/2015 12:51:53 PM"
        "corpdc001","CORPDC002","2/11/2015 12:57:43 PM","0","2/11/2015 12:57:43 PM"
        "corpdc001","CORPDC101","2/11/2015 12:55:50 PM","0","2/11/2015 12:55:50 PM"
        "corpdc002","CORPDC001","2/11/2015 12:57:46 PM","0","2/11/2015 12:57:46 PM"
        "corpdc301","CORPDC101","2/11/2015 12:46:28 PM","0","2/11/2015 12:46:28 PM"
        "corpdc701","CORPDC702","2/11/2015 12:57:49 PM","0","2/11/2015 12:57:49 PM"
        "corpdc701","CORPDC102","2/11/2015 12:56:49 PM","0","2/11/2015 12:56:49 PM"
        "corpdc702","CORPDC701","2/11/2015 12:57:52 PM","0","2/11/2015 12:57:52 PM"
        "@ | ConvertFrom-CSV | Sort From

        $Header = @"
        <style>
        TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
        TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
        TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
        .odd  { background-color:#ffffff; }
        .even { background-color:#dddddd; }
        </style>
        "@

        $RawHTML = $Data | ConvertTo-Html -Head $Header


        $New = Set-GroupRowColorsByColumn -InputObject $RawHTML -ColumnName From -CSSEvenClass even -CSSOddClass odd
        
        #Can also use:
        $New = $RawHTML | Set-GroupRowColorsByColumn -ColumnName From -CSSEvenClass even -CSSOddClass odd

        $New | Out-File .\Report.html

    .NOTES
        Author:             Martin Pugh
          
        Changelog:
            1.52            Updated the help, removed an unnecessary variable
            1.51            Removed test code, added comment based help
            1.5             Added ability to set row color with -Row switch instead of the individual cell
            1.03            Added error message in case the $Property field cannot be found in the table header
            1.02            Added some additional text to help.  Added some error trapping around $Filter
                            creation.
            1.01            Added verbose output
            1.0             Initial Release
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]]$InputObject,
        [Parameter(Mandatory)]
        [string]$ColumnName,
        [string]$CSSEvenClass = "TREven",
        [string]$CSSOddClass = "TROdd"
    )
    Process {
        ForEach ($Line in $InputObject)
        {
            If ($Line -like "*<th>*")
            {
                If ($Line -notlike "*$ColumnName*")
                {
                    Write-Error "Unable to locate a column named $ColumnName" -ErrorAction Stop
                }
                $Search = $Line | Select-String -Pattern "<th>.*?</th>" -AllMatches
                $Index = 0
                ForEach ($Column in $Search.Matches)
                {
                    If (($Column.Groups.Value -replace "<th>|</th>","") -eq $ColumnName)
                    {
                        Break
                    }
                    $Index ++
                }
            }
            If ($Line -like "*<td>*")
            {
                $Search = $Line | Select-String -Pattern "<td>.*?</td>" -AllMatches
                If ($LastColumn -ne $Search.Matches[$Index].Value)
                {
                    If ($Class -eq $CSSEvenClass)
                    {
                        $Class = $CSSOddClass
                    }
                    Else
                    {
                        $Class = $CSSEvenClass
                    }
                }
                $LastColumn = $Search.Matches[$Index].Value
                $Line = $Line.Replace("<tr>","<tr class=""$Class"">")
            }
            Write-Output $Line
        }
    }
}
