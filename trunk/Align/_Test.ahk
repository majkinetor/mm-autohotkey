;_("mo! w e d")
#SingleInstance, force
SetWinDelay, -1
	Gui, +LastFounds +Resize
	hGui := WinExist()

	Gui, Show, w500 h400 Hide

	Gui, Add, Edit,		HWNDhEdt1, F1 - hide`nF2 - show
	Gui, Add, Button,	HWNDhBtn1, Top
	Gui, Add, Button,	HWNDhBtn2, Bottom
	Gui, Add, MonthCal, HWNDhCal

	Align(hEdt1, "L", 200)
	Align(hBtn1, "T", 35)
	Align(hBtn2, "B")
	Align(hCal,  "F")

	Attach(hEdt1, "h")
	Attach(hBtn1, "w")
	Attach(hCal,  "w h")
	Attach(hBtn2, "y w")
	
	Gui, Show
return

F1::
	WinHide, ahk_id %hBtn2%
	WinHide, ahk_id %hEdt1%	
	Align(hGui)		;re-align (it will reset attach automatically if present among includes)
return

F2::
	WinShow, ahk_id %hBtn2%
	WinShow, ahk_id %hEdt1%	
	Win_MoveDelta(hBtn2, "", -10, "", 10)	;make bottom button larger each time
	Align(hGui)		;re-align
return

#include Align.ahk


;sample includes
#include inc
#include Attach.ahk
#include Win.ahk
