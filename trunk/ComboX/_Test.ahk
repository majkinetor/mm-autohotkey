_("mo!")
SetBatchLines, -1
#SingleInstance, force 

	Gui, +LastFound 
	Gui, Add, Edit, vMyEdit1 gOnFontChange w160
	Gui, Add, Edit, x+0 vMyEdit2 gOnFontChange w160

	Gui, Font, ,Webdings
	Gui, Add, Button, HWNDhBtn x+5 gCxLV w24 h25 0x8000, 6
	Gui, Font, 
	
	Gui, Add, Edit, xm vMainEdit xm w350 h250,Some Test text`nbla bla bla bla`n`n`n`n`nSome more text 


	Gui, Add, ListView, HWNDhcxLV w348 h190 x20 y28 gOnCombo1 altsubmit, Font|Style 
	FillTheList()

	Gui, Add, Edit, HWNDhcxTV w370 h190 xm y+3 gOnCombo2 altsubmit
	Gui, Add, Button, HWNDhBtn2 gCxTV x360 y260 ,V
	FillTheTreeView()

	ComboX_Set( hcxLV, "esc space enter click " hBtn+0, "OnComboX"),	ComboX_Set( hcxTV, "enter esc" hbtn2+0, "OnComboX")
	Gui, Show, w385 h300, ComboX Test
return 

OnComboX(Hwnd, Event) {
	m(event, Hwnd)
}

FillTheList() {	
	LV_Add("", "Verdana", "s22 bold")
    LV_Add("", "Courier New", "s10")
    LV_Add("", "Times New Roman", "s10 italic underline")
    LV_Add("", "Arial Narrow", "s32")
    LV_Add("", "Comic Sans MS", "s14")
    LV_Add("", "Arial Bold", "s12")
    LV_Add("", "Terminal", "s12 strikeout italic")
    LV_Add("", "Webdings", "s22")
	LV_ModifyCol(1,140),   LV_ModifyCol(2,140)
}

FillTheTreeView() {
	loop, 10
		TV_ADD(A_Index)
}

F1::
CxLV:
	ComboX_Show(hcxLV)
return

CxTV:
	ComboX_Show(hcxTV)
return

OnCombo2:
OnCombo1:
Onbtn2:
Onbtn:
OnFontChange:

return

#include ComboX.ahk