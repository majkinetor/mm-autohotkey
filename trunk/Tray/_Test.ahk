SetBatchLines, -1
#singleinstance, force
	OnExit, OnExit
	Gui,  +LastFound +AlwaysOnTop Toolwindow
	hGui := WinExist() + 0

	loop, 3
		Tray_Add(hGui, "OnTrayIcon", "shell32.dll:" A_Index, "AHK tray icon " A_Index)
	OnMessage(0x200, "OnMouseMove")

	loop, 20
		Gui, Add, Picture, yp x+5 w32 h32 0x3 HWNDh%A_Index% gOnPicture

	RefreshTray()
	SetTimer, RefreshTray, 1000

	gui, show, y0 w400 h50
return


RefreshTray(){
	s := Tray_Define("", "o")
	loop, parse, s, `n
		SetIcon(A_Index, A_LoopField), c := A_Index

	c++
	loop, % 20-c
		SetIcon(c+A_Index-1, 0)
}

RefreshTray:
	RefreshTray()
return

OnPicture:
	MouseGetPos,,,,c
	StringReplace, c, c, static
;	Tray_Click(	c, "R" )	;worked only for this script icons.

	Tray_Define(c, "inhw", pos, name, handle, parent)
	tip := Tray_GetTooltip(c)
	msgbox Pos: %pos%  Handle: %handle%  Parent: %parent%  Name: %name%`nTooltip: %tip%
return	


OnMouseMove(wparam, lparam){
	global
	MouseGetPos,,,,c
	if c contains Static
	{
		StringReplace, c, c, static
		c := Tray_GetTooltip(c)
		SetTimer, ShowTooltip, -200
	} else Tooltip
}

ShowTooltip:
	Tooltip, %c%
return

SetIcon(Pos, hIcon){
	global
	GuiControlGet hPic, HWND, Static%pos%
	SendMessage, 0x172, 0x1, hIcon, , ahk_id %hPic%
}
																				   
OnTrayIcon(Hwnd, Event) {
	global

	if event not in R,M,L	;return if event is not right click
		return                                                                       
					
	MsgBox, ,Icon %n%, %EVENT% Button clicked.`n`nPress F1 to exit script 
}                 

F1::
OnExit:
	Tray_Remove(hGui)
	ExitApp
return

F2::
	Tray_Remove(hGui)
return



ShowAllTooltips(){
	s := Tray_Define()
	loop, parse, s, `n
		r .= A_Index " " Tray_GetTooltip(A_Index) "`n"
	msgbox %r%
}

MoveAhkIcons(){
	;put ahk icons at the end
	s := Tray_Define("autohotkey.exe", "i")
	loop, parse, s, `n
		Tray_Move(A_LoopField+1 - A_Index)
}

#include Tray.ahk