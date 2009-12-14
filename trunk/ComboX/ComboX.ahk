/* Title:	ComboX
			Impose combobox behavior on arbitrary control.

/*
 Function:	ComboX
			Initialises control as ComboX control
 
 Parameters:
			HCtrl	- Handle of the control that is to get combobox behavior.
			Handler	- Notification function. Optional.
			Options	- Space separated list of options. See below. By Default "esc click enter".

 Options:
			space, esc, enter, click	- Specify one or more of these options to close the control on it. Space and Enter will trigger "Select" event.
			Hwnd	- Handle of the glue control. This control represents the "arrow button" in normal ComboBox control. When ComboX control is shown,
					  it will be positioned relative to the glue control.			
			PHW		- Letters specifying how control is positioned relative to the glue control. P specifies on wich corner of glue control to bind (1..4), 
					  W how width is expanded - L (left) R(right), H how height is expanded - U (up) D (down). 
					  For instance 4LD mimic standard combobox control.
 */
ComboX_Set( HCtrl, Options="", Handler="") {
	ifEqual, Options,,SetEnv, Options, esc click

	HCtrl += 0
	Win_Show(HCtrl, false)
	Win_SetParent(HCtrl, 0, true)
	Win_Subclass(HCtrl, "ComboX_wndProc")
	
	RegExMatch(Options, "S)[\d]+", out)
	ComboX( HCtrl "HButton", out)

	RegExMatch(Options, "Si)[1-4][LR][UD]", out)
	ComboX( HCtrl "Pos", out)
	ComboX( HCtrl "Options", Options)
	if IsFunc(Handler)
		ComboX(	HCtrl "Handler", Handler)
}

ComboX_setPosition( HCtrl, Pos, Hwnd ) {
	ifEqual, Pos, , SetEnv, Pos, 4LD
	StringSplit, p, Pos

	WinGetPos, x, y, w, h, ahk_id %Hwnd%
	Win_Get(HCtrl, "Rwh", cw, ch)
	cx := (p1=1 || p1=3 ? x : x + w) + (p2="R" ? 0 : -cw)
	cy := (p1=1 || p1=2 ? y : y + h) + (p3="D" ? 0 : -ch)
	Win_Move(HCtrl, cx, cy)
}

/*
 Function:	Show
			Show ComboX control. Sets ComboX_Active to currently shown control.
 
 Parameters:
			hCombo	- handle of the combox control to be shown
 */
ComboX_Show( HCtrl ) {
	HCtrl += 0
	ComboX("", HCtrl ")handler HButton Pos", handler, hBtn, Pos)
	if handler !=
		%handler%(HCtrl, "Show")	
	WinGetPos, x, y, , , ahk_id %hBtn%

	ComboX_setPosition(HCtrl, Pos, hBtn)
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