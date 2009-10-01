_("mo!")
#SingleInstance, force
	Gui, +LastFound +Resize
	hwnd := WinExist()

	Gui, Add, Button,x0		gOnBtn, Insert
	Gui, Add, Button,x+0 yp	gOnBtn, Delete
	Gui, Add, Button,x+0 yp	gOnBtn, Move Up
	Gui, Add, Button,x+0 yp	gOnBtn, Move Down

	Gui, Add, Button,x+20 yp gOnBtn, Colorize Row
	Gui, Add, Button,x+0 yp	gOnBtn, Set Colors
	Gui, Add, Button,x+20 yp gOnBtn, Read Cell

	Gui, Add, Button,x+40 yp gOnBtn, Reload
	Gui, Show, h300 w1000
	
	hIL:= IL_Create(255)
	Loop 255  
		IL_Add(hIL, "shell32.dll", A_Index)

	
	hGrd := RG_Add(hwnd, 0, 40, 1000, 250, "GRIDFRAME VGRIDLINES NOSEL", "OnRa" ), Attach(hGrd, "w h")
	RG_SetFont(hGrd, "s10, Arial")
	RG_SetHdrHeight(hGrd, 30), RG_SetRowHeight(hGrd, 25)	

	loop,1
	{
		RG_AddColumn(hGrd, "txt=EditText",  "w=30", "hdral=1",	"txtal=1", "type=EditText")
		RG_AddColumn(hGrd, "txt=EditLong",  "w=100", "hdral=1", "txtal=1", "type=EditLong", "format=# ### ###")
		RG_AddColumn(hGrd, "txt=Combo",		"w=90",  "hdral=1", "txtal=1", "type=ComboBox")
		RG_AddColumn(hGrd, "txt=Check",		"w=30",  "hdral=1", "txtal=1", "type=CheckBox")
		RG_AddColumn(hGrd, "txt=Button",	"w=100", "hdral=1", "txtal=1", "type=Button")
		RG_AddColumn(hGrd, "txt=EButton",	"w=100", "hdral=1", "txtal=1", "type=EditButton")
		RG_AddColumn(hGrd, "txt=Image",		"w=100", "hdral=1", "txtal=1", "type=Image", "il=" hIL)
		RG_AddColumn(hGrd, "txt=Hotkey",	"w=100", "hdral=1", "txtal=1", "type=Hotkey")
		RG_AddColumn(hGrd, "txt=Date",		"w=100", "hdral=1", "txtal=1", "type=Date", "format=dd'.'MM'.'yyyy")
		RG_AddColumn(hGrd, "txt=Time",		"w=100", "hdral=1", "txtal=1", "type=Time", "format=hh':'mm")
		RG_AddColumn(hGrd, "txt=User",		"w=100", "hdral=1", "txtal=1", "type=User")
	}
	RG_ComboAddString(hGrd, 3, "combo 1|combo 2|combo 3|combo 4|combo 5|combo 6|combo 7|combo 8|combo 9|combo 10|combo 11|combo 12")

	loop, 255
		RG_AddRow(hGrd), RG_SetCell(hGrd, 1, A_Index, A_Index), RG_SetCell(hGrd, 7, A_INdex, A_Index)
		
	RG_AddRow(hGrd, "", "Another") ;, 0, 0, 1, "btn1", "ebtn1", 0)
;	RG_AddRow(hGrd, "", "Extreme", 1, 1, 0, "btn2", "ebtn2", 1)
;	RG_AddRow(hGrd, "", "Control", 2, 2, 1, "btn3", "ebtn3", 2)
;	RG_AddRow(hGrd, "", "RaGrid",  3, 3, 0, "btn4", "ebtn4", 3)
return 

OnRa(HCtrl, Event, Col, Row, Data="") {
;	m(hctrl, event, col, row, NumGet(data+0), RG_strAtAdr(data), data)

	if (Event = "beforeedit") && (Col=1)
		return 1
}

OnBtn:
	if A_GuiControl = Insert
		RG_AddRow(hGrd, RG_GetCurrentRow(hGrd))

	if A_GuiControl = Delete
		RG_DeleteRow(hGrd)
	
	if A_GuiControl = Move up 
	{
		r := RG_GetCurrentRow(hGrd)
		RG_MoveRow(hGrd, r, r+1)
		RG_SetCurrentRow(hGrd, r+1) 
	}

	if A_GuiControl = Move down 
	{
		r := RG_GetCurrentRow(hGrd)
		RG_MoveRow(hGrd, r, r-1)
		RG_SetCurrentRow(hGrd, r-1) 
	}

	if A_GuiControl = Reload
		Reload

	if A_GuiControl = Colorize Row
	{
		RG_SetRowColor(hGrd, "", 0xFF, 0xFF0000)
		WinSet, Redraw, ,ahk_id %hGrd%
	}
	
	if A_GuiControl = Read Cell
		msgbox % RG_GetCell(hGrd)

	if A_GuiControl = Set Colors
		RG_SetColors(hGrd, "B1 G0xFF F0xFFFFFF")
return


F1:: 	msgbox % RG_GetCell(hGrd)

#Include RaGrid.ahk
#include inc\Attach.ahk