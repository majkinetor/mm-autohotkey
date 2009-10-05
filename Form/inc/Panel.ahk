/*
 Function:	Add
			Adds new panel.
 
 Parameters:
			HParent		- Handle of the parent.
			X..H		- Placement.
			Style		- White space separated list of panel styles. Additionally, any integer style can be specified among other styles.
			Text		- Text to display.

 Styles:
			HIDDEN, SIMPLE, VCENTER, HCENTER, CENTER, RIGHT, SUNKEN, BLACKFRAME, BLACKRECT, GRAYFRAME, GRAYRECT, WHITEFRAME, WHITERECT.
			
 Returns:
		    Handle of the control or error messge if control couldn't be created.

 Remarks:
			If you <Attach> Panel control to its parent, Panel will disable Attach for itself when it becomes explicitelly hidden and enable itself when you show it latter.
			When Panel doesn't attach, its parent will skip it when performing repositioning of the controls. If Panel itself is attaching its own children, 
			this means that it will also stop attaching them as its own size wont change. However, its children won't be disabled so if you programmatically change the 
			the placement of such Panel, it will still reposition its controls. Hence, if you create Panel with HIDDEN state and used Attach, you should also prefix
			attach defintion string with "-" to set up that Panel initialy disabled. If you don't do that Panel will do attaching in hidden state initially 
			(as it was never hidden explicitelly).

			If you have deep hierarchy of Panels(>10), script may block or show some undesired behavior. Using #MaxThreads, 255 can sometimes help.

			Depending on control you want to host inside the Panel, you may need to redifine which messages Panel redirects to the main window.
			This is hardcoded in Panel_wndProc function:

 >			redirect = "32,78,273,276,277"  ;WM_SETCURSOR=32, WM_COMMAND=78, WM_NOTIFY=273, WM_HSCROLL=276, WM_VSCROLL=277
 */
Panel_Add(HParent, X, Y, W, H, Style="", Text="") {
	static WS_VISIBLE=0x10000000, WS_CHILD=0x40000000, WS_CLIPCHILDREN=0x2000000
		   ,PS_HIDDEN=0, PS_VSCROLL=0x200000, PS_HSCROLL=0x100000, PS_SCROLL=0x300000, PS_DISABLED=0x8000000, PS_BORDER=0x800000, PS_TITLE=0x400000, PS_SUNKEN=0x200
		   ,init=0

	if !init
		if !(init := Panel_registerClass())
			return A_ThisFunc "> Failed to register class."

	hStyle := InStr(" " Style " ", " hidden ") ? 0 : WS_VISIBLE
	hExStyle := !InStr(" " Style " ", " sunken ") ? 0 : PS_SUNKEN
	loop, parse, Style, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, , continue
		if A_LoopField is integer
			 hStyle |= A_LoopField
		else if (PS_%A_LOOPFIELD%)
			hStyle |= PS_%A_LOOPFIELD%
		else hExStyle |= 
	}

	hCtrl := DllCall("CreateWindowEx" 
	  , "Uint",	  hExStyle 
	  , "str",    "Panel"	
	  , "str",    Text
	  , "Uint",   WS_CHILD	| WS_CLIPCHILDREN | hStyle
	  , "int",    X, "int", Y, "int", W, "int",H
	  , "Uint",   HParent
	  , "Uint",   0, "Uint",0, "Uint",0, "Uint")

	IfEqual, hCtrl,0,return A_ThisFunc "> Failed to create control."
	return hCtrl
} 

Panel_wndProc(Hwnd, UMsg, WParam, LParam) { 
	static WM_SIZE:=5, GWL_ROOT := 2, WM_SHOWWINDOW=0x18, anc, attach, init		
	static redirect = "32,78,273,276,277"  ;WM_SETCURSOR=32, WM_COMMAND=78, WM_NOTIFY=273, WM_HSCROLL=276, WM_VSCROLL=277

	if !init {
		ifEqual, attach, %A_Space%, return
		ifEqual, attach,, SetEnv, attach, % IsFunc("Attach_") ? "Attach_" : A_Space
		init := true
	}

	if UMsg in %redirect%
		ifEqual, anc,,SetEnv, anc, % DllCall("GetAncestor", "uint", Hwnd, "uint", GWL_ROOT)
		else return DllCall("SendMessage", "uint", anc, "uint", UMsg, "uint", WParam, "uint", LParam)
	
	if (UMsg = WM_SIZE) 
		%attach%(Wparam, LParam, UMsg, Hwnd)
	
	if (Umsg = WM_SHOWWINDOW)
		%attach%(Hwnd, WParam ? "+" : "-", "", "")

	return DllCall("DefWindowProc", "uint", hwnd, "uint", umsg, "uint", wParam, "uint", lParam)
}

Panel_registerClass() {
	static CS_PARENTDC = 0x80, CS_REDRAW=3, COLOR_WINDOW=5

	clsName := "Panel"
	cursor  := DllCall("LoadCursor", "Uint", 0, "Int", 32512, "Uint")		;ARROW
	procAdr := RegisterCallback("Panel_WndProc")

   VarSetCapacity(WC, 40, 0) 
    , NumPut(3, WC, 0)							
    , NumPut(procAdr, WC, 4) 
    , NumPut(cursor, WC, 24)		;curcor
    , NumPut(COLOR_WINDOW, WC, 28)	;background 
    , NumPut(&clsName, WC, 36)		;class 

   return DllCall("RegisterClass", "uint", &WC) 
 }

Panel_add2Form(hParent, Txt, Opt){
	static parse = "Form_Parse"
	%parse%(Opt, "x# y# w# h# style", x, y, w, h, style)
	hCtrl := Panel_Add(hParent, x, y, w, h, style, Txt)	
	return hCtrl
}

/* Group: About
	o Ver 0.1 by majkinetor. 
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/>.
*/