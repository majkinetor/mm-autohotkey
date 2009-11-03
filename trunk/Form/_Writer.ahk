_("c-1")
	w := 550, h := 250
	hForm1 := Form_New("+Resize w" w " h" h)
		
	h := Writer_Add(hForm1, 0, 0, w, h), Attach(h, "w h")
	Form_Show()
return

Writer_Add(hParent, X, Y, W, H, Style="") {
	global 

  ;create layout
	pnlMain	:= Panel_Add(hParent, X, Y, W, H)
	pnlTool	:= Panel_Add(pnlMain, 0, 0, W, 30)
	hRE		:= RichEdit_Add(pnlMain, "", "", "", "", "NOHIDESEL MULTILINE SELECTIONBAR VSCROLL"), RichEdit_FixKeys(hRE)
	RichEdit_SetCharFormat(hRE, "Tahoma", "s10 -bold")
	ControlFocus,,ahk_id %hRe% 
	
	Align(pnlTool, "T"), Align(hRE, "F")

	hIL := IL_Create(10)
	loop, btns\*.png
		IL_Add(hIL, A_LoopFileFullPath)
	
	;populate toolbars
	btns =
	 (LTrim
		Bold,,,
		Italic,,, 
		Underline,,, 
		Strikeout,,, 
		-
		Left,,,
		Center,,,
		Right,,,
		-
		Ident,,,
		Dedent,,,
		Number,,, 
		Bullet,,, 
		Back Color,,,DROPDOWN
		Text Color,,,DROPDOWN
	 )
	cbFonts := Form_Add(pnlTool, "ComboBox", "Arial||", "gWriter_OnTool x0 y0 w180", "Align L")
	Form_Add(pnlTool, "ComboBox", "8|9|10||11|12|14|16|18|20|22|24|26|28|36|48|72", "gWriter_OnTool w50", "Align L")
	hToolbar := Form_Add(pnlTool, "Toolbar", btns, "gWriter_OnToolbar x0 style='flat list nodivider tooltips' il" hIL, "Align L")
	Toolbar_AutoSize(hToolbar)
  	Form_AutoSize(pnlTool, .2)
	Align(pnlMain)

	Attach(hRE, "w h")
	Attach(pnlTool, "w")

	Writer_enumFonts()
	return pnlMain
}


Writer_OnToolbar(Hwnd, Event, Txt) {
	global 
	local style, font

	ifEqual, event, hot, return
	if !Hwnd
	{
		if Txt is not integer
			 font := Txt, 
		else style := "s" Txt
		return RichEdit_SetCharFormat(hRE, font, style )
	}

	if Txt in Bold,Italic,Underline,Strikeout
		return RichEdit_GetCharFormat(hRE, _, style), RichEdit_SetCharFormat( hRE, "", Instr(style, Txt) ? "-" Txt : Txt )
	
	if Txt in left,right,center
		return RichEdit_SetParaFormat(hRE, "Align=" Txt)
	
	if Txt in ident,dedent
		return RichEdit_SetParaFormat(hRE, "Ident=" (Txt="dedent" ? -1:1)*500)

	if Txt in Number,Bullet
		return RichEdit_SetParaFormat(hRE, "Num=" (Txt="Number" ? "DECIMAL" : "BULLET") ",1,D")
}

Writer_OnTool:
	Writer_OnToolbar(0, "", A_GuiControl)
return

Writer_enumFonts() {
	global 

	hDC := DllCall("GetDC", "Uint", 0) 
	DllCall("EnumFonts", "Uint", hDC, "Uint", 0, "Uint", RegisterCallback("Writer_enumFontsProc", "F"), "Uint", 0) 
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
	
	s := Writer_enumFontsProc(0, 0, 0, 0)
	loop, parse, s, |
		Control, Add, %A_LoopField%,,ahk_id %cbFonts%
}

Writer_enumFontsProc(lplf, lptm, dwType, lpData) {
	static s
	
	ifEqual, lplf, 0, return s

	s .= DllCall("MulDiv", "Int", lplf+28, "Int",1, "Int", 1, "str") "|"
	return 1
}


#include inc
#include _Forms.ahk