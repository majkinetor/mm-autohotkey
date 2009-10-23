_("mo!")
	
	text = 
	 (Ltrim
		http://www.google.com
		www.google.com

		meh...
	 )

	CreateGui(text)
	Form_Show()

	;RichEdit_SetText(hRichEdit, "Document.rtf", "FROMFILE")
	;RichEdit_SetEvents(hRichEdit, "Handler", "DRAGDROPDONE DROPFILES KEYEVENTS MOUSEEVENTS SCROLLEVENTS PROTECTED REQUESTRESIZE")
return

CreateGui(Text, W=800, H=600) {
	global 

	hForm1 := Form_New("+Resize w" W " h" H)
			
				 Form_Add(hForm1, "StatusBar", "RichEdit Test", "", "Align b")
	hPanel1   := Form_Add(hForm1, "Panel", "", "", "Align L, 300", "Attach h")
	hRichEdit := Form_Add(hForm1, "RichEdit", Text, "", "Align F", "Attach w h")

	hExample := Form_Add(hPanel1, "Edit", "", "ReadOnly ", "Align T, 250", "*|)Font s8, Courier New")
	hList	 := Form_Add(hPanel1, "ListView", "API", "gOnLV", "Align F", "Attach h",  "*|)Font s10, Courier New")

	PopulateList()
}

PopulateList() {
	apis = AutoUrlDetect
	loop, parse, apis, %A_Space%
		LV_Add("", A_LoopField)
}

OnLV:
  If ( A_GuiEvent != "DoubleClick" )
	return 

  LV_GetText( api, LV_GetNext() )
  goto %api%
return


AutoUrlDetect:  ; Enable disable or toggle automatic detection of URLs by a rich edit control.
  state := RichEdit_AutoUrlDetect( hRichEdit )
  MsgBox,262144,, % "url detect = " state
  
  state := RichEdit_AutoUrlDetect( hRichEdit, "Toggle" )
  MsgBox,262144,, % "url detect = " state
  
  MsgBox,262144,, % RichEdit_AutoUrlDetect( hRichEdit, false )
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