Function Set-PSHLink {
    <#
    .SYNOPSIS
        Simple tool used after ConvertTo-HTML to change any html links into clickable links.
    .DESCRIPTION
        Must be used in conjunction with ConvertTo-HTML, may not work on HTML generated in other
        ways.

        Currently limited to links that use http or https

    .PARAMETER InputObject
        Used take the output of ConvertTo-HTML, either via pipeline, variable or Get-Content

    .PARAMETER NewPage
        If you want the link to open a new tab use this switch

    .EXAMPLE
        $HTML = $Data | ConvertTo-HTML | Set-PSHLink
        $HTML = $Data | ConvertTo-HTML | Set-PSHLink -NewPage

    .EXAMPLE
        $Fragment = $Data | ConvertTo-HTML -Fragment
        $Fragment = Set-PSHLink -InputObject $Fragment

    .NOTES
        Author:             Martin Pugh
        Twitter:            @thesurlyadm1n
        Spiceworks:         Martin9700
        Blog:               www.thesurlyadmin.com
      
        Changelog:
            3/24/2019       Initial Release
    .LINK
        https://www.powershellgallery.com/packages/PSHTMLTools
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true)]
        [string[]]$InputObject,

        [switch]$NewPage
    )

    Begin {
        Write-Verbose "$(Get-Date): Set-PSHLink starting"
    }

    Process {
        ForEach ($Line in $InputObject)
        {
            If ($Line -notmatch "<!DOCTYPE html|<html xmlns")
            {
                $TempLine = $Line -replace "&quot",",quot"
                $Search = $TempLine | Select-String -Pattern '(https?://[^\s"<>,]*)( |<)?' -AllMatches
                If ($Search.Matches)
                {
                    #Now begin replacing
                    For ($Element = $Search.Matches.Count -1; $Element -ge 0; $Element --)
                    {
                        $Target = $null
                        If ($NewPage)
                        {
                            $Target = " target=""_blank"""
                        }
                        $Match = $Search.Matches[$Element]
                        $TempLine = $TempLine.Remove($Match.Groups[1].Index,$Match.Groups[1].Length).Insert($Match.Groups[1].Index,"<a href=""$($Match.Groups[1].Value)""$Target>$($Match.Groups[1].Value)</a>")
                    }
                    Write-Verbose "$(Get-Date): Old Line  : $Line"        
                    Write-Verbose "$(Get-Date): Chagned to: $TempLine"
                }
                $Line = $TempLine -replace ",quot","&quot"
            }
            Write-Output $Line
        }
            
    }

    End {
        Write-Verbose "$(Get-Date): Set-PSHLink completed"
    }
}
