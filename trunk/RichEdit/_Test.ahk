_("mo!")

	text = 
	 (Ltrim
		http://www.google.com
		www.google.com

		meh...
	 )
 
	CreateGui(text)

	Form_Show("", "Maximize")
	Log("Press F1 or doubleclick to execute selected API"), Log()
	RichEdit_AutoUrlDetect( hRichEdit, "^" )
	RichEdit_SetText(hRichEdit, "Document.rtf", "FROMFILE")
	;	RichEdit_LimitText( hRichEdit, 900000 )  ; to taste save...
return

F2::
	RichEdit_SetFontSize(hRichEdit, 2)
return

Handler(hCtrl, Event, p1, p2, p3 ) {
  If (Event = "DROPFILES")  {
    MsgBox, % "Dropped files: " P1 "`n----`n" P2 "`n----`nChar position: " P3
    return
  }

  msg = %Event% `tp1 = %p1% `tp2 = %p2% `tp3 = %p3% `t%L%
  Log(msg)
  IfEqual, Event, PROTECTED, return TRUE
}

CreateGui(Text, W=850, H=600) {
	global 

	CMenu=
	(LTrim
		[RichEditMenu]
		Cut
		Copy
		Paste
	)

	btns =
	(LTrim
		Load,,,autosize
		Save,,,autosize
	    -----
		B,,,autosize
		I,,,autosize
		U,,,autosize
		S,,,autosize
		-----
		Font,,,autosize
		FG,,,autosize
		BG,,,autosize
		-
		+2,,,autosize
		-2,,,autosize
		-----
		Wrap,,,check autosize
		BackColor,,,autosize
		-----
		Events,,,check autosize
	)

	hForm1    := Form_New("+Resize w" W " h" H)
	hList	  := Form_Add(hForm1, "ListView", "API|Description", "gOnLV AltSubmit", "Align T", "Attach p")
	hPanel1   := Form_Add(hForm1, "Panel", "", "", "Align L, 300", "Attach p")
	hExample  := Form_Add(hPanel1,"Edit", "`n", "T8 ReadOnly Multi -vscroll", "Align T,150", "Attach p", "*|)Font s10,Tahoma")
	hLog	  := Form_Add(hPanel1,"ListBox", "", "0x100", "Align F", "Attach p")
	hSplitter := Form_Add(hForm1, "Splitter", "", "", "Align L, 6", "Attach p")
	hPanel2	  := Form_Add(hForm1, "Panel", "", "", "Align F", "Attach p")
	hPanel3   := Form_Add(hPanel2, "Panel", "", "", "Align T,30", "Attach w")
				 Form_Add(hPanel3, "Slider", "", "Range1-10 gOnSlider vSlider h30", "Align R, 100", "Attach x")
	hToolbar  := Form_Add(hPanel3, "Toolbar", btns, "gOnToolbar style='flat nodivider tooltips' il=0 x30", "Align F", "Attach w")
	Toolbar_SetBitmapSize(hToolbar, 0)
	hRichEdit := Form_Add(hPanel2, "RichEdit", "", "style='MULTILINE SCROLL WANTRETURN'", "Align F", "Attach w h", "CMenu RichEditMenu")

	cSlider := 0
	Splitter_Set(hSplitter, hPanel1 " | " hPanel2)
	PopulateList()		
}

OnSlider:
	d := slider - cslider
	ifEqual, d, 0, return
	
	
	RichEdit_Zoom( hRichEdit, d ) 
	critical off


	cSlider := slider
return

Form1_Close:
	ExitApp
return

RichEditMenu:
	if A_ThisMenuItem in Cut,Copy,Paste
		Edit_%A_ThisMenuItem%(hRichEdit)
return

Log(t1="", t2="", t3="", t4="", t5="") {
	global hLog
	txt = %t1% %t2% %t3% %t4% %t5%
	Control,Add,%txt%,, ahk_id %hLog%
	ControlSend, ,{End},ahk_id %hLog%
}

OnToolbar(hCtrl, Event, Txt, Pos=""){
	global 
	ifEqual, Event, hot, return

	if Txt = Font
	{
		RichEdit_GetCharFormat( hRichEdit, font, style, color)
		if Dlg_Font(font, style, color, 1, hForm1)
			RichEdit_SetCharFormat(hRichEdit, font, style, color)
	}

	if Txt = FG
	{
		RichEdit_GetCharFormat( hRichEdit, _, _, color)
		if Dlg_Color(color, hForm1)
			RichEdit_SetCharFormat(hRichEdit, "", _, color)
	}

	if Txt = BG
		msgbox  not implemented

	if Txt = Wrap 
		RichEdit_WordWrap(hRichEdit, Toolbar_GetButton(hCtrl, Pos, "S")="checked")

	if Txt in B,I,U,S
	{
		B := "bold", I := "italic", U := "underline", S := "strikeout"
		RichEdit_GetCharFormat( hRichEdit, _, style)
		if Instr(style, %Txt%)
			StringReplace, style, style, %Txt%
		else style .= " " %Txt%
		RichEdit_SetCharFormat( hRichEdit, "", style )
	}

	if Txt = BackColor
		if Dlg_Color(color, hForm1)
			RichEdit_SetBgColor(hRichEdit, color)	
	
	if Txt = Load
		RichEdit_SetText(hRichEdit, Dlg_Open(hForm1), "FROMFILE")

	if Txt = Save
		if fn := Dlg_Save(hForm1, "", "", "", "", "rtf") 
			RichEdit_Save(hRichEdit, fn)

	if Txt = Events
	{
		b := Toolbar_GetButton(hCtrl, Pos, "S")="checked"
		events := !b ? "" : "DRAGDROPDONE DROPFILES KEYEVENTS MOUSEEVENTS SCROLLEVENTS PROTECTED REQUESTRESIZE"
		RichEdit_SetEvents(hRichEdit, "Handler", events)
	}

	If Txt in +2,-2
		RichEdit_SetFontSize(hRichEdit, Txt)
}

PopulateList() {
	global demo

	FileRead, demo, % A_ScriptFullPath
	StringReplace, demo, demo, `r,,A
	StringReplace, demo, demo, MsgBox`,262144`,`,,MsgBox`,,A

    ;take only sublabels that have description
	pos := 1
	Loop
		If pos := RegExMatch( demo, "`ami)^(?P<Api>[\w]+):\s*;\s*(?P<Desc>.+)$", m, pos )
		  LV_Add("", mApi, mDesc ),  pos += StrLen(mApi), n := A_Index
		Else break

	Log(n " APIs detected.")

	LV_ModifyCol(1,180), LV_ModifyCol(2), LV_Modify(1, "select")
}

OnLV:
  LV_GetText( api, LV_GetNext() ), LV_GetText( desc, LV_GetNext(), 2 )

  If ( A_GuiEvent = "I" ) {
	RegExMatch(demo, "mi)" api ":\s*(;.+?)\nreturn", m)
	StringReplace, m1, m1, `n,`r`n,A
	ControlSetText, ,%m1%, ahk_id %hExample%
  }
  If ( A_GuiEvent = "DoubleClick" )
	IfNotEqual, api, API, goto %api%
return


AutoUrlDetect:  ; Enable disable or toggle automatic detection of URLs by a rich edit control.

  state := RichEdit_AutoUrlDetect( hRichEdit )
  MsgBox,262144,, % "url detect = " state
  
  state := RichEdit_AutoUrlDetect( hRichEdit, "^" )
  MsgBox,262144,, % "url detect = " state
return

GetSel: ;Retrieve the starting and ending character positions of the selection.

	RichEdit_GetSel( hRichEdit, min, max  )
	if !(count := min-max)
		 MsgBox, Cursor Position: %min%
	else MsgBox,,%count% char's selected, Selected from: %max%-%min%
return

GetText: ;Retrieves a specified range of characters from a rich edit control.

 msgbox % RichEdit_GetText( hRichEdit ) ; get current selection
 msgbox % RichEdit_GetText( hRichEdit, 0, -1 ) ; get all
 msgbox % RichEdit_GetText( hRichEdit, 4, 10 ) ; get range
return

LineFromChar: ;Determines which line contains the specified character in a rich edit control.

 msgbox, % "Line: " RichEdit_LineFromChar( hRichEdit, RichEdit_GetSel(hRichEdit) )
return

LimitText:	;Sets an upper limit to the amount of text the user can type or paste into a rich edit control
	RichEdit_LimitText( hRichEdit, 20 )  ; limit to 20 characters
return

TextMode:	;Sets text mode.
	txt := RichEdit_GetText( hRichEdit, 0, -1 )
	RichEdit_SetText(hRichEdit)
	RichEdit_TextMode(hRichEdit, "RICHTEXT") 
	RichEdit_SetText(hRichEdit, txt)
return

^1::reload
^U::
^B::
^I::
	OnToolbar(hToolbar, "click", SubStr(A_ThisHotkey, 2))
return

F1:: IfNotEqual, api, API, goto %api%

#include RichEdit.ahk
#include Todo.ahk

;sample includes
#include Edit.ahk
#include inc
#include _.ahk
#include Dlg.ahk
#include Attach.ahk
#include Align.ahk
#include Form.ahk
#include Panel.ahk
#include Font.ahk
#include Splitter.ahk
#include Toolbar.ahk
#include CMenu.ahk
