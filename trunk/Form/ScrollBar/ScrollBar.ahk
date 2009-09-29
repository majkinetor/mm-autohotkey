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
				Handler		- Handler routine. See below.
				o1..o5		- Optional parameters.

 Optional parameters:
				style		- "hor" (defualt) or "ver"
				min, max	- range, by default 0, 100
				pos			- initial position of the slider, by deafult 0
				page		- page, by default 10

 Handler:
 > Handler(HCtrl, Pos)	
		HCtrl	- Handle of the control sending notification.
		Pos		- Position of the slider.


 Returns:
				Handle of the control, error message if control can not be created.

 Example:
 				hHBar := ScrollBar_Add(hwnd, 0, 0, 280, -1, "OnScroll", "style=ver", "min=1", "max=100", "page=10", "pos=10")
				ScrollBar_Add(hwnd, "myEdit", 0, 0, 0, "OnScroll")		;glue to the myEdit GUI control
 */
ScrollBar_Add(HParent, X, Y, W, H, Handler, o1="", o2="", o3="", o4="", o5="") {
	static WM_HSCROLL := 0x114, WM_VSCROLL := 0x115, vThumb, hThumb, init
	
	if !init {
		OnMessage(WM_HSCROLL, "ScrollBar_onScroll"), OnMessage(WM_VSCROLL, "ScrollBar_onScroll") ;!!! old funs
		SysGet, hThumb, 10
		SysGet, vThumb, 9
		init++
	}

	style := "hor", min := 0, max := 100, page := 10, pos := 0
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
      , "Uint", HParent	    ; hWndParent
      , "Uint", 0           ; hMenu
      , "Uint", 0           ; hInstance
      , "Uint", 0, "Uint")
	ifEqual, hCtrl, 0, return A_ThisFunc "> Can not create control."
	
	if !IsFunc(Handler)
		return A_ThisFunc "> Invalid handler: " Handler

	ScrollBar(hCtrl "Handler", Handler)
	
	ScrollBar_Set(hCtrl, pos, min, max, page) 
	return hCtrl
}

/*
 Function:		Get
				Get the scrollbar parameter.

 Parameters:	
				HCtrl	- Handle of the scroll bar control.
				pQ		- Query parameter. Any space separated combination of pos, page, min, max, track. Omit to return all data in that order.
				o1..o5	- Reference to oputut variables.				

 Returns:
				o o1 on success, nothing on failure.
*/
ScrollBar_Get(HCtrl, pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="") {
	static SIF_ALL=0x17, SB_CTL=2, SIF_TRACKPOS=0x10, page=16, pos=20, min=8, max=12, track=24, init, SINFO

	if !init
		init := VarSetCapacity(SINFO, 28), NumPut(28, SINFO), NumPut(SIF_ALL, SINFO, 4)

	ifEqual, pQ,, SetEnv, PQ, pos page min max track
	r := DllCall("GetScrollInfo", "uint", HCtrl, "int", SB_CTL, "uint", &SINFO)
	ifEqual, r, 0, return 

	loop, pQ, parse, %A_Space%
		o%A_Index% := NumGet(SINFO, %A_LoopField%)

	return o1
}
/*
 Function:		Set
				Set scroll bar parameters.

 Parameters:	
				HCtrl	- Handle of the scroll bar control.
				Pos		- Set position, by default 0.
				Page	- Set page, optional.
				Min		- Set minimum, optional.
				Max		- Set maximum, optional.
				Redraw	- Set to true to redraw the scroll bar.

 Returns:
				Current position of the scroll bar.
*/
ScrollBar_Set(HCtrl, Pos="", Min="", Max="", Page="", Redraw="") {
	static SIF_RANGE=1, SIF_PAGE=2, SIF_POS=4, SB_CTL=2, SINFO, init

	if !init
		init := VarSetCapacity(SINFO, 28), NumPut(28, SINFO)
	
	fMask := 0
	 | (Min  != "" || Max != "") ?  SIF_RANGE : 0)
	 | (Page != ""	? SIF_PAGE : 0)
	 | (Pos  != ""	? SIF_POS  : 0)

	NumPut(fMask,	SINFO, 4)	
	 , NumPut(Min,	SINFO, 8)	
	 , NumPut(Max,	SINFO, 12)	
	 , NumPut(Page,	SINFO, 16)
	 , NumPut(Pos,	SINFO, 20)

	return DllCall("SetScrollInfo", "uint", HCtrl, "int", SB_CTL, "uint", &SINFO, "uint", Redraw)
}

ScrollBar_onScroll(Wparam, Lparam, Msg){
	static SB_LINEDOWN=1, SB_PAGEDOWN=3, SB_PAGEUP=2, SB_THUMBTRACK=5, SB_TOP=6, SB_BOTTOM=7, SB_LINEUP=0, SB_ENDSCROLL=8
	
	Handler := ScrollBar(LParam "Handler")
	nPos := ScrollBar_Get(LParam)
	
	action := Wparam & 0xFFFF
	ifEqual, action, %SB_ENDSCROLL%, return

	IfEqual, action, %SB_TOP%,				SetEnv, nPos, % ScrollBar_Get(Lparam, "min")
	else IfEqual, action, %SB_BOTTOM%,		SetEnv, nPos, % ScrollBar_Get(Lparam, "max")
	else IfEqual, action, %SB_LINEUP%,		EnvSub, nPos, 1
	else IfEqual, action, %SB_LINEDOWN%,	EnvAdd, nPos, 1
	else IfEqual, action, %SB_PAGEUP%,		EnvSub, nPos, % ScrollBar_Get(Lparam, "page")
	else IfEqual, action, %SB_PAGEDOWN%,	EnvAdd, nPos, % ScrollBar_Get(Lparam, "page")
	else IfEqual, action, %SB_THUMBTRACK%,	SetEnv, nPos, % ScrollBar_Get(Lparam, "track")

	ScrollBar_SetPos(LParam, nPos)	;lets do this faster
	%Handler%( Hwnd, ScrollBar_Get(LParam) )
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
				Show or hide scroll bar.

 Parameters:	
				hCtrl	- Handle to the scroll bar control.
				show	- True to show, false to hide (default=show).

 Returns:
				Positive number on success, 0 on failure.
*/
ScrollBar_Show(hCtrl, show=true) {
	static SB_CTL=2
	return DllCall("ShowScrollBar", "uint", hCtrl, "uint", SB_CTL, "uint", show)
}

;Storage
ScrollBar(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
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