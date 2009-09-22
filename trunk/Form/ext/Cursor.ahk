Ext_Cursor(HCtrl, Shape) { 
	static curWndProc

	oldFormat := A_FormatInteger 
	SetFormat, Integer, D

	Form_SubClass(HCtrl, "Ext_Cursor_WndProc", "", curWndProc)
	Ext_Cursor_WndProc(0, 0, Shape, HCtrl+0)

	SetFormat, Integer, %oldFormat%
	return 1
} 

Ext_Cursor_WndProc(Hwnd, UMsg, WParam, LParam) { 
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
