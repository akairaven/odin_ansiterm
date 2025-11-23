package ansiterm

ESC :: 27
KEY_UP :: "\e[A"
KEY_DOWN :: "\e[B"
KEY_LEFT :: "\e[D"
KEY_RIGHT :: "\e[C"
KEY_HOME :: "\e[H"
KEY_INSERT :: "\e[2~"
KEY_DELETE :: "\e[3~"
KEY_END :: "\e[F"
KEY_F1 :: "\eOP"


FOCUS_ENTER :: "\e[I"
FOCUS_EXIT :: "\e[O"

/* row, col */
CursorPosition :: "\e[%d;%dH" /* row, col */
SetScrollingRegion :: "\e[%d;%dr" /* top, bottom */
ForegroundColor :: "\e[38;2;%d;%d;%dm" /* r,g,b */
BackgroundColor :: "\e[48;2;%d;%d;%dm" /* r,g,b */
EraseInLine :: "\e[%dK" /* 0 til end of line, 1 = beginning of line, 2 = entire line */
EraseLine :: "\e[2K" /* 0 til end of line, 1 = beginning of line, 2 = entire line */

DefaultStyle :: "\e[0m"
EnableBold :: "\e[1m"
DisableBold :: "\e[22m"
EnableUnderline :: "\e[4m"
DisableUnderline :: "\e[24m"
EnableNegative :: "\e[7m"
DisableNegative :: "\e[27m"

WindowTitle :: "\e]2;%s\a" /* OCR title */

EnableReportFocus :: "\e[?1004h"
DisableReportFocus :: "\e[?1004l"

HideCursor :: "\e[?25l"
ShowCursor :: "\e[?25h"
SavePosition :: ""
RestorePosition :: ""
SoftReset :: "\e[!p"
HardReset :: "\ec"
ClearScreen :: "\e[0m\e[2J\e[1;1H"
SaveScreen :: "\e[?47h"
RestoreScreen :: "\e[?47l"
