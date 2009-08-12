;-------------------------------------------------------------------------------------------------------------------
; Title:    Panel
;			Container for other controls. Implements advanced features like auotmatic control aligning and anchoring
;			and upgrades standard AutoHotKey controls with new properties.
;-------------------------------------------------------------------------------------------------------------------

/*
 Function: Add
 			Add control to the panel
 
 Parameters: 
 			hPanel	- Handle of the panel which becomes parent of the control.
 			hCtrl	- Control handle, if control already exists, or control name, if it is to be made.
 			opt		- Optional list of control options, white space separated. See bellow.
 			txt		- Optional text of the control, if control is to be made.
 
 Making controls:
 			Panel can make any control internaly supported plus Panel control. The usage is exactly the same as Gui, Add:
 
 > 			Panel_Add(hPanel, "CtrlName", "Options", "Text")
 > 			Gui,  Add,		   CtrlName,   Options,  Text
 
 			"Options" is a list of AHK options for that control plus list of extended options. For the "Panel" control, options 
 			will be passed as "style". See <New> for details. Don't use HWND option, as it is automaticaly added.
 
 Extended options:
 			Ltype (align)	- Sets align for the control. See <Align> for details. Instead aligns "dim" parameter, use w or h.
 			Adef (anchor)	- Sets anchor for the control. See <Anchor> for details.
 
 Returns:
 			Control's handle if succesifull, or error message.
 
 Examples:
 >			hBtn	:= Panel_Add(hParent, "Button", "gOnBtn Aw.5h.5 h200 w100", "Cancel" )	 ;add button
 >
 >			hPanel1 := Panel_Add(hParent, "Panel", "Ltop Awh h200", "Panel1")		;add panel
 >		    hEdit   := Panel_Add(hPanel1, "Edit", "Lclient gOnEdit", "Memo`n")		;add multiline edit
 */
Panel_Add(hPanel, hCtrl, def="", txt="") {
	r := Panel_parse(def, a, p)
	ifNotEqual, r, OK, return r
		
	p_x := p_y := 0
	loop, parse, p, %A_Space%
		t := SubStr(A_LoopField, 1, 1), p_%t% := SubStr(A_LoopField, 2)

	if hCtrl is not Integer
		if (hCtrl = "Panel")
			 hCtrl := Panel_New(hPanel, p_x, p_y, p_w, p_h, a, txt)		;a can be only style if this is panel
		else Gui, Add, %hCtrl%, HWNDhCtrl %a%, %txt%

	if !p_w 
		ControlGetPos, , , p_w, , , ahk_id %hCtrl%
	if !p_h
		ControlGetPos, , , ,p_h , , ahk_id %hCtrl%		

	flag := p_w or p_h ? 0 : 1		; SWP_NOSIZE := 1
	DllCall("SetParent", "uint", hCtrl, "uint", hPanel)
	DllCall("SetWindowPos", "uint", hCtrl, "uint", 0, "uint", p_x, "uint", p_y, "uint", p_w, "uint", p_h, "uint", 0)

	r := p_L ? Panel_Align(hCtrl, p_L)  : ""
	r .= p_A ? Panel_Anchor(hCtrl, p_A) : ""

	return hCtrl+0
}

/*
  Function:	Align
 			Aligns control to its parent
 
  Parameter:
 			hCtrl	- Control's handle
 			Type	- String specifying align type. Available align types are left, right, top, bottom and client.
 					  Top and bottom types are horizontal aligments, while left and right are vertical. Client is both
 					  vertical and horizontaly aligned.
 					  Control will be aligned to the edge of given type of its parent. If you use align, control's
 					  x, y are ignored, w is ignored for vertical, h for horizontal aligment.
 			dim		- Optional dimension to use. This is width for vertical and height for horizontal aligment type.
 					  If you omit dimension, controls current width or height will be used.
 
  Remarks:		
 			You can also set align via <Add> function which is more convenient in most cases.
 
  Example:
 >			Panel_Align(hCtrl, "left", 100)		;align control to the left edge of its parent, set width to 100
 */
Panel_Align(hCtrl, type="", dim=""){
	local ax, ay, dx, dy,   left, right, top, bottom, client
	local hParent,  x,y,w,h,  data
	static types = "left,right,top,bottom,client", vars = "ax,ay,dx,dy"


	hParent := DllCall("GetParent", "uint", hCtrl)		;get the container panel
	data := Panel_%hParent%_data
	if type =
		return Panel_%hParent%_data := ""
	
	if (data="") {
		ax := ay := 0
		ControlGetPos, ,,w,h,,ahk_id %hParent%
		dx := w, dy := h
	} else loop, parse, vars, `,
		%A_LoopField% := Panel_getToken(data, A_Index)		;get token resets the statics when 2nd param is 1 :)

	if !hParent or !hCtrl
		return "Err: Invalid handles `n`nParent: " hParent "`nChild: " hCtrl

	if type not in %types%
		return "Err: unrecognised type - '" type "'"

	%type% := 1
	if dim =
		if (Right or Left)
			 ControlGetPos,,,dim,,,ahk_id %hCtrl%
		else if (Top or Bottom)
			 ControlGetPos,,,,dim,,ahk_id %hCtrl%

;	order = %order%%hParent% %hCtrl% %type%`n

	x := Right  ? dx - dim : ax
	y := Bottom ? dy - dim : ay
	w := Right or Left ? dim : dx - ax
	h := Top or Bottom ? dim : dy - ay

	DllCall("SetWindowPos", "uint", hCtrl, "uint", 0, "uint", x, "uint", y, "uint", w, "uint", h, "uint", 4)
	
	ax += Left   ? dim : 0
	ay += Top    ? dim : 0
	dx -= Right  ? dim : 0
	dy -= Bottom ? dim : 0

	Panel_%hParent%_data := ax " " ay " " dx " " dy
	return "OK"
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
 			mx..mh	- Property multiplier, value between 0 and 1. By default, 1
 			Rn	- Redraw type. Set N=1 to redraw after anchoring, set N=2 for delayed redrawing (100ms after user finished resize/move operation). 
 				  If you omit N, it defaults to 1. If you omit R, no redrawing is done.
 
 Remarks:		
 			You can also set anchor via <Add> function which is more convenient in most cases.
 
 Example:
 >			Panel_Anchor(hCtrl, "w.5h.5r2")	;anchor width and height, with multiplier 0.5, redraw with delay
 */ 
Panel_Anchor(hCtrl, aDef=""){
	local hPanel, cx, cy, cw, ch, px, py, pw, ph, z, s, j
	static tokens := "xywhr"

	hPanel := DllCall("GetParent", "uint", hCtrl)

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

Panel_TableLayout(hPanel, ByRef ctrls, ByRef rules, ByRef spacing, ByRef marginX, ByRef marginY, ByRef xi = "", ByRef yi = "", ByRef totWidth = "", ByRef totHeight = "", ByRef resizeRules = "") {
	width := totWidth
	height := totHeight

	; parse the rules
	repeatIndex = 1
	index := 0
	Loop, Parse, rules, _
	{
		row := ++index
		if A_LoopField {
			if A_LoopField is digit
			{
				%cell%repeat := A_LoopField
				%cell%count := 0
				index--
			} else {
				Loop, Parse, A_LoopField, |
				{
					column := A_Index
					cell = cells%row%_%column%
					%cell%n = 1
					%cell%r = 1
					%cell%c = 1
					Loop, Parse, A_LoopField, %A_Space%
					{
						f := SubStr(A_LoopField, 1, 1)
						%cell%%f% := SubStr(A_LoopField, 2)
					}
				}
				columns%row% := column
			}
		} else {
			repeatIndex := index--
		}
	}
	
	; calculate needed heights and widths for the rows and columns respectively
	; as well as determine the cell to which a control belongs
	rows := row
	rIndex := cIndex := row := column := num := 1
	cell = cells1_1
	height1 := %cell%h
	width1 := %cell%w
	celln := %cell%n
	if height1 && !(%cell%f && %cell%f & 2)
		%cell%xH := true
	if width1 && !(%cell%f && %cell%f & 1)
		%cell%xW := true
	rSpan := %cell%r
	cSpan := %cell%c
	if !xi {
		StringGetPos, pos, ctrls, `n
		StringMid, ctrl, ctrls, 1, pos
		ControlGetPos, xi, yi, , , %ctrl%
	}
	Loop, Parse, ctrls, `n
	{
		Repeat:
		if %cell%n {
			ControlGetPos, , , w, h, %A_LoopField%
			; throw some attributes at the control
			%A_LoopField%w := w
			%A_LoopField%h := h
			%A_LoopField%c := column
			%A_LoopField%r := row
			%A_LoopField%cell := cell
			wh := "h", p := "t"
			GoSub, CheckPadding
			p := "b"
			GoSub, CheckPadding
			wh := "w", p := "l"
			GoSub, CheckPadding
			p := "e"
			GoSub, CheckPadding
			GoSub, CheckHeight
			GoSub, CheckWidth
			if (%cell%n > num) {
				; this cell has multiple controls in it
				num++
				continue
			}
			num = 1
		} else 
			num = 0
		Loop, %rSpan% {
			; mark the entire span as filled
			r := row + A_Index - 1
			Loop, %cSpan% {
				c := column + A_Index - 1
				cells%r%_%c%Filled = true
			}
		}
		columns := columns%rIndex%
		if (cIndex = columns) {
			if (!%cell%repeat || ++%cell%count > %cell%repeat) {
				%cell%count := 0
				if (rIndex = rows)
					rIndex := repeatIndex
				else
					rIndex++
			}
			row++
			cIndex = 1
			column = 1
		} else {
			cIndex++
			column++
		}
		cell = cells%rIndex%_%cIndex%
		rSpan := %cell%r
		cSpan := %cell%c
		Next:
		Loop, %rSpan% {
			; find next unfilled cell
			r := row + A_Index - 1
			Loop, %cSpan% {
			c := column + A_Index - 1
				if cells%r%_%c%Filled {
					column := c + 1
					Goto, Next
				}
			}
		}
		h := %cell%h
		if h {
			GoSub, CheckHeight
			if (!%cell%xH && !(%cell%f && %cell%f & 2))
				%cell%xH = true
		}
		w := %cell%w
		if w {
			GoSub, CheckWidth
			if (!%cell%xW && !(%cell%f && %cell%f & 1))
				%cell%xW = true
		}
		if !num {
			num = 1
			GoTo, Repeat
		}
	}
	
	; check widths of controls with colSpan > 1
	if neededWidth {
		wh = width
		GoSub, Expand
	}
	; check heights of controls with rowSpan > 1
	if neededHeight {
		wh = height
		GoSub, Expand
	}
	
	
	
	; calculation of culmination of all column widths and row heights
	totWidth := 0
	lenWidth := 0
	x1 := xi + marginX
	y1 := yi + marginY
	Loop {
		w := width%A_Index%
		if !(w is number)
			break
		totWidth += w
		lenWidth++
	}
	totHeight := 0
	lenHeight := 0
	Loop {
		h := height%A_Index%
		if !(h is number)
			break
		totHeight += h
		lenHeight++
	}

	; stretch non fixed rows and columns if appropriate
	if resizeRules {
		Loop, Parse, resizeRules, %A_Space%
			fixed%A_LoopField% = true
		width -= spacing * (lenWidth - 1) + marginX * 2
		rc = c
		wh = width
		GoSub, Stretch
		height -= spacing * (lenHeight - 1) + marginY * 2
		rc = r
		wh = height
		GoSub, Stretch
	}
	
	totWidth += spacing * (lenWidth - 1) + marginX * 2
	totHeight += spacing * (lenHeight - 1) + marginY * 2

	Loop, %lenWidth% {
		i := A_Index + 1
		x%i% := x%A_Index% + width%A_Index% + spacing
	}
	Loop, %lenHeight% {
		i := A_Index + 1
		y%i% := y%A_Index% + height%A_Index% + spacing
	}
	
	; position each control in its cell based on the alignment rules given
	delay := A_ControlDelay
	SetControlDelay, -1

	Loop, Parse, ctrls, `n
	{
		cell := %A_LoopField%cell
		row := %A_LoopField%r
		column := %A_LoopField%c
		a := %cell%a
		v := %cell%v
		x := x%column%
		pl := %cell%l ? %cell%l : %cell%p ? %cell%p : 0
		pr := %cell%e ? %cell%e : %cell%p ? %cell%p : 0
		if (%cell%xW || a) {
			w := -spacing
			cs := %cell%c
			Loop, %cs% {
				i := column + A_Index - 1
				w += width%i% + spacing
			}
			if %cell%xW {
				x += pl
				w -= pl + pr
			} else {
				cellW := w
				w := %A_LoopField%w
				cellX := cellW - w
				if (a = 1) {
					cellX -= pl + pr
					cellX := pl + cellX / 2
				} else
					cellX -= pr
				x += cellX
			}
		} else {
			w := %A_LoopField%w
			x += pl
		}
		y := y%row%
		pt := %cell%t ? %cell%t : %cell%p ? %cell%p : 0
		pb := %cell%b ? %cell%b : %cell%p ? %cell%p : 0
		if (%cell%xH || v) {
			h := -spacing
			rs := %cell%r
			Loop, %rs% {
				i := row + A_Index - 1
				h += height%i% + spacing
			}
			if %cell%xH {
				y += pt
				h -= pt + pb
			} else {
				cellH := h
				h := %A_LoopField%h
				cellY := cellH - h
				if (v = 1) {
					cellY -= pt + pb
					cellY := pt + cellY / 2
				} else
					cellY -= pb
				y += cellY
			}
		} else {
			h := %A_LoopField%h
			y += pt
		}
		ControlMove, %A_LoopField%, x, y, w, h
	}
	SetControlDelay, %delay%

	return

	CheckNeeded:
		spanLength = -spacing
		Loop, %span% {
			spanLength += %wh%%n% + spacing
			n++
		}
		if (l > spanLength) {
			needed := l - spanLength
			if needed%wh% {
				if needed in % needed%wh%
				{
					needed%wh%%needed%l := needed%wh%%needed%l . "," . l
					needed%wh%%needed%n := needed%wh%%needed%n . "," . n-span
					needed%wh%%needed%s := needed%wh%%needed%s . "," . span
					return
				}
				needed%wh% := needed%wh% . "," . needed
			} else
				needed%wh% := needed
			needed%wh%%needed%l := l
			needed%wh%%needed%n := n-span
			needed%wh%%needed%s := span
		}
		return
	CheckPadding:
		if %cell%%p%
			%wh% += %cell%%p%
		else if %cell%p
			%wh% += %cell%p
		return
	CheckHeight:
		if %cell%xH
			return
		span := %cell%r
		if (span > 1) {
			wh = height
			l := h
			n := row
			GoSub, CheckNeeded
		} else if (h > height%row%)
			height%row% := h
		return
	CheckWidth:
		if %cell%xW
			return
		span := %cell%c
		if (span > 1) {
			wh = width
			l := w
			n := column
			GoSub, CheckNeeded
		} else if (w > width%column%)
			width%column% := w
		return
	Stretch:
		if (!fixed%rc% && tot%wh% && %wh% > tot%wh%) {
			stretch := tot%wh%
			len := len%wh%
			Loop, %len% {
				l := %wh%%A_Index%
				if fixed%rc%%A_Index% {
					stretch -= l
					%wh% -= l
				}
			}
			error := %wh%
			stretch := %wh% / stretch
			Loop, %len% {
				l := %wh%%A_Index%
				if !fixed%rc%%A_Index%
					error -= (%wh%%A_Index% := Round(l * stretch))
			}
			if error {
				inc := error < 0 ? -1 : 1
				Loop {
					if !fixed%rc%%A_Index%
						%wh%%A_Index% += inc
					if !(error -= inc)
						break
				}
			}
			
		}
		return
	Expand:
		Sort, needed%wh%, N D`, R
		Loop, Parse, needed%wh%, `,
		{
			StringSplit, l, needed%wh%%A_LoopField%l, `,
			StringSplit, n, needed%wh%%A_LoopField%n, `,
			StringSplit, s, needed%wh%%A_LoopField%s, `,
			Loop, %n0% {
				l := l%A_Index%
				n := n%A_Index%
				span := s%A_Index%
				spanLength := -spacing
				zeros = 0
				Loop, %span% {
					if width%n%
						spanLength += width%n% + spacing
					else {
						spanLength += spacing
						zeros++
						zeros%zeros% := n
					}
					n++
				}
				needed := l - spanLength
				if (needed <= 0)
					continue
				if (needed != A_LoopField) {
					; must reinsert at proper position, necessary to compact a table to its minimum size
					if needed in % needed%wh%
					{
						needed%wh%%needed%l := needed%wh%%needed%l . "," . l
						needed%wh%%needed%n := needed%wh%%needed%n . "," . n-span
						needed%wh%%needed%s := needed%wh%%needed%s . "," . span
					} else {
						resort = true
						needed%wh% := needed%wh% . "," . needed
						needed%wh%%needed%l := l
						needed%wh%%needed%n := n-span
						needed%wh%%needed%s := span
					}
				} else {
					if zeros {
						error := Mod(needed, zeros)
						l := Floor(needed/zeros)
						Loop, %zeros% {
							n := zeros%A_Index%
							%wh%%n% := l
							if error {
								%wh%%n% += 1
								error -= 1
							}
						}
					} else {
						error := l - spacing * (span - 1)
						stretch := error / (spanLength - spacing * (span - 1))
						Loop, %span% {
							n--
							l := %wh%%n%
							error -= (%wh%%n% := Round(l * stretch))
						}
						if error {
							inc := error < 0 ? -1 : 1
							Loop {
								%wh%%n% += inc
								if !(error -= inc)
									break
								n++
							}
						}
					}
				}
			}
			if resort {
				resort = false
; TODO use List.ahk optimizations
				needed%wh% := "," . needed%wh%
				pos := InStr(needed%wh%, "," . A_LoopField . ",")
				StringMid, needed%wh%, needed%wh%, pos + StrLen(A_LoopField) + 2
				GoTo, Expand
			}
		}
		return
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
	static WS_VISIBLE=0x10000000, WS_CHILD=0x40000000, WS_CLIPCHILDREN=0x2000000
	static SS_BLACKFRAME = 7, SS_BLACKRECT = 4, SS_CENTER = 1, SS_ETCHEDFRAME = 0x12, SS_ETCHEDHORZ = 0x10, SS_ETCHEDVERT = 0x11, SS_GRAYFRAME = 0x8, SS_GRAYRECT = 0x5, SS_RIGHT = 2, SS_SUNKEN = 0x1000, SS_WHITEFRAME = 9, SS_WHITERECT = 6

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
	  , "Uint",   WS_VISIBLE | WS_CHILD	| WS_CLIPCHILDREN | hstyle
	  , "int",    x, "int", y, "int",w, "int",h
	  , "Uint",   hGui
	  , "Uint",   0, "Uint",0, "Uint",0, Uint) 

	ifEqual, res, 0, return "Err: failed to create control"
	return res + 0
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
Panel_GuiSize(w,h,e,main){
	static s
	
	if e = 1
		return s:=e
	else if (e=2) and (s=1)
		return s:=e

	ControlMove, , , ,w,h, ahk_id %main%	
	s := e
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
	static WM_SIZE = 0x05,  SWP_NOSIZE=1, SWP_NOMOVE=2
	static redirect = "32,78,273,277,279", anc		;WM_SETCURSOR, WM_COMMAND,WM_NOTIFY,WM_HSCROLL,WM_VSCROLL
	
	critical  30		;!!! 

	if uMsg in %redirect%
	{	

		if !anc
			anc := DllCall("GetAncestor", "uint", hwnd, "uint",2) ;GWL_ROOT = 2
		return DllCall("SendMessage", "uint", anc, "uint", umsg, "uint", wparam, "uint", lparam)
	}

	if (umsg = WM_SIZE)
		Panel_size(hwnd, lparam & 0xFFFF, lparam >> 16)

	return DllCall("CallWindowProc","uint",A_EventInfo,"uint",hwnd,"uint",uMsg,"uint",wParam,"uint",lParam)
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

;------------------------------------------------------------------------------
; function that parases panel 
;  a - autohotkey things
;  x - extended things 
;
Panel_parse(def, ByRef a, ByRef x){
	static extra="x,y,w,h,L,A"
	static styles = "BLACKFRAME,BLACKRECT,TCENTER,ETCHEDFRAME,ETCHEDHORZ,ETCHEDVERT,GRAYFRAME,GRAYRECT,TRIGHT,sunken,WHITEFRAME,WHITERECT"
	static ahk = "BackgroundTrans,Background,Border,Theme,AltSubmit,Disabled,Hidden,Left,Right,Center,Section,TabStop,Wrap,VScroll,HScroll"
	static colors="cBlack,cSilver,cGray,cWhite,cMaroon,cRed,cPurple,cFuchsia,cGreen,cLime,cOlive,cYellow,cNavy,cBlue,cTeal,cAqua"

	a := x := ""
	loop, parse, def, %A_Space%%A_Tab%, %A_Space%%A_Tab%
	{
		ifEqual A_LoopField, ,continue
		token := A_LoopField

		if token is Integer
		{
			a .= token " "
			continue
		}

		c1 := c2 := SubStr(token, 1, 1)
		if c1 in +,-
			token := SubStr(token, 2)
		else c1 =

		if token in %ahk%,%colors%
		{
			a .= c1 token " "
			continue
		} else	if (c2 = "g") or (c2="c" and SubStr(token, 2))
				{
					a .= token " "
					continue			
				}
		if token in %styles%
		{
			a .= token " "
			continue
		}

		if c2 not in %extra%									
				return "Err: Invalid option - " token
		x .= token " " 
	}	
	return "OK"
}



;-------------------------------------------------------------------------------------------------------------------
;Group: Example



;-------------------------------------------------------------------------------------------------------------------
;Group: About
;	o Ver 1.0 a1 by majkinetor. 
;	o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.