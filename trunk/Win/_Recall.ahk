#SingleInstance, force
MakeGui:
	n++
	Gui, %n%:+Resize +LastFound
	Hwnd := WinExist(), %Hwnd% := n
	Gui, %n%:Add, Text, ,F1-New Gui    ESC-exit.
	Gui, %n%:Add, Button, y+50 gOnbutton, Save (F2)
	Gui, %n%:Add, Button, yp x+5 gOnbutton, Recall (F3)
	Gui, %n%:Add, Button, xm	 gOnbutton, Save All (F4)
	Gui, %n%:Add, Button, yp x+5 gOnbutton, Recall All
	
	WinSetTitle, Gui %n%
	if !Win_Recall("<" n, Hwnd, "config.ini")	
		Gui, %n%:Show, autosize, Gui %n%	
return

F1:: goto MakeGui
F2:: Hwnd := WinExist("A"), Win_Recall(">" %Hwnd%  Hwnd, "config.ini")
F3:: Hwnd := WinExist("A"), Win_Recall("<" %Hwnd%, Hwnd, "config.ini")
F4:: Win_Recall(">>")

OnButton:
	if A_GuiControl contains F2
		 Win_Recall(">" A_Gui, A_Gui, "config.ini")
	else if A_GuiControl contains F3 
		 Win_Recall("<" A_Gui, A_Gui, "config.ini")
	else if A_GuiControl contains F4
		 Win_Recall(">>", "", "config.ini")
	else Win_Recall("<<", "", "config.ini")
return

ESC::
	Win_Recall(">>", "", "config.ini")
	ExitApp
return

#include Win.ahk