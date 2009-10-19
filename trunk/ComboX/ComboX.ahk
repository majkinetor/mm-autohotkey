/* Title:	ComboX
			Impose combobox behavior on arbitrary control.
 *?

/*
 Function:	ComboX
			Initialises control as ComboX control
 
 Parameters:
			hCombo	- handle of the control that is to get combobox behavior
 */
ComboX( HCtrl ) {
	Win_SetParent(HCtrl)
	Win_Subclass(HCtrl, "ComboX_wndProc")
	ComboX_Hide( HCtrl )
}

/*
 Function:	Show
			Show ComboX control. Sets ComboX_Active to currently shown control.
 
 Parameters:
			hCombo	- handle of the combox control to be shown
 */
ComboX_Show( HCtrl ) {
	Win_Show(HCtrl)	;, Win_Redraw( hCombo )
 	ControlFocus, ,ahk_id %HCtrl%
}

/*
 Function:	Hide
			Hide ComboX control 
 
 Parameters:
			hCombo	- handle of the combox control to be hidden
 */
ComboX_Hide( hCombo ) {
 	Win_Hide( hCombo )
}


ComboX_wndProc(Hwnd, uMsg, wParam, lParam){ 
	res := DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam) 
	if (uMsg = 8) 
		ComboX_Hide(Hwnd), ComboX_Active := ""
	return res 
}