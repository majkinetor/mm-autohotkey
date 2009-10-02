_()
	hForm1	:=	Form_New("w500 h400 Resize T Font='s8, Courier New' -Caption +ToolWindow")

	Form_Add(hForm1, "Picture", "res\test.bmp", "x20 y50 BackgroundTrans GuiMove")
	Form_Add(hForm1, "combobox", "hey there|2|3", "x20 y20 w100 0x8000")

	Form_Show()
return

uiMove: 
	PostMessage, 0xA1, 2,,, A 
Return

F1::
	WInActivate, ahk_id %hForm1%
	WinShow, ahk_id %hForm1%
return

ESC::
	WinHide, ahk_id %hForm1%
return

#include inc\Form.ahk