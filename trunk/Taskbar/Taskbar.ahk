/* Title:		Taskbar
				*Taskbar monitor and controller*
 :
				Using this module you can monitor and controll Windows taskbar. 
				Your script can get information about windows currently displayed in Taskbar
				as well as hide, delete or move its buttons.
 */

/* Function:	Define
 				Get information about toolbar buttons.
 
  Parameters:
				Filter  - Contains process name, ahk_pid, ahk_id or 1-based position for which to return information.
						  If you specify position as Filter, you can use output variables to store information since only 1 item
						  will be returned in that case. If you omit this parameter, information about all buttons will be returned.
				pQ		- Query parameter, by default "iwt".
				o1..o4  - Reference to output variables.

  Query:
				h	- Handle.
				i	- PosItion (1 based).
				w	- Parent Window handle.
				p	- Process Pid.
				n	- Process Name.
				o	- IcOn handle.
 
  Returns:
				String containing icon information per line. 
 */
Taskbar_Define(Filter="", pQ="", ByRef o1="~`a ", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6=""){
	static TB_BUTTONCOUNT = 0x418, TB_GETBUTTON=0x417, sep="|"
	ifEqual, pQ,, SetEnv, pQ, iwt

	if Filter is integer
		 bPos := Filter
	else if Filter contains ahk_pid,ahk_id
		 bPid := InStr(Filter, "ahk_pid"),  bID := !bPid,  Filter := SubStr(Filter, 8)
	else bName := true

	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on

	WinGet,	pidTaskbar, PID, ahk_class Shell_TrayWnd
	hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc := DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	hctrl := Taskbar_getTaskBar()
	SendMessage,TB_BUTTONCOUNT,,,, ahk_id %hctrl%
	
	i := bPos ? bPos-1 : 0
	cnt := bPos ?  1 : ErrorLevel
	Loop, %cnt%
	{
		i++
		SendMessage, TB_GETBUTTON, i-1, pProc,, ahk_id %hctrl%

		VarSetCapacity(BTN,32), DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &BTN, "Uint", 32, "Uint", 0)
		if !(dwData := NumGet(BTN,12))
			dwData := NumGet(BTN,16,"int64")
		
		h := NumGet(BTN, 4)

		VarSetCapacity(NFO,32), DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &NFO, "Uint", 32, "Uint", 0)
		if NumGet(BTN,12)
			 w := NumGet(NFO, 0),		   o := NumGet(NFO, 20)
		else w := NumGet(NFO, 0, "int64"), o := NumGet(NFO, 24)
		ifEqual, w, 0, continue

		WinGet, n, ProcessName, ahk_id %w%
		WinGet, p, PID, ahk_id %w%
		WinGetTitle, t, ahk_id %w%
		
		if !Filter || bPos || (bName && Filter=n) || (bPid && Filter=p) || (bId && Filter=w) {
			loop, parse, pQ
				f := A_LoopField, res .= %f% sep
			res := SubStr(res, 1, -1) "`n"		
		}
	}
	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000), DllCall("CloseHandle", "Uint", hProc)
	
	if (bPos)
		loop, parse, pQ
			o%A_Index% := %A_LoopField%

	DetectHiddenWindows, %oldDetect%
	return SubStr(res, 1, -1)
}

/*  
 Function:	Hide
 			Hide Toolbar button.
 
 Parameters:
 			Position	- Position of the button.
			bHide		- Set to TRUE (default) to hide button. FALSE will show it again.
 
 Returns:
			TRUE if successful, or FALSE otherwise. 	
 */

Taskbar_Hide(Handle, bHide=True){
	static TB_HIDEBUTTON=0x404
	h := Taskbar_getTaskBar()
	SendMessage, TB_HIDEBUTTON, Handle, bHide,,ahk_id %h%
	return ErrorLevel
}

/*  
 Function:	Move
 			Move Toolbar button.
 
 Parameters:
 			Pos		- 1-based postion of the button to be moved.
 			NewPos	- 1-based postion where the button will be moved.
 
 Returns:
			TRUE indicates success. FALSE indicates failure. 
 */
Taskbar_Move(Pos, NewPos){
	static TB_MOVEBUTTON=0x452
	h := Taskbar_getTaskBar()
	SendMessage, TB_MOVEBUTTON,Pos, NewPos,, ahk_id %h%
	return ErrorLevel
}

/*  
 Function:	Remove
 			Remove Toolbar button.
 
 Parameters:
 			Position	- Position of the button.
 
 Returns:
			TRUE indicates success. FALSE indicates failure. 	
 */

Taskbar_Remove(Position){
	static TB_DELETEBUTTON=0x416
	h := Taskbar_getTaskBar()
	SendMessage, TB_DELETEBUTTON,Position-1,,,ahk_id %h%
	return ErrorLevel
}



Taskbar_getTaskBar(){
	ControlGet, hParent, HWND,,MSTaskSwWClass1, ahk_class Shell_TrayWnd
	ControlGet, h, HWND,, ToolbarWindow321, ahk_id %hParent%
	return h
}

/* Group: About
	o v1.0 by majkinetor.
	o Original code by Sean. See <http://www.autohotkey.com/forum/topic18652.html>.
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/> .
 */