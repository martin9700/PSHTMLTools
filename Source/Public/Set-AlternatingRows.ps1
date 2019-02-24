Function Set-AlternatingRows {
	<#
	.SYNOPSIS
		Simple function to alternate the row colors in an HTML table

	.DESCRIPTION
		This function accepts pipeline input from ConvertTo-HTML or any
		string with HTML in it.  It will then search for <tr> and replace 
		it with <tr class=(something)>.  With the combination of CSS it
		can set alternating colors on table rows.
		
		CSS requirements:
		.odd  { background-color:#ffffff; }
		.even { background-color:#dddddd; }
		
		Classnames can be anything and are configurable when executing the
		function.  Colors can, of course, be set to your preference.
		
		This function does not add CSS to your report, so you must provide
		the style sheet, typically part of the ConvertTo-HTML cmdlet using
		the -Head parameter.

	.PARAMETER Line
		String containing the HTML line, typically piped in through the
		pipeline.

	.PARAMETER CSSEvenClass
		Define which CSS class is your "even" row and color.

	.PARAMETER CSSOddClass
		Define which CSS class is your "odd" row and color.
	.EXAMPLE $Report | ConvertTo-HTML -Head $Header | Set-AlternateRows -CSSEvenClass even -CSSOddClass odd | Out-File .\HTMLReport.html

	
		$Header can be defined with a here-string as:
		$Header = @"
		<style>
		TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
		TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
		TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
		.odd  { background-color:#ffffff; }
		.even { background-color:#dddddd; }
		</style>
		"@
		
		This will produce a table with alternating white and grey rows.  Custom CSS
		is defined in the $Header string and included with the table thanks to the -Head
		parameter in ConvertTo-HTML.

    .EXAMPLE
        $RawHTML = $Report | ConvertTo-HTML -Head $Header
        $FinalHTML = Set-AlternateRows -CSSEvenClass even -CSSOddClass odd -InputObject $RawHTML
        $FinalHTML | Out-File .\HTMLReport.html

	.NOTES
		Author:         Martin Pugh
		Twitter:        @thesurlyadm1n
		Spiceworks:     Martin9700
		Blog:           www.thesurlyadmin.com
		
		Changelog:
            1.5         Added ability to specify HTML instead of piping it. Updated look of the script and added an additional
                        example to help.
			1.1         Modified replace to include the <td> tag, as it was changing the class
                        for the TH row as well.
            1.0         Initial function release
	.LINK
		http://community.spiceworks.com/scripts/show/1745-set-alternatingrows-function-modify-your-html-table-to-have-alternating-row-colors
    .LINK
        http://thesurlyadmin.com/2013/01/21/how-to-create-html-reports/
	#>
    [CmdletBinding()]
   	Param(
       	[Parameter(Mandatory,ValueFromPipeline)]
        [string[]]$InputObject,
       
   	    [Parameter(Mandatory)]
       	[string]$CSSEvenClass,
       
        [Parameter(Mandatory)]
   	    [string]$CSSOddClass
   	)
	Begin {
		$ClassName = $CSSEvenClass
	}
	Process {
        ForEach ($Line in $InputObject)
        {
		    If ($Line.Contains("<tr><td>"))
		    {	
                $Line = $Line.Replace("<tr>","<tr class=""$ClassName"">")
			    If ($ClassName -eq $CSSEvenClass)
			    {	
                    $ClassName = $CSSOddClass
			    }
			    Else
			    {	
                    $ClassName = $CSSEvenClass
			    }
		    }
		    Write-Output $Line
        }
	}
}
