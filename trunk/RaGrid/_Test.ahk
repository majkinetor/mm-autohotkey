_("mo! e")
#SingleInstance, force

	w := 1000, h := 500, header := 50

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
	Gui, Show, h%h% w%w%
	
	hIL:= IL_Create(255)
	Loop 255  
		IL_Add(hIL, "shell32.dll", A_Index)
	
	hGrd := RG_Add(hwnd, 0, header, w, h-header, "GRIDFRAME VGRIDLINES NOSEL", "OnRa" ), Attach(hGrd, "w h")
	RG_SetFont(hGrd, "s8, Courier New")
	RG_SetHdrHeight(hGrd, 30), RG_SetRowHeight(hGrd, 25)	

	loop, 1
	{
		RG_AddColumn(hGrd, "txt=EditText",  "w=100", "hdral=1",	"txtal=1", "type=EditText")
		RG_AddColumn(hGrd, "txt=EditLong",  "w=100", "hdral=1", "txtal=1", "type=EditLong", "format=# ### ####")
		RG_AddColumn(hGrd, "txt=Combo",		"w=90",  "hdral=1", "txtal=1", "type=ComboBox", "items=combo 1|combo 2|combo 3|combo 4|combo 5|combo 6|combo 7|combo 8|combo 9|combo 10|combo 11|combo 12")
		RG_AddColumn(hGrd, "txt=Check",		"w=70",  "hdral=1", "txtal=1", "type=CheckBox")
		RG_AddColumn(hGrd, "txt=Button",	"w=100", "hdral=1", "txtal=1", "type=Button")
		RG_AddColumn(hGrd, "txt=EButton",	"w=100", "hdral=1", "txtal=1", "type=EditButton")
		RG_AddColumn(hGrd, "txt=Image",		"w=100", "hdral=1", "txtal=1", "type=Image", "il=" hIL)
		RG_AddColumn(hGrd, "txt=Hotkey",	"w=100", "hdral=1", "txtal=1", "type=Hotkey")
		RG_AddColumn(hGrd, "txt=Date",		"w=100", "hdral=1", "txtal=1", "type=Date", "format=dd'.'MM'.'yyyy")
		RG_AddColumn(hGrd, "txt=Time",		"w=100", "hdral=1", "txtal=1", "type=Time", "format=hh':'mm")
		RG_AddColumn(hGrd, "txt=User",		"w=100", "hdral=1", "txtal=1", "type=User", "data=1234")
	}
	Rg_AddRow(HGrd)
	RG_GetColumn(hGrd, 2, "txt") ;, hdral=8, txtal=12, type=16, txtmax=20, format=24, il=28, hdrflag=32, hctrl=40, data=44")
	return

	loop, 10
		RG_AddRow(hGrd, 0, "Text" A_Index ,A_Index, mod(A_Index, 12), mod(A_Index, 2), "btn" A_Index, "",mod(A_Index, 255))
		, RG_AddRow(hGrd, 0 " " 10, "Text" A_Index ,A_Index, mod(A_Index, 12), mod(A_Index, 2), "btn" A_Index, "", mod(A_Index, 255))

	m("Loading finished`n`nRows " RG_GetRowCount(hGrd) " Cols " RG_GetColCount(hGrd))
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
		RG_SetRowColor(hGrd, "", 0xFF, 0xFFFF)
		WinSet, Redraw, ,ahk_id %hGrd%
	}
	
	if A_GuiControl = Read Cell
		msgbox % RG_GetCell(hGrd)

	if A_GuiControl = Set Colors
		RG_SetColors(hGrd, "B1 G0xFF F0xFFFFFF")
return

F1::  m( RG_ConvertDate(hGrd, "", RG_GetCell(hGrd)) )

#Include RaGrid.ahk
#include inc\Attach.ahk