SetBatchLines, -1
#singleinstance, force
	OnExit, OnExit
	Gui,  +LastFound                                                                 
	hGui := WinExist()

	iconNo := 2
	loop, %iconNo%
		hTray := Tray_Add( hGui, "OnTrayIcon", "shell32.dll:" A_Index, "My Tray Icon " A_Index)
return                                                                               
																				   
OnTrayIcon(Hwnd, Event) {
	global

	if event not in R,M,L	;return if event is not right click
		return                                                                       
					
	n := aTrayIcons_%hwnd%																				  
	MsgBox, ,Icon %n%, %EVENT% Button clicked.`n`nPress F1 to exit script 
}                 

F1::
OnExit:
	Tray_Remove(hGui)
	ExitApp
return

F2::
	m(Tray_Define("ahk_id " hGui, "i") )
;	Tray_Modify(66116, 1226, "shell32.dll:1", "aloha")
return

F3::	
	;put ahk icons at the end
	s := Tray_Define("autohotkey.exe", "i")
	loop, parse, s, `n
		Tray_Move(A_LoopField+2 - A_Index)

return

#include Tray.ahk