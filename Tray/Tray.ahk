; Title:		Tray
;				*Tray icons controller*

;----------------------------------------------------------------------------------------------------------------------------------
; Function:		Add
;				Add new icon in the system tray
;
; Parameters:
;				hGui	- Handle of the parent window (the one that monitors notification messages)
;				fun		- Notification function.
;				ico		- Icon path or handle. Icons allocated by module will be automatically destroyed when <Remove> function
;						  returns. If the user passed icon handle, <Remove> will not destroy it.
;				txt		- Optional tooltip text
;
; Notifications:
;>				OnTray(hwnd, event)
;
;				hwnd	- Handle of the tray icon
;				event	- Tray event, see bellow.
;
; Events:
;				Notification subroutine will be called on mouse events. You can receive L,R and M events (left, right and middle button click)
;				and "Move" event on mouse move. Additionally, "u" or "d" can follow event name meaning "up" and "doubleclick".
;				For example, you will be notified on "Lu" when an user releases left mouse button.
;				
; Returns:
;				0 on failure, handle on success. This handle is used with other Tray functions.
;
Tray_Add( hGui, fun, ico, txt="") {
	local hIcon, flags, NID
	static NIF_ICON=2, NIF_MESSAGE=1, NIF_TIP=4, MM_SHELLICON=0x500
	static nidSize=88, uid=100, init

	if !init 
		OnMessage( MM_SHELLICON, "Tray_onShellIcon" ),  init := true

	hIcon := ico/ico ? ico : Tray_loadIcon(ico, 32)			;single line version of  if ico is Integer then ico else API_Load....
	flags := NIF_ICON | NIF_TIP | NIF_MESSAGE 

	VarSetCapacity( NID, nidSize, 0)
	NumPut(nidSize, NID, 0)
	NumPut(hGui,	NID, 4)
	NumPut(++uid,	NID, 8)
	NumPut(flags,   NID, 12)
	NumPut(MM_SHELLICON,   NID, 16)
	NumPut(hIcon,   NID, 20)
	DllCall("lstrcpyn", "uint", &NID+24, "uint", &txt, "int", 64)
	
	if !DllCall("shell32.dll\Shell_NotifyIconA", "uint", 0, "uint", &NID)
		return 0

	Tray_%uid%_fun := fun
	if ico is not Integer				;save icon handle allocated by Tray module so icon can be destroyed.
		Tray_%uid%_hIcon := hIcon
	return uid
}
;----------------------------------------------------------------------------------------------------------------------------------
; Function:		Modify
;				Modify icon properties
;
; Parameters:
;				hGui	- Handle of the parent window (the one that monitors notification messages)
;				hTray	- Handle of the tray icon (returned by <Add> function)
;				ico		- Icon path or handle, set to "" to skip
;				txt		- New ToolTip,  set to "-" to remove tooltip completely.
;
; Returns:
;				TRUE on success, FALSE otherwise
;
Tray_Modify( hGui, hTray, ico, txt="" ) {
	local hIcon, flags, res, NID
	static NIM_MODIFY=1
	static NIF_ICON=2, NIF_TIP=4

	VarSetCapacity( NID, 88, 0)
	NumPut(88, NID, 0)

	flags := 0
	flags |= ico != "" ? NIF_ICON : 0
	flags |= txt != "" ? NIF_TIP  : 0

	if (ico != "") {
		hIcon := ico/ico ? ico : Tray_loadIcon(ico)
	}

	if (txt != ""){
		IfEqual, txt, -, SetEnv, txt
		DllCall("lstrcpyn", "uint", &NID+24, "uint", &txt, "int", 64)
	}

	NumPut(hGui,	NID, 4)
	NumPut(hTray,	NID, 8)
	NumPut(flags,   NID, 12)
	NumPut(hIcon,   NID, 20)
	res := DllCall("shell32.dll\Shell_NotifyIconA", "uint", NIM_MODIFY, "uint", &NID)

	if ico 
	{
		DllCall("DestroyIcon", "uint", Tray_%hTray%_hIcon)
		if ico is not Integer
			Tray_%hTray%_hIcon := hIcon
	}

	return res
}

;----------------------------------------------------------------------------------------------------------------------------------
; Function:		Remove
;				Remove tray icon
;
; Parameters:
;				hGui	- Handle of the parent window
;				hTray	- Handle of the tray icon
;
; Returns:
;				TRUE on success, FALSE otherwise
;
Tray_Remove( hGui, hTray ) {
	local res, NID
	static NIM_DELETE=2, nidSize=88


	VarSetCapacity( NID, nidSize, 0)
	NumPut(nidSize, NID, 0),  NumPut(hGui,	NID, 4),   NumPut(hTray,	NID, 8)

	res := DllCall("shell32.dll\Shell_NotifyIconA", "uint", NIM_DELETE, "uint", &NID)
	
	DllCall("DestroyIcon", "uint", Tray_%hTray%_hIcon)		;function will just fail if hIcon is invalid
	return res
}


;======================================== PRIVATE ====================================

Tray_loadIcon(pPath, pW=0, pH=0){
    return  DllCall( "LoadImage", "uint", 0, "str", pPath, "uint", 2, "int", pW, "int", pH, "uint", 0x10 | 0x20)     ; LR_LOADFROMFILE | LR_TRANSPARENT
}


Tray_onShellIcon(wparam, lparam) {
	local event, fun
	static EVENT_512="Move", EVENT_513="L", EVENT_514="Lu", EVENT_515="Ld", EVENT_516="R", EVENT_517="Ru", EVENT_518="Rd", EVENT_519="M", EVENT_520="Mu", EVENT_521="Md"
	
	fun := Tray_%wparam%_fun,   event := (lparam & 0xFFFF),   event := EVENT_%event%,   %fun%(wparam, event)
}


;-------------------------------------------------------------------------------------------------------
;Group: Example
;
;>		Gui,  +LastFound
;>		hGui := WinExist()
;> 
;>		Tray_Add( hGui, "OnTrayIcon", "Tray.ico", "My Tray Icon")
;>	return
;> 
;>	OnTrayIcon(hwnd, event){
;>	  	if (event != "R")		;return if event is not right click
;>			return
;> 
;>		MsgBox Right Button clicked
;>	}


;-------------------------------------------------------------------------------------------------------
;Group: About
;	o v1.01 by majkinetor. See http://www.autohotkey.com/forum/topic26042.html
;   o Reference: <http://msdn2.microsoft.com/en-us/library/aa453686.aspx>
;	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/> 