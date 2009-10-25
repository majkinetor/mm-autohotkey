#SingleInstance, force
	Gui, +LastFound
	hwnd := WinExist()

	hRichEdit := RichEdit_Add( hwnd, 0, 0, 445, 490)
	Gui, Show, w805 h500
return


RichEdit_Add(HParent, X="", Y="", W="", H="", Style="", Text="")  {
  static WS_CLIPCHILDREN=0x2000000, WS_VISIBLE=0x10000000, WS_CHILD=0x40000000
		,ES_DISABLENOSCROLL=0x2000, EX_BORDER=0x200
		,ES_LEFT=0, ES_CENTER=1, ES_RIGHT=2, ES_MULTILINE=4, ES_AUTOVSCROLL=0x40, ES_AUTOHSCROLL=0x80, ES_NOHIDESEL=0x100, ES_NUMBER=0x2000, ES_PASSWORD=0x20,ES_READONLY=0x800,ES_WANTRETURN=0x1000
		,ES_HSCROLL=0x100000, ES_VSCROLL=0x200000, ES_SCROLL=0x300000 
		,MODULEID

	if !MODULEID
		init := DllCall("LoadLibrary", "Str", "Msftedit.dll", "Uint")


	ifEqual, Style,, SetEnv, Style, MULTILINE WANTRETURN	
	hStyle := InStr(" " Style " ", " hidden ") ? 0 : WS_VISIBLE,  hExStyle := 0
	Loop, parse, Style, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, ,continue
		else if A_LoopField is integer
			 hStyle |= A_LoopField
		else if (v := ES_%A_LOOPFIELD%)
			 hStyle |= v
		else if (v := EX_%A_LOOPFIELD%)
			 hExStyle |= v
		else continue
	}
	
	hCtrl := DllCall("CreateWindowEx"
                  , "Uint", 0			; ExStyle
                  , "str" , "RICHEDIT50W"		; ClassName
                  , "str" , Text				; WindowName
                  , "Uint", WS_CHILD | hStyle	; Edit Style
                  , "int" , X					; Left
                  , "int" , Y					; Top
                  , "int" , W					; Width
                  , "int" , H					; Height
                  , "Uint", HParent				; hWndParent
                  , "Uint", 0					; hMenu 
                  , "Uint", 0					; hInstance
                  , "Uint", 0, "Uint")			; must return uint.
	return hCtrl
}

F1:: Gui, Show