_()
	hForm1	:=	Form_New("w200 h140 T Resize Font='s8, Courier New' -Caption +ToolWindow")

	Form_Add(hForm1, "Picture", "res\test.bmp", "x5 y65 GuiMove")
	Form_Add(hForm1, "Edit", "ESC to hide F1 to show. Drag picture to move.", "-vscroll x5 y5 w200 r3 0x8000")

	Form_Show()
return

uiMove: 
	PostMessage, 0xA1, 2,,, A 
Return

F1::
	WinShow, ahk_id %hForm1%
	WInActivate, ahk_id %hForm1%
return

ESC::
	WinHide, ahk_id %hForm1%
return	

#include inc\Form.ahk