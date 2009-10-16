_("mo! e")
	hForm1	:=	Form_New("w400 h300 -Resize")
	Form_Show(hForm1, "xCenter yCenter", hForm1)

	hForm2 := Form_New("w200 +Resize +ToolWindow")
	Form_Add(hForm2, "Text", "Customize width")
	Form_Show(hForm2, "", hForm2)

	hForm3 := Form_New("w50 +ToolWindow")
	Form_Show(hForm3, "", hForm3)

	DockA(hForm1, hForm2, "x(1) y() h(1)")
	DockA(hForm1, hForm3, "x(,-1,-15)  y(1,-1) h(.5)")
	DockA(hForm1)
return

Form1_Size:
	DockA( hForm1 )
return

PictureDrag: 
	PostMessage, 0xA1, 2,,, A 
Return

F1:: 
	WinShow, ahk_id %hForm1%
	WinActivate, ahk_id %hForm1%
return

F2::
	DockA(hForm1)
return

F3::
	DockA(hForm1, hForm2, "-")
return

F4::
	DockA(hForm1, hForm2, "")
return

#include inc
#include _Forms.ahk
#include DockA.ahk