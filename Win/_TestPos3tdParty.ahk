;_("e2 d"), _ := " "
#singleinstance, force
	hwnd := WinExist("Total")
	Set(hwnd)
return


Set(hwnd){

	pos := Win_Pos("<mygui hwnd" hwnd, nx, ny, nw, nh, nm)
	if pos !=
		WinMove, ahk_id %hwnd%, , nx, ny, nw, nh
	if nm = maximize
		WInMaximize, ahk_id %hwnd%
	else if nm = minimized
		WInMinimize, ahk_id %hwnd%	
}

ESC::
	ExitApp
return
	
F1::
	pos := Win_Pos(">mygui hwnd" hwnd)
return

F2::
	Set(hwnd)
return

#include Win.ahk