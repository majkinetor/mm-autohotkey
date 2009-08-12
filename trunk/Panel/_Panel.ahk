#SingleInstance, force 
;SetBatchLines, -1
	hMain		 := Form("Form1", "w800 h500 style=Resize")

	hp1	 := Panel_Add(hMain,"Edit", "P1", "h99 style='center'", "Ltop Awr" )
	hSep := Panel_Add(hMain, "Panel", "", "h5 style='sunken'", "Ltop Awr")
;	hp2	 := Panel_Add(hMain,"Panel", "P2", "style=center", "Lclient Ahwr" )
	hp2  := Panel_Add(hMain,"MonthCal", "", "", "Lclient Ahw" )
			Separator(hSep, hp1, hp2)
	
	Form_Show("Form1")
return


Separator(hs, h1, h2){
	global 
;	Extension_SubClass(hs, "Separator_wndProc")
;	Separator_wndProc(0, 0, h1, h2)
	Panel_%hs%_separator := h1 " " h2
}



Redraw:

return

OnHLink(hwnd, pText, pLink){
	msgbox Text: %pText% `nLink: %pLink%
}

Form1_Size:
	Panel_GuiSize(hMain)
return

Esc:: ExitApp

Form(Name, Options) {
	local g, x, y, w, h, style, rect

	g := Form_%Name% := Panel_getFreeGuiNum()
	
	Panel_Parse(Options, "x y w h style", x, y, w, h, style)
	Gui, %g%:+LastFound +Label%Name%_ %style%
	hGui := WinExist()
	
	rect := (x ? "x" x : " ") (y ? " y" y : " ") (w ? " w" w : " ") (h ? " h" h : " ")

	Gui, %g%:Show, %rect% Hide, %Name%
	Gui, %g%:Margin, 0, 0		;this makes Add function behave normaly i.e. if you add control on pos X,Y it will not be X+mx and Y+my

	return Panel_New(hGui, 0, 0, w, h, "blackrect")
}

Form_Show( Name, Title="" ){
	local g
	g := "Form_" Name, g := %g%
	Gui, %g%:Show, , %Title%
}

Form_Close( Name ) {
	local g
	g := "Form_" Name, g := %g%
	Gui, %g%:Hide
}

/*
 Function: Add
 			Add control to the panel
 
 Parameters: 
 			hPanel	- Handle of the panel which becomes parent of the control.
 			hCtrl	- Control handle, if control already exists, or control name, if it is to be made.
 			Txt		- Text of the new control (optional).
			Opt		- List of control options, white space separated (optional).
			POpt	- List of panel control options, white space separated (optional).
			E1..En  - Control extensions (optional).
 
 Making controls:
 			Panel can make any internal AHK control and any custom control that provides adequate creation function.
			Making internal control is similar as as using native command Gui, Add :
 
 > 			Gui,  Add,		   CtrlName,  Options,  Text
 > 			Panel_Add(hPanel, "CtrlName", "Text", "Options")
 
 			To make external control, you must include appropriate module designed to work with Panel (i.e. to implement
			CtrlName_Add2Panel function ). The exception to this rule is Panel control itself because if you use Panel, its already included.
 
 Panel options:
 			Ltype (align)	- Sets align for the control. See <Align> for details. Instead "dim" parameter of Align function, use w or h.
 			Adef  (anchor)	- Sets anchor for the control. See <Anchor> for details.
 
 Returns:
 			Control's handle if succesifull, or error message otherwise.
 
 Examples:
 >			hBtn	:= Panel_Add(hParent, "Button", "Cancel", "gOnBtn h200 w100", "Aw.5h.5")	 ;add button
 >			hPanel1 := Panel_Add(hParent, "Panel", "Panel1", "h200" "Ltop Awh")		;add panel
 >		    hEdit   := Panel_Add(hPanel1, "Edit", "Memo`n", "gOnEdit", "Lclient")	;add multiline edit
 */
Panel_Add(hPanel, Ctrl, Txt="", Opt="", POpt="", E1="",E2="",E3="",E4="",E5=""){
  ;var
	local o,k, f_Option, f_Add, f_Extension
	static integrated = "Text,Edit,UpDown,Picture,Button,Checkbox,Radio,DropDownList,ComboBox,ListBox,ListView,TreeView,Hotkey,DateTime,MonthCal,Slider,Progress,GroupBox,Tab2,StatusBar"
	static po_L="Panel_Align", po_A="Panel_Anchor"

  ;make control with options
	if Ctrl is not Integer
	{
		if Ctrl in %integrated% 
			 f_Add := "Panel_addAhkControl", hCtrl := %f_Add%(hPanel, Ctrl, Txt, Opt)
		else f_Add := Ctrl "_Add2Panel",     hCtrl := %f_Add%(hPanel, Txt, Opt)
	}

  ;apply panel options 
	loop, parse, POpt, %A_Space%%A_Tab%, %A_Space%%A_Tab%
	{
		ifEqual A_LoopField, ,continue
		o := SubStr(A_LoopField, 1, 1),  f_Option := "po_" o,  f_Option := %f_Option%
		ifEqual, f_Option,, return A_ThisFunc ">    Invalid panel option - " A_LoopField
		%f_Option%( hCtrl, SubStr(A_LoopField, 2) )		
	}	

  ;apply extensions
	loop {
		o := E%A_Index%
		ifEqual, o, , break

		f_Extension := "Extension_" SubStr(o, 1, k:=InStr(o, A_Space)-1), k := SubStr(o, k+2)
		o := "", o := %f_Extension%(hCtrl, k)
		ifEqual, o, , return A_ThisFunc " >   Invalid extension: " SubStr( f_Extension, 11 )
		ifEqual, o,0, return A_ThisFunc " >   Unsuported " Ctrl " extension: " SubStr( f_Extension, 11 )
	}
		
	return hCtrl
}


Panel_GuiSize:
	Panel_GuiSize( hMain )
return

OnCtrl:
return

return

/*
  Function:	Align
 			Aligns control to its parent
 
  Parameter:
 			hCtrl	- Control's handle
 			Type	- String specifying align type. Available align types are left, right, top, bottom and fill.
 					  Top and bottom types are horizontal aligments while left and right are vertical. Client is both
 					  vertical and horizontaly aligned.
 					  Control will be aligned to the edge of given type of its parent. If you use align, control's
 					  x, y are ignored, w is ignored for vertical, h for horizontal aligment.
 			Dim		- Optional dimension to use. This is width for vertical and height for horizontal aligment type.
 					  If you omit dimension, controls current width or height will be used.
 
  Remarks:		
 			You can also set align via <Add> function which is more convenient in most cases.
 
  Example:
 >			Panel_Align(hCtrl, "left", 100)		;align control to the left edge of its parent, set width to 100
 */
Panel_Align(Hctrl, Type="", Dim=""){
	local ax, ay, dx, dy,   left, right, top, bottom, client
	local hParent,  x,y,w,h,  data
	static types = "left,right,top,bottom,client", vars = "ax ay dx dy"

	hParent := DllCall("GetParent", "uint", Hctrl)			;get the container panel
	if !hParent or !hCtrl
		return A_ThisFunc ">   Invalid handle.   Parent: " hParent "   Child: " hCtrl

	data := Panel_%hParent%_data
	ifEqual, Type, , return Panel_%hParent%_data := ""		;if there is no align type, reset data for the parent panel.

	if Type not in %types%
		return A_ThisFunc ">   Unknown type: '" Type "'"
	
	if (data = "") {
		ax := ay := 0
		ControlGetPos, ,,w,h,,ahk_id %hParent%
		dx := w, dy := h
	} else loop, parse, vars, %A_Space%
		%A_LoopField% := Panel_getToken(data, A_Index)		;get token resets its internal statics when 2nd param is 1 :)	

	%Type% := 1
	if Dim =
		if (right or left)
			 ControlGetPos,,,Dim,,,ahk_id %Hctrl%
		else if (top or bottom)
			 ControlGetPos,,,,Dim,,ahk_id %Hctrl%

;	order = %order%%hParent% %hCtrl% %type%`n

	x := right ? dx - Dim : ax
	y := bottom ? dy - Dim : ay
	w := right or left ? Dim : dx - ax
	h := top or bottom ? Dim : dy - ay

	DllCall("SetWindowPos", "uint", Hctrl, "uint", 0, "uint", x, "uint", y, "uint", w, "uint", h, "uint", 4)
	
	ax += left   ? Dim : 0
	ay += top    ? Dim : 0
	dx -= right  ? Dim : 0
	dy -= bottom ? Dim : 0

	Panel_%hParent%_data := ax " " ay " " dx " " dy
	return 1
}

/*
 Function: Anchor
 			Set controls anchor.
 
 Parameters:
 			hCtrl	- Handle of the control
 			aDef	- Anchor defintion
 
 Anchor Definition:
 >			Syntax:  "Xmx Ymy Wmw Hmh Rn" (without spaces)
 
 			X..H	- If specified, controls property will be anchored relative to its parent.
 			mx..mh	- Property multiplier, positive value. By default, 1
 			Rn	- Redraw type. Set n=1 to redraw after anchoring, set m=2 for delayed redrawing (100ms after user finished resize/move operation).
 				  If you omit n, it defaults to 1. If you omit R, no redrawing is done.
 
 Remarks:		
 			You can also set anchor via <Add> function which is more convenient in most cases.
 
 Example:
 >			Panel_Anchor(hCtrl, "w.5h.5r2")	;anchor width and height, with multiplier 0.5, redraw with delay
 >			Panel_Anchor(hCtrl)				;reset anchor for this control. Must be done after moving controls programatically.
 */ 
Panel_Anchor(hCtrl, aDef="", r=false){
	local hPanel, cx, cy, cw, ch, px, py, pw, ph, z, s, j
	static tokens := "xywhr"

	hPanel := DllCall("GetParent", "uint", hCtrl)

	if r
	{
		re = `nm)%hCtrl%.+\n*
		Panel_%hPanel%_anchorList := RegExReplace(Panel_%hPanel%_anchorList, re)
	}

	ControlGetPos, px, py, pw, ph, , ahk_id %hPanel%
	ControlGetPos, cx, cy, cw, ch, , ahk_id %hCtrl%
	cx-=px, cy-=py		;!!! -borderx -bordery

 ;add space between tokens for easier parsing
	loop, parse, tokens
		StringReplace, aDef, aDef, %A_LoopField%, %A_Space%%A_LoopField%
	aDef := SubStr(aDef, 2)

 ;compile
	loop, parse, aDef, %A_Space%
	{
		s := A_LoopField,	z := SubStr(s,1,1)

		if z=r
			continue

		if (j := InStr(s, "/"))
			j := SubStr(s, 2, j-2) / SubStr(s, j+1), s := SubStr(s,1,1) j
		else if (SubStr(s,2)="")
				s .= "1"

		j := SubStr(A_LoopField, 1, 1), j := c%j%
		StringReplace, s, s, %z%, %z%:
		StringReplace, aDef, aDef, %A_LoopField%, %s%:%j%
	}

	Panel_%hPanel%_anchorList .= (Panel_%hPanel%_anchorList ? "`n" : "" ) hCtrl " " aDef
	Panel_%hPanel%_startSize  := pw " " ph
}

Panel_Show(hPanel) {
	WinShow, ahk_id %hPanel%
}


Panel_Hide(hPanel) {
	WinHide, ahk_id %hPanel%
}

/*
 Function:	 New
			 Create new panel.

 Parameters: 
			 hGui	- Handle of the GUI
			 x .. h - Panels position and size
			 style	- White space separated list of styles. Any style of the "Static" control is supported.
			 text	- Optional text to be shown inside the panel

 Returns:
			Handle of the panel if succesiful, or 0 if control can't be created.

 Remarks:
			You should use this function only to create main panel for the GUI. Its more appropriate to use
			<Add> function to add new Panel.
 */
Panel_New(hGui, x, y, w, h, style="", text="") { 
	static init=0
	static WS_VISIBLE=0x10000000, WS_CHILD=0x40000000, WS_CLIPCHILDREN=0x2000000, SS_NOTIFY=0x100
	static SS_SIMPLE = 0xB, SS_BLACKFRAME = 7, SS_BLACKRECT = 4, SS_CENTER=0x201, SS_VCENTER=0x200, SS_HCENTER = 1, SS_GRAYFRAME = 0x8, SS_GRAYRECT = 0x5, SS_RIGHT = 2, SS_SUNKEN = 0x1000, SS_WHITEFRAME = 9, SS_WHITERECT = 6

	if !init
		init := Panel_registerClass()

	hstyle := 0
	loop, parse, style, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, , continue
		if A_LoopField is integer
			 hStyle |= A_LoopField
		else hStyle |= SS_%A_LOOPFIELD%
	}

	res := DllCall("CreateWindowEx" 
	  , "Uint",	  0
	  , "str",    "Panel"	
	  , "str",    text		
	  , "Uint",   WS_VISIBLE | WS_CHILD	| WS_CLIPCHILDREN | SS_NOTIFY | hStyle
	  , "int",    x, "int", y, "int",w, "int",h
	  , "Uint",   hGui
	  , "Uint",   0, "Uint",0, "Uint",0, "Uint") 

	ifEqual, res, 0, return "Err: failed to create control"
	return res
} 


Panel_Add2Panel(hParent, Txt, Parameters){
	Panel_Parse(Parameters, "x y w h style", x, y, w, h, style)
	return Panel_New(hParent, x, y, w, h, style, Txt)	
}


Panel_OnSize(hPanel, fun) {
	
}

/*
 Function:	 GuiSize
			 Mandatory function to call inside GuiSize subroutine

 Parameters: 
			 w,h,e	- A_GuiWidth, A_GuiHeight, A_EventInfo
			 main	- The main panel, the one that has the same size as the entire GUI.
 */
Panel_GuiSize( hMainPanel ){
	static s

	if A_EventInfo = 1
		return s:=A_EventInfo
	else if (A_EventInfo=2) and (s=1)
		return s:=A_EventInfo

	ControlMove, , , ,A_GuiWidth,A_GuiHeight, ahk_id %hMainPanel%	
	s := A_EventInfo
}

;==================================== PRIVATE ================================================
;Anchor handler
;
Panel_size(hwnd, pw, ph) {
	local anchorList, anchor, hCtrl, j, z0,z1,z2,z3, s0,s1,s2, cx,cy,cw,ch, flag, ux, uy, uw, uh,  px, py,  r
	static tokens="x,w,y,h"

	ControlGetPos, px, py,,, , ahk_id %hwnd%

	anchorList := Panel_%hwnd%_anchorList
	ifEqual, anchorList, , return

	StringSplit, s, Panel_%hwnd%_startSize, %A_Space%
	loop, parse, anchorList, `n 
	{
		j := InStr(A_LoopField, " "), hCtrl := SubStr(A_LoopField, 1, j-1), anchor := SubStr(A_LoopField, j+1)
		ControlGetPos, cx, cy, cw, ch, , ahk_id %hCtrl%
		cx-=px, cy-=py		;!!! -borderx -bordery
		loop, parse, anchor, %A_Space%
		{
			if (SubStr(A_LoopField, 1, 1) = "r"){
				r := SubStr(A_LoopField, 2, 1)
				ifEqual, r, , SetEnv, r, 1
				continue
			}

			StringSplit, z, A_LoopField, :
			c%z1% := z3+z2*(z1="x" OR z1="w" ? pw-s1 : ph-s2)
			u%z1% := true
		}

		flag := 4 | (r=1 ? 0x100 : 0)	;nocopybits=0x100, nozorder=4
		flag |= uw OR uh ? 0 : 1		;SWP_NOSIZE=1
		flag |= ux OR uy ? 0 : 2		;SWP_NOMOVE=2

		DllCall("SetWindowPos", "uint", hCtrl, "uint", 0, "uint", cx, "uint", cy, "uint", cw, "uint", ch, "uint", flag) ; SWP_NOZORDER=4
		if r=2
			Panel_redrawDelayed(hCtrl)
	}
}

;----------------------------------------------------------------------------------------------
; Window procedure
;
Panel_wndProc(hwnd, uMsg, wParam, lParam) { 
    global
	static WM_SIZE = 0x05,  SWP_NOSIZE=1, SWP_NOMOVE=2
	static redirect = "32,78,273,277,279", anc		;WM_SETCURSOR,WM_COMMAND,WM_NOTIFY,WM_HSCROLL,WM_VSCROLL

	static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200, WM_LBUTTONDOWN=0x201, WM_LBUTTONUP=0x202
	static SIZENS := 32645,  SIZEWE := 32644
	static cursor, delta, moving
	
	;critical  30		;!!! 

	if uMsg in %redirect%
	{	
		if !anc
			anc := DllCall("GetAncestor", "uint", hwnd, "uint",2) ;GWL_ROOT = 2
		return DllCall("SendMessage", "uint", anc, "uint", umsg, "uint", wparam, "uint", lparam)
	}

	if (umsg = WM_SIZE)
		Panel_size(hwnd, lparam & 0xFFFF, lparam >> 16)

	If (UMsg = WM_SETCURSOR) 
	  return 1 
	
	ss := Panel_%hwnd%_separator
	if ss = 
		return DllCall("CallWindowProc","uint",A_EventInfo,"uint",hwnd,"uint",uMsg,"uint",wParam,"uint",lParam)
		
	if (UMsg = WM_MOUSEMOVE) 
	{
		if cursor = 
			cursor := DllCall("LoadCursor", "Uint", 0, "Int", SIZENS, "Uint")
		DllCall("SetCursor", "uint", cursor)
		if moving 
			Separator_UpdateVisual()
	}

	if (UMsg = WM_LBUTTONDOWN)
	{
		DllCall("SetCapture", "uint", hwnd)
		VarSetCapacity(RECT, 16)
		DllCall("GetWindowRect", "uint", hGui, "uint", &RECT)
;		NumPut( NumGet(RECT, 4) + 40, RECT, 4)	
		DllCall("ClipCursor", "uint", &RECT)
		moving := true
		DllCall("SetCursor", "uint", cursor)
	}
	if (UMsg = WM_LBUTTONUP)
	{
		delta := (LParam >> 16)
		if delta > 10000 
			delta -= 0xFFFF 

		DllCall("ClipCursor", "uint", 0)
		DllCall("ReleaseCapture")
		
		DllCall("SetCursor", "uint", cursor)
		moving := false
		Splitter_Move(hwnd, delta, ss)
	}

	return DllCall("CallWindowProc","uint",A_EventInfo,"uint",hwnd,"uint",uMsg,"uint",wParam,"uint",lParam)
}

Separator_UpdateVisual() {
	global
	static dc, brush, RECT, R2, w
	critical 30
	MouseGetPos, mx, my
	my-=30
	if !dc
	{
		 dc := DllCall("GetDC", "uint", hMain)
		 brush := DllCall("CreateSolidBrush", "uint", 0xAAAAAA)
		 VarSetCapacity(RECT, 16), 		 VarSetCapacity(R2, 16)
		
	 	 DllCall("GetClientRect", "uint", hMain, "uint", &R2)
		 DllCall("DrawFocusRect", "uint", dc, "uint", &R2)

	 	 tooltip 1, 1000, 1000
		 tooltip

		 NumPut(my-2, R2, 4)
		 NumPut(my+2, R2, 12)		
	 	 DllCall("DrawFocusRect", "uint", dc, "uint", &R2)	

	}
	DllCall("DrawFocusRect", "uint", dc, "uint", &R2)

	NumPut(my-3, R2, 4)
	NumPut(my+3, R2, 12)

	DllCall("DrawFocusRect", "uint", dc, "uint", &R2)
}

Splitter_Move(hwnd, delta, controls){
	StringSplit, s, controls, %A_Space%

	Win_MoveDelta(s1, "", "", "", delta)
	Win_MoveDelta(hwnd, "", delta)
	Win_MoveDelta(s2, "", delta, "", -delta)

	Panel_Anchor(s1, "wr", 1)
	Panel_Anchor(hwnd, "wr", 1)
	Panel_Anchor(s2, "hwr", 1)
	Win_Redraw(  DllCall("GetParent", "uint", hwnd) )
}


Panel_redrawDelayed(ctrl){
	static s

	if !InStr(s, ctrl)
		s .= ctrl " "
	
	SetTimer, Panel_redrawDelayed, -100
return

 Panel_redrawDelayed:
	loop, parse, s, %A_Space%
		WinSet, Redraw, , ahk_id %A_LoopField%
	s =
 return
}

Panel_registerClass(){
    static ClassAtom, ClassName="Panel"
    
	if ClassAtom
        return ClassAtom
    
    VarSetCapacity(wcl,40)
    if ! DllCall("GetClassInfo","uint",0,"str","Static","uint",&wcl)
        return false
    NumPut(NumGet(wcl)|0x20000,wcl) ; wcl->style |= CS_DROPSHADOW
    NumPut(&ClassName,wcl,36)       ; wcl->lpszClassName = &ClassName
    NumPut(DllCall("GetModuleHandle","uint",0),wcl,16)  ; wcl->hInstance = NULL

	; Create a callback for Panel_WndProc, passing Static's
    ; WindowProc as A_EventInfo. lpfnWndProc := the callback.
    NumPut(RegisterCallback("Panel_WndProc","",4,NumGet(wcl,4)),wcl,4)
    
    return DllCall("RegisterClass","uint",&wcl)
}

Panel_getToken(s, r=0) {
	static next=1, sep=" "
	ifEqual, r,1,SetEnv, next, 1
	j := InStr(s, sep, 0, next)
	IfEqual, j, 0, return SubStr(s, next), next := 1
	r := SubStr(s, next, j-next), next:=j+1
	return, r
}

Panel_Parse(o, pQ, ByRef o1="",ByRef o2="",ByRef o3="",ByRef o4="",ByRef o5="",ByRef o6="",ByRef o7="",ByRef o8="", ByRef o9="")
{
	loop, parse, o, %A_Space%
	{	
		if (LF := A_LoopField) = ""	{
			if c
				p_%n% .= A_Space
			continue
		}
		lq := SubStr(LF, 1, 1) = "'", rq := SubStr(LF, 0, 1) = "'",   len=StrLen(LF),   q := lq && rq,  sq := lq AND !rq
		e := (!lq*!c) * InStr(LF, "="),  liq := e && (SubStr(LF, e+1, 1)="'"),  iq := liq && rq
		if !c
			n := (e ? SubStr(LF, 1, e-1) : (i=""? i:=1:++i)), c := (c || sq || liq) AND !iq, p_# := i
		if q or iq
			p_%n% := SubStr(LF, iq ? e+2:2, len-2-(iq ? e : 0))
		else if c
			if e
				 p_%n% := SubStr(LF, e+2)
			else p_%n% .= " " SubStr(LF, sq ? 2 : 1,  rq ? len-1 : len),   c := rq ? 0 : 1
		else p_%n% := e ? SubStr(LF, e+1) : LF
	}
	loop, %p_#%
		_ := SubStr(p_%A_Index%, 1, 1), p_%_% := SubStr(p_%A_Index%, 2)		;this creates locals x, y, w, h
	
	loop, parse, pQ, %A_Space%
		if (A_Index > 9)
			break
		else _ := "p_" A_LoopField,  o%A_Index% := %_%
}

Panel_addAhkControl(hParent, Ctrl, Txt, Opt ) {

	Gui, Add, %Ctrl%, HWNDhCtrl %Opt%, %Txt%
	DllCall("SetParent", "uint", hCtrl, "uint", hParent)	
	return hCtrl + 0
}

Panel_getFreeGuiNum(){
	loop {
		if (A_Index = 100)
			return 0
		Gui %A_Index%:+LastFoundExist
		IfWinNotExist
		   return A_Index
	}
}

#include HiEdit.ahk
#include HLink.ahk
;#include _Extensions.ahk
#include Win.ahk