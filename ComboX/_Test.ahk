SetBatchLines, -1
#SingleInstance, force 

	Gui, +LastFound 
	Gui, Add, Edit, x20 vMyEdit1 gOnFontChange w150
	Gui, Add, Edit, x+0 vMyEdit2 gOnFontChange w150
	Gui, Font, ,Webdings
	Gui, Add, Button, x+0 gOnBtn w20 h22s 0x8000, 6
	Gui, Font, 
	Gui, Add, Edit, xm vMainEdit xm w350 h250, Some Test text`n bla bla bla bla`n`n`n`n`nSome more text 


	Gui, Add, ListView, HWNDhCombo1 w300 h90 x20 y28 gOnCombo1 -Hdr altsubmit, c1|c2 
	LV_Add("")
	LV_Add("", "Verdana", "s22 bold")
    LV_Add("", "Courier New", "s10")
    LV_Add("", "Times New Roman", "s10 italic underline")
    LV_Add("", "Arial Narrow", "s32")
    LV_Add("", "Comic Sans MS", "s14")
    LV_Add("", "Arial Bold", "s12")
    LV_Add("", "Terminal", "s12 strikeout italic")
    LV_Add("", "Webdings", "s22")
	LV_ModifyCol(1,140),   LV_ModifyCol(2,140)


	Gui, Add, Button, gOnBtn2 x+40 w20 h15 y+150 0x8000, V
	Gui, Add, TreeView, HWNDhCombo2 w300 h90 xm y+3 gOnCombo2 altsubmit
	loop, 10
		TV_ADD(A_Index)

	ComboX( hCombo1 ), 	ComboX( hCombo2 )

	Gui, Add, Button, gOnAbout xm y300, About

	Gui, Show, w380 h400, ComboX Test

return 

OnAbout:
	msgbox % ComboX_About()
return

OnFontChange:
	Gui,  Submit, NoHide
	Gui, Font, %MyEdit2%, %MyEdit1%
	GuiControl, Font, MainEdit
return

OnCombo2:
	if (A_GuiEvent="DoubleClick") or ((A_GuiEvent="K") and (A_EventInfo=32)) {
		TV_GetText(txt, TV_GetSelection())
		ControlSend, Edit3, %txt%
	}
return 

OnCombo1:
	if (A_GuiEvent="DoubleClick") or ((A_GuiEvent="K") and (A_EventInfo=32)) {
		LV_GetText(txt1, LV_GetNext()), LV_GetText(txt2, LV_GetNext(), 2)
		GuiControl, ,MyEdit1, %txt1%
		GuiControl, ,MyEdit2, %txt2%
		
		ComboX_Hide(hCombo1)
	
		Gui, Font, %txt2%, %txt1%
		GuiControl, Font, MainEdit

	}
return

#IfWinActive ComboX Test
ESC::
	if ComboX_Active =
		ExitApp
	ComboX_Hide( ComboX_Active )
return 

F1::
OnBtn:
   ComboX_Show( hCombo1 )
return 

F2::
OnBtn2:
   ComboX_Show( hCombo2 )
return

#IfWinActive

#include ComboX.ahk