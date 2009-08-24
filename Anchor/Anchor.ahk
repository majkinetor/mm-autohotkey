;	static WM_SIZE = 0x05,
Anchor(hCtrl="", aDef=""){
	static tokens := "xywhr"
	static 
	
	if A_Gui !=
	{
		Gui, %A_Gui%:+LastFound
		hwnd := WinExist()
		return Panel_size(hwnd, %hPanel%_a)
	}
		

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

	%hPanel%_a .= "`n"  hCtrl " " aDef	;store anchor definition for the control
	%hPanel%_s := pw " " ph				;store size for the parent
}


Panel_size(Hwnd, aList, startSize) {
	static tokens="x,w,y,h", adrSetWindowPos

	if !adrSetWindowPos
		adrSetWindowPos := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "SetWindowPos")

	ph := A_GuiHeight, 	pw := A_GuiWidth
	ControlGetPos, px, py,,, , ahk_id %Hwnd%

	StringSplit, s, startSize, %A_Space%
	loop, parse, aList, `n, `n
	{
		ifEqual, A_LoopField, , continue
		
		j := InStr(A_LoopField, " "),  hCtrl := SubStr(A_LoopField, 1, j-1),  aDef := SubStr(A_LoopField, j+1)
		ControlGetPos, cx, cy, cw, ch, , ahk_id %hCtrl%
		cx-=px, cy-=py		;!!! -borderx -bordery
		loop, parse, aDef, %A_Space%
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

		DllCall(adrSetWindowPos, "uint", hCtrl, "uint", 0, "uint", cx, "uint", cy, "uint", cw, "uint", ch, "uint", flag)
;		ifEqual, r, 2, % RedrawDelayed(hCtrl)
	}
}