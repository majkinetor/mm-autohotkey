/* Title:    Splitter
			 Splitter control.

			 (see splitter.png)

 Dependency:
			 <Win> 1.2++
 */

/*
 Function:	Add
 			Add new Splitter.
 
 Parameters:
 			Opt	  - Splitter Gui options. Splitter is subclassed Text control (Static), so it accepts any Text options.
					plus one the following: blackframe, blackrect, grayframe, grayrect, whiteframe, whiterect, sunken.	
			Text  - Text to set.
			Handler - Notification function. Triggered when user changes the position. Accepts two parameters - control handle and new position.

 Returns:
			Splitter handle.

 Remarks:
			This function adds a new splitter on the given position. User is responsible for correct position of the splitter.
			Splitter is inactive until you call <Set> function.
			When setting dimension of the splitter (width or height) use even numbers.
			Splitter will set CoordMode, mouse, relative.

			Upon movement, splitter will reset <Attach> for the parent, if present.
 */
Splitter_Add(Opt="", Text="", Handler="") {
	static SS_NOTIFY=0x100, SS_CENTER=0x200, SS_SUNKEN=0x1000, SS_BLACKRECT=4, SS_GRAYRECT=5, SS_WHITERECT=6, SS_BLACKFRAME=7, SS_GRAYFRAM=8, SS_WHITEFRAME=9

	hStyle := 0
	loop, parse, Opt, %A_Space%
		if A_LoopField in blackframe,blackrect,grayframe,grayrect,sunken,whiteframe,whiterect,sunken,center
			hStyle |= SS_%A_LoopField%
		else Opt .= A_LoopField " "

	Gui, Add, Text, HWNDhSep -hscroll -vscroll %SS_CENTERIMAGE% %SS_NOTIFY% center %Opt% %hStyle%, %Text%	
	hSep+=0
	if IsFunc(Handler)
		Splitter(hSep "Handler", Handler)
	return hSep
}

/*
 Function:	GetPos
 			Get position of the splitter.
 */
Splitter_GetPos( HSep ) {
	return Win_GetRect(HSep, Splitter_IsVertical(HSep) ? "*x" : "*y")
}


/*
 Function:	Set
 			Initiates separation of controls.
 
 Parameters:
 			hSep - Splitter handle.
			Def	 - Splitter definition or words "off" or "on". The syntax of splitter definition is given bellow.
			Pos	 - Position of the splitter, optional.

 Splitter Defintion:
 >		c11 c12 c13 ... Type c21 c22 c23 ...
		
		c1n - Controls left or top of the splitter.
		Type - Splitter type: " | " vertical or " - " horizontal.
		c2n	- Controls right or bottom of the splitter.
							
 Returns:
		Splitter handle
 */
Splitter_Set( HSep, Def, Pos="" ) {
	static

	if Def=off
		return Win_subclass(HSep, old)
	else if Def=on
		return Win_subclass(HSep, wndProc)

	if bVert := (InStr(Def, "|") != 0)
		WinSet, Style, +0x80, ahk_id %HSep%		; SS_NOPREFIX=0x80  style used to mark vertical splitter


	Splitter_wndProc(0, bVert, Def, HSep)
	old := Win_subclass(HSep, wnadProc = "" ? "Splitter_wndProc" : wndProc, "", wndProc)

	if Pos != 
		Splitter_SetPos(HSep, Pos)
}

/*
 Function:	SetPos
 			Set position of the splitter.

 Parameters:
			Pos		- Position to set. If empty, function simply returns.

 Remarks:
			Resets <Attach> for the parent.
 */
Splitter_SetPos( HSep, Pos ) {
	static WM_LBUTTONUP := 0x202
	ifEqual, Pos, , return

	bVert := Splitter_IsVertical(HSep)
	sz := Win_GetRect(HSep, bVert ? "w" : "h") // 2
	cpos := Splitter_GetPos(HSep), delta := Pos + sz - cpos
	Splitter_wndProc(HSep, WM_LBUTTONUP, 12345, bVert ? delta : delta << 16)
}

;=============================================== PRIVATE ===============================================
;required by forms framework.
Splitter_add2Form(HParent, Txt, Opt){
	static parse = "Form_Parse"
	%parse%(Opt, "handler", handler, extra)
	DllCall("SetParent", "uint", hCtrl := Splitter_Add(extra, Txt, handler), "uint", HParent)
	return hCtrl
}

Splitter_wndProc(Hwnd, UMsg, WParam, LParam) {	
	static
	static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200, WM_LBUTTONDOWN=0x201, WM_LBUTTONUP=0x202, WM_LBUTTONDBLCLK=0x203,  SIZENS := 32645, SIZEWE := 32644

	Hwnd += 0
	if !Hwnd
		return 	hwnd := Lparam+0, %hwnd%_bVert := Umsg, %hwnd%_def := WParam, %hwnd%_cursor := DllCall("LoadCursor", "Uint", 0, "Int", UMsg ? SIZEWE : SIZENS, "Uint")

	bVert := %Hwnd%_bVert
	If (UMsg = WM_SETCURSOR)
		return 1 
	
	if (UMsg = WM_MOUSEMOVE) {
		critical 100	;always in new thread.
		DllCall("SetCursor", "uint", %Hwnd%_cursor)
		if moving 
			Splitter_updateVisual(Hwnd, bVert)
	}

	if (UMsg = WM_LBUTTONDOWN) {
		DllCall("SetCapture", "uint", Hwnd),  parent := DllCall("GetParent", "uint", Hwnd, "Uint")
		VarSetCapacity(RECT, 16), DllCall("GetWindowRect", "uint", parent, "uint", &RECT)

		sz := Win_GetRect(Hwnd, bVert ? "w" : "h") // 2
		ch := Win_Get(parent, "Nh" )				;get caption size of parent window
		ifGreater, ch, 1000, SetEnv, ch, 0			;Gui, -Caption returns large numbers here...

	  ;prevent user from going offscreen with separator
	  ; let the separator always be visible a little if it is pulled up to the edge
		NumPut( NumGet(Rect, 0) + sz-1	,RECT, 0)
		NumPut( NumGet(RECT, 4) + sz+ch ,RECT, 4)
		NumPut( NumGet(RECT, 8) - sz+4 	,RECT, 8)
		NumPut( NumGet(RECT, 12)- sz+4	,RECT, 12)

		DllCall("ClipCursor", "uint", &RECT), DllCall("SetCursor", "uint", %Hwnd%_cursor),	moving := true
	}
	if (UMsg = WM_LBUTTONUP){
		delta := bVert ? LParam & 0xFFFF : LParam >> 16
		if delta > 10000
			delta -= 0xFFFF

		DllCall("ClipCursor", "uint", 0),  DllCall("ReleaseCapture")
		moving := false, Splitter_UpdateVisual(), Splitter_move(Hwnd, delta, %Hwnd%_def, Wparam=12345)
	}

;	if (UMsg =  WM_LBUTTONDBLCLK){
;		return	; move splitter to 0 or to max
;	}

	return DllCall("CallWindowProc","uint",A_EventInfo,"uint",hwnd,"uint",uMsg,"uint",wParam,"uint",lParam)
}

;delta - offset by which to move splitter
Splitter_move(HSep, Delta, Def, manual=""){
	bVert := Splitter_IsVertical(HSep)

	Delta -= Win_GetRect(HSep,  bVert ? "*wx" : "*hy", szf, d) // 2
	parent := DllCall("GetParent", "uint", HSep, "Uint")	;prevent it from going too much positive. if that happens you can't pull it back.
	Win_Get(parent, "RwhBxyNh", pw, ph, bx, by, ch)
	ifGreater, ch, 1000, SetEnv, ch, 0		;Gui, -Caption returns large numbers here and panel too.

	min := bVert ? bx : by + ch
	max := bVert ? pw - szf - bx*2 : ph - szf - by*2 - ch		

	if (d + Delta < min)					;prevent going too much negative, if that happens controls become overlapped.
		Delta := - d

	if !manual								
		if (d + Delta > max )				;prevent going too much positive, but only if user is actually dragging it, not do it when using SetPos.
			Delta := max-d

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
					
	Win_Redraw( Win_Get(HSep, "A") )	;redrawing imediate parent was not that good.
	IsFunc(f := "Attach") ? %f%(DllCall("GetParent", "uint", HSep, "Uint")) : ""

	if (handler := Splitter(HSep "Handler")) && !manual
		%handler%(HSep, Splitter_GetPos(HSep))
}

Splitter_updateVisual( HSep="", bVert="" ) {
	static

	if !HSep
		return dc := 0
	
	MouseGetPos, mx, my
	if !dc 
	{
		ifEqual, adrDrawFocusRect,, SetEnv, adrDrawFocusRect, % DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "DrawFocusRect")
		CoordMode, mouse, relative

		root := Win_Get(hSep, "A")
		Win_Get(root, "NhB" (bVert ? "x" : "y"), ch, b)		;get caption and border size
		ifGreater, ch, 1000, SetEnv, ch, 0

		dc := DllCall("GetDC", "Uint", root, "Uint")
		Win_GetRect(HSep, "!xywh", sx, sy, sw, sh),	  sz := (bVert ? sw : sh) // 2
		VarSetCapacity(RECT, 16),  NumPut(sx, RECT), NumPut(sy, RECT, 4), NumPut(sx+sw, RECT, 8), NumPut(sy+sh, RECT, 12)
		return DllCall(adrDrawFocusRect, "uint", dc, "uint", &RECT)
	}
	DllCall(adrDrawFocusRect, "uint", dc, "uint", &RECT)
	if (bVert)
		 NumPut(mx-b-sz, RECT),	NumPut(mx-b+sz, RECT, 8)
	else NumPut(my-ch-b-sz, RECT, 4),  NumPut(my-ch-b+sz, RECT, 12)
	DllCall(adrDrawFocusRect, "uint", dc, "uint", &RECT)
}

Splitter_IsVertical(Hwnd) {
	old := A_DetectHiddenWindows
	DetectHiddenWindows, on
	WinGet, s, Style, ahk_id %Hwnd%
	DetectHiddenWindows, %old%
	return s & 0x80 
}

;storage
Splitter(Var="", Value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") {
	static
	_ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
}


#include *i Win.ahk

/* Group: Examples
 (start code)
		w := 500, h := 600, sep := 5
		w1 := w//3, w2 := w-w1 , h1 := h // 2, h2 := h // 3

		Gui, Margin, 0, 0
		Gui, Add, Edit, HWNDc11 w%w1% h%h1%
		Gui, Add, Edit, HWNDc12 w%w1% h%h1%
		hSepV := Splitter_Add( "x+0 y0 h" h " w" sep )
		Gui, Add, Monthcal, HWNDc21 w%w2% h%h2% x+0
		Gui, Add, ListView, HWNDc22 w%w2% h%h2%, c1|c2|c3
		Gui, Add, ListBox,  HWNDc23 w%w2% h%h2% , 1|2|3

		sdef = %c11% %c12% | %c21% %c22% %c23%			;vertical splitter.
		Splitter_Set( hSepV, sdef )

		Gui, show, w%w% h%h%	
	return
 (end code)
 */

/* Group: About
	o Ver 1.11 by majkinetor. 
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/>.
 */