_()
	Gui, +Resize +LastFound
	hGui := WinExist()

	Gui, Add, Edit, HWNDhe1 w100 h100
	Anchor(he1, "w.5h")
	Gui, Add, Picture, HWNDhe2 w100 x+5 h100, c:\WINDOWS\Soap Bubbles.bmp 
	Anchor(he2, "x.5w.5hr")

	Gui, Add, Edit, HWNDhe3 w100 xm h100
	Anchor(he3, "y")
	Gui, Add, Edit, HWNDhe4 w100 x+5 h100
	Anchor(he4, "yw")

	Gui, Show, autosize
return


F1::
	Win_MoveDelta(he1, "", "", -50)
	Win_MoveDelta(he2, -50, "", 50)
	Anchor()	;reset
return

F2::
;	Win_GetRect(he1, "*xywh", x,y,w,h)
;	GetPos(hGui, he1, x,y,w,h)
;	m(x,y,w,h)
return



GetPos(hParent, hCtrl, ByRef x="", ByRef y="", ByRef w="", ByRef h=""){
	static
	if !adrB
		VarSetCapacity(B, 60), NumPut(60, B), adrB := &B ,adrWindowInfo := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "GetWindowInfo")
		
	DllCall(adrWindowInfo, "uint", hParent, "uint", adrB)
	px := NumGet(B, 4), py := NumGet(B, 8), pw := NumGet(B, 12)	- px, ph := NumGet(B, 16)- py,  lx := NumGet(B, 20), ly := NumGet(B, 24)

	DllCall(adrWindowInfo, "uint", hCtrl, "uint", adrB)
	x := NumGet(B, 4),	y := NumGet(B, 8), w := NumGet(B, 12)-x, h := NumGet(B, 16)-y, x-=lx, y-=ly
}




Anchor(hCtrl="", aDef="") {
	_Anchor(hCtrl, aDef, "", "")
}

_Anchor(hCtrl, aDef, Msg, Hwnd){
	static
	static tokens="x,w,y,h,r", adrSetWindowPos, WM_SIZE = 0x05

	if Hwnd =
	{
		if !adrSetWindowPos
		{
			adrSetWindowPos := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "SetWindowPos")
			OnMessage(WM_SIZE, A_ThisFunc)
		}
		hPanel := DllCall("GetParent", "uint", hCtrl)
		GetPos(hPanel, hCtrl, cx, cy, cw, ch)

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

		if j := InStr(%hPanel%_a , "`n"  hCtrl " ")
		{
			re = `nm)^%hCtrl%.+$
			%hPanel%_a := RegExReplace(%hPanel%_a, re, hCtrl " " aDef)
			reset := 1
		} else 
			%hPanel%_a .= "`n"  hCtrl " " aDef	;store anchor definition for the control
		
		return
	}
	pw := aDef & 0xFFFF,	ph := aDef >> 16	
	if (%hwnd%_s = "") || reset 
		%hwnd%_s := pw " " ph, reset := 0
	
	StringSplit, s, %Hwnd%_s, %A_Space%
	loop, parse, %Hwnd%_a, `n, `n
	{
		ifEqual, A_LoopField, , continue
		j := InStr(A_LoopField, " "), hCtrl := SubStr(A_LoopField, 1, j-1), aDef := SubStr(A_LoopField, j+1)

		GetPos(Hwnd, hCtrl, cx, cy, cw, ch)
		r := 0
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

		DllCall(adrSetWindowPos, "uint", hCtrl, "uint", 0, "uint", cx, "uint", cy, "uint", cw, "uint", ch, "uint", flag) ; SWP_NOZORDER=4
;		ifEqual, r, 2, % redrawDelayed(hCtrl)
	}
}