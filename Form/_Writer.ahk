_("mo!")
	w := 550, h := 250
	hForm1 := Form_New("+Resize w" w " h" h)
		
	h := Writer_Add(hForm1, 0, 0, w, h), Attach(h, "w h")
	Form_Show()
return

Writer_Add(hParent, X, Y, W, H, Style="", Init="s10 -bold,Tahoma") {
	global 

  ;create layout
	pnlMain	:= Panel_Add(hParent, X, Y, W, H)
	pnlTool	:= Panel_Add(pnlMain, 0, 0, W, 60)
	hRE		:= RichEdit_Add(pnlMain, "", "", "", "", "NOHIDESEL MULTILINE SELECTIONBAR VSCROLL"), RichEdit_FixKeys(hRE)
	ControlFocus,,ahk_id %hRe% 
	
	Align(pnlTool, "T"), Align(hRE, "F")

	hIL := IL_Create(10)
	loop, btns\*.png
		IL_Add(hIL, A_LoopFileFullPath)
	
	;populate toolbars
	btns =
	 (LTrim
		Bold,,,check
		Italic,,,check 
		Underline,,,check 
		Strikeout,,,check 
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

	cbFonts := Form_Add(pnlTool, "ComboBox", Writer_enumFonts(), "gWriter_OnTool y6 x4 w180")
	Form_Add(pnlTool, "ComboBox", "8|9|10||11|12|14|16|18|20|22|24|26|28|36|48|72", "gWriter_OnTool x+5 w50")
	hToolbar := Form_Add(pnlTool, "Toolbar", btns, "gWriter_OnToolbar x2 y30 style='flat list nodivider tooltips' il" hIL)
	Toolbar_AutoSize(hToolbar)
  	Form_AutoSize(pnlTool, .2)
	Align(pnlMain)

	StringSplit, Init, Init, `,, %A_SPACE%
	Control, ChooseString, %Init2%,,ahk_id %cbFonts%

	RichEdit_SetCharFormat(hRE, Init2, Init1)
	RichEdit_AutoUrlDetect(hRE, true ) 
	RichEdit_SetEvents(hRE, "Writer_onRichEdit", "SELCHANGE LINK")

	Attach(hRE, "w h")
	Attach(pnlTool, "w")

	return pnlMain
}

Writer_onRichEdit(hCtrl, Event, p1, p2, p3 ) {
	if Event = SELCHANGE
	{
		SetTimer, Writer_SetUI, -50		; don't spam while typing...
		return
	}

	if Event = Link
		Run, % RichEdit_GetText(hCtrl, p2, p3)

	return

 Writer_SetUI:
	Writer_SetUI()
 return
}


Writer_SetUI() {
	global hRE, hToolbar,cbFonts

	static bold=1, italic=2, underline=3, strikeout=4, btns="bold,italic,underline,strikeout"

	RichEdit_GetCharFormat(hRE, font, style, fg, bg)
	StringSplit, style, style, %A_Space%

	oldDelay := A_ControlDelay 
	SetControlDelay, -1

	loop, %style0%
		s := style%A_Index%,  Toolbar_SetButton(hToolbar, %s%, "checked"), _%s% := 1

	loop, parse, btns, `,
		if !_%A_LoopField%
			Toolbar_SetButton(hToolbar, %A_LoopField%, "-checked")

	Control, ChooseString, %Font%,,ahk_id %cbFonts%	

				
	SetControlDelay, %oldDelay%
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
;	 Writer_OnToolbar(0, "", A_GuiControl)
return

Writer_enumFonts() {

	hDC := DllCall("GetDC", "Uint", 0) 
	DllCall("EnumFonts", "Uint", hDC, "Uint", 0, "Uint", RegisterCallback("Writer_enumFontsProc", "F"), "Uint", 0) 
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
	
	return Writer_enumFontsProc(0, 0, 0, 0)
}

Writer_enumFontsProc(lplf, lptm, dwType, lpData) {
	static s
	
	ifEqual, lplf, 0, return s

	s .= DllCall("MulDiv", "Int", lplf+28, "Int",1, "Int", 1, "str") "|"
	return 1
}


#include inc
#include _Forms.ahk