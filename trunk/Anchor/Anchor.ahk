Anchor(hCtrl="", aDef="") {
	 _Anchor(hCtrl, aDef, "", "")
}

_Anchor(hCtrl, aDef, Msg, hParent){
	static

	if (hCtrl = "") {		;reset
		hParent := hGui
		loop, parse, %hParent%, %A_Space%
		{
			hCtrl := A_LoopField,  aDef := %hCtrl%,  %hCtrl% := ""
			gosub Anchor_GetPos
			loop, parse, aDef, %A_Space%
			{
				StringSplit, z, A_LoopField, :
				%hCtrl% .= A_LoopField="r" ? "r " : (z1 ":" z2 ":" c%z1% " ")
			}
			%hCtrl% := SubStr(%hCtrl%, 1, -1)
		}
		return reset := 1
	}

	if (hParent = ""){		;prepare
		if !adrSetWindowPos
			adrSetWindowPos := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "SetWindowPos")
			,adrWindowInfo  := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "GetWindowInfo")
			,OnMessage(5, A_ThisFunc),	VarSetCapacity(B, 60), NumPut(60, B), adrB := &B
			,hGui := DllCall("GetParent", "uint", hCtrl, "Uint") 

		hParent := hGui
		gosub Anchor_GetPos
		loop, parse, aDef, %A_Space%
		{
			l := A_LoopField,	f := SubStr(l,1,1), k := StrLen(l)=1 ? 1 : SubStr(l,2)
			if (j := InStr(l, "/"))
				k := SubStr(l, 2, j-2) / SubStr(l, j+1)
			%hCtrl% .= l="r" ? "r " : (f ":" k ":" c%f% " ")
		}
		return %hCtrl% := SubStr(%hCtrl%, 1, -1), %hParent% .= InStr(%hParent%, hCtrl) ? "" : (%hParent% = "" ? "" : " ")  hCtrl 
	}
	pw := aDef & 0xFFFF, ph := aDef >> 16
	outputdebug %wparam%
		
	if (%hParent%_s = "") || reset
		%hParent%_s := pw " " ph, reset := 0
		
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
	return

 Anchor_GetPos:		;hParent & hCtrl must be set up
		DllCall(adrWindowInfo, "uint", hParent, "uint", adrB), 	lx := NumGet(B, 20), ly := NumGet(B, 24), DllCall(adrWindowInfo, "uint", hCtrl, "uint", adrB)
		,cx :=NumGet(B, 4),	cy := NumGet(B, 8), cw := NumGet(B, 12)-cx, ch := NumGet(B, 16)-cy, cx-=lx, cy-=ly
 return
}