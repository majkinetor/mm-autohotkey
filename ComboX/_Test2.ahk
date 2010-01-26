#NoEnv 
#SingleInstance Force 
SendMode Input 
SetWorkingDir %A_ScriptDir%  
_("d")
SetBatchLines -1 

  Gui, +LastFound 
  Gui, Add, ListView, w254 h170 x20 y28 hwndhLV gLVEvents, test |t
  Gui, Add, datetime, w100 h22 x20 y28 hwndhED vvED, 111111111 
  ComboX_Set( hED, "esc enter", "OnComboX") 
  FillTheList() 
  Gui, Show, autosize, ComboX In Cell Editing Test 
return 

SetCombo() {
	global
	static LB_GETITEMRECT = 0x198, LB_GETITEMHEIGHT = 0x1A1
	
	VarSetCapacity(RECT, 16, 0), NumPut(2, RECt)
	SendMessage, 0x1000+14, LV_GetNext()-1, &RECT, , ahk_id %hLV%
	loop, 4
		p%A_Index% := NumGet(RECT, A_Index*4-4)

	Win_GetRect(hLV, "xywh", cx, cy, cw, ch)
	Win_Move(hEd, p1+cx+1, p2+cy+1, p3-p1, p4-p2)
}

F1:: SetCombo(), ComboX_Show(hEd)

LVEvents: 
  IF A_GuiControlEvent = DoubleClick 
    ComboX_Show(hED) 
return 

OnComboX(Hwnd, Event) { 
	global 
	if (Event != "select") 
		return
	
	GuiControlGet, NewValue , , vED, 
	LV_GetText( RowData, FocusedRow := LV_GetNext("C"), 1 ) 
} 

FillTheList() {    
    LV_Add("", "Verdana") 
    LV_Add("", "Courier New") 
    LV_Add("", "Times New Roman") 
    LV_Add("", "Arial Narrow") 
    LV_Add("", "Comic Sans MS") 
    LV_Add("", "Arial Bold") 
    LV_Add("", "Terminal") 
    LV_Add("", "Webdings") 
    LV_ModifyCol(1,"Auto") 
} 

#include ComboX.ahk