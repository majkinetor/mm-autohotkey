/*
	Function:		Attach
					Determines how a control is resized with its parent.

	Parameters:		
					hCtrl	- hWnd of the control. If omited, function will reset its internal data. If you have multiple parents specify which one you want
							  to reset as this parameter.
					aDef	- Attach definition string. You can use x,y,w,h and r letters along with coefficients, decimal numbers which can also
							  be specified in p/q form. "r" option signifies that control should be redrawn (see example below). If first parameter is omited, 
							  aDef holds the handle of the parent to be reset. You don't have to specify parent if you have only one, in which case Attach() 
							  resets internal storage.

	Remarks:
					You should reset Attach when you programmatically change the position of the controls. 
					Don't do this while parent is resizing as reseting procedure may be interupted.
					Function monitors WM_SIZE message to detect parent changes. That means that it can be used with other eventual container controls
					and not only top level windows.

	Example:
	(start code)
		#SingleInstance, force
			Gui, +Resize
			Gui, Add, Edit, HWNDhe1 w150 h100
			Gui, Add, Picture, HWNDhe2 w100 x+5 h100, pic.bmp 

			Gui, Add, Edit, HWNDhe3 w100 xm h100
			Gui, Add, Edit, HWNDhe4 w100 x+5 h100
			Gui, Add, Edit, HWNDhe5 w100 yp x+5 h100
			
			gosub SetAttach					;comment this line to disable Attach
			Gui, Show, autosize			
		return

		SetAttach:
			Attach(he1, "w.5 h")		
			Attach(he2, "x.5 w.5 h r")
			Attach(he3, "y w1/3")
			Attach(he4, "y x1/3 w1/3")
			Attach(he5, "y x2/3 w1/3")
		return
	(end code)

	About:
			o 1.0 by majkinetor
			o Licenced under BSD <http://creativecommons.org/licenses/BSD/> 
 */

Attach(hCtrl="", aDef="") {
	 _Attach(hCtrl, aDef, "", "")
}

_Attach(hCtrl, aDef, Msg, hParent){
	static

	if (aDef = "") {					;reset
		hParent := hCtrl != "" ? hCtrl+0 : hGui
		loop, parse, %hParent%, %A_Space%
		{
			hCtrl := A_LoopField,  aDef := %hCtrl%,  %hCtrl% := ""
			gosub Attach_GetPos
			loop, parse, aDef, %A_Space%
			{
				StringSplit, z, A_LoopField, :
				%hCtrl% .= A_LoopField="r" ? "r " : (z1 ":" z2 ":" c%z1% " ")
			}
			%hCtrl% := SubStr(%hCtrl%, 1, -1)				
		}
		reset := 1
	}

	if (hParent = "")  {		;initialize
		if !adrSetWindowPos
			adrSetWindowPos := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "SetWindowPos")
			,adrWindowInfo  := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "GetWindowInfo")
			,OnMessage(5, A_ThisFunc),	VarSetCapacity(B, 60), NumPut(60, B), adrB := &B

		hGui := hParent := DllCall("GetParent", "uint", hCtrl, "Uint") 
		gosub Attach_GetPos
		loop, parse, aDef, %A_Space%
		{
			l := A_LoopField,	f := SubStr(l,1,1), k := StrLen(l)=1 ? 1 : SubStr(l,2)
			if (j := InStr(l, "/"))
				k := SubStr(l, 2, j-2) / SubStr(l, j+1)
			%hCtrl% .= l="r" ? "r " : (f ":" k ":" c%f% " ")
		}
		return %hCtrl% := SubStr(%hCtrl%, 1, -1), %hParent% .= InStr(%hParent%, hCtrl) ? "" : (%hParent% = "" ? "" : " ")  hCtrl 
	}

	if !reset {
		%hParent%_pw := aDef & 0xFFFF, %hParent%_ph := aDef >> 16
		ifEqual, %hParent%_ph, 0, return		;when u create gui without any control, it will send message with height=0 and scramble the controls ....
	}

	if (%hParent%_s = "") || reset
		%hParent%_s := %hParent%_pw " " %hParent%_ph,  reset := 0

	StringSplit, s, %hParent%_s, %A_Space%
	loop, parse, %hParent%, %A_Space%
	{
		hCtrl := A_LoopField, aDef := %hCtrl%, 	uw := uh := ux := uy := r := 0
		gosub Attach_GetPos
		loop, parse, aDef, %A_Space%
			ifEqual, A_LoopField, r, SetEnv, r, 1
			else {
				StringSplit, z, A_LoopField, :
				c%z1% := z3 + z2 * (z1="x" || z1="w" ?  %hParent%_pw-s1 : %hParent%_ph-s2), u%z1% := true
			}
		flag := 4 | (r=1 ? 0x100 : 0) | (uw OR uh ? 0 : 1) | (ux OR uy ? 0 : 2)			; nozorder=4 nocopybits=0x100 SWP_NOSIZE=1 SWP_NOMOVE=2						
		DllCall(adrSetWindowPos, "uint", hCtrl, "uint", 0, "uint", cx, "uint", cy, "uint", cw, "uint", ch, "uint", flag)
	}
	return

 Attach_GetPos:		;hParent & hCtrl must be set up
		DllCall(adrWindowInfo, "uint", hParent, "uint", adrB), 	lx := NumGet(B, 20), ly := NumGet(B, 24), DllCall(adrWindowInfo, "uint", hCtrl, "uint", adrB)
		,cx :=NumGet(B, 4),	cy := NumGet(B, 8), cw := NumGet(B, 12)-cx, ch := NumGet(B, 16)-cy, cx-=lx, cy-=ly
 return
}