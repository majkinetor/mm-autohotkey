_("mo!")
	Gui, +Resize +LastFound ; WS_VSCROLL | WS_HSCROLL 
	Gui, Margin, 0, 0
	hGui := WinExist()

	hP := Panel_Add(hGui, 20, 20, 221, 400, "resizable", "My Panel")
	Loop, 15
	{
		Gui, Add, Edit, HWNDhc H100 W200 -vscroll, Edit %A_Index%
		Win_SetParent(hc, hP)
	}

	Gui, Show, W500 H500 
	Scroller_Set(hGui)
return 


GuiClose: 
ExitApp 

GuiSize:
	Scroller_UpdateBars(hGui)
return


/* Title:	Scroller
			Makes window scrollable.
 */

Scroller_Set(hParent){
	static WM_VSCROLL=0x115, WM_HSCROLL=0x114, init

	OnMessage(WM_VSCROLL, "Scroller_OnScroll")
	OnMessage(WM_HSCROLL, "Scroller_OnScroll")
}

Scroller_UpdateBars(hParent){
    static SIF_RANGE=0x1, SIF_PAGE=0x2, SIF_DISABLENOSCROLL=0x8, SB_HORZ=0, SB_VERT=1

	Scroller_getScrollArea(hParent, left, top, right, bottom)
	sWidth := right - left, sHeight := bottom - top
	WinGetPos,,,pw,ph, ahk_id %hParent%
	
	VarSetCapacity(si, 28, 0), NumPut(28, si)
	NumPut(SIF_RANGE | SIF_PAGE, si, 4)

  ; Update horizontal scroll bar. 
    NumPut(sWidth, si, 12)	; nMax 
    NumPut(pw, si, 16)		; nPage 
    DllCall("SetScrollInfo", "uint", hParent, "uint", SB_HORZ, "uint", &si, "int", 1) 
    
  ; Update vertical scroll bar. 
   ;NumPut(SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, si, 4) ; fMask 
    NumPut(sHeight, si, 12) ; nMax 
    NumPut(ph, si, 16)		; nPage 
    DllCall("SetScrollInfo", "uint", hParent, "uint", SB_VERT, "uint", &si, "int", 1) 

  ; scroll window if needed
	if (left < 0 && right < pw) 
        x := Abs(left) > pw-right ? pw-right : Abs(left) 
    if (Top < 0 && Bottom < ph) 
        y := Abs(top) > ph-bottom ? ph-bottom : Abs(top) 
    if (x || y) 
        DllCall("ScrollWindow", "uint", hParent, "int", x, "int", y, "uint", 0, "uint", 0) 
}

Scroller_getScrollArea(hParent, ByRef left, ByRef top, ByRef right, ByRef bottom) {
	static WS_HSCROLL=0x100000, WS_VSCROLL=0x200000 , sbs
    left := top := 99999,   right := bottom := 0

	if !sbs		;ScrollBar Size
		SysGet, sbs, 2

	Win_Get(hParent, "NhBxy", th, bx, by)
	ifGreater, th, 100, SetEnv, th, 0

    WinGet, ctrlList, ControlListHwnd, ahk_id %hParent% 
	WinGet, style, Style, ahk_id %hParent%
	bHor := (style & WS_HSCROLL) != 0,		bVer := (style & WS_VSCROLL) != 0
    Loop, Parse, ctrlList, `n
    { 
		ifEqual, A_LoopField,, continue
;        ControlGetPos, cx, cy, cw, ch,, ahk_id %A_LoopField%
		Win_GetRect(A_LoopField, "*xywh", cx, cy, cw, ch)
		cr := cx+cw, cb := cy+ch

        ifLess, cx, %left%,   SetEnv, left,	 %cx%
        ifLess, cy, %top%,   SetEnv, top, %cy%
		ifGreater, cr, %right%,  SetEnv, right, %cr%
		ifGreater, cb, %bottom%, SetEnv, bottom, %cb%
    }
	left-=bx, right +=bx+sbs*bVer, top -= by, bottom += by + th + sbs*bHor
	m(left, right, top, bottom)
	
}

Scroller_onScroll(WParam, LParam, Msg, Hwnd){
    static SIF_ALL=0x17, SCROLL_STEP=10 

	bar := Msg = 0x115		; SB_HORZ=0, SB_VERT=1 
    
    VarSetCapacity(si, 28, 0), NumPut(28, si) 
    NumPut(SIF_ALL, si, 4) ; fMask 

    if !DllCall("GetScrollInfo", "uint", Hwnd, "int", bar, "uint", &si) 
        return 

    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "uint", Hwnd, "uint", &rect) 
    
    old_pos := new_pos := NumGet(si, 20) ; nPos 
  
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
        new_pos := NumGet(si, 8, "int") ; nMin 
    else if action = 7 ; SB_BOTTOM 
        new_pos := NumGet(si, 12, "int") ; nMax 
    else 
        return 
    
    min := NumGet(si, 8, "int")						; nMin 
    max := NumGet(si, 12, "int") - NumGet(si, 16)	; nMax - nPage 
    new_pos := new_pos > max ? max : new_pos 
    new_pos := new_pos < min ? min : new_pos 
    
    ;old_pos := NumGet(si, 20, "int") ; nPos 
    
    x := y := 0 
    if bar = 0	; SB_HORZ 
         x := old_pos - new_pos 
    else y := old_pos - new_pos 

    DllCall("ScrollWindow", "uint", hwnd, "int", x, "int", y, "uint", 0, "uint", 0)    ; Scroll contents of window and invalidate uncovered area. 
    
    ; Update scroll bar. 
    NumPut(new_pos, si, 20, "int") ; nPos 
    DllCall("SetScrollInfo", "uint", Hwnd, "int", bar, "uint", &si, "int", 1) 
}

#include Panel.ahk
#include ..\inc\Attach.ahk
#include ..\inc\Align.ahk