/*	Title:	Scroller
			Makes window scrollable.

	Dependencies:
			<Win> 1.22
 */

/*
 Function:	Init
			Sets scrolling for a window.

 Parameters:
			Hwnd, Bar	- If present, function will call <UpdateBars> for given window.
 
 Remarks:
			After calling this function, all windows can be made scrollable. 
			To add scrollbars to the window, simply call <UpdateBars> after adding controls.
			To remove scrollbars for window, remove its WS_HSCROLL=0x100000 and/or WS_VSCROLL=0x200000 (or both 0x300000) and
			stop calling UpdateBars. You will also have to add UpdateBars in GuiSize routine.

			Scroller replaces message handlers for WM_VSCROLL & WM_HSCROLL messages at the moment which will influence <ScrollBar> control
			if you have it. There is usualy no need to use both in the same script.
 */
Scroller_Init(Hwnd="", Bar=3){
	static WM_VSCROLL=0x115, WM_HSCROLL=0x114, old1, old2
	
	if old1 =
		old1 := OnMessage(WM_VSCROLL, "Scroller_OnScroll"), old2 := OnMessage(WM_HSCROLL, "Scroller_OnScroll")

	if Hwnd != 
		Scroller_UpdateBars(Hwnd, Bar)
}

/*
 Function:	UpdateBars
			Updates horizontal and/or vertical scroll bar.	
 
 Parameters:
			Hwnd	- Window that contains system created scrollbars.
			Bars	- 1 to updates only horizontal bar, 2 updates only vertical bar, 3 (default) updates both.
  */
Scroller_UpdateBars(Hwnd, Bars=3){
    static SIF_RANGE=0x1, SIF_PAGE=0x2, SIF_DISABLENOSCROLL=0x8, SB_HORZ=0, SB_VERT=1

	Scroller_getScrollArea(Hwnd, left, top, right, bottom)
	sWidth := right - left, sHeight := bottom - top
	WinGetPos,,,pw,ph, ahk_id %Hwnd%
	VarSetCapacity(SI, 28, 0), NumPut(28, SI)
	NumPut(SIF_RANGE | SIF_PAGE, SI, 4)

  ; Update horizontal scroll bar. 
	if Bars in 1,3
	{
		NumPut(sWidth, SI, 12)	; nMax 
		NumPut(pw, SI, 16)		; nPage 
		DllCall("SetScrollInfo", "uint", Hwnd, "uint", SB_HORZ, "uint", &si, "int", 1) 
	} else DllCall("ShowScrollBar", "uint", HCtrl, "uint", SB_HORZ, "uint", 0)
    
  ; Update vertical scroll bar. 
   ;NumPut(SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, SI, 4) ; fMask 
   	if Bars in 2,3
	{
	    NumPut(sHeight, SI, 12) ; nMax 
		NumPut(ph, SI, 16)		; nPage 
	    DllCall("SetScrollInfo", "uint", Hwnd, "uint", SB_VERT, "uint", &si, "int", 1) 
	} else DllCall("ShowScrollBar", "uint", Hwnd, "uint", SB_VERT, "uint", 0)

  ; scroll window if needed
	if (left < 0 && right < pw) 
        x := Abs(left) > pw-right ? pw-right : Abs(left) 
    if (top < 0 && bottom < ph) 
        y := Abs(top) > ph-bottom ? ph-bottom : Abs(top) 
    if (x || y)
        DllCall("ScrollWindow", "uint", Hwnd, "int", x, "int", y, "uint", 0, "uint", 0) 
}

;=============================================== PRIVATE =====================================================

Scroller_getScrollArea(Hwnd, ByRef left, ByRef top, ByRef right, ByRef bottom) {
	static WS_HSCROLL=0x100000, WS_VSCROLL=0x200000 , sbs
    left := top := 99999,   right := bottom := 0

	if !sbs		;ScrollBar Size
		SysGet, sbs, 2

	Win_Get(Hwnd, "NhBxy", th, bx, by)

    WinGet, ctrlList, ControlListHwnd, ahk_id %Hwnd%		;!!! get list of ctrls for this parent only, not its children...
	WinGet, style, Style, ahk_id %Hwnd%	
	bHor := (style & WS_HSCROLL) != 0,		bVer := (style & WS_VSCROLL) != 0
    Loop, Parse, ctrlList, `n
    { 
		ifEqual, A_LoopField,, continue
		Win_GetRect(A_LoopField, "*xywh", cx, cy, cw, ch)
		cr := cx+cw, cb := cy+ch

        ifLess, cx, %left%,   SetEnv, left,	 %cx%
        ifLess, cy, %top%,   SetEnv, top, %cy%
		ifGreater, cr, %right%,  SetEnv, right, %cr%
		ifGreater, cb, %bottom%, SetEnv, bottom, %cb%
    }
	right +=sbs*bVer + 2*bx, bottom += th + sbs*bHor + 2*by
}

Scroller_onScroll(WParam, LParam, Msg, Hwnd){
    static SIF_ALL=0x17, SCROLL_STEP=10

	bar := Msg = 0x115
    
    VarSetCapacity(SI, 28, 0), NumPut(28, SI) 
    NumPut(SIF_ALL, SI, 4) ; fMask 

    if !DllCall("GetScrollInfo", "uint", Hwnd, "int", bar, "uint", &si) 
        return 

    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "uint", Hwnd, "uint", &rect) 
    
    old_pos := new_pos := NumGet(SI, 20) ; nPos 

	action := WParam & 0xFFFF 
    if action = 0 ; SB_LINEUP 
        new_pos -= SCROLL_STEP 
    else if action = 1 ; SB_LINEDOWN 
        new_pos += SCROLL_STEP 
    else if action = 2 ; SB_PAGEUP 
        new_pos -= NumGet(rect, 12, "int") - SCROLL_STEP 
    else if action = 3 ; SB_PAGEDOWN 
        new_pos += NumGet(rect, 12, "int") - SCROLL_STEP 
    else if (action = 5 || action = 4) ; SB_THUMBTRACK || SB_THUMBPOSITION 
        new_pos := WParam >> 16 
    else if action = 6 ; SB_TOP 
        new_pos := NumGet(SI, 8, "int") ; nMin 
    else if action = 7 ; SB_BOTTOM 
        new_pos := NumGet(SI, 12, "int") ; nMax 
    else return 
    
    min := NumGet(SI, 8, "int")						; nMin 
    max := NumGet(SI, 12, "int") - NumGet(SI, 16)	; nMax - nPage 
    new_pos := new_pos > max ? max : new_pos 
    new_pos := new_pos < min ? min : new_pos 
    
    x := y := 0 
    if bar = 0	; SB_HORZ 
         x := old_pos - new_pos 
    else y := old_pos - new_pos 

    DllCall("ScrollWindow", "uint", Hwnd, "int", x, "int", y, "uint", 0, "uint", 0)    ; Scroll contents of window and invalidate uncovered area. 
    
  ; Update scroll bar. 
    NumPut(new_pos, SI, 20, "int") ; nPos 
    DllCall("SetScrollInfo", "uint", Hwnd, "int", bar, "uint", &si, "int", 1) 
}