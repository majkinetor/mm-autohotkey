/*
	Title:		ScrollBar
				Scroll Bar control.
*/

/*
 Function:		Add
				Creates scroll bar control.

 Parameters:	
				HParent		- Handle of the parent window
				X..H		- Position. You can set width|height to -1 to use system's default for vertical|horizontal scroll bar.
							  To glue scroll bar to another GUI control, specify control's associated variable as the x parameter; 
							  You can also refer to a control via its handle - use "* hwnd" as x parameter.
							  In glue mode, y parameter is ignored; w is ignored for horizontal, and h for vertical scroll bar.
				Handler		- Subroutine that will receive ScrollBar_HWND & ScrollBar_POS global variables.
							  This routine will be called when user change scroll bar position via its UI.
				o1..o5		- Optional parameters.

 Optional parameters:
				style		- "hor" (defualt) or "ver"
				min, max	- range, by default 0, 100
				pos			- initial position of the slider, by deafult 0
				page		- page, by default 10

 Returns:
				Handle of the control, error message if control can not be created.

 Example:
 				hHBar := ScrollBar_Add(hwnd, 0, 0, 280, -1, "OnScroll", "style=ver", "min=1", "max=100", "page=10", "pos=10")
				ScrollBar_Add(hwnd, "myEdit", 0, 0, 0, "OnScroll")		;glue to the myEdit GUI control
 */
ScrollBar_Add(HParent, x, y, w, h, fun, o1="", o2="", o3="", o4="", o5="") {
	local style := "hor", min := 0, max := 100, page := 10, pos := 0, hGlue, hCtrl, j, prop, cx, cy, cw, ch, dx, dy
	static init=0, WM_HSCROLL := 0x114, WM_VSCROLL := 0x115, vThumb, hThumb
	 
	if (!init++) {
		OnMessage(WM_HSCROLL, "ScrollBar_onScroll"), OnMessage(WM_VSCROLL, "ScrollBar_onScroll") ;!!! old funs
		SysGet, hThumb, 10
		SysGet, vThumb, 9
	}

	loop, 5 { 
		if !o%A_index% 
			continue 
		j := InStr( o%A_index%, "=" ),   prop := SubStr( o%A_index%, 1, j-1 ),   %prop% := SubStr( o%A_index%, j+1, 100) 
	}

	if x is not Integer
	{
		if SubStr(x,1,1) = "*"
		{
			hGlue := SubStr(x,2)
			if !DllCall("IsWindow", "uint", hGlue)
				return "Err: Invalid glue control - " hGlue
		} else GuiControlGet, hGlue, Hwnd, %x%

		ControlGetPos, cx,cy,cw,ch,, ahk_id %hGlue%
		SysGet, dy, 31
		SysGet, dx, 5
		cy -=dy+2, cx-=dx+2
		if (style="ver")
			  x := cx + cw, y := cy, w := w ? w:-1, h := ch
		else  x := cx, y := cy + ch, w :=cw, h := h ? h:-1
	}

	if (style="ver") {
		 IfEqual, w, -1, SetEnv, w, %vThumb%
	}
	else IfEqual, h, -1, SetEnv, h, %hThumb%


	style := style = "ver" ? 1 : 0
	hCtrl := DllCall("CreateWindowEx"
      , "Uint", 0
      , "str",  "SCROLLBAR"      
      , "str",  ""   
      , "Uint", 0x40000000 	| 0x10000000 | style
      , "int",  x			; Left
      , "int",  y           ; Top
      , "int",  w           ; Width
      , "int",  h		    ; Height
      , "Uint", hGui	    ; hWndParent
      , "Uint", 0           ; hMenu
      , "Uint", 0           ; hInstance
      , "Uint", 0, "Uint")
	if !hCtrl  
		return "Err: Control creation failed"
	
	if !IsLabel(fun)
		return "Err: Invalid label"
	
	ScrollBar_%hCtrl%_fun := fun

	ScrollBar_Set(hCtrl, pos, min, max, page) 
	return hCtrl
}

/*
 Function:		Get
				Get scroll bar parameter

 Parameters:	
				hCtrl		- Handle of the scroll bar control
				info		- Optional string describing wich parameter function returns. It can be 
							  "pos", "page", "min", "max", "track"

 Returns:
				If info parameter is omited current position, else, the requested parameter.
				-1 on failure
*/
ScrollBar_Get(hCtrl, info="pos") {
	static SIF_RANGE=1, SIF_PAGE=2, SIF_POS=4, SB_CTL=2, SIF_TRACKPOS=0x10

	fMask := SIF_POS
	if (info = "page")
		 fMask := SIF_PAGE 
	else if (info = "min") or (info="max")
		 fMask := SIF_RANGE
	else if (info = "track") 
		 fMask := SIF_TRACKPOS

	VarSetCapacity(SINFO, 28, 0), 
	NumPut(28,		SINFO, 0)	;cbSize	
	NumPut(fMask,	SINFO, 4)	;fMask
	r := DllCall("GetScrollInfo", "uint", hCtrl, "int", SB_CTL, "uint", &SINFO)
	if r = 0 
		return -1

	if (info = "pos")
		return NumGet(SINFO, 20)
	if (info = "page")
		return NumGet(SINFO, 16)
	if (info = "min")
		return NumGet(SINFO, 8)
	if (info = "max")
		return NumGet(SINFO, 12)
	if (info = "track")
		return NumGet(SINFO, 24)
}
/*
 Function:		Set
				Set scroll bar parameters

 Parameters:	
				hCtrl		- Handle of the scroll bar control
				nPos		- Set position, by default 0
				nMin		- Set minimum, optional, -1 to let it unchanged
				nMax		- Set maximum, optinal, -1 to let it unchanged
				nPage		- Set page, -1 to let it unchanged
				redraw		- Set to true to redraw the scroll bar

 Returns:
				Current position of the scroll bar
*/
ScrollBar_Set(hCtrl, nPos=0, nMin=-1, nMax=-1, nPage=-1, redraw=0) {
	static SIF_RANGE=1, SIF_PAGE=2, SIF_POS=4, SB_CTL=2

	fMask := 0
	fMask |= (nMin > -1) or (nMax > -1) ?  SIF_RANGE : 0
	fMask |= nPage > - 1 ? SIF_PAGE : 0
	fMask |= nPos > -1 ? SIF_POS : 0

	VarSetCapacity(SINFO, 28, 0)
	NumPut(28,		SINFO, 0)	;cbSize
	NumPut(fMask,	SINFO, 4)	;fMask
	NumPut(nMin,	SINFO, 8)	;nMin
	NumPut(nMax,	SINFO, 12)	;nMax
	NumPut(nPage,	SINFO, 16)	;nPage
	NumPut(nPos,	SINFO, 20)	;nPos
								;TrackPos
	return DllCall("SetScrollInfo", "uint", hCtrl, "int", SB_CTL, "uint", &SINFO, "uint", redraw)
}

ScrollBar_onScroll(wparam, lparam, msg){
	local hCtrl := lParam,  action := wparam & 0x0000FFFF, nPos
	static SB_LINEDOWN=1, SB_PAGEDOWN=3, SB_PAGEUP=2, SB_THUMBTRACK=5, SB_TOP=6, SB_BOTTOM=7, SB_LINEUP=0
	
	nPos := ScrollBar_Get(hCtrl)

	IfEqual, action, %SB_TOP%,				SetEnv, nPos, % ScrollBar_Get(hCtrl, "min")
	else IfEqual, action, %SB_BOTTOM%,		SetEnv, nPos, % ScrollBar_Get(hCtrl, "max")
	else IfEqual, action, %SB_LINEUP%,		EnvSub, nPos, 1
	else IfEqual, action, %SB_LINEDOWN%,	EnvAdd, nPos, 1
	else IfEqual, action, %SB_PAGEUP%,		EnvSub, nPos, % ScrollBar_Get(hCtrl, "page")
	else IfEqual, action, %SB_PAGEDOWN%,	EnvAdd, nPos, % ScrollBar_Get(hCtrl, "page")
	else IfEqual, action, %SB_THUMBTRACK%,	SetEnv, nPos, % ScrollBar_Get(hCtrl, "track")

	ScrollBar_SetPos(hCtrl, nPos)	;lets do this faster
	ScrollBar_POS  := ScrollBar_Get(hCtrl), ScrollBar_HWND := hCtrl
	GoSub % ScrollBar_%hCtrl%_fun
}

/*
 Function:		SetPos
				Set scroll bar position and redraws it

 Parameters:	
				hCtrl	- Handle to the scroll bar control
				nPos	- Position to set (default = 1)

 Returns:
				Previous position.
*/
ScrollBar_SetPos(hCtrl, nPos=1) {
	static SB_CTL=2
	return DllCall("SetScrollPos", "uint", hCtrl, "int", SB_CTL, "uint", nPos, "uint", 1)
}

/*
 Function:		Enable
				Enable or desable scroll bar

 Parameters:	
				hCtrl	- Handle to the scroll bar control
				enable	- True to enable, false to desable (default=true)
*/
ScrollBar_Enable(hCtrl, enable=true) {
	static SB_CTL=2
	
	if !enable
		return DllCall("EnableScrollBar", "uint", hCtrl, "uint", SB_CTL, "uint", 3)	;it doesn't work for some reason with Enable_Both flag...
	else WinSet, Enable, , ahk_id %hCtrl%
}

/*
 Function:		Show
				Show or hide scroll bar

 Parameters:	
				hCtrl	- Handle to the scroll bar control
				show	- True to show, false to hide (default=show)

 Returns:
				Positive number on success, 0 on failure
*/
ScrollBar_Show(hCtrl, show=true) {
	static SB_CTL=2
	return DllCall("ShowScrollBar", "uint", hCtrl, "uint", SB_CTL, "uint", show)
}

/* Group: Example
	(start code)
		Gui,  +LastFound
		hGui := WinExist()
		
		Gui, Add, Edit, -vscroll y50 h100 w230 vMyEdit, 0
		hHBar := ScrollBar_Add(hGui, 0,   10, 280, 8,  "OnScroll", "min=0", "max=50", "page=5")
		hVBar := ScrollBar_Add(hGui, 280, 10, -1,  290, "OnScroll", "style=ver", "pos=10")

		;glue to the MyEdit
		hhE := ScrollBar_Add(hGui, "myEdit", 0, 0, 10, "OnScroll", "pos=50")
		hvE := ScrollBar_Add(hGui, "myEdit", 0, 0, 0, "OnScroll", "style=ver", "pos=50")

		Gui, show, h300 w300, ScrollBar Test
	return

	OnScroll:
		if (ScrollBar_HWND = hHBar) 
			 s := "horizontal"
		else if (ScrollBar_HWND = hVBar) 
			 s := "vertical"
		else s := "glued"

		ControlSetText, Edit1, %ScrollBar_POS% - %s% bar
	return
   (end code)
 */

/*
 Group: About
	o v2.0 by majkinetor.
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/>.
 */