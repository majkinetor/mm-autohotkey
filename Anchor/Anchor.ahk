_()
	Gui, +Resize +LastFound
	hGui := WinExist()

	Gui, Add, Edit, HWNDhe1 w100 h100
	Anchor(he1, "w.5 h")
	Gui, Add, Picture, HWNDhe2 w100 x+5 h100, pic.bmp 
	Anchor(he2, "x.5 w.5 h r")

	Gui, Add, Edit, HWNDhe3 w100 xm h100
	Anchor(he3, "y w1/3")
	Gui, Add, Edit, HWNDhe4 w100 x+5 h100
	Anchor(he4, "y x1/3 w1/3")
	Gui, Add, Edit, HWNDhe5 w100 yp x+5 h100
	Anchor(he5, "y x2/3 w1/3")

	Gui, Show, autosize
return


F1::
	Win_MoveDelta(he1, "", "", -50)
	Win_MoveDelta(he2, -50, "", 50)
	Anchor()	;reset
return

Anchor(hCtrl="", aDef="") {
	return _Anchor(hCtrl, aDef, "", "")
}

_Anchor(hCtrl, aDef, Msg, hParent){
	static
	if (hParent = ""){
		if !adrSetWindowPos
			adrSetWindowPos := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "SetWindowPos")
			,adrWindowInfo  := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "GetWindowInfo")
			,OnMessage(5, A_ThisFunc),	VarSetCapacity(B, 60), NumPut(60, B), adrB := &B

		hParent := DllCall("GetParent", "uint", hCtrl, "Uint")
		gosub Anchor_GetPos

		loop, parse, aDef, %A_Space%
		{
			l := A_LoopField,	f := SubStr(l,1,1), k := StrLen(l)=1 ? 1 : SubStr(l,2)
			if (j := InStr(l, "/"))
				k := SubStr(l, 2, j-2) / SubStr(l, j+1)
			%hCtrl% .= l="r" ? "r " : (f ":" k ":" c%f% " ")
		}
		return %hCtrl% := SubStr(%hCtrl%, 1, -1), %hParent% .= InStr(%hParent%, hCtrl) ? "" : hCtrl " "
	}

	pw := aDef & 0xFFFF, ph := aDef >> 16
	if (%hParent%_s = "")
		%hParent%_s := pw " " ph
		
	StringSplit, s, %hParent%_s, %A_Space%
	loop, parse, %hParent%, %A_Space%
	{
		hCtrl := A_LoopField, aDef := %hCtrl%, 	uw := uh := ux := uy := r := 0
		gosub Anchor_GetPos
		loop, parse, aDef, %A_Space%
			ifEqual, A_LoopField, r, SetEnv, r, 1
			else {
				StringSplit, z, A_LoopField, :
				c%z1% := z3 + z2 * (z1="x" || z1="w" ? pw-s1 : ph-s2), u%z1% := true
			}
		flag := 4 | (r=1 ? 0x100 : 0) | (uw OR uh ? 0 : 1) | (ux OR uy ? 0 : 2)			; nozorder=4 nocopybits=0x100 SWP_NOSIZE=1 SWP_NOMOVE=2						
		DllCall(adrSetWindowPos, "uint", hCtrl, "uint", 0, "uint", cx, "uint", cy, "uint", cw, "uint", ch, "uint", flag)
	}

 Anchor_GetPos:	
		DllCall(adrWindowInfo, "uint", hParent, "uint", adrB), 	lx := NumGet(B, 20), ly := NumGet(B, 24), DllCall(adrWindowInfo, "uint", hCtrl, "uint", adrB)
		,cx :=NumGet(B, 4),	cy := NumGet(B, 8), cw := NumGet(B, 12)-cx, ch := NumGet(B, 16)-cy, cx-=lx, cy-=ly
 return
}