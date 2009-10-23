_("mo!")

	text = 
	 (Ltrim
		http://www.google.com
		www.google.com

		meh...
	 )

	CreateGui(text)
	Form_Show("", "Maximize")

	;RichEdit_SetText(hRichEdit, "Document.rtf", "FROMFILE")
	;RichEdit_SetEvents(hRichEdit, "Handler", "DRAGDROPDONE DROPFILES KEYEVENTS MOUSEEVENTS SCROLLEVENTS PROTECTED REQUESTRESIZE")
return

CreateGui(Text, W=850, H=600) {
	global 

	hForm1 := Form_New("+Resize w" W " h" H)
	hList	 := Form_Add(hForm1, "ListView", "API|Description", "gOnLV AltSubmit", "Align T", "Attach p",  "*|)Font s10, Courier New")
				Form_Add(hForm1, "StatusBar", "RichEdit Test", "", "Align B")

	hPanel1   := Form_Add(hForm1, "Panel", "", "", "Align L, 300", "Attach p")
				 Form_Add(hPanel1,"Button", "Execute", "gOnExecute 0x8000", "Align T", "Attach p")
	hExample  := Form_Add(hPanel1,"Edit", "`n", "hscroll ReadOnly Multi -Wrap", "Align F", "Attach p", "*|)Font s10, Courier New")
	hSplitter := Form_Add(hForm1, "Splitter", "", "sunken", "Align L, 6", "Attach p")
	hRichEdit := Form_Add(hForm1, "RichEdit", Text, "", "Align F", "Attach p")

	Splitter_Set(hSplitter, hPanel1 " | " hRichEdit)
	PopulateList()
	RichEdit_SetText(hRichEdit, "Document.rtf", "FROMFILE")
}

OnExecute:
	IfNotEqual, api, API, goto %api%
return

PopulateList() {
	global demo

	FileRead, demo, % A_ScriptFullPath
	StringReplace, demo, demo, `r,,A
	StringReplace, demo, demo, MsgBox`,262144`,`,,MsgBox`,,A

    ;take only sublabels that have description
	pos := 1
	Loop
	If pos := RegExMatch( demo, "`ami)^(?P<Api>[\w]+):\s*;\s*(?P<Desc>.+)$", m, pos )
	  LV_Add("", mApi, mDesc ),  pos += StrLen(mApi)
	Else break

	LV_ModifyCol(1,180), LV_ModifyCol(2), LV_Modify(1, "select")
}

OnLV:
  LV_GetText( api, LV_GetNext() ), LV_GetText( desc, LV_GetNext(), 2 )

  If ( A_GuiEvent = "I" ) {
	RegExMatch(demo, "mi)" api ":\s*(;.+)return", m)
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