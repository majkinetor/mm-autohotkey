/*
	Title:	Win
			*Set of window functions*
 */


/*
 Function:	Animate
 			Enables you to produce special effects when showing or hiding windows.
 
 Parameters:
 			Type		- White space separated list of animation flags. By default, these flags take effect when showing a window.
			Time		- Specifies how long it takes to play the animation, in millisecond .
 
 Animation types:
			activate	- Activates the window. Do not use this value with HIDE flag.
			blend		- Uses a fade effect. This flag can be used only if hwnd is a top-level window.
			center		- Makes the window appear to collapse inward if HIDE is used or expand outward if the HIDE is not used. The various direction flags have no effect.
			hide		- Hides the window. By default, the window is shown.
			slide		- Uses slide animation. Ignored when used with CENTER.
			:
			hneg		- Animates the window from right to left. This flag can be used with roll or slide animation. It is ignored when used with CENTER or BLEND.
			hpos		- Animates the window from left to right. This flag can be used with roll or slide animation. It is ignored when used with CENTER or BLEND.
			vneg		- Animates the window from top to bottom. This flag can be used with roll or slide animation. It is ignored when used with CENTER or BLEND.
			vpos		- Animates the window from bottom to top. This flag can be used with roll or slide animation. It is ignored when used with CENTER or BLEND.
 Returns:
 			If the function succeeds, the return value is nonzero.
 
 */
Win_Animate(Hwnd, Type="", Time=100){
	static AW_ACTIVATE = 0x20000, AW_BLEND=0x80000, AW_CENTER=0x10, AW_HIDE=0x10000
			,AW_HNEG=0x2, AW_HPOS=0x1, AW_SLIDE=0x40000, AW_VNEG=0x8, AW_VPOS=0x4

	hFlags := 0
	loop, parse, Type, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		ifEqual, A_LoopField,,continue
		else hFlags |= AW_%A_LoopField%

	ifEqual, hFlags, ,return "Err: Some of the types are invalid"
	DllCall("AnimateWindow", "uint", Hwnd, "uint", Time, "uint", hFlags)
}

/*
 Function:	Get
 			Get window information
 
 Parameters:
 			pQ			- List of query parameters.
			o1 .. o9	- Reference to output variables. R,L,B & N query parameters can return multiple outputs.
 
 Query:
 			C,I			- Class, pId.
			R,L,B,N		- One of the window rectangles: R (window Rectangle), L (cLient rectangle screen coordinates), B (ver/hor Border), N (captioN rect).
 						  N gives size of the caption regardless of the window style. These coordinates include all title-bar elements except the window menu.
						  The function returns x, y, w & h separated by space. 
						  For all 4 query parameters you can additionaly specify x,y,w,h arguments in any order (except Border which can have only x(hor) and y(ver) arguments) to
						  extract desired number into ouput variable.
 			S,E			- Style, Extended style
 		    P,A,O		- Parents handle, Ancestors handle, Owners handle
 			M			- Module full path (owner exe), unlike WinGet,,ProcessName which returns only name without path.
 			T			- Title for top level windows or Text for child windows
 
 Returns:
 			o1
 
 Examples:
 (start code)
  	Win_Get(hwnd, "CIT", class, pid, text)					;get class, pid and text
    Win_Get(hwnd, "RxwTC", x, w, t, c)						;get x & width attributes of window rect, title and class
  	Win_Get(hwnd, "RxywhCLxyTBy",wx,wy,ww,wh,c,lx,ly,t,b)	;get all 4 attributes of window rect, class, x & y of client rect, text and horizontal border height
    right := Win_Get(hwnd, "Rx") + Win_Get(hwnd, "Rw")		;first output is returned as function result so u can use function in expressions.
    Win_Get(hwnd, "Rxw", x, w), right := x+w				;the same as above but faster
    right := Win_Get(hwnd, "Rxw", x, w ) + w				;not recommended
 (end code)
 */
Win_Get(Hwnd, pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7="", ByRef o8="", ByRef o9="") {
	if pQ contains R,B,L
		VarSetCapacity(WI, 60, 0), NumPut(60, WI),  DllCall("GetWindowInfo", "uint", Hwnd, "uint", &WI)

	k := i := 0
	loop
	{
		i++, k++
		if (_ := SubStr(pQ, k, 1)) = ""
			break

		if !IsLabel("Window_Get_" _ )
			return A_ThisFunc "> Invalid query parameter: " _
		Goto Window_Get_%_%

		Window_Get_C:
				WinGetClass, o%i%, ahk_id %hwnd%		
		continue

		Window_Get_I:
				WinGet, o%i%, PID, ahk_id20/08/2009 %hwnd%		
		continue

		Window_Get_N:
				rect := "title"
				VarSetCapacity(TBI, 44, 0), NumPut(44, TBI, 0), DllCall("GetTitleBarInfo", "uint", hwnd, "str", TBI)
				title_x := NumGet(TBI, 4, "Int"), title_y := NumGet(TBI, 8, "Int"), title_w := NumGet(TBI, 12) - title_x, title_h := NumGet(TBI, 16) - title_y 
				goto Window_Get_Rect
		Window_Get_B:
				rect := "border"
				border_x := NumGet(WI, 48, "UInt"),  border_y := NumGet(WI, 52, "UInt")	
				goto Window_Get_Rect
		Window_Get_R:
				rect := "window"
				window_x := NumGet(WI, 4,  "Int"),  window_y := NumGet(WI, 8,  "Int"),  window_w := NumGet(WI, 12, "Int") - window_x,  window_h := NumGet(WI, 16, "Int") - window_y
				goto Window_Get_Rect
		Window_Get_L: 
				client_x := NumGet(WI, 20, "Int"),  client_y := NumGet(WI, 24, "Int"),  client_w := NumGet(WI, 28, "Int") - client_x,  client_h := NumGet(WI, 32, "Int") - client_y
				rect := "client"
		Window_Get_Rect:
				k++, arg := SubStr(pQ, k, 1)
				if arg in x,y,w,h
				{
					o%i% := %rect%_%arg%, j := i++
					goto Window_Get_Rect
				}
				else if !j
						  o%i% := %rect%_x " " %rect%_y  (_ = "B" ? "" : " " %rect%_w " " %rect%_h)
				
		rect := "", k--, i--, j := 0
		continue
		Window_Get_S:
			WinGet, o%i%, Style, ahk_id %Hwnd%
		continue
		Window_Get_E: 
			WinGet, o%i%, ExStyle, ahk_id %Hwnd%
		continue
		Window_Get_P: 
			o%i% := DllCall("GetParent", "uint", Hwnd)
		continue
		Window_Get_A: 
			o%i% := DllCall("GetAncestor", "uint", Hwnd, "uint", 2) ; GA_ROOT
		continue
		Window_Get_O: 
			o%i% := DllCall("GetWindowLong", "uint", Hwnd, "int", -8) ; GWL_HWNDPARENT
		continue
		Window_Get_T:
			if DllCall("IsChild", "uint", hwnd)
				 WinGetText, o%i%, ahk_id %hwnd%
			else WinGetTitle, o%i%, ahk_id %hwnd%
		continue
		Window_Get_M: 
			WinGet, _, PID, ahk_id %hwnd%
			hp := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", _ ) 
			if (ErrorLevel or !hp) 
				continue
			VarSetCapacity(buf, 512, 0), DllCall( "psapi.dll\GetModuleFileNameExA", "uint", hp, "uint", 0, "str", buf, "uint", 512),  DllCall( "CloseHandle", hp ) 
			o%i% := buf 
		continue
	}	
	
	return o1
}

/*
 Function:	GetRect
 			Get window rectangle.
 
 Parameters:
 			hwnd		- Window handle
			pQ			- Query parameter: ordered list of x, y, w and h characters. If you specify * as first char rectangle will be raltive to the client area of window's parent.
						  Leave pQ empty or "*" to return all attributes separated by space.
			o1 .. o4	- Reference to output variables. 

 Returns:
			o1

 Remarks:
			This function is faster alternative to <Get> with R parameter. However, if you query additional window info using <Get>, it may be faster and definitely more 
			convenient then obtaining the info using alternatives. 
			Besides that, you can't use <Get> to obtain relative coordinates of child windows.

 Examples:
	(start code)
  			Win_GetRect(hwnd, "xw", x, w)		;get x & width
  			Win_GetRect(hwnd, "yhx", y, h, x)	;get y, height, and x
  			p := Win_GetRect(hwnd, "x") + 5		;for single query parameter you don't need output variable as function returns o1
  			all := Win_GetRect(hwnd)			;return all
  			Win_Get(hwnd, "*hx", h, x)			;return relative h and x
  			all_rel := WiN_Get(hwnd, "*")		;return all relative coorinates
	(end code)
 */
Win_GetRect(hwnd, pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="") {
	VarSetCapacity(RECT, 16), r := DllCall("GetWindowRect", "uint", hwnd, "uint", &RECT)
	ifEqual, r, 0, return

	if (pQ = "") or pQ = ("*")
		retAll := true,  pQ .= "xywh"

	xx := NumGet(RECT, 0, "Int"), yy := NumGet(RECT, 4, "Int")
	if SubStr(pQ, 1, 1) = "*"
	{
		Win_Get(DllCall("GetParent", "uint", hwnd), "Lxy", lx, ly), xx -= lx, yy -= ly
		StringTrimLeft, pQ, pQ, 1
	}
	
	loop, parse, pQ
		if A_LoopField = x
			o%A_Index% := xx
		else if A_LoopField = y
			o%A_Index% := yy
		else if A_LoopField = w
			o%A_Index% := NumGet(RECT, 8, "Int") - xx - ( lx ? lx : 0)
		else if A_LoopField = h
			o%A_Index% := NumGet(RECT, 12, "Int") - yy - ( ly ? ly : 0 )

	return retAll ? o1 " " o2 " " o3 " " o4 : o1
}


/*
 Function:	Is
 			Checks handle against specified criterium.
 
 Parameters:
			pQ			- Query parameter.

 Query:
			win			- True if handle is window.
			child		- True if handle is child window.
			enabled		- True if window is enabled.
			visible		- True if window is visible.
			max			- True if window is maximized.
			hung		- True if window is hung and doesn't respond to messages.

 Returns:
			TRUE or FALSE
 */
Win_Is(Hwnd, pQ="win") {
	static is_win = "IsWindow", is_child="IsChild", is_enabled="IsWindowEnabled", is_visible="IsWindowVisible", is_max = "IsZoomed", is_hung = "IsHungAppWindow"
	fun := "is_" pQ, fun := %fun%

	ifEqual, fun, , return A_ThisFunc "> Invalid query parameter: " pQ
	return DllCall(fun, "uint", Hwnd)
}

/*
 Function:	Move
			Change the size and position of a child, pop-up, or top-level window.
	
 Parameters:
			X..H		- Size / position. You can omit any parameter to keep its current value.
			Flags		- Can be R or A.

 Flags:
			R - Does not redraw changes. If this flag is set, no repainting of any kind occurs. 
			A - Asynchronous mode - if the calling thread and the thread that owns the window are attached to different input queues, the system posts the request to the thread that owns the window. This prevents the calling thread from blocking its execution while other threads process the request.

 Returns:
			True if successful, False otherwise.

 Remarks:
			Does not produce the same effect as ControlMove on child windows. Mentioned AHK function puts child window relative to the ancestor window rectangle 
			while Win_Move puts it relative to the parent's client rectangle which is usually the wanted behavior.
			WinMove produces the same effect as Win_Move on child controls, except its X and Y parameters are not optional which makes lot of addtional code for frequent operation: moving the control by some offset of its current position. 
			In order to do that you must get the current position of the control. That can be done with ControlGetPos which works in pair with ControlMove hence it is not relative to the client rect or WinGetPos which returns screen coordinates of child control so those can not 
			be imediatelly used in WinMove as it positions child window relative to the parents client rect. This scenario can be additionaly complicated by the fact that each window may have its own theme which influences the size of its borders, non client area, etc...

 */
Win_Move(Hwnd, X="", Y="", W="", H="", Flags="") {
;	static SWP_NOMOVE=2, SWP_NOREDRAW=8, SWP_NOSIZE=1, SWP_NOZORDER=4, SWP_NOACTIVATE = 0x10, SWP_ASYNCWINDOWPOS=0x4000, HWND_BOTTOM=1, HWND_TOPMOST=-1, HWND_NOTOPMOST = -2
	static SWP_NOMOVE=2, SWP_NOSIZE=1, SWP_NOZORDER=4, SWP_NOACTIVATE = 0x10, SWP_R=8, SWP_A=0x4000

	hFlags := SWP_NOZORDER | SWP_NOACTIVATE
	loop, parse, Flags
		hFlags |= SWP_%A_LoopField%
		
	if (x y != "") {
		p := DllCall("GetParent", "uint", hwnd), Win_Get(p, "Lxy", px, py), Win_GetRect(hwnd, "xywh", cx, cy, cw, ch)
		if x=
			x := cx - px
		if y=
			y := cy - py
	} else hFlags |= SWP_NOMOVE

	if (h w != "") {
		if !cx
			Win_GetRect(hwnd, "wh", cw, ch)
		if w=
			w := cw
		if h=
			h := ch
	} else  hFlags |= SWP_NOSIZE

	return DllCall("SetWindowPos", "uint", Hwnd, "uint", 0, "int", x, "int", y, "int", w, "int", h, "uint", hFlags)
}

/*
 Function:	MoveDelta
 			Move the window by specified amount.
 
 Parameters:
			Xd .. Hd - Delta to add to each window rect property. Skipped properties will not be changed.
			Flags	 - The same as in <Move>.

 Returns:
			True if successful, False otherwise.
 */

Win_MoveDelta( Hwnd, Xd="", Yd="", Wd="", Hd="", Flags="" ) {
	Win_GetRect(Hwnd, "*xywh", cx, cy, cw, ch)
	return Win_Move( Hwnd, cx+Xd, cy+Yd, cw+Wd, ch+Hd, flags)
}


/* 
  Function:	Pos
			Store/Get window's position, size and maximize state using Windows Registry.


  Parameters:

		Options		 - White space separated list of options. 		
		X-H, MinMax  - Reference to output variables, if needed. Optional.

  Options:
		">", "<", "-", "--" - Operation, ">" (store) or "<"(get). This is mandatory option.
					It can be optionally followed by the string representing the name of the window for which to do operation.					
					">" is a special name that can be used to save all AHK Guis.
					"-"	is used alone as argument to delete Registry entries  belonging to the script.
					"--" is used alone as argument to delete all Registry entries for all scripts.
		Hwnd	  - Hwnd of the window for which to store data or Gui number (if AHK window). Valid only for ">" operation. 
					If omitted, function will use Hwnd of the default AHK Gui. You can also use Gui, N:Default 
					prior to calling the function. 
					For 3td party windows this option must be set.
		!		  - Ignore windows which state is minimized or maximized. In this case function will simply return without saving anything.
					Valid only with ">" operation mode.

		?		  - Everything else found in options will be sent back from the function in case there is no previous save. This can be used
					to set up default position for AHK Guis.
		

  Remarks:
			Position is saved in the Registry under AutoHotKey\Win section.
			If window which position is to be stored is in maximized or minimized state, function will restore the window to get its
			position in normal state. If this is undesirable use ! option to ignore windows in states.

  Returns:
			Position string in AHK form which can be used for AHK Gui's.

  Examples:
		(start code)
			pos := Win_Pos("< w300 h100")			;Get the previous window position if present. If not, use w300 h100.
			Gui, Show, %pos%
			
			Win_Pos(">")							;Save position for default AHK Gui.
			Win_Pos(">MyGui")						;Save position for default AHK Gui under name MyGui.
			Win_Pos("<MyGui autosize")				;Restore position for MyGui, return autosize if there is no previous save.

			Win_Pos(">MyGui2 hwnd2")				;Save gui2 position under MyGui2 name. AHK only.
			Win_Pos(">MyGui2 hwnd" hWnd)			;Save window position under MyGui2 name, given the window handle.
			Win_Pos(">>")							;Save all guis. The names will be given by their number. AHK only.
			Win_Pos(">> !")							;Save all guis but ignore windows in min/max state. AHK only.

			Win_Pos("-")							;Delete all Registry enteries for the script.
		(end code)

 */
Win_Pos( Options, ByRef X="",ByRef Y="",ByRef W="",ByRef H="", ByRef MinMax="" ){
	static key="Software\AutoHotkey\Win"
	
	if (Options = "-"){
		loop, HKEY_CURRENT_USER, %key%
			if InStr(A_LoopRegName, A_ScriptFullPath)
				RegDelete, HKEY_CURRENT_USER, %key%, %A_LoopRegName%		
		return
	} else if (Options = "--") {
		RegDelete, HKEY_CURRENT_USER, %key%
		return
	}

	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on
	loop, parse, Options, %A_Space%%A_Tab%, %A_Space%%A_Tab%
	{
		ifEqual, A_LoopField, , continue
		f := SubStr(A_LoopField, 1, 1),  p := SubStr(A_LoopField, 2)

		if (f = ">")
			 op := ">", name := p
		else if (f = "<")
			 op := "<", name := p
		else if (f = "!")
			 ignore := true
		else if InStr(A_LoopField, "Hwnd")
			 hwnd := SubStr(A_LoopField, 5)		
		else def .= A_LoopField " "	
	}

	if (op = "<") {
		RegRead, pos, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%!%name%
		ifEqual, ErrorLevel, 1, SetEnv, pos, %def%
	
		StringSplit, p, pos, %A_Space%
		loop, %p0%
			f := SubStr(p%A_Index%,1,1), %f% := SubStr(p%A_Index%,2)
		MinMax := m != "" ? "m" m : ""
	} 
	else if (op = ">") {
		if (name = ">") {		;save all guis
			Loop, 99
			{
				Gui, %A_Index%:+LastFoundExist
				ifWinExist
					Win_Pos(">" A_Index " hwnd" A_Index (ignore ? " !" : ""))
			}
			DetectHiddenWindows, %oldDetect%
			return
		}
	
		if (hwnd = "") || (hwnd <= 99) {
			ifEqual, hwnd,, Gui, +LastFound
			else Gui, %hwnd%:+LastFound
			hwnd := WinExist()
		}

		WinGet, mm0, MinMax, ahk_id %hwnd%				
		if (mm0 != 0) && ignore
			return

		ifNotEqual, mm0, 0,  WinRestore, ahk_id %hwnd%			;do it twice, window can be maximized then minimized.
		WinGet, mm1, MinMax, ahk_id %hwnd%
		ifNotEqual, mm1, 0,  WinRestore, ahk_id %hwnd%

		WinGetClass, class, ahk_id %hwnd%
		if (class = "AutoHotkeyGUI")
			  Win_Get(Hwnd, "RxyLwh", x,y,w,h)
		else  WinGetPos, x, y, w, h, ahk_id %hwnd%

		m := mm0=-1 ? "minimized" : mm0 ? "maximize" : ""
		pos := "x" x " y" y " w" w " h" h " " m

	
		RegWrite, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%!%name%, %pos%
	}
	DetectHiddenWindows, %oldDetect%
	return pos
}

/*
 Function:	Redraw
 			Redraws the window.

			Hwnd - Handle of the window. If this parameter is omited, Redraw updates the desktop window.
 
 Returns:
			A nonzero value indicates success. Zero indicates failure.

 Remarks:
			This function will update the window for sure, unlike WinSet or InvalidateRect.
 */
Win_Redraw( Hwnd=0 ) {
	static RDW_ALLCHILDREN:=0x80, RDW_ERASE:=0x4, RDW_ERASENOW:=0x200, RDW_FRAME:=0x400, RDW_INTERNALPAINT:=0x2, RDW_INVALIDATE:=0x1, RDW_NOCHILDREN:=0x40, RDW_NOERASE:=0x20, RDW_NOFRAME:=0x800, RDW_NOINTERNALPAINT:=0x10, RDW_UPDATENOW:=0x100, RDW_VALIDATE:=0x8
	return DllCall("RedrawWindow", "uint", Hwnd, "uint", 0, "uint", 0, "uint"
		      ,RDW_INVALIDATE | RDW_ERASE | RDW_FRAME | RDW_ERASENOW | RDW_UPDATENOW | RDW_ALLCHILDREN)
}

/*
 Function:	SetMenu
 			Set the window menu.
 
 Parameters:
			hMenu	- Handle of the menu to set for window. By default 0 means that menu will be removed.

 Returns:
			Handle of the previous menu.
 */
Win_SetMenu(Hwnd, hMenu=0){
	hPrevMenu := DllCall("GetMenu", "uint", hwnd, "Uint")
	DllCall("SetMenu", "uint", hwnd, "uint", hMenu)
	return hPrevMenu
}

/*
 Function:	SetIcon
 			Set the titlebar icon for the window.
 
 Parameters:
			Icon	- Path to the icon. If omited, icon is removed. If integer, handle to the already loaded icon.
			Flag	- 1 sets the large icon for the window, 0 sets the small icon for the window. 

 Returns:
			The return value is a handle to the previous large or small icon, depending on the Flag value.

 */
Win_SetIcon( Hwnd, Icon="", Flag=1){
	static WM_SETICON = 0x80, LR_LOADFROMFILE=0x10, IMAGE_ICON=1

	if Flag not in 0,1
		return A_ThisFunc "> Unsupported Flag: " Flag

	if Icon != 
		hIcon := Icon+0 != "" ? Icon : DllCall("LoadImage", "Uint", 0, "str", Icon, "uint",IMAGE_ICON, "int", 32, "int", 32, "uint", LR_LOADFROMFILE)  

	SendMessage, WM_SETICON, %Flag%, hIcon, , ahk_id %Hwnd%
	return ErrorLevel
}

/*
 Function:	SetParent
 			Changes the parent window of the specified window.
 
 Parameters:
			hParent	- Handle to the parent window. If this parameter is 0, the desktop window becomes the new parent window.

 Returns:
			If the function succeeds, the return value is a handle to the previous parent window.
 */
Win_SetParent(Hwnd, hParent=0){
	return DllCall("SetParent", "uint", Hwnd, "uint", hParent)
}


/*
 Function:	SetOwner
 			Changes the owner window of the specified window.
 
 Parameters:
			hOwner	- Handle to the owner window.

 Returns:
			Handle of the previous owner.

 Remarks:
			An owned window is always above its owner in the z-order. The system automatically destroys an owned window when its owner is destroyed. An owned window is hidden when its owner is minimized. 
			Only an overlapped or pop-up window can be an owner window; a child window cannot be an owner window.
 */

;Famous misleading statement. Almost as misleading as the choice of GWL_HWNDPARENT as the name. It has nothing to do with a window's parent. 
;It really changes the Owner exactly the same thing as including the Owner argument in the Show statement. 
;A more accurate version might be: "SetWindowLong with the GWL_HWNDPARENT will not change the parent of a child window. Instead, use the SetParent function."
;GWL_HWNDPARENT should have been called GWL_HWNDOWNER, but nobody noticed it until after a bazillion copies of the SDK had gone out. This is what happens 
;when the the dev team lives on M&Ms and CocaCola for to long. Too bad. Live with it.
;
Win_SetOwner(Hwnd, hOwner){
	static GWL_HWNDPARENT = -8
	return DllCall("SetWindowLong", "uint", Hwnd, "int", GWL_HWNDPARENT, "uint", hOwner)		
}

/*
 Function:	Show
 			Show / Hide window.
 
 Parameters:
			bShow	- True to show (default), False to hide window.

 Returns:
		If the window was previously visible, the return value is nonzero. 
		If the window was previously hidden, the return value is zero.
 */
Win_Show(Hwnd, bShow=true) {
	return DllCall("ShowWindow", "uint", Hwnd, "uint", bShow ? 5:0)
}

/*
 Function:	Subclass 
			Subclass child window (control)
 
 Parameters: 
			hCtrl   - Handle to the child window to be subclassed
			Fun		- New window procedure. You can also pass function address here in order to subclass child window
					  with previously created window procedure.
			Opt		- Optional callback options for Fun, by default "" 
		   $WndProc - Optional reference to the ouptut variable that will receive address of the new window procedure.

 Returns:
			The addresss of to the previous window procedure or 0 on error	

 Remarks:
			Works only for controls created in the autohotkey process.

 Example:
	(start code)
  	if !Win_SubClass(hwndList, "MyWindowProc") 
  	     MsgBox, Subclassing failed. 
  	... 
  	MyWindowProc(hwnd, uMsg, wParam, lParam){ 
  
  	   if (uMsg = .....)  
            ; my message handling here 
  
  	   return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam) 
  	}
	(end code)
 */
Win_Subclass(hCtrl, Fun, Opt="", ByRef $WndProc="") { 
	if Fun is not integer
	{
		 oldProc := DllCall("GetWindowLong", "uint", hCtrl, "uint", -4) 
		 ifEqual, oldProc, 0, return 0 
		 $WndProc := RegisterCallback(Fun, Opt, 4, oldProc) 
		 ifEqual, $WndProc, , return 0
	}
	else $WndProc := Fun
	   
    return DllCall("SetWindowLong", "UInt", hCtrl, "Int", -4, "Int", $WndProc, "UInt") 
}

/*
Group: About
	o v1.0c by majkinetor.
	o Reference: <http://msdn.microsoft.com/en-us/library/ms632595(VS.85).aspx>
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
/*