[![Build status](https://ci.appveyor.com/api/projects/status/jsy9xqt0t8atdan5?svg=true)](https://ci.appveyor.com/project/MartinPugh/pshtmltools)

# PSHTMLTools
Simple tools to pretty up the HTML from ConvertTo-HTML


Tools
-----

| Function            | Comments                                                      |
| ------------------- | ------------------------------------------------------------- |
| Set-AlternatingRows | Alternate every row in a HTML table to different colors       |
| Set-CellColor       | Change color of individual cells based on supplied conditions |
| Set-GroupRowColorsByColumn | Alternate rows based on a trigger column changing value | 


Installation Instructions
-------------------------

```powershell
Find-Module PSHTMLTools | Install-Module
```