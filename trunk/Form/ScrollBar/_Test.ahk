_("mo!")
#SingleInstance force
	Gui,  +LastFound
	hwnd := WinExist()
	
	Gui, Add, Edit, +vscroll y50 h100 w230 vMyEdit, 0
;	hHBar := ScrollBar_Add(hwnd, 0,   10, 280, 8,  "OnScroll", "min=0", "max=50", "page=5")
;	hVBar := ScrollBar_Add(hwnd, 280, 10, -1,  290, "OnScroll", "style=ver", "pos=10")
;
;    ;glue to the myEdit
;	hhE := ScrollBar_Add(hwnd, "myEdit", 0, 0, 10, "OnScroll", "pos=50")
;	hvE := ScrollBar_Add(hwnd, "myEdit", 0, 0, 0, "OnScroll", "style=ver", "pos=50")
																			  
	Gui, Add, Button, x10 y200 0x8000 gOnBtn, Show
	Gui, Add, Button, x+0 0x8000 gOnBtn, Hide
	Gui, Add, Button, x+10 0x8000 gOnBtn, Enable
	Gui, Add, Button, x+0 0x8000 gOnBtn, Disable
	Gui, Add, Button, xm y+50 0x8000 gOnBtn, About

	Gui, show, h300 w300, ScrollBar Test
return

OnScroll(Hwnd, Pos) {
	global

	if (Hwnd = hHBar) 
		 s := "horizontal"
	else if (Hwnd = hVBar) 
		 s := "vertical"
	else s := "glued"

	ControlSetText, Edit1, %Pos% - %s% bar
}

OnBtn:
	if A_GuiControl = About
		MsgBox Scroll control`n`nby majkinetor

	if A_GuiControl in Enable,Disable
		ScrollBar_Enable(hVBar, A_GuiControl="Enable" ? 1:0 ), ScrollBar_Enable(hvE, A_GuiControl="Enable" ? 1:0 )
	
	if A_GuiControl in Show,Hide
		ScrollBar_Show(hhE, A_GuiControl="Show" ? 1:0), ScrollBar_Show(hvE, A_GuiControl="Show" ? 1:0)
return


;mapping wheel to scroll bar example
	#IfWinActive, ScrollBar Test
	WheelDown:: 
		ScrollBar_Set(hVBar, ScrollBar_Get(hVBar)+ScrollBar_Get(hVBar, "page"))
		DllCall("InvalidateRect", "uint", hVBar, "uint", 0, "uint", 0)	;!!!
	return

	WheelUp:: 
		ScrollBar_Set(hVBar, ScrollBar_Get(hVBar)-ScrollBar_Get(hVBar, "page"))
		DllCall("InvalidateRect", "uint", hVBar, "uint", 0, "uint", 0)	;!!!
	return


#include ScrollBar.ahk
