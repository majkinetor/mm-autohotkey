/* Group: Cursor
          Set cursor shape for control or window.
 
 Parameters: 
			HCtrl	- Contorls handle.
            Shape   - Name of the system cursor to set or cursor handle or full cursor path (must have .ani or .cur extension).

 System Cursors: 
      appstarting  - Standard arrow and small hourglass.
      arrow        - Standard arrow.
      cross        - Crosshair.
      hand         - Hand.
      help         - Arrow and question mark.
      ibeam        - I-beam.
      icon         - Obsolete for applications marked version 4.0 or later. 
      no           - Slashed circle.
      size         - Obsolete for applications marked version 4.0 or later. Use IDC_SIZEALL.
      sizeall      - Four-pointed arrow pointing north, south, east, and west.
      sizenesw     - Double-pointed arrow pointing northeast and southwest.
      sizens       - Double-pointed arrow pointing north and south.
      sizenwse     - Double-pointed arrow pointing northwest and southeast.
      sizewe       - Double-pointed arrow pointing west and east.
      uparrow      - Vertical arrow.
      wait         - Hourglass.
      sizewe_big   - Big double-pointed arrow pointing west and east.
      sizeall_big  - Big four-pointed arrow pointing north, south, east, and west.
      sizen_big    - Big arrow pointing north.
      sizes_big    - Big arrow pointing south.
      sizew_big    - Big arrow pointing west.
      sizee_big    - Big arrow pointing east.
      sizenw_big   - Big double-pointed arrow pointing north and west.
      sizene_big   - Big double-pointed arrow pointing north and east.
      sizesw_big   - Big double-pointed arrow pointing south and west.
      sizese_big   - Big double-pointed arrow pointing south and east.

 About:
	o 1.2 by majkinetor
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/> 
 */
Ext_Cursor(HCtrl, Shape) { 
	static adrWndProc = "Ext_Cursor_wndProc"

	Form_SubClass(HCtrl, adrWndProc, "", adrWndProc)
	return Ext_Cursor_WndProc(0, 0, Shape, HCtrl)
} 

Ext_Cursor_wndProc(Hwnd, UMsg, WParam, LParam) { 
	static 
	static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200
	static APPSTARTING := 32650, HAND := 32649 ,ARROW := 32512,CROSS := 32515 ,IBEAM := 32513 ,NO := 32648,SIZE := 32646 ,SIZENESW := 32643 ,SIZENS := 32645 ,SIZENWSE := 32642 ,SIZEWE := 32644 ,UPARROW := 32516, WAIT := 32514, SIZEWE_BIG := 32653, SIZEALL_BIG := 32654, SIZEN_BIG := 32655, SIZES_BIG := 32656, SIZEW_BIG := 32657, SIZEE_BIG := 32658, SIZENW_BIG := 32659, SIZENE_BIG := 32660, SIZESW_BIG := 32661, SIZESE_BIG := 32662
	
	if !Hwnd  {
		if WParam is not Integer
		{
			ext := SubStr(WParam, -2, 3)
			if ext in cur,ani
			 	 %LParam% := DllCall("LoadCursorFromFile", "Str", WParam) 
			else %LParam% := DllCall("LoadCursor", "Uint", 0, "Int", %WParam%, "Uint") 		
		} else %LParam% := %WParam%
		
		curArrow .= curArrow ? "" : DllCall("LoadCursor", "Uint", 0, "Int", 32512, "Uint")
		return (%LParam%)
	}

   If (UMsg = WM_SETCURSOR) 
      return 1 

   if (UMsg = WM_MOUSEMOVE) 
      If (%Hwnd% != "")
			DllCall("SetCursor", "uint", %Hwnd%)
	  else  DllCall("SetCursor", "uint", curArrow)
   return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
} 
