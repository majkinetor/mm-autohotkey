/* Title:	ComboX
			Impose combobox behavior on arbitrary control.

/*
 Function:	ComboX
			Initialises control as ComboX control
 
 Parameters:
			HCtrl	- Handle of the control that is to get combobox behavior.
			Handler	- Notification function. Optional.
			Options	- space esc enter click hwnd.  By Default "esc click"
 */
ComboX_Set( HCtrl, Options="", Handler="") {
	ifEqual, Options,,SetEnv, Options, esc click

	HCtrl += 0

	Win_SetParent(HCtrl, 0, true)
	Win_Subclass(HCtrl, "ComboX_wndProc")
	Win_Show(HCtrl, false)

	RegExMatch(Options, "S)[\d]+", out)
	ComboX( HCtrl "HButton", out)
	ComboX( HCtrl "Options", Options)
	if IsFunc(Handler)
		ComboX(	HCtrl "Handler", Handler)
}

/*
 Function:	Show
			Show ComboX control. Sets ComboX_Active to currently shown control.
 
 Parameters:
			hCombo	- handle of the combox control to be shown
 */
ComboX_Show( HCtrl ) {
	ComboX("", HCtrl+0 ")handler HButton", handler, hBtn)
	if handler !=
		%handler%(HCtrl+0, "Show")	
	WinGetPos, x, y, , , ahk_id %hBtn%
	Win_Move(HCtrl, x, y)
	Win_Show(HCtrl)
	WinActivate, ahk_id %HCtrl%
}

/*
 Function:	Hide
			Hide ComboX control 
 
 Parameters:
			hCombo	- handle of the combox control to be hidden
 */
ComboX_Hide( hCombo ) {
 	Win_Show( hCombo, false )
}



ComboX_wndProc(Hwnd, UMsg, WParam, LParam){ 
	static WM_KEYDOWN = 0x100, WM_KILLFOCUS=8, WM_LBUTTONDOWN=0x201, WM_LBUTTONUP=0x202
		  ,VK_ESCAPE=27, VK_ENTER=13, VK_SPACE=32


	critical		;safe, always in new thread

	res := DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam) 

	ComboX("", Hwnd ")handler Options", handler, op)

	if (UMsg = WM_KILLFOCUS)
		ComboX_Hide(Hwnd)
	
	if (UMsg = WM_KEYDOWN)
		if (WParam = VK_ESCAPE) && InStr(op, "esc")
			ComboX_Hide(Hwnd)
		else if ((WParam = VK_ENTER) && InStr(op, "enter")) || ((WParam = VK_SPACE) && InStr(op, "space"))
			goto %A_ThisFunc%

	if (Umsg = WM_LBUTTONUP) && InStr(op, "click") 
		goto %A_ThisFunc%

	return res  

 ComboX_wndProc:
		Sleep 100
		ComboX_Hide(Hwnd)
		if handler !=
			%handler%(Hwnd, "Select")	
 return
}

;Storage
ComboX(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	if (var = "" ){
		if ( _ := InStr(value, ")") )
			__ := SubStr(value, 1, _-1), value := SubStr(value, _+1)
		loop, parse, value, %A_Space%
			_ := %__%%A_LoopField%,  o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	} else _ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}