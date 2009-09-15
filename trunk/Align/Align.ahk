_("w")
	Gui, +LastFounds
	hGui := WinExist()

	Gui, Show, w400 h500 Hide

	Gui, Add, Edit, HWNDhBtn1,
	Gui, Add, Button, HWNDhBtn2, Nice
	Gui, Add, Button, HWNDhBtn3 , Meh
	Gui, Add, MonthCal, HWNDhCal

	Align(hBtn1, "L", 100)
	Align(hBtn2, "T", 35)
	Align(hBtn3, "B")
	Align(hCal,  "F")

	Gui, Show
return

F1::
	WinHide, ahk_id %hBtn3%
	WinHide, ahk_id %hBtn1%	
	Win_Redraw(hGui, "-")
	Align(hGui)			;realign
	Win_Redraw(hGui, "+")
return


/*
  Function:	Align
 			Aligns control to its parent
 
  Parameter:
 			hCtrl	- Control's handle
 			Type	- String specifying align type. Available align types are left, right, top, bottom and fill.
 					  Top and bottom types are horizontal aligments while left and right are vertical. Fill is both
 					  vertical and horizontaly aligned.
 					  Control will be aligned to the edge of given type of its parent. If you use align, control's
 					  x, y are ignored, w is ignored for vertical, h for horizontal aligment.
 			Dim		- Optional dimension to use. This is width for vertical and height for horizontal aligment type.
 					  If you omit dimension, controls current width or height will be used.
 
  Remarks:		
 			You can also set align via <Add> function which is more convenient in most cases.
 
  Example:
 >			Align(hCtrl, "left", 100)	;align control to the left edge of its parent, set width to 100
 */
Align(HCtrl, Type="", Dim=""){
	static 

	HCtrl += 0
	if (Type="") {	;realign
		hParent := HCtrl
		%hParent%rect := ""
		loop, parse, %hParent%, |
		{
			StringSplit, s, A_LoopField, %A_Space%
			HCtrl := s1, Type := s2, %Type% := true
			gosub %A_ThisFunc%
		}
		return
	}

 	hParent := DllCall("GetParent", "uint", HCtrl, "Uint")
	if !hParent or !hCtrl
		return A_ThisFunc "> Invalid handle.   Control: " hCtrl "  Parent: " hParent

 Align:
	if Type not in l,r,t,b,f
		 return A_ThisFunc "> Unknown type: " Type 
	else l:=r:=t:=b:=f:=0, %Type% := true

	if (%hParent%rect = "") {
		c1 := c2 := 0
		Win_Get(hParent, "Lwh", c3, c4)
	} else StringSplit, c, %hParent%rect, %A_Space%

	if !InStr(list, HCtrl)
		%hParent% .= (%hParent% != "" ? "|" : "") HCtrl " " Type

	ControlGet, style, Style, , , ahk_id %HCtrl%
	if !(style & 0x10000000)	;WS_VISIBLE
		return

	if (Dim = "") {
		ControlGetPos,,,DimH,DimV,,ahk_id %HCtrl%
		Dim := r || l ? DimH : DimV
	}

	  x := r		? c3-Dim : c1
	, y := b		? c4-Dim : c2
	, w := r || l	? Dim : c3-c1
	, h := t || b	? Dim : c4-c2
	
	DllCall("SetWindowPos", "uint", Hctrl, "uint", 0, "uint", x, "uint", y, "uint", w, "uint", h, "uint", 4)
	
	  c1 += l ? Dim : 0
	, c2 += t ? Dim : 0
	, c3 -= r ? Dim : 0
	, c4 -= b ? Dim : 0

	%hParent%rect := c1 " " c2 " " c3 " " c4
 return
}