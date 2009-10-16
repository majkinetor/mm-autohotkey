_("mo! e w")
	hForm1	:=	Form_New("w400 h300 +Resize ")
	Form_Show(hForm1, "xCenter yCenter", hForm1)

	hForm2 := Form_New("w200 +Resize +ToolWindow -Sysmenu")
	Form_Add(hForm2, "Text", "Customize width")
	Form_Show(hForm2, "", hForm2)

	hForm3 := Form_New("w150 h50 +ToolWindow  -Sysmenu")
	Form_Show(hForm3, "", hForm3)

	DockA(hForm1, hForm2, "x(1) y() h(1)")
	DockA(hForm1, hForm3, "x() y(,,30) w(1)")
	DockA(hForm1)
return

Form1_Size:
	DockA( hForm1 )
return

Form1_Close:
	ShowForms(false)
return

ShowForms(BShow) {
	global

	loop,3
		if BShow
			 Form_Show(hForm%A_Index%)
		else Form_Hide(hForm%A_Index%)
}

F1:: 
	ShowForms(true)
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