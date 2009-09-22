Panel_New(HParent, X, Y, W, H, Style="", Text="") { 
	static init=0
	static WS_VISIBLE=0x10000000, WS_CHILD=0x40000000, WS_CLIPCHILDREN=0x2000000, SS_NOTIFY=0x100
	static SS_SIMPLE = 0xB, SS_BLACKFRAME = 7, SS_BLACKRECT = 4, SS_CENTER=0x201, SS_VCENTER=0x200, SS_HCENTER = 1, SS_GRAYFRAME = 0x8, SS_GRAYRECT = 0x5, SS_RIGHT = 2, SS_SUNKEN = 0x1000, SS_WHITEFRAME = 9, SS_WHITERECT = 6

	if !init
		init := Panel_registerClass()

	hStyle := 0
	loop, parse, Style, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, , continue
		if A_LoopField is integer
			 hStyle |= A_LoopField
		else hStyle |= SS_%A_LOOPFIELD%
	}

	hCtrl := DllCall("CreateWindowEx" 
	  , "Uint",	  0
	  , "str",    "Panel"	
	  , "str",    text		
	  , "Uint",   WS_VISIBLE | WS_CHILD	| WS_CLIPCHILDREN | SS_NOTIFY | hStyle
	  , "int",    X, "int", Y, "int", W, "int",H
	  , "Uint",   HParent
	  , "Uint",   0, "Uint",0, "Uint",0, "Uint") 

	ifEqual, res, 0, return A_ThisFunc "> Failed to create control."
	return hCtrl
} 

Panel_wndProc(Hwnd, UMsg, WParam, LParam) { 
	static WM_SIZE:=5, redirect = "32,78,273,277,279", anc, f="Attach_"		;WM_SETCURSOR,WM_COMMAND,WM_NOTIFY,WM_HSCROLL,WM_VSCROLL
	
	if UMsg in %redirect%
	{	
		anc := DllCall("GetAncestor", "uint", Hwnd, "uint",2)	;GWL_ROOT = 2
		return DllCall("SendMessage", "uint", anc, "uint", umsg, "uint", wparam, "uint", LParam)
	}
	
	if (UMsg = WM_SIZE)
		return IsFunc(f) ? %f%(Wparam, LParam, UMsg, Hwnd) : ""

	return DllCall("CallWindowProc","uint",A_EventInfo,"uint",Hwnd,"uint",UMsg,"uint",WParam,"uint",LParam)
}


Panel_registerClass() {
    static ClassAtom, ClassName="Panel"
    
	ifNotEqual, ClassAtom,, return ClassAtom
    
    VarSetCapacity(wcl,40)
    if ! DllCall("GetClassInfo","uint",0,"str","Static","uint",&wcl)
        return false
    NumPut(NumGet(wcl)|0x20000,wcl)						; wcl->style |= CS_DROPSHADOW
    NumPut(&ClassName,wcl,36)							; wcl->lpszClassName = &ClassName
    NumPut(DllCall("GetModuleHandle","uint",0),wcl,16)  ; wcl->hInstance = NULL

	; Create a callback for Form_WndProc, passing Static's WindowProc as A_EventInfo. lpfnWndProc := the callback.
    NumPut(RegisterCallback("Panel_WndProc","",4,NumGet(wcl,4)),wcl,4)    
    return DllCall("RegisterClass","uint",&wcl)
}

Panel_Add2Form(hParent, Txt, Parameters){
	Form_Parse(Parameters, "x# y# w# h# style", x, y, w, h, style)
	return Panel_New(hParent, x, y, w, h, style, Txt)	
}