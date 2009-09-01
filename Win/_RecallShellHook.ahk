#Persistent 
SetBatchLines, -1 
	if !RegisterShellHook("OnShell"){
		 msgbox Can't register hook. Aborting!
		 ExitApp
	}
	else msgbox Hook installed. `nF2 - Save active window location`nESC-Exit.
return

ESC:: ExitApp

/*
	Function:	RegisterShellHook

	Parameter:
				Handler	- Function to call.

	Handler:
		
 >	OnShell(Reason, Param) {	
 >		static WINDOWCREATED=1, WINDOWDESTROYED=2, WINDOWACTIVATED=4, GETMINRECT=5, REDRAW=6, TASKMAN=7, APPCOMMAND=12
 >	} 
		
	Handler Parameters:
		Reason		- Reason for which handler is called. 
		Param		- Parameter of the handler. Parameters are given bellow for each reason.

	
		WINDOWACTIVATED	-	The HWND handle of the activated window.
		WINDOWREPLACING	-	The HWND handle of the window replacing the top-level window.
		WINDOWCREATED	-	The HWND handle of the window being created.
		WINDOWDESTROYED	-	The HWND handle of the top-level window being destroyed.		
		GETMINRECT		-	A pointer to a RECT structure.
		TASKMAN			-	Can be ignored.
		REDRAW			-	The HWND handle of the window that needs to be redrawn.
		
	Returns:
		0 on failure, name of the previous hook procedure on success.
 */
RegisterShellHook(Handler) {
	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on
	Process, Exist
	h := WinExist("ahk_pid " ErrorLevel)
	DetectHiddenWindows, %oldDetect%

	if !DllCall("RegisterShellHookWindow", "UInt", h) 
		return 0
	return OnMessage(DllCall( "RegisterWindowMessage", "str", "SHELLHOOK") , Handler)
}

F2::
	hwnd := WinExist("A")
	WinGetClass, cls, ahk_id %hwnd%
	Win_Recall(">" cls, hwnd, "config.ini")
	msgbox Saved under %cls%
return

OnShell(Reason, Param) {	
	static WINDOWCREATED=1, WINDOWDESTROYED=2, WINDOWACTIVATED=4, GETMINRECT=5, REDRAW=6, TASKMAN=7, APPCOMMAND=12

	if (Reason = WINDOWCREATED)  
	{ 
		WinGetClass, cls, ahk_id %Param%
		p := Win_Recall("<" cls, Param, "config.ini")
		if p != 
			m("recalled: " Param)
	} 
} 

#include Win.ahk