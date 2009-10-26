_("mo!")
#MaxThreads, 255

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
	hToolbar  := Form_Add(hPanel3, "Toolbar", btns, "gOnToolbar style='flat nodivider tooltips' il=0 x0 h30", "Align T", "Attach w")
	Toolbar_SetBitmapSize(hToolbar, 0)	

	hPanel4   := Form_Add(hPanel2, "Panel", "", "", "Align T,30", "Attach w")
		hFind := Form_Add(hPanel4, "Edit",   "", "x0 y0 w100")
 				 Form_Add(hPanel4, "Button", "Find", "gOnFind h24 x+2 AltSubmit 0x8000")
		hUp	  := Form_Add(hPanel4, "CheckBox", "up", "x+2 yp+5")

	hRichEdit := Form_Add(hPanel2, "RichEdit", "", "style='MULTILINE SCROLL WANTRETURN'", "Align F", "Attach w h", "CMenu RichEditMenu")

	cSlider := 0
	Splitter_Set(hSplitter, hPanel1 " | " hPanel2)
	PopulateList()		
}

OnFind:
	pos := RichEdit_GetSel(hRichEdit)
	ControlGetText, txt, ,ahk_id %hFind%
	ControlGet, bUp, Checked,  ,,ahk_id %hUp%
	direction := bUp ? "" : " down"

	pos := RichEdit_FindText(hRichEdit, txt, pos + (bUp ? -1 : 1), -1, "unicode" direction)
	Log("Found pos: " pos)
	if pos != -1
	{
		RichEdit_SetSel(hRichEdit, pos, pos+StrLen(txt))
		ControlFocus, , ahk_id %hRichEdit%
	}
return

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
		RichEdit_%A_ThisMenuItem%(hRichEdit)
return

Log(t1="", t2="", t3="", t4="", t5="") {
	global hLog, hRichEdit
	txt = %t1% %t2% %t3% %t4% %t5%
	Control,Add,%txt%,, ahk_id %hLog%
	ControlSend, ,{End},ahk_id %hLog%
	ControlFocus,, ahk_id %hRichEdit%
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

	FileRead, demo, _Demo.ahk
	StringReplace, demo, demo, `r,,A

    ;take only sublabels that have description
	pos := 1
	Loop
		If pos := RegExMatch( demo, "`ami)^(?P<Api>[\w]+):\s*;\s*(?P<Desc>.+)$", m, pos )
		  LV_Add("", mApi, mDesc ),  pos += StrLen(mApi), n := A_Index
		Else break

	Log(n " demo APIs detected.")

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


^1::reload
^U::
^B::
^I::
	OnToolbar(hToolbar, "click", SubStr(A_ThisHotkey, 2))
return

F1:: IfNotEqual, api, API, goto %api%

#include RichEdit.ahk
#include _Demo.ahk
#include Todo.ahk

;sample includes
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
