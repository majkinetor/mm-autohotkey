#SingleInstance, force
	Gui, +LastFound +Resize
	hwnd := WinExist()

	Gui, Add, Button,x0		gOnBtn, Insert
	Gui, Add, Button,x+0 yp	gOnBtn, Delete
	Gui, Add, Button,x+0 yp	gOnBtn, Move Up
	Gui, Add, Button,x+0 yp	gOnBtn, Move Down

	Gui, Add, Button,x+20 yp	gOnBtn, Colorize
	Gui, Add, Button,x+0 yp	gOnBtn, Set Colors
	Gui, Add, Button,x+20 yp	gOnBtn, Read Cell

	Gui, Add, Button,x+40 yp	gOnBtn, Reload
	Gui, Show, h300 w600

	hGrd := RG_Add(hwnd, 0, 40, 600, 300, "GRIDFRAME VGRIDLINES NOSEL" ), Attach(hGrd, "w h")
	RG_SetFont(hGrd, "s10, Arial")
	RG_SetHdrHeight(hGrd, 30), RG_SetRowHeight(hGrd, 22)	

	RG_AddColumn(hGrd, "txt=EditText",  "w=150", "hdral=0"	"txtal=2", "type=EditText")
	RG_AddColumn(hGrd, "txt=EditLong",  "w=100", "hdral=2", "txtal=2", "type=EditLong")
	RG_AddColumn(hGrd, "txt=Combo",		"w=90",  "hdral=1", "txtal=1", "type=ComboBox")
	RG_AddColumn(hGrd, "txt=Check",		"w=70",  "hdral=1", "txtal=1", "type=CheckBox")
	RG_AddColumn(hGrd, "txt=Button",	"w=100", "hdral=1", "txtal=1", "type=Button")
	RG_AddColumn(hGrd, "txt=Hotkey",	"w=100", "hdral=1", "txtal=1", "type=Hotkey")

	RG_ComboAddString(hGrd, 3, "combo 1|combo 2|combo 3|combo 4|combo 5|combo 6|combo 7|combo 8|combo 9|combo 10|combo 11|combo 12")
	
	RG_SetCell(hGrd, 1, 1, "Hello there")

;	RG_AddRow(hGrd, "", "Another", "12")
;	RG_AddRow(hGrd, "", "Extreme", "8")
;	RG_AddRow(hGrd, "", "control")
;	RG_AddRow(hGrd, "", "- RaGrid -")


;	RG_SetCellNum(hGrd, 0, 2, 0)	;set combo indices
;	RG_SetCellNum(hGrd, 2, 2, 2)
;
;	RG_SetCellNum(hGrd, 0, 3, 1)	;set radios here
;	RG_SetCellNum(hGrd, 1, 3, 0)
;	RG_SetCellNum(hGrd, 2, 3, 1)
;	RG_SetCellNum(hGrd, 3, 3, 0)
;
;	RG_SetCellText(hGrd, 1, 1, "1234")		
;	RG_SetCellText(hGrd, 1, 4, "btn txt")
;
	

return 


OnBtn:
	if A_GuiControl = Insert
		RG_AddRow(hGrd, aColName, RG_GetCurrentRow(hGrd))

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

	if A_GuiControl = Colorize
		RG_SetRowColor(hGrd, 0xFF, 0xFF0000)
	
	if A_GuiControl = Read Cell
		msgbox % RG_GetCell(hGrd)

	if A_GuiControl = Set Colors
		RG_SetColors(hGrd, "B1 GFFFFFF TFFFFFF")
return


#Include RaGrid.ahk
#include inc\Attach.ahk