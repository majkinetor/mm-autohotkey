#SingleInstance force
CoordMode, Mouse, screen
#NoEnv

	Gui, +LastFound +Resize
	hwnd := WinExist()

	CreateMenu()
	hEdit := HE_Add(hwnd,0,0,800,600, "HSCROLL VSCROLL HILIGHT TABBED FILECHANGEALERT")


	fStyle := "s10" ,	fFace  := "Courier New"
	HE_SetFont( hEdit, fStyle "," fFace)

	SetColors(hEdit)
	;msgbox % HE_GetColors(hEdit)


	HE_SetTabWidth(hEdit, 4)
	HE_LineNumbersBar(hEdit, "automaxsize"), lineNumbers := true
	HE_AutoIndent(hedit, true), autoIndent := true

	Menu, Features, Check, LineNumbersBar
	Menu, Features, Check, AutoIndent


	HE_SetKeywordFile( A_ScriptDir "\Keywords.hes")
	HE_OpenFile( hEdit, A_ScriptFullPath )

	Gui, Show, w800 h600
return

OnHiEdit:
	OutputDebug % HE_EVENT " | " HE_INFO
return


F3:: FindNext(hedit)
^F:: CmnDlg_Find( hwnd, "OnFind" )
^G:: GoToLine()


SetColors(hEdit) {
	colors=
	(
		Text				= 0xFFFFFF
		Back				= 0
		SelText				= 0xFFFFFF
		ActSelBack			= 0xc56a31
		InSelBack			= 0xAAAAAA
		LineNumber			= 0x0
		SelBarBack			= 0xAAAAAA
		NonPrintableBack	= 0xFFFFFF
		Number				= 0xFFFFFF
	)
	HE_SetColors(hEdit, colors )								
}

CreateMenu(){
	Menu, FileMenu, Add, &New,		MenuHandler  
	Menu, FileMenu, Add, &Close,	MenuHandler 
	Menu, FileMenu, Add, 
	Menu, FileMenu, Add, &Open,		MenuHandler  
	Menu, FileMenu, Add, &SaveAs,	MenuHandler  
	Menu, FileMenu, Add, Reload,	MenuHandler  
	Menu, FileMenu, Add, 
	Menu, FileMenu, Add, E&xit,		MenuHandler

	Menu, Features, Add, GetFileCount,	 Features
	Menu, Features, Add, GetFileName,	 Features
	Menu, Features, Add, 
	Menu, Features, Add, GetCurrentFile, Features
	Menu, Features, Add, SetCurrentFile, Features
	Menu, Features, Add, 
	Menu, Features, Add, AutoIndent,	Features
	Menu, Features, Add, SetTabWidth,	Features
	Menu, Features, Add, SetFont,		Features
	Menu, Features, Add, SetColors,		Features
	Menu, Features, Add 
	Menu, Features, Add, LineNumbersBar,Features
	Menu, Features, Add, ShowFileList,	Features
	Menu, Features, Add, ConvertCase,	Features
	Menu, Features, Add 
	Menu, Features, Add, Enable Events, Features


	Menu, Standard, Add, Undo,			 Standard
	Menu, Standard, Add, Redo,			 Standard
	Menu, Standard, Add
	Menu, Standard, Add, Find,			 Standard
	Menu, Standard, Add, Find Next,		 Standard
	Menu, Standard, Add
	Menu, Standard, Add, GetTextRange,  Standard
	Menu, Standard, Add, GetTextLength, Standard
	Menu, Standard, Add
	Menu, Standard, Add, GetSel, Standard
	Menu, Standard, Add, SetSel, Standard
	Menu, Standard, Add, GetSelText, Standard
	Menu, Standard, Add, ReplaceSel, Standard
	Menu, Standard, Add, ScrollCaret, Standard
	Menu, Standard, Add
	Menu, Standard, Add, Go To Line, Standard
	Menu, Standard, Add, GetLine,	Standard
	Menu, Standard, Add, GetLineCount, Standard
	Menu, Standard, Add, LineIndex, Standard
	Menu, Standard, Add, LineLength, Standard	
	Menu, Standard, Add, GetFirstVisibleLine, Standard


	Menu, MyMenuBar, Add,File,		:FileMenu  
	Menu, MyMenuBar, Add,&Features, :Features 
	Menu, MyMenuBar, Add,&Standard,  :Standard
	Menu, MyMenuBar, Add,About,		MenuHandler
	Menu, MyMenuBar, Color,  DDDDDD
	Gui, Menu, MyMenuBar
}


Standard:
;	HE_GetSel(hEdit, s, e)

	if A_ThisMenuItem = GetTextRange
		msgbox % "100 chars from carret possition:`n`n" HE_GetTextRange(hEdit, s, s+100)
	
	if A_ThismenuItem = Go To Line
		GoToLine()

	if A_ThismenuItem = GetTextLength
		MsgBox % HE_GetTextLength(hEdit)

	if A_ThismenuItem = GetSelText
		MsgBox % HE_GetSelText(hEdit)	

	if A_ThismenuItem = ScrollCaret
	{
		Msgbox This will scroll caret into the view
		HE_ScrollCaret(hEdit)
	}

	if A_ThismenuItem = GetSel
		MsgBox Selection start: %s%`n`nSelection end: %e%

	if A_ThisMenuItem = SetSel
		HE_SetSel(hEdit, s, s+100)

	if A_ThisMenuItem = ReplaceSel
		HE_ReplaceSel(hEdit, "---")

	if A_ThisMenuItem = Find
		CmnDlg_Find( hwnd, "OnFind" )

	if A_ThisMenuItem = Find Next
		FindNext( hEdit )

	if A_ThisMenuItem = Undo
		HE_Undo(hEdit)

	if A_ThisMenuItem = Redo
		HE_Redo(hEdit)

	if A_ThisMenuItem = GetLine
		MsgBox % HE_GetLine(hEdit)

	if A_ThisMenuItem = GetLineCount
		MsgBox % HE_GetLineCount(hEdit)

	if A_ThisMenuItem = LineLength
		MsgBox % HE_LineLength(hEdit)
	
	if A_ThisMenuItem = LineIndex
		msgbox % HE_LineIndex(hEdit)

	if A_ThisMenuItem = GetFirstVisibleLine
		msgbox % HE_GetFirstVisibleLine(hEdit)
return

Features:
	if A_ThisMenuItem = ConvertCase
		HE_ConvertCase(hEdit)

	if A_ThisMenuItem = GetFileCount
		MsgBox % HE_GetFileCount(hEdit)

	if A_ThisMenuItem = GetFileName
		Msgbox % HE_GetFileName(hEdit)
	if A_ThisMenuItem = GetCurrentFile
		Msgbox % HE_GetCurrentFile(hEdit)

	if A_ThisMenuItem = SetCurrentFile
	{
		InputBox, idx, SetCurrentFile ,Index of file to activate,,150,120,,,,,0
		if ErrorLevel
			return
		if (idx < HE_GetFileCount(hEdit))
			HE_SetCurrentFile(hEdit, idx)
		else Msgbox Index is too large
	}

	if A_ThisMenuItem = SetTabWidth
	{
		InputBox, w, SetTabWidth ,Set Tab Width,,150,120,,,,,4
		if ErrorLevel
			return
		HE_SetTabWidth(hEdit, w)
	}

	if A_ThisMenuItem = AutoIndent
	{
		Menu, %A_ThisMenu%, ToggleCheck, %A_ThisMenuItem%
		He_AutoIndent(hEdit, autoIndent := !autoIndent)
	}

	if A_ThisMenuItem = LineNumbersBar
	{
		Menu, %A_ThisMenu%, ToggleCheck, %A_ThisMenuItem%
		lineNumbers := !lineNumbers
		HE_LineNumbersBar(hEdit, lineNumbers ? "automaxsize" : "hide")
	}

	if A_ThisMenuItem = SetFont
	{
		if CmnDlg_Font(fFace, fStyle, pColor, true, hwnd)
			HE_SetFont(hEdit, fStyle "," fFace)
	}

	if A_ThisMenuItem = SetColors
		MsgBox For Homework...
		
	if A_ThisMenuItem = ShowFileList
	{
		MouseGetPos, x, y
		HE_ShowFileList(hEdit, x, y )
		return
	}

	if A_ThisMenuItem = Enable Events
	{
		HE_SetEvents(hEdit, "OnHiEdit", "SelChange Scroll Key Mouse ContextMenu")
		MsgBox Open DebugView to monitor events
	}

return

OnFind:

	StringReplace, CmnDlg_Flags, CmnDlg_Flags, d,
	StringReplace, CmnDlg_Flags, CmnDlg_Flags, c, MATCHCASE%A_SPACE%
	StringReplace, CmnDlg_Flags, CmnDlg_Flags, w, WHOLEWORD%A_SPACE%


	res := HE_FindText(hEdit, CmnDlg_FindWhat, HE_GetSel(hEdit)+ (res!="")*1, -1, CmnDlg_Flags)
	HE_SetSel(hEdit, res, res + StrLen(CmnDlg_FindWhat))
	HE_ScrollCaret(hEdit)
return

GoToLine() {
	global hEdit

	cnt := HE_GetLineCount(hEdit)
	InputBox, line, Go To Line, Enter line (1 - %cnt%), , 200, 120
	if ErrorLevel
		return
	if line > cnt
		line := cnt

	line_idx := HE_LineIndex(hEdit, line-1)
	HE_SetSel( hEdit, line_idx, line_idx)
	HE_ScrollCaret(hEdit )
}

FindNext( hEdit ){
	global CmnDlg_Text

	if (CmnDlg_Text = "")
		return
	gosub OnFind
}

MenuHandler:
	if A_ThisMenuItem = &Open
	{
		FileSelectFile, fn
		if Errorlevel
			return
		HE_OpenFile(hEdit, fn)
	}

	if A_ThisMenuItem = E&xit
		ExitApp

	if A_ThisMenuItem = &New
		HE_NewFile(hEdit)

	if A_ThisMenuItem = &Close
		HE_CloseFile(hEdit, -1)

	if A_ThisMenuItem = &SaveAs
	{
		FileSelectFile, fn, S 16
		if (Errorlevel)
			return
		HE_SaveFile(hEdit, fn, -1)
		return
	}

	if A_ThisMenuItem = Reload
		HE_ReloadFile(hEdit)

	if A_ThisMenuItem = About
	{
		msg := "HiEdit AHK demo`n`n"
		msg .= "For more information visit: www.winasm.net`n`n`n`n"
		msg .= "HiEdit by akyprian`n"
		msg .= "AHK wrapper by majkinetor"
		MsgBox 48, About, %msg%
	}

return


GuiClose:
	ExitApp
return


Anchor(c, a = "", r = false) { ; v3.6 - Titan
	static d
	GuiControlGet, p, Pos, %c%
	If ex := ErrorLevel {
		Gui, %A_Gui%:+LastFound
		ControlGetPos, px, py, pw, ph, %c%
	}
	If !(A_Gui or px) and a
		Return
	i = x.w.y.h./.7.%A_GuiWidth%.%A_GuiHeight%.`n%A_Gui%:%c%=
	StringSplit, i, i, .
	d := a ? d . ((n := !InStr(d, i9)) ? i9 : "")
		: RegExReplace(d, "\n\d+:" . c . "=[\-\.\d\/]+")
	Loop, 4
		x := A_Index, j := i%x%, i6 += x = 3
		, k := !RegExMatch(a, j . "([\d.]+)", v) + (v1 ? v1 : 0)
		, e := p%j% - i%i6% * k, d .= n ? e . i5 : ""
		, RegExMatch(d, "\Q" . i9 . "\E(?:([\d.\-]+)/){" . x . "}", v)
		, l .= p%j% := InStr(a, j) ? (ex ? "" : j) . v1 + i%i6% * k : ""
	If r
		rx = Draw
	If ex
		ControlMove, %c%, px, py, pw, ph
	Else GuiControl, Move%rx%, %c%, %l%
}


GuiSize:
  Anchor("HiEdit1", "wh")
return


#include HiEdit.ahk
#include CmnDlg.ahk