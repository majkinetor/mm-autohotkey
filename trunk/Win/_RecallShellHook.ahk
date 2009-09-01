#Persistent 
SetBatchLines, -1 
	if !Shell_SetHook("OnShell"){
		 msgbox Can't register hook. Aborting!
		 ExitApp
	}
	else msgbox Hook installed. `nF2 - Save active window location`nESC-Exit.
return

ESC:: ExitApp

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
			msgbox recalled:  %cls%
	} 
} 


/*
	Function:	Shell_SetHook

	Parameter:
				Handler	- Name of the function to call on shell events.

	Handler:
		Reason		- Reason for which handler is called. 
		Param		- Parameter of the handler. Parameters are given bellow for each reason.

 >	OnShell(Reason, Param) {	
 >		static WINDOWCREATED=1, WINDOWDESTROYED=2, WINDOWACTIVATED=4, GETMINRECT=5, REDRAW=6, TASKMAN=7, APPCOMMAND=12
 >	} 
		
	Param:		
		WINDOWACTIVATED	-	The HWND handle of the activated window.
		WINDOWREPLACING	-	The HWND handle of the window replacing the top-level window.
		WINDOWCREATED	-	The HWND handle of the window being created.
		WINDOWDESTROYED	-	The HWND handle of the top-level window being destroyed.		
		GETMINRECT		-	A pointer to a RECT structure.
		TASKMAN			-	Can be ignored.
		REDRAW			-	The HWND handle of the window that needs to be redrawn.

	Remarks:
		Requires explorer to be set as a shell in order to work.

	Returns:
		0 on failure, name of the previous hook procedure on success.
 */
Shell_SetHook(Handler) {
	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on
	Process, Exist
	h := WinExist("ahk_pid " ErrorLevel)
	DetectHiddenWindows, %oldDetect%

	if !DllCall("RegisterShellHookWindow", "UInt", h) 
		return 0
	return OnMessage(DllCall( "RegisterWindowMessage", "str", "SHELLHOOK") , Handler)
}

#include Win.ahk