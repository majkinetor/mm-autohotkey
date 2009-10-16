_()
	hForm1	:=	Form_New("e3 w200 h500")
	Form_Add(hForm1, "Edit", "ESC to close script. F2 to resize. Drag picture to move.", "-vscroll w200 r3 0x8000","Align T", "Attach w")
	Form_Add(hForm1, "Picture", "res\test.bmp", "gPictureDrag", "Cursor size")

	hFont := Font("", "s12 italic, Courier New")
	sz := Font_DrawText("Click here to go to Google", "", hFont, "calcrect ahksize")
	pos := Form_GetNextPos(hForm1, sz)
	Form_Add(hForm1, "HLink", "Click 'here':www.google.com to go to Google", pos " " sz, "Font " hFont)
	pos := Form_GetNextPos(hForm1, "x+50 yp")
	Form_Add(hForm1, "HLink", "Click 'here':www.google.com to go to Google", pos " " sz, "Font " hFont)

	Form_AutoSize( hForm1, 10.5)
	Form_Show(hForm1, "xCenter yCenter")
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