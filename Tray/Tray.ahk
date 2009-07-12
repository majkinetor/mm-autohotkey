/* Title:		Tray
				*Tray icon controller*
 */

/*Function:		Add
 				Add icon in the system tray.
 
  Parameters:
 				hGui	- Handle of the parent window (the one that monitors notification messages)
 				Handler	- Notification handler.
 				Icon	- Icon path or handle. Icons allocated by module will be automatically destroyed when <Remove> function
 						  returns. If you pass icon handle, <Remove> will not destroy it. If path is an icon resource, you can 
						  use "path:idx" notation to get the handle of the desired icon by its resource index (0 based).
 				Tooltip	- Tooltip text.
 
  Notifications:
 >				Handler(Hwnd, Event)
 
 				Hwnd	- Handle of the tray icon.
 				Event	- L (Left click),R(Right click), M (Middle click), P (Position - mouse move).
		 				  CAdditionally, "u" or "d" can follow event name meaning "up" and "doubleclick".
 						  For example, you will be notified on "Lu" when user releases the left mouse button.
 				
  Returns:
 				0 on failure, handle on success.
 */
Tray_Add( hGui, Handler, Icon, Tooltip="") {
	static NIF_ICON=2, NIF_MESSAGE=1, NIF_TIP=4, MM_SHELLICON := 0x500
	static uid=100, hFlags

	if !hFlags
		OnMessage( MM_SHELLICON, "Tray_onShellIcon" ), hFlags := NIF_ICON | NIF_TIP | NIF_MESSAGE 

	if !IsFunc(Handler)
		return A_ThisFunc "> Invalid handler: " Handler

	hIcon := Icon/Icon ? Icon : Tray_loadIcon(Icon, 32)

	VarSetCapacity( NID, 88, 0) 
	 ,NumPut(88,	NID)
	 ,NumPut(hGui,	NID, 4)
	 ,NumPut(++uid,	NID, 8)
	 ,NumPut(hFlags, NID, 12)
	 ,NumPut(MM_SHELLICON, NID, 16)
	 ,NumPut(hIcon, NID, 20)
	 ,DllCall("lstrcpyn", "uint", &NID+24, "str", Tooltip, "int", 64)
	
	if !DllCall("shell32.dll\Shell_NotifyIconA", "uint", 0, "uint", &NID)
		return 0

	Tray( uid "handler", Handler)
	Icon/Icon ? Tray( uid "hIcon", hIcon) :		;save icon handle allocated by Tray module so icon can be destroyed.
	return uid
}

/*	Function:	Modify
				Modify icon properties.

	Parameters:
				hGui	- Handle of the parent window (the one that monitors notification messages).
				hTray	- Handle of the tray icon (returned by <Add> function)
				Icon	- Icon path or handle, set to "" to skip.
				Tooltip	- ToolTip text, omit to keep the current tooltip.

	Returns:
				TRUE on success, FALSE otherwise.
 */
Tray_Modify( hGui, hTray, Icon, Tooltip="~`a " ) {
	static NIM_MODIFY=1, NIF_ICON=2, NIF_TIP=4

	VarSetCapacity( NID, 88, 0)
	NumPut(88, NID, 0)

	hFlags := 0
	Icon != "" ? hFlags |= NIF_ICON :
	Tooltip != "" ? hFlags |= NIF_TIP :

	if (Icon != "") {
		hIcon := Icon/Icon ? Icon : Tray_loadIcon(Icon)
		DllCall("DestroyIcon", "uint", Tray( hTray "hIcon", "") )
		Icon/Icon ? Tray( hTray "hIcon", hIcon) :
	}

	if (Tooltip != "~`a ")
		DllCall("lstrcpyn", "uint", &NID+24, "str", Tooltip, "int", 64)


	NumPut(hGui,	  NID, 4)
	 ,NumPut(hTray,	  NID, 8)
	 ,NumPut(hFlags,  NID, 12)
	 ,NumPut(hIcon,   NID, 20)
	return DllCall("shell32.dll\Shell_NotifyIconA", "uint", NIM_MODIFY, "uint", &NID)	
}

/* Function:	Remove
 				Remove the tray icon.
 
  Parameters:
 				hGui	- Handle of the parent window.
 				hTray	- Handle of the tray icon. If omited, all icons will be removed.
 
  Returns:
 				TRUE on success, FALSE otherwise.
 */
Tray_Remove( hGui, hTray) {
	static NIM_DELETE=2
	
	VarSetCapacity( NID, 88, 0), NumPut(88, NID),  NumPut(hGui, NID, 4)

	NumPut(hTray, NID, 8)
	if hIcon := Tray(hTray "hIcon", "")
		DllCall("DestroyIcon", "uint", hIcon)
	return DllCall("shell32.dll\Shell_NotifyIconA", "uint", NIM_DELETE, "uint", &NID)
}

/* Function:	Refresh
 				Refresh tray icons.
 
 */
Tray_Refresh(){ 
	static WM_MOUSEMOVE = 0x200

	ControlGetPos,,,w,h,ToolbarWindow321, AHK_class Shell_TrayWnd 
	width:=w, hight:=h 
	while % ((h:=h-5)>0 and w:=width)
		while % ((w:=w-5)>0)
			PostMessage, WM_MOUSEMOVE,0,% ((hight-h) >> 16)+width-w,ToolbarWindow321, AHK_class Shell_TrayWnd 
}

;======================================== PRIVATE ====================================

Tray_loadIcon(pPath, pSize=32){
	j := InStr(pPath, ":", 0, 0), idx := 0
	if j > 2
		idx := Substr( pPath, j+1), pPath := SubStr( pPath, 1, j-1)

	DllCall("PrivateExtractIcons"
            ,"str",pPath,"int",idx,"int",pSize,"int", pSize
            ,"uint*",hIcon,"uint*",0,"uint",1,"uint",0,"int")

	return hIcon
}



Tray_onShellIcon(Wparam, Lparam) {
	static EVENT_512="P", EVENT_513="L", EVENT_514="Lu", EVENT_515="Ld", EVENT_516="R", EVENT_517="Ru", EVENT_518="Rd", EVENT_519="M", EVENT_520="Mu", EVENT_521="Md"

	handler := Tray(Wparam "handler")
	 ,event := (Lparam & 0xFFFF)  
	 ,%handler%(Wparam, EVENT_%event%)
}


;storage
Tray(var="", value="~`a ") { 
	static
	_ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
}


/* Group: Example
 (start code)
		Gui,  +LastFound
		hGui := WinExist()
 
		Tray_Add( hGui, "OnTrayIcon", "Tray.ico", "My Tray Icon")
	return
 
	OnTrayIcon(hCtrl, Event){
	  	if (Event != "R")		;return if event is not right click
			return
 
		MsgBox Right Button clicked
	}
 (end code)
*/

/* Group: About
	o v2.0 by majkinetor. See http://www.autohotkey.com/forum/topic26042.html
	o Tray_Refresh by HotKeyIt
	o Reference: <http://msdn2.microsoft.com/en-us/library/aa453686.aspx>
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/> 
 */