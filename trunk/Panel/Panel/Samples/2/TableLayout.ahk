/*  Function: TableLayout
			  Automatically layout controls for the "Last Found Window"

   Parameters:
   	rules - List of rules for each cell, See Syntax of Rules
   	spacing - The margin between each cell
   	marginX - Horizontal margin for the table
   	marginY - Vertical margin for the table
	ctrls	- List of controls delimited by `n
   	xi		- Optional  x position from the windows top left corner to position the table if a blank variable is passed, the x AND y position will be that of the first control in the parameter ctrls, both xi and yi will be updated with the x,y position of the table
   	yi		- Optional y position from the windows top left corn er to position the table
   	totWidth - Optional width of the table including margins and spacing contents will be ignored if resizeRules is not specified the resulting width of the table is stored in this variable regardless
   	totHeight - Optional height of the table including margins and spacing contents will be ignored if resizeRules is not specified the resulting height of the table is stored in this variable regardless
	resizeRules - List of rules for resizing, See Syntax of Resize Rules
    
   Syntax of Rules:
	 |  - Column delimiter
   	_  - Row delimiter
   	__ - (two underscores) will mark where to repeat if more rows are needed than provided in the rules
			will default to repeat back to the first row if two consecutive underscores are not encountered
   			useful for providing a header row that should not be repeated..
   	_# - Will repeat the preceeding row # times (e.g a1|a1_2_c2 will be 3 rows of a1|a1, 1 row of c2).
   	n# - default = 1. Number of controls to put in cell. Note that they will overlap (useful for hiding/showing different controls).
   		 If 0 is specified, the cell will be left empty.
   	r# - [rowSpan] default = 1. Rows the control spans.
   	c# - [colSpan] default= 1. Columns the control spans.
   	a# - [align] default = 0. Alignment of control in cell: 0 (left), 1 (center), 2 (right)
   	v# - [vAlign] default = 0. Vertical alignment of control in cell: 0 (top), 1 (middle), 2 (bottom)
   	h# - Minimum height of cell, by default 0. If this is set (>0), the control will be expanded to fit the height of its cell (minus padding)
   		If it is not set, the height will never be any less than the preset height of the control (plus padding)
   		See Also f#
   	w# - [width] default = 0.
   		Minimum width of cell
   		If this is set (>0), the control will be expanded to fit the width of its cell (minus padding)
   		If it is not set, the width will never be any less than the preset width of the control (plus padding)
   		See Also f#
   	f# - [fixed control size] default = 0. 0 (not fixed, control will expand to the width of its cell if w# is specified and the height of its cell if h# is specified), 
   		1 (fixed width), 2 (fixed height), 3(fixed width and height)
   	p# - [padding] default = 0. Width and height of the padding between the cell edges and control edges
   		t# b# e# and l# will be used in preference to this value. So to set a padding of t1 b3 e3 l3, you can instead use t1 p3
   	t# - [north/top padding] default = 0
   		height of the padding between the top edge of the cell and the top edge of the control
   	b# - [south/bottom padding] default = 0
   		height of the padding between the bottom edge of the cell and the bottom edge of the control
   	e# - [east/right padding] default = 0
   		width of the padding between the right edge of the cell and the right edge of the control
   	l# - [west/left padding] default = 0
   		width of the padding between the left edge of the cell and the left edge of the control
   
   Syntax of Resize Rules:
   	r  - all rows have a fixed height
   	c  - all columns have a fixed width
   	r# - row # has a fixed height (may include multiple, i.e r1 r3)
   	c# - column # has a fixed width (may include multiple as above)
 
   Example 1: 
   Laying out all controls in a window.
   (start code)
		Gui, +LastFound
		Gui, Margin , 0, 0  ; use layout margin
		Gui, Add, Text, , Label 1:
		Gui, Add, Edit
		Gui, Add, CheckBox
		Gui, Add, Text, , Label 2:
		Gui, Add, Edit
		Gui, Add, CheckBox
		Gui, Add, Text, , Label 3:
		Gui, Add, Edit
		Gui, Add, CheckBox
		Size := WindowTableLayout("a2 v1||v1", 5, 5, 5)
			; a2 - right alignment
			; v1 - middle alignment
		Gui, Show, %Size%
	return
  (end)
   
   Example 2: 
   Laying out all controls in a resizable window.
    (start code)
		Gui, +LastFound +Resize
		Gui, Margin , 0, 0
		Gui, Add, Edit ; all edit controls are used in the ecample to give each cell a visual representation.
		Gui, Add, Edit
		Gui, Add, Edit
		Gui, Add, Edit
		Gui, Add, Edit
		Gui, Add, Edit
		Size := WindowTableLayoutResize("w100 h20|w100 h1|w100 h1 r2_w1 h20 c2_w1 c3_w1 h20 c3,5,5,5,r3")
			; comma delimited list of fules, spacing, marginX, marginY, resizeRuiles
			; r3 in resizeRules will fix the height of row 3
		Gui, Show, %Size%
   	return
   	
	GuiSize:
   		WindowTableLayoutResize()
   	return
   (end)
 */

TableLayout(ByRef ctrls, ByRef rules, ByRef spacing, ByRef marginX, ByRef marginY, ByRef xi = "", ByRef yi = "", ByRef totWidth = "", ByRef totHeight = "", ByRef resizeRules = "") {
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

WindowTableLayout(rules, spacing, marginX, marginY, ByRef ctrls = "", ByRef x = "", ByRef y = "", ByRef w = "", ByRef h = "") {
	if !ctrls
		WinGet, ctrls, ControlList
	TableLayout(ctrls, rules, spacing, marginX, marginY, x, y, w, h)
	return "w" w " h" h
}

WindowTableLayoutResize(set = "") {
	static ctrls, rules, spacing, marginX, marginY, resizeRules, x, y, w, h
	if set {
		WinGet, ctrls, ControlList
		StringSplit, set, set, `,
		rules := set1
		spacing := set2
		marginX := set3
		marginY := set4
		resizeRules := set5 ? set5 : true
		TableLayout(ctrls, rules, spacing, marginX, marginY, x, y, w, h)
		return "w" w " h" h
	}
	w := A_GuiWidth
	h := A_GuiHeight
	TableLayout(ctrls, rules, spacing, marginX, marginY, x, y, w, h, resizeRules)
}


















