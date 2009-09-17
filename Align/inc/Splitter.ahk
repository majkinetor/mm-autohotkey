/* Title:    Splitter
			*Implementation of the Splitter control*
 :
			Both Windows and AHK don't have splitter control. 
			With this module you can add splitters to your GUIs. 
			
			(see splitter.gif)

 Dependency:
			Win 1.2
 */

/*
 Function:	Add
 			Add new Splitter.
 
 Parameters:
 			Opt	  - Splitter Gui options. Splitter is subclassed Text control (Static), so it accepts any Text options.
					plus one the following: blackframe, blackrect, grayframe, grayrect, whiteframe, whiterect, sunken.
			Text  - Text or picture to set.

 Returns:
			Splitter handle.

 Remarks:
			This function adds a new splitter on the given position. User is responsible for correct position of the splitter.
			Splitter is inactive until you call <Set> function.

 */
Splitter_Add(Opt="", Text="") {
	static SS_NOTIFY=0x100, SS_CENTERIMAGE=0x200, SS_SUNKEN=0x1000, SS_BLACKRECT=4, SS_GRAYRECT=5, SS_WHITERECT=6, SS_BLACKFRAME=7, SS_GRAYFRAM=8, SS_WHITEFRAME=9

	hStyle := 0
	loop, parse, Opt, %A_Space%
		if A_LoopField in blackframe,blackrect,grayframe,grayrect,sunken,whiteframe,whiterect
			hStyle |= SS_%A_LoopField%
		else Opt .= A_LoopField " "

	Gui, Add, Text, HWNDhSep -hscroll -vscroll %SS_CENTERIMAGE% %SS_NOTIFY% center %Opt% %hStyle%, %Text%	
	return hSep
}

/*
 Function:	Set
 			Initiates separation of controls.
 
 Parameters:
 			hSep - Splitter handle.
			Def	 - Splitter definition or words "off" or "on". The syntax of splitter definition is:

 >		c11 c12 c13 ... Type c21 c22 c23 ...
		
		c1n - Controls left or top of the splitter.
		Type - Splitter type: " | " vertical or " - " horizontal.
		c2n	- Controls right or bottom of the splitter.
							
 Returns:
		Splitter handle
 */
Splitter_Set( HSep, Def ) {
	static

	if Def=off
		return Win_subclass(HSep, old)
	else if Def=on
		return Win_subclass(HSep, wndProc)

	if bVert := InStr(Def, "|") != 0
		WinSet, Style, +0x80, ahk_id %HSep%		; SS_NOPREFIX=0x80  style used to mark vertical splitter

	Splitter_wndProc(0, bVert, Def, HSep)
	old := Win_subclass(HSep, wnadProc = "" ? "Splitter_wndProc" : wndProc, "", wndProc)
}

Splitter_wndProc(Hwnd, UMsg, WParam, LParam) {	
	static
	static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200, WM_LBUTTONDOWN=0x201, WM_LBUTTONUP=0x202, WM_LBUTTONDBLCLK=0x203,  SIZENS := 32645, SIZEWE := 32644

	critical 100
	if !Hwnd
		return 	hwnd := Lparam+0, %hwnd%_bVert := Umsg, %hwnd%_def := WParam, %hwnd%_cursor := DllCall("LoadCursor", "Uint", 0, "Int", Umsg="hor" ? SIZENS : SIZEWE, "Uint")	

	bVert := %Hwnd%_bVert
	If (UMsg = WM_SETCURSOR)
		return 1 
	
	if (UMsg = WM_MOUSEMOVE) {
		DllCall("SetCursor", "uint", %Hwnd%_cursor)
		if moving 
			Splitter_updateVisual(Hwnd, bVert)
	}

	if (UMsg = WM_LBUTTONDOWN) {
		DllCall("SetCapture", "uint", Hwnd), parent := DllCall("GetParent", "uint", Hwnd, "Uint")
		VarSetCapacity(RECT, 16), DllCall("GetWindowRect", "uint", parent, "uint", &RECT)

		sz := Win_GetRect(Hwnd, bVert ? "w" : "h") // 2
		ch := Win_Get(parent, "Nh" )				;get caption size of parent window
		ifGreater, ch, 1000, SetEnv, ch, 0			;Gui, -Caption returns large numbers here...

	  ;prevent user from going offscreen with separator
	  ; let the separator always be visible a little if it is pulled up to the edge
		NumPut( NumGet(Rect, 0) + sz	,RECT, 0)
		NumPut( NumGet(RECT, 4) + sz+ch ,RECT, 4)
		NumPut( NumGet(RECT, 8) - sz	,RECT, 8)
		NumPut( NumGet(RECT, 12)- sz	,RECT, 12)

		DllCall("ClipCursor", "uint", &RECT), DllCall("SetCursor", "uint", %Hwnd%_cursor),	moving := true
	}
	if (UMsg = WM_LBUTTONUP){
		delta := bVert ? LParam & 0xFFFF : LParam >> 16
		if delta > 10000
			delta -= 0xFFFF
		
		DllCall("ClipCursor", "uint", 0),  DllCall("ReleaseCapture"), DllCall("SetCursor", "uint", cursor)
		moving := false, Splitter_UpdateVisual(), Splitter_move(Hwnd, delta, %Hwnd%_def)
	}

	if (UMsg =  WM_LBUTTONDBLCLK){
		return	; move splitter to 0 or to max
	}

	return DllCall("CallWindowProc","uint",A_EventInfo,"uint",hwnd,"uint",uMsg,"uint",wParam,"uint",lParam)
}

Splitter_move(HSep, Delta, Def){
	WinGet, s, Style, ahk_id %HSep%
	bVert := s & 0x80

	Delta -= Win_GetRect(HSep,  bVert ? "*wx" : "*hy", _, d) // 2
	if (d + Delta < 0)		;prevent splitter from going negative, if that happens controls become overlapped.
		Delta := -d

	j := InStr(Def, "|") or InStr(Def, "-")
	StringSplit, s, Def, %A_Space%
	
	v := bVert ? Delta : 0,	  h := bVert ? 0 : Delta
	loop, %s0%
	{
		s := s%A_Index%
		if !otherSide
		{
			Win_MoveDelta(s, "", "", v, h)
			if s in |,-
				otherSide := true, Win_MoveDelta(HSep, v, h)
		} else 	Win_MoveDelta(s, v, h, -v, -h)
	}		
					
	Win_Redraw( Win_Get(HSep, "A") )
	IsFunc(f := "Attach") ? %f%(DllCall("GetParent", "uint", HSep, "Uint")) : 
}

Splitter_updateVisual( HSep="", bVert="" ) {
	static sz, dc, RECT, parent, adrDrawFocusRect, ch, b

	if !HSep
		return dc := 0
	
	MouseGetPos, mx, my
	if !dc
	{
		CoordMode, mouse, relative
		adrDrawFocusRect := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "DrawFocusRect")
		parent := DllCall("GetParent", "uint", HSep)
		
		Win_Get(parent, "NhB" (bVert ? "x" : "y"), ch, b)		;get caption and border size
	
		ifGreater, ch, 1000, SetEnv, ch, 0
		dc := DllCall("GetDC", "uint", parent)

		VarSetCapacity(RECT, 16), 	DllCall("GetClientRect", "uint", HSep, "uint", &RECT)
		sz := Win_GetRect(HSep, bVert ? "w" : "h") // 2

;		my -= ch
		if (bVert)
			 NumPut(mx-b-sz, RECT, 0),	NumPut(mx-b+sz, RECT, 8)
		else NumPut(my-b-sz, RECT, 4),	NumPut(my-b+sz, RECT, 12)

		DllCall(adrDrawFocusRect, "uint", dc, "uint", &RECT)	
		return
	}
	DllCall(adrDrawFocusRect, "uint", dc, "uint", &RECT)
;	my -= ch
	if (bVert)
		 NumPut(mx-b-sz, RECT, 0),  NumPut(mx-b+sz, RECT, 8)
	else NumPut(my-b-sz, RECT, 4),  NumPut(my-b+sz, RECT, 12)

	DllCall(adrDrawFocusRect, "uint", dc, "uint", &RECT)
}

#include Win.ahk

/* Group: Example
 (start code)
		w := 500, h := 600, sep := 5
		w1 := w//3, w2 := w-w1 , h1 := h // 2, h2 := h // 3

		gui, margin, 0, 0
		gui, add, edit, HWNDc11 w%w1% h%h1%
		gui, add, edit, HWNDc12 w%w1% h%h1%
		hSepV := Splitter_Add( "x+0 y0 h" h " w" sep )
		gui, add, monthcal, HWNDc21 w%w2% h%h2% x+0
		gui, add, ListView, HWNDc22 w%w2% h%h2%, c1|c2|c3
		gui, add, ListBox, HWNDc23 w%w2% h%h2% , 1|2|3

		sdef = %c11% %c12% | %c21% %c22% %c23%			;vertical splitter.
		Splitter_Set( hSepV, sdef )

		gui, show, w%w% h%h%	
	return

	#include Splitter.ahk
 (end code)
 */

/* Group: About
	o Ver 1.0b by majkinetor. 
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/> 
 */