;-----------------------------------------------------------------------------------------------
;  Title:		Extension
;				Form control extensions
;
;-----------------------------------------------------------------------------------------------


Extension_Tooltip(HCtrl, Text){
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

	Extension_subClass(HCtrl, "Extension_tooltipProc", "", tipWndProc)
	Extension_tooltipProc(0, 0, Text, HCtrl+0)

	SetFormat, Integer, %oldFormat%
	return 1
}

Extension_tooltipProc(Hwnd, UMsg, WParam, LParam){	
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
			SetTimer, %A_ThisFunc%_Hide, -%Tooltip_Hide%
	}
	
	if (umsg = WM_MOUSELEAVE){
		last =
		Tooltip,,,, %Tooltip_Num%
	}

	return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
 

 Extension_tooltipProc_Hide:
		Tooltip,,,, %Tooltip_Num%
 return
}

Extension_Cursor(HCtrl, Shape) { 
	static curWndProc

	oldFormat := A_FormatInteger 
	SetFormat, Integer, D

	Extension_SubClass(HCtrl, "Extension_cursorProc", "", curWndProc)
	Extension_cursorProc(0, 0, Shape, HCtrl+0)

	SetFormat, Integer, %oldFormat%
	return 1
} 

Extension_cursorProc(Hwnd, UMsg, WParam, LParam) { 
	static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200 
	static APPSTARTING := 32650, HAND := 32649 ,ARROW := 32512,CROSS := 32515 ,IBEAM := 32513 ,NO := 32648,SIZE := 32646 ,SIZENESW := 32643 ,SIZENS := 32645 ,SIZENWSE := 32642 ,SIZEWE := 32644 ,UPARROW := 32516, WAIT := 32514, SIZEWE_BIG := 32653, SIZEALL_BIG := 32654, SIZEN_BIG := 32655, SIZES_BIG := 32656, SIZEW_BIG := 32657, SIZEE_BIG := 32658, SIZENW_BIG := 32659, SIZENE_BIG := 32660, SIZESW_BIG := 32661, SIZESE_BIG := 32662
	static cursor, ctrls="`n", init 

	if !hwnd  {
		if WParam is not Integer
		{
			ext := SubStr(WParam, -2, 3)
			if ext in cur,ani
				 cursor := DllCall("LoadCursorFromFile", "Str", WParam) 
			else cursor := DllCall("LoadCursor", "Uint", 0, "Int", %WParam%, "Uint") 
			ifEqual, cursor, 0, return A_ThisFunc ">   Can't load cursor: " WParam
		}
		ctrls .= LParam "=" cursor "`n" 
		return 1
	}

   If (UMsg = WM_SETCURSOR) 
      return 1 

   if (UMsg = WM_MOUSEMOVE) 
      If j := InStr(ctrls, "`n" Hwnd) 
         hover := true,  j += 2+StrLen(Hwnd),   j := SubStr(ctrls, j, InStr(ctrls, "`n", 0, j)-j+1), DllCall("SetCursor", "uint",j) 

   return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
} 



Extension_Image(HBtn, Parameters){ 
    static BM_SETIMAGE=247, IMAGE_ICON=2, BS_ICON=0x40 
	static param_1 := "Image", param_2 := "Size"
	loop, parse, Parameters, `n
		_ := param_%A_Index%, %_% := A_LoopField

	WinGetClass, cls, ahk_id %HBtn%
	ifNotEqual, cls, Button, return 0
		

	if Image is not integer 
    { 
        j := InStr(Image, ":", 0, 0), idx := 1 
        if j > 2  
            idx := Substr( Image, j+1), pPath := SubStr( Image, 1, j-1) 
        DllCall("PrivateExtractIcons","str",pPath,"int",idx-1,"int",Size,"int",Size,"uint*",hIco,"uint*",0,"uint",1,"uint",0,"int") 
        ifEqual, hIco, 0, return A_ThisFunc ">   Can't load image: " Image 

	} else hIco := Image 
    
    WinSet, Style, +%BS_ICON%, ahk_id %hBtn%
    SendMessage, BM_SETIMAGE, IMAGE_ICON, hIco, , ahk_id %hBtn% 
    if ErrorLevel 
        DllCall("DeleteObject", "UInt", ErrorLevel) 
		
    return hIco 
}


Extension_subclass(hCtrl, Fun, Opt="", ByRef $WndProc="") { 
	if Fun is not integer
	{
		 oldProc := DllCall("GetWindowLong", "uint", hCtrl, "uint", -4) 
		 ifEqual, oldProc, 0, return 0 
		 $WndProc := RegisterCallback(Fun, Opt, 4, oldProc) 
		 ifEqual, $WndProc, , return 0
	}
	else $WndProc := Fun
	   
    return DllCall("SetWindowLong", "UInt", hCtrl, "Int", -4, "Int", $WndProc, "UInt")
}