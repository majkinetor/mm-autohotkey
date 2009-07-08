#SingleInstance, force
SetBatchLines, -1

	Gui, +LastFound +LabelMyGui
	hGui := WinExist() 
	w := 950, h := 650
	Gui, Show , w%w% h%h% Hide, Toolbar Test		;set gui width & height (mandatory)

	Gui, Add, StatusBar, , 

	hIL := IL_Create(200, 0, 1) 
	loop, 150
	   IL_ADD(hIL, A_WinDir "\system32\shell32.dll", A_Index) 

	hToolbar := Toolbar_Add(hGui, "OnToolbar", "WRAPABLE ADJUSTABLE FLAT TOOLTIPS", hIL)

	btns = 
	(LTrim
		btn &1  ,	,checked, check
		btn &2	,	,		,dropdown check showtext, 101
		btn &3	,	,		,,
		-
		btn &4	,7	,		,dropdown check showtext, 102
		btn &5	,	,		,showtext a

		*a1		,128,		,showtext
		*a2		,129
		*a3		,130
	)
	Toolbar_AddButtons(hToolbar, btns)
	Gui, Show, , 
	MakeTestGui(w/2, h-430)
return

MakeTestGui(w, h){

	help=
	(LTrim
		Function		Parameter(s)
		____________________________________________________________________

		AddButtons		pBtns,  pPos=""

		Define			pQ = "c" - current btns only, "a" - available btns only, "" - everything

		DeleteButton		pPos=1 

		GetButton		pWhichBtn,  pQ = C (Caption), I (Icon number), S (State), L (styLe)

		Count			pQ="c | a" 

		SetButton		pWhichBtn,  state = "[-]checked, [-]disabled, [-]hidden",  width=""

		SetButtonWidth		pMin, pMax=""

		ToggleStyle		pStyle= "adjustable border flat list tooltips tabstop wrapable"	

		
		pWitchBtn		Button postion or ID. To specify ID use "." infront of the number
		pQ			Query parameter, function dependant
		pBtns			Button defintion: [*]caption, iconNum, state, style, ID
	)
		

	Gui, Add, BUTTON, w100 X0 y%h% section gOnBtn, Define
	Gui, Add, BUTTON, w100 X+10 yp gOnBtn, Add
	Gui, Add, BUTTON, w100 X+10 yp gOnBtn, Insert
	Gui, Add, BUTTON, w100 X+10 yp gOnBtn, Delete
	Gui, Add, BUTTON, w100 X+10 yp gOnBtn, Clear

	Gui, Add, BUTTON, w100 Xs	gOnBtn, Count
	Gui, Add, BUTTON, w100 X+10 yp gOnBtn, Customize
	Gui, Add, BUTTON, w100 X+10 yp gOnBtn, ToggleStyle

	Gui, Add, BUTTON, w100 Xs  gOnBtn, GetButton
	Gui, Add, BUTTON, w100 X+10 yp  gOnBtn, SetButton
	Gui, Add, BUTTON, w100 X+10 yp  gOnBtn, SetButtonWidth
	Gui, Add, BUTTON, w100 X+10 yp  gOnBtn, SetButtonSize

	Gui, Add, Text, x0 y+10 , Input / Output :
	Gui, Add, Edit, x0 w%w% y+5 h300,
	Gui, Add, Text, x+10 yp w%w% h300, %help%
}

OnToolbar(hwnd, event, pos, txt, id) {
	if event = hot
	{
		d := Toolbar_GetButton(hwnd, pos, "d"),   s := Toolbar_GetButton(hwnd, pos, "s")
		return SB_SetText(txt  "   Data: " d "  " s)
	}

	msgbox Event:  %event%`nPosition:  %pos%`nCaption:  %txt%`n`nID:%id%
}

OnBtn:
		
	_ := Get()
	p1 := p2 := p3 := ""
	stringsplit, p, _, `,,%A_Space%%A_Tab%

	if A_GuiControl = Define
		Set( Toolbar_Define(hToolbar, p1) )

	if A_GuiControl = Count
		Set( Toolbar_Count(hToolbar, p1) )

	if A_GuiControl = Customize
		Toolbar_Customize(hToolbar)

	if A_GuiControl = Add
		Toolbar_AddButtons(hToolbar, _)

	if A_GuiControl = Insert
		Toolbar_AddButtons(hToolbar, _, 3)

	if A_GuiControl = ToggleStyle
		Toolbar_ToggleStyle(hToolbar, p1 != "" ? p1 : "LIST")

	if A_GuiControl = Delete
		Toolbar_DeleteButton(hToolbar, p1 != "" ? p1 : 1)
	
	if A_GuiControl = GetButton
		Set( Toolbar_GetButton(hToolbar, p1 != "" ? p1 : 1) )
	
	if A_GuiControl = Clear
		Toolbar_Clear(hToolbar)

	if A_GuiControl = SetButton
		Toolbar_SetButton(hToolbar, p1, p2, p3)

	if A_GuiControl = SetButtonWidth
		Toolbar_SetButtonWidth(hToolbar, p1, p2)

	if A_GuiControl = SetButtonSize
		Toolbar_SetButtonSize(hToolbar, p1, p2)		
return

Set(txt){
	ControlSetText, Edit1, %txt%, A
}

Get() {
	ControlGetText, txt, Edit1, A
	StringReplace, txt, txt, `r`n, `n, A
	return txt
}

#Include Toolbar.ahk