#NoEnv
#SingleInstance Force  
SetBatchLines -1 
DetectHiddenWindows, on

  Gui, +LastFound 
  Gui, Add, ListView, w254 h170 x20 y28 hwndhLV gLVEvents, test |t
  Gui, Add, Edit, w100 h22 x20 y28 hwndhED vvED, 111111111 
  ComboX_Set( hED, "esc enter", "OnComboX") 
  FillTheList() 
  Gui, Show, autosize, ComboX In Cell Editing Test 
return 

F1:: ShowCombo()

SetCombo() {
	global
	
	VarSetCapacity(RECT, 16, 0), NumPut(2, RECt)
	SendMessage, 0x1000+14, LV_GetNext()-1, &RECT, , ahk_id %hLV%	;LVM_GETITEMRECT
	loop, 4
		p%A_Index% := NumGet(RECT, A_Index*4-4)

	Win_GetRect(hLV, "xywh", cx, cy, cw, ch)
	Win_Move(hEd, p1+cx+1, p2+cy+1, p3-p1+2, p4-p2)
}

ShowCombo(){
	global
	
	LV_GetText(txt, LV_GetNext())
	
	SetCombo()
	ComboX_Show(hEd)
	ControlSetText,,%txt%, ahk_id %hEd%
	Send {End}^a
}

LVEvents: 
  IF A_GuiControlEvent = DoubleClick 
		ShowCombo() 
return 

OnComboX(Hwnd, Event) { 
	global 
	if (Event != "select") 
		return
	
	ControlGetText, txt, , ahk_id %hEd%  
	LV_Modify(LV_GetNext(), "", txt) 
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