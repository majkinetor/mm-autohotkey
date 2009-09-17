_("mo! w e d")
#SingleInstance, force
SetWinDelay, -1
	Gui, +LastFounds
	hGui := WinExist()
	pos := Win_Recall("<", 0, "config.ini")
	if (pos != "") {	
			StringSplit, p, pos, %A_Space%
			pos = x%p1% y%p2% w%p6% h%p7%
	}
	else pos = w500 h400
	Gui, Show, %pos% Hide

	Gui, Add, Edit,		HWNDhEdt1, F1 - hide`nF2 - show
	hSplit := Splitter_Add()
	Gui, Add, Button,	HWNDhBtn1, Top
	Gui, Add, Button,	HWNDhBtn2, Bottom
	Gui, Add, MonthCal, HWNDhCal	

	sdef = %hEdt1% | %hBtn1% %hBtn2% %hCal%			;vertical splitter.
	Splitter_Set( hSplit, sdef )
	
	spos := 100

	Align(hEdt1,  "L", spos)
	Align(hSplit, "L", 6)
	Align(hBtn1,  "T", 35)
	Align(hBtn2,  "B")
	Align(hCal,   "F")

	Attach(hEdt1,	"h")
	Attach(hSplit,	"h")
	Attach(hBtn1,	"w")
	Attach(hCal,	"w h")
	Attach(hBtn2,	"y w")
	
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


F3::
;	m(Splitter_GetPos(hSplit))
return

Esc:: 
GuiClose:
	Win_Recall(">", "", "config.ini")
	s := Win_GetRect(hSplit, "*y")
	
	ExitApp
return

#include Align.ahk


;sample includes
#include inc
#include Attach.ahk
#include Win.ahk
#include Splitter.ahk