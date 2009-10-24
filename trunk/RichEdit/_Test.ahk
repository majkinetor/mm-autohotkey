_("mo!")

	text = 
	 (Ltrim
		http://www.google.com
		www.google.com

		meh...
	 )

	CreateGui(text)
	Form_Show("", "Maximize")
	
	RichEdit_AutoUrlDetect( hRichEdit, "^" )
	RichEdit_SetText(hRichEdit, "Document.rtf", "FROMFILE")
	;RichEdit_SetEvents(hRichEdit, "Handler", "DRAGDROPDONE DROPFILES KEYEVENTS MOUSEEVENTS SCROLLEVENTS PROTECTED REQUESTRESIZE")
return

CreateGui(Text, W=850, H=600) {
	global 

	hForm1 := Form_New("+Resize w" W " h" H)
	hList	 := Form_Add(hForm1, "ListView", "API|Description", "gOnLV AltSubmit", "Align T", "Attach p")
				Form_Add(hForm1, "StatusBar", "RichEdit Test", "", "Align B")

	hPanel1   := Form_Add(hForm1, "Panel", "", "", "Align L, 300", "Attach p")
				 Form_Add(hPanel1,"Button", "Execute", "gOnExecute 0x8000", "Align T", "Attach p")
	hExample  := Form_Add(hPanel1,"Edit", "`n", "T8 hscroll ReadOnly Multi -Wrap", "Align F", "Attach p", "*|)Font s10, Courier New")
	hSplitter := Form_Add(hForm1, "Splitter", "", "", "Align L, 6", "Attach p")
	hPanel2	  := Form_Add(hForm1, "Panel", "", "", "Align F", "Attach p")
	hPanel3   := Form_Add(hPanel2, "Panel", "", "", "Align T,35", "Attach w")
	hToolbar  := Form_Add(hPanel3, "Toolbar", "B`nI`nU`nS`n---`nFont`nFG`nBG`n---`nWrap,,checked,CHECK", "gOnToolbar style='nodivider tooltips' il=0", "Attach w")
	Toolbar_SetBitmapSize(hToolbar, 0)
	hRichEdit := Form_Add(hPanel2, "RichEdit", "", "", "Align F", "Attach w h")

	Splitter_Set(hSplitter, hPanel1 " | " hPanel2)
	PopulateList()		
}

OnExecute:
	IfNotEqual, api, API, goto %api%
return

OnToolbar(hCtrl, Event, Txt, Pos, Id){
	global 
	ifEqual, Event, hot, return

	if Txt = Font
		Dlg_Font(font, style, color, 1, hForm1)

	if Txt in BG,FG
		Dlg_Color(color, hForm1)

	if Txt = Wrap 
		RichEdit_WordWrap(hRichEdit, Toolbar_GetButton(hCtrl, Pos, "S")="checked")

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

	SB_SetText("Number of functions: " n)

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
	else MsgBox,,%count% char's selected, Selected from: %min%-%max%
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

#include RichEdit.ahk

;sample includes
#include inc
#include _.ahk
#include Dlg.ahk
#include Attach.ahk
#include Align.ahk
#include Form.ahk
#include Panel.ahk
#include Font.ahk
#include Win.ahk
#include Splitter.ahk
#include Toolbar.ahk