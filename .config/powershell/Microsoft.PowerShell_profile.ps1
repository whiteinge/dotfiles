Set-PSReadlineOption -EditMode vi
Set-PSReadLineKeyHandler -Key Ctrl-a -ViMode Insert -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key Ctrl-e -ViMode Insert -Function EndOfLine
Set-PSReadLineKeyHandler -Key Ctrl-n -ViMode Insert -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl-p -ViMode Insert -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl-w -ViMode Insert -Function BackwardDeleteWord

Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

$colors = @{
   "Selection" = "$([char]0x1b)[38;2;0;0;0;48;2;178;255;102m"
}
Set-PSReadLineOption -Colors $colors

function pwhich($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}
