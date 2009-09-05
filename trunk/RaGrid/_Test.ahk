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

	Gui, Add, Button,x+24 yp	gOnBtn, Reload
	Gui, Add, Button,x+0 w15 yp	gOnBtn, ?

;EDITTEXT,EDITLONG,	CHECKBOX,	COMBOBOX,	HOTKEY,	BUTTON,	IMAGE,	DATE,	TIME,	USER,	EDITBUTTON
	hGrd := RG_Add(hwnd, 0, 30, 500, 300, "GRIDFRAME VGRIDLINES NOSEL" )
	
	RG_AddColumn(hGrd, "cap=Text", "w=150", "ha=2", "ca=2", "type=EditText" )
	RG_AddColumn(hGrd, "cap=Text", "w=50", "ha=2", "ca=2", "type=EditText" )
	RG_AddColumn(hGrd, "cap=Combo", "w=90", "ha=1", "ca=1", "type=ComboBox")
	RG_AddColumn(hGrd, "cap=Check", "w=70", "ha=1", "ca=1", "type=CheckBox")
	RG_AddColumn(hGrd, "cap=Button", "w=100", "ha=1", "ca=1", "type=Button")
	RG_SetFont(hGrd, "s10 bold, Arial")


	aCol1 := "Another",	aCol2 := "12", 	RG_AddRow(hGrd, "aCol")
	aCol1 := "extreme",	aCol2 := "8", 	RG_AddRow(hGrd, "aCol")
	aCol1 := "control",	aCol2 := "15", 	RG_AddRow(hGrd, "aCol")
	aCol1 := "RaGrid"	aCol2 := "11", 	RG_AddRow(hGrd, "aCol")
	RG_ComboAddString(hGrd, 2, "combo 1|combo 2|combo 3")

	RG_SetCellNum(hGrd, 0, 2, 0)	;set combo indices
	RG_SetCellNum(hGrd, 2, 2, 2)

	RG_SetCellNum(hGrd, 0, 3, 1)	;set radios here
	RG_SetCellNum(hGrd, 1, 3, 0)
	RG_SetCellNum(hGrd, 2, 3, 1)
	RG_SetCellNum(hGrd, 3, 3, 0)

	RG_SetCellText(hGrd, 1, 1, "1234")		
	RG_SetCellText(hGrd, 1, 4, "btn txt")

	RG_SetHdrHeight(hGrd, 30)
	RG_SetRowHeight(hGrd, 22)

	RG_SetHdrText(hGrd, 0, "Some Text")

    Attach("RaGrid1", "w h")
	Gui, Show, h300 w500
return 


OnBtn:

	if A_GuiControl = Insert
		RG_AddRow(hGrd, aColName, RG_GetCurRow(hGrd))

	if A_GuiControl = Delete
		RG_DelRow(hGrd, RG_GetCurRow(hGrd))
	
	if A_GuiControl = Move up 
	{
		r := RG_GetCurRow(hGrd)
		RG_MoveRow(hGrd, r, r+1)
		RG_SetCurRow(hGrd, r+1) 
	}

	if A_GuiControl = Move down 
	{
		r := RG_GetCurRow(hGrd)
		RG_MoveRow(hGrd, r, r-1)
		RG_SetCurRow(hGrd, r-1) 
	}

	if A_GuiControl = Reload
		Reload

	if A_GuiControl = Colorize
		RG_SetRowColor(hGrd, 0xFF, 0xFF0000, RG_GetCurRow(hGrd) )
	
	if A_GuiControl = Read Cell
	{	
		c := RG_GetCurCol(hGrd)
		txt := RG_GetCellNum(hGrd, RG_GetCurRow(hGrd), RG_GetCurCol(hGrd))
		if c in 0,1,4
			txt := RG_GetCellText(hGrd, RG_GetCurRow(hGrd), RG_GetCurCol(hGrd))



		msgbox %txt%
	}

	if A_GuiControl = Set Colors
		RG_SetColors(hGrd, "B1 GFFFFFF TFFFFFF")

	;refresh (happens when you set focus)	
	ControlFocus,, ahk_id %hGrd%
return


#Include RaGrid.ahk
#Include Attach.ahk