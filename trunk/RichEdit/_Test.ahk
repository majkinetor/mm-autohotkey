_("mo!")

	CreateGui(text)
	
	RichEdit_SetText(hRichEdit, "colors.rtf", "FROMFILE")
	RichEdit_AutoUrlDetect( hRichEdit, "^" )
	
	Form_Show("", "Maximize")

	Log("Press F1 or doubleclick to execute selected API")
	Log("Sort API by clicking ListView header.")
	Log()

	;RichEdit_SetText(hRichEdit, RTF_Table(3, 1, "300"), "", -1 )
return


Handler(hCtrl, Event, p1, p2, p3 ) {
  If (Event = "DROPFILES")  {
    MsgBox, % "Dropped files: " P1 "`n----`n" P2 "`n----`nChar position: " P3
    return
  }
	if event = Link
		Log("Link:", RichEdit_GetText(hCtrl, p2, p3))
  msg = %Event% `tp1 = %p1% `tp2 = %p2% `tp3 = %p3% `t%L%
  Log(msg)
  IfEqual, Event, PROTECTED, return TRUE
}

CreateGui(Text, W=980, H=600) {
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

	btns2 =
	(LTrim
		Num
		Bullet
		-----
		Left
		Center
		Right
		Justify
		-----
		->
		<-
	)

	hForm1    := Form_New("+Resize w" W " h" H)
	hList	  := Form_Add(hForm1, "ListView", "API|Description", "gOnLV AltSubmit", "Align T", "Attach p")
	hPanel1   := Form_Add(hForm1, "Panel", "", "", "Align L, 300", "Attach p")
	hExample  := Form_Add(hPanel1,"Edit", "`n", "T8 ReadOnly Multi -vscroll", "Align T,150", "Attach p", "*|)Font s10,Tahoma")
	hLog	  := Form_Add(hPanel1,"ListBox", "", "0x100", "Align F", "Attach p")
	hSplitter := Form_Add(hForm1, "Splitter", "", "", "Align L, 6", "Attach p")
	hPanel2	  := Form_Add(hForm1, "Panel", "", "", "Align F", "Attach p")


	hPanel3   := Form_Add(hPanel2, "Panel", "", "", "Align T,30", "Attach w")
				 Form_Add(hPanel3, "Slider", "", "Range1-10 gOnSlider AltSubmit vSlider h30", "Align R, 100", "Attach x")
	hToolbar  := Form_Add(hPanel3, "Toolbar", btns, "gOnToolbar style='flat nodivider tooltips' il=0 x0 h30", "Align T", "Attach w")
	Toolbar_SetBitmapSize(hToolbar, 0)	

	hPanel4   := Form_Add(hPanel2, "Panel", "", "", "Align T,30", "Attach w")
		hFind := Form_Add(hPanel4, "Edit",   "", "x0 y2 w100")
 				 Form_Add(hPanel4, "Button", "Find", "gOnFind h24 x+2 AltSubmit 0x8000")
		hUp	  := Form_Add(hPanel4, "CheckBox", "up", "x+2 yp+5")
	hToolbar  := Form_Add(hPanel4, "Toolbar", btns2, "gOnToolbar style='flat nodivider tooltips' il=0 x200 h30")
	Toolbar_SetBitmapSize(hToolbar, 0), Toolbar_AutoSize(hToolbar)

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
	Log(RichEdit_Zoom( hRichEdit ))
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
			 return RichEdit_SetCharFormat(hRichEdit, font, style, color)
		else return 
	}

	if Txt in FG,BG
	{
		RichEdit_GetCharFormat( hRichEdit, _, _, fg, bg)
		if Txt = FG
			 bg := ""
		else fg := ""

		if Dlg_Color(%txt%, hForm1)
			return RichEdit_SetCharFormat(hRichEdit, "", "", fg, bg)
		else return 
	}

	if Txt = Wrap 
		return RichEdit_WordWrap(hRichEdit, Toolbar_GetButton(hCtrl, Pos, "S")="checked")

	if Txt in B,I,U,S
	{
		B := "bold", I := "italic", U := "underline", S := "strikeout"
		RichEdit_GetCharFormat( hRichEdit, _, style)
		return RichEdit_SetCharFormat( hRichEdit, "", Instr(style, %Txt%) ? "-" %Txt% : %Txt% )
	}

	if Txt = BackColor
		if Dlg_Color(color, hForm1)
			 return RichEdit_SetBgColor(hRichEdit, color)
		else return
	
	if Txt = Load
		return RichEdit_SetText(hRichEdit, Dlg_Open(hForm1, "", "RTF files (*.rtf)|Text files (*.txt)"), "FROMFILE")

	if Txt = Save
		if fn := Dlg_Save(hForm1, "", "RTF files (*.rtf)|Text files (*.txt)", "", "", "rtf") 
			 return RichEdit_Save(hRichEdit, fn)
		else return

	if Txt = Events
	{
		b := Toolbar_GetButton(hCtrl, Pos, "S")="checked"
		events := !b ? "" : "DRAGDROPDONE LINK DROPFILES KEYEVENTS SELCHANGE SCROLLEVENTS PROTECTED REQUESTRESIZE"
		return RichEdit_SetEvents(hRichEdit, "Handler", events)
	}

	If Txt in +2,-2
		return RichEdit_SetFontSize(hRichEdit, Txt)

	if Txt in left,right,center,justify
		return RichEdit_SetParaFormat(hRichEdit, "Align=" Txt)

	if Txt in <-,->
		return RichEdit_SetParaFormat(hRichEdit, "Ident=" (Txt="<-" ? -1:1)*1000)
	
	if Txt in Num,Bullet
		return RichEdit_SetParaFormat(hRichEdit, "Num=" (Txt="Num" ? "DECIMAL" : "BULLET") ",1,D")
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

	Log(n " demo routines detected.")

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
#include RTF.ahk

#include _Demo.ahk

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
