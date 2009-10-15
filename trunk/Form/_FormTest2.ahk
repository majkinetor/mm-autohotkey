_("")
	hForm1	:=	Form_New("m0.0 e3 w200 h500 -Caption")
	Form_Add(hForm1, "Edit", "ESC to hide F1 to show. F2 to resize. Drag picture to move.", "-vscroll w200 r3 0x8000","Align T", "Attach w")
	Form_Add(hForm1, "Picture", "res\test.bmp", "gPictureDrag", "Cursor size")

	hFont := Font("", "s16 italic, Courier New")
	pos := Font_DrawText("Ask Google and don't trouble me", "", hFont, "calcrect ahksize")
	hlink := Form_Add(hForm1, "HLink", "Ask 'Google':www.google.com and don't trouble me", pos " y200", "Font " hFont)
	Font(hlink, hFont), Font(htext, hFont)

	Form_AutoSize( hForm1, 10.10)
	Form_Show()
return

PictureDrag: 
	PostMessage, 0xA1, 2,,, A 
Return

F1:: 
	WinShow, ahk_id %hForm1%
	WinActivate, ahk_id %hForm1%
return

F2::
	WinSet, Style, ^0x40000, ahk_id %hForm1%
	Form_AutoSize(hForm1)
	Win_Redraw()
return

#include inc
#include _Forms.ahk