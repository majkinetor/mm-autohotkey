#singleinstance, force
	OnExit, OnExit
	Gui,  +LastFound                                                                 
	hGui := WinExist()                                                               

	iconNo := 5

	loop, %iconNo%
		hTray := Tray_Add( hGui, "OnTrayIcon", "Tray.ico", "My Tray Icon " A_Index), aTrayIcons_%hTray% := A_Index, aIcon_%A_Index% := hTray
return                                                                               
																				   
OnTrayIcon(hwnd, event) {
	global

	if event not in R,M,L	;return if event is not right click
		return                                                                       
					
	n := aTrayIcons_%hwnd%																				  
	MsgBox, ,Icon %n%, %EVENT% Button clicked.`n`nPress F1 to exit script 
}                 

F1::
OnExit:
	loop, %iconNo%
		Tray_Remove(hGui, aIcon_%A_Index%) 	;must be done or icon will stand there hanging if app is restarted

	ExitApp
return

#include Tray.ahk