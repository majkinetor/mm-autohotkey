#singleinstance, force
	OnExit, OnExit
	Gui,  +LastFound                                                                 
	hGui := WinExist()                                                               

	iconNo := 10

	loop, %iconNo%
		hTray := Tray_Add( hGui, "OnTrayIcon", "shell32.dll:" A_Index, "My Tray Icon " A_Index), aTrayIcons_%hTray% := A_Index, aIcon_%A_Index% := hTray
return                                                                               
																				   
OnTrayIcon(Hwnd, Event) {
	global

	if event not in R,M,L	;return if event is not right click
		return                                                                       
					
	n := aTrayIcons_%hwnd%																				  
	MsgBox, ,Icon %n%, %EVENT% Button clicked.`n`nPress F1 to exit script 
}                 

OnExit:
F1::
	loop, %iconNo%
		Tray_Remove(hGui, aIcon_%A_Index%) 	;must be done or icon will stand there hanging if app is restarted

	ExitApp
return


#include Tray.ahk