#SingleInstance, force

	;============================
	text := "Some dummy text"
	font := "s32, Courier New"
	;============================

	Gui, Add, Edit, HWNDh, %text%
	hFont := Font(h, font)
	
	size := Font_DrawText(text, "", hFont, "CALCRECT")
	StringSplit, size, size, .
	width := size1 + 8,	height := size2 + 8  	;include control border

	Gui, Add, Edit, HWNDh y+50 w%width% h%height% -wrap -vscroll,%text%
	Font(h, hFont)

	Gui, Add, Edit, HWNDh y+50 h%height% -vscroll,%text%
	Font(h, hFont)

	Gui, Show, autosize
return

GuiClose:
GuiEscape:
  ExitApp
return

#include Font.ahk