Ext_Tooltip(HCtrl, Text){
	local cls, oldFormat, tipWndProc
	static SS_NOTIFY=0x100

	oldFormat := A_FormatInteger
	SetFormat, Integer, D

	ifEqual, Tooltip_Show,, SetEnv, Tooltip_Show, 800
	ifEqual, Tooltip_Num,,  SetEnv, Tooltip_Num, 13

	WinGetClass, cls, ahk_id %HCtrl%
	if cls = Static
		WinSet, Style, +%SS_NOTIFY%, ahk_id %HCtrl%		;static control doesn't report WM_MOUSEMOVE without this flag.
	else if cls = ComboBox
		ControlGet, HCtrl, HWND,,Edit1, ahk_id %HCtrl%	; while in combo, it happens in edit owned by the combo

	Form_SubClass(HCtrl, "Ext_Tooltip_WndProc", "", tipWndProc)
	Ext_Tooltip_WndProc(0, 0, Text, HCtrl+0)

	SetFormat, Integer, %oldFormat%
	return 1
}

Ext_Tooltip_WndProc(Hwnd, UMsg, WParam, LParam){	
	local TME, j
	static WM_MOUSEHOVER = 0x2A1, WM_MOUSELEAVE = 0x2A3, WM_MOUSEMOVE = 0x200, TM_HOVERLEAVE=3, last
	static tips = "`r"

	if !hwnd {
		tips .= LParam " " WParam "`r"
		return
	}

	if (UMsg = WM_MOUSEMOVE) and (last != Hwnd) 
		VarSetCapacity(TME, 16)
		 ,NumPut(16,			TME, 0)
		 ,NumPut(TM_HOVERLEAVE, TME, 4)  
		 ,NumPut(Hwnd,			TME, 8)
		 ,NumPut(Tooltip_Show,  TME, 12) 
		 ,DllCall("TrackMouseEvent", "uint", &TME),   last := Hwnd

	if (umsg = WM_MOUSEHOVER) 
	{
		j := InStr(tips, "`r" Hwnd), TME := SubStr(tips, j+1, InStr(tips, "`r", 0, j+1)-j-1), TME := SubStr(TME, InStr(TME, " ")+1)
		Tooltip, %TME%,,,%Tooltip_Num%
		if Tooltip_Hide
			SetTimer, %A_ThisFunc%, -%Tooltip_Hide%
	}
	
	if (umsg = WM_MOUSELEAVE){
		last =
		Tooltip,,,, %Tooltip_Num%
	}

	return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
 

 Ext_Tooltip_WndProc:
		Tooltip,,,, %Tooltip_Num%
 return
}
