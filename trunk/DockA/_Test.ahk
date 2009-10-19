_("e d")
#SingleInstance, force
	Gui, 1:+LastFound +Resize +LabelForm1_
	Gui, 1:Show,  w400 h300, Form1
	hForm1 := WinExist()

	Gui, 2:+LastFound +Resize +ToolWindow -Sysmenu
	Gui, 2:Add, Button, gOnButton,Toggle dock
	Gui, 2:Show,  w300 h200, Form2
	hForm2 := WinExist()
	
	Gui, 3:+LastFound -Caption
	Gui, 3:Show,  Hide w150 h140, Form3
	Gui, 3:Add, Listbox, x0 y0,1|2|3
	Gui, 3:Add, Statusbar
	hForm3 := WinExist()

	DockA(hForm1, hForm2, "x(1) y() h(1)")
	DockA(hForm1, hForm3, "x() y(,,30) w(1)")
	DockA(hForm1), bDockOn := 1

	ShowForms(true)
return

Form1_Size:
	DockA( hForm1 )
return

Form1_Close:
	ShowForms(false)
return

Onbutton:
	if (bDockOn)
		 DockA(hForm1, hForm2, "-")
	else DockA(hForm1, hForm2)

	bDockOn := !bDockOn
return

ShowForms(BShow) {
	global

	if BShow
		DockA(hForm1)

	loop,3
		if BShow
			 Gui, %A_Index%:Show
		else Gui, %A_Index%:Hide
}

F1:: ShowForms(true)

#include DockA.ahk