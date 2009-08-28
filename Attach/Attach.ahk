/*
	Function:		Attach
					Determines how a control is resized with its parent.

	Parameters:		
					hCtrl	-  - hWnd of the control if aDef is not empty.
					 		-  - hWnd of the parent to be reset if aDef is empty. If you are using the function with only one parent, you don't have to
								 specify its handle, its enough to call Attach without any parameters.
								 With multiple parents you need to specify which one you want to reset.
					 		-  - Handler name, if parameter is string and aDef is empty. Handler will be called after the function has finished 
								 moving controls for the parent. Handler receives hWnd of the parent as its only argument.


					aDef	- Attach definition string. Space separated list of attach options.
					 		- You can use x,y,w,h,r,p letters along with coefficients, decimal numbers which can also
							  be specified in m/n form (see example below). "r" or "r1" option specifies that control should be redrawn immediately.
							  Specify "r2" to delay redrawing 100ms for the control. This can be used to prevent redrawing spam which in some situations
							  may be annoying. 
							  "p" is special coeficient that can only be used without x-h options. It means "proportional". It will make control always stay 
							  in the same proportion to its parent (so, pin the control to the parent). Although you can mix pinned and non-pinned controls 
							  that is rarely what you want. You will generally want to pin every control in the parent.

					 		- You can use single letters "+" or "-" to enable or disable function for the control. If control is hidden, you may want to 
							  disable the function for performance reasons. Its perfectly OK to leave invisible controls attached, but if you have lots of 
							  them you can use this feature to get faster and more responsive updates.
							  When you want to show disabled invisible control, make sure you first attach it back so it can take its correct position
							  and size while in hidden state, then show it.
					 		- If aDef parameter is omitted, function working depends on 1st parameter.

	Remarks:
					You should reset the function when you programmatically change the position of the controls in the parent control.
					Don't do this while parent is resizing as resetting procedure may be interrupted.
					
					Function monitors WM_SIZE message to detect parent changes. That means that it can be used with other eventual container controls
					and not only top level windows.

	Examples:
	(start code)
					Attach(h, "w.5 h1/3 r2")	;Attach control's w, h and redraw it with delay.
					Attach(h, "-")				;Disable function for control h but keep its definition. To enable it latter use "+".
					Attach()					;Reset first parent. Use when you have only 1 parent.
					Attach(hGui2)				;Reset Gui2.
					Attach("Win_Redraw")		;Use Win_Redraw function as a Handler. Attach will call it with parent's handle as argument.

					
					; This is how to do delayed refresh of entire window.
					; To prevent redraw spam which can be annoying in some cases, 
					; you can choose to redraw entire window only when user has finished resizing it.
					; This is similar to r2 option for controls, except it works with entire parent.
					
					Attach("OnAttach")			;Set Handler to OnAttach function
					...
					
					OnAttach( Hwnd ) {
						global hGuiToRedraw := hwnd
						SetTimer, Redraw, -100
					}

					Redraw:
						Win_Redraw(hGuiToRedraw)
					return

	(end code)
	Full Example:
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
	 Attach_(hCtrl, aDef, "", "")
}

Attach_(hCtrl, aDef, Msg, hParent){
	static

	if (aDef = "") {							;Reset if integer, Handler if string
		if IsFunc(hCtrl)
			return Handler := hCtrl
		hParent := hCtrl != "" ? hCtrl+0 : hGui
		loop, parse, %hParent%, %A_Space%
		{
			hCtrl := A_LoopField, SubStr(%hCtrl%,1,1), aDef := SubStr(%hCtrl%,1,1)="-" ? SubStr(%hCtrl%,2) : %hCtrl%,  %hCtrl% := ""
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

	if (hParent = "")  {						;Initialize controls 
		if !adrSetWindowPos
			adrSetWindowPos		:= DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "SetWindowPos")
			,adrWindowInfo		:= DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "GetWindowInfo")
			,OnMessage(5, A_ThisFunc),	VarSetCapacity(B, 60), NumPut(60, B), adrB := &B

		hGui := hParent := DllCall("GetParent", "uint", hCtrl, "Uint") 
		if aDef contains p
			aDef := "xp yp wp hp" SubStr(aDef, 2)
		ifEqual, aDef, -, return SubStr(%hCtrl%,1,1) != "-" ? %hCtrl% := "-" %hCtrl% : 
		else if (aDef = "+")
			SubStr(%hCtrl%,1,1) != "-" ? return : %hCtrl% := SubStr(%hCtrl%, 2), enable := 1 
		else {
			gosub Attach_GetPos
			%hCtrl% := ""
			loop, parse, aDef, %A_Space%
			{
				l := A_LoopField,	f := SubStr(l,1,1), k := StrLen(l)=1 ? 1 : SubStr(l,2)
				if (j := InStr(l, "/"))
					k := SubStr(l, 2, j-2) / SubStr(l, j+1)
				%hCtrl% .= f ":" k ":" c%f% " "
			}
			return %hCtrl% := SubStr(%hCtrl%, 1, -1), %hParent% .= InStr(%hParent%, hCtrl) ? "" : (%hParent% = "" ? "" : " ")  hCtrl 
		}
	}
 	if !reset && !enable {						;WM_SIZE handler starts here
		%hParent%_pw := aDef & 0xFFFF, %hParent%_ph := aDef >> 16
		ifEqual, %hParent%_ph, 0, return		;when u create gui without any control, it will send message with height=0 and scramble the controls ....
	}
	if (%hParent%_s = "") || reset
		%hParent%_s := %hParent%_pw " " %hParent%_ph,  reset := 0

	StringSplit, s, %hParent%_s, %A_Space%
	loop, parse, %hParent%, %A_Space%
	{
		hCtrl := A_LoopField, aDef := %hCtrl%, 	uw := uh := ux := uy := r := 0, hCtrl1 := SubStr(%hCtrl%,1,1)
		ifEqual, hCtrl1, -, continue
		
		gosub Attach_GetPos
		loop, parse, aDef, %A_Space%
		{
			StringSplit, z, A_LoopField, :		; opt:coef:initial
			ifEqual, z1, r, SetEnv, r, %z2%
			else if z2=p
				 c%z1% := z3 * (z1="x" || z1="w" ?  %hParent%_pw/s1 : %hParent%_ph/s2), u%z1% := true
			else c%z1% := z3 + z2*(z1="x" || z1="w" ?  %hParent%_pw-s1 : %hParent%_ph-s2), 	u%z1% := true
		}
		flag := 4 | (r=1 ? 0x100 : 0) | (uw OR uh ? 0 : 1) | (ux OR uy ? 0 : 2)			; nozorder=4 nocopybits=0x100 SWP_NOSIZE=1 SWP_NOMOVE=2						
		DllCall(adrSetWindowPos, "uint", hCtrl, "uint", 0, "uint", cx, "uint", cy, "uint", cw, "uint", ch, "uint", flag)
		r+0=2 ? Attach_redrawDelayed(hCtrl) : 
	}

	return Handler != "" ? %Handler%(hParent) : "", enable := 0

 Attach_GetPos:									;hParent & hCtrl must be set up at this point
		DllCall(adrWindowInfo, "uint", hParent, "uint", adrB), 	lx := NumGet(B, 20), ly := NumGet(B, 24), DllCall(adrWindowInfo, "uint", hCtrl, "uint", adrB)
		,cx :=NumGet(B, 4),	cy := NumGet(B, 8), cw := NumGet(B, 12)-cx, ch := NumGet(B, 16)-cy, cx-=lx, cy-=ly
 return
}

Attach_redrawDelayed(hCtrl){
	static s
	s .= !InStr(s, hCtrl) ? hCtrl " " : ""
	SetTimer, %A_ThisFunc%, -100
	return
 Attach_redrawDelayed:
	loop, parse, s, %A_Space%
		WinSet, Redraw, , ahk_id %A_LoopField%
 return, s := ""
}
