;_("mo! w e d")
#SingleInstance, force
SetWinDelay, -1
	Gui, +LastFounds +Resize
	hGui := WinExist()
	pos := Win_Recall("<", 0, "config.ini")
	if (pos != "") {	
			StringSplit, p, pos, %A_Space%
			pos = x%p1% y%p2% w%p6% h%p7%
	}
	else pos = w500 h500
	Gui, Show, %pos% Hide

	Gui, Add, Edit,		HWNDhEdt1, F1 - hide`nF2 - show
	hSplit := Splitter_Add()
	Gui, Add, ListView,	HWNDhList, Top control
	Gui, Add, Text,		h100 0x200 HWNDhText,  Bottom
	Gui, Add, MonthCal, HWNDhCal	

	sdef = %hEdt1% | %hList% %hText% %hCal%			;vertical splitter.
	IniRead, spos, config.ini, Config, Splitter, %A_Space%
	ifEqual, spos, ,SetEnv, spos, 100
	Splitter_Set( hSplit, sdef, spos )
	
	Align(hEdt1,  "L", spos)
	Align(hSplit, "L", 6)
	Align(hList,  "T", 200)
	Align(hText,  "B")
	Align(hCal,   "F")

	Attach(hEdt1,	"h")
	Attach(hSplit,	"h")
	Attach(hList,	"w")
	Attach(hCal,	"w h")
	Attach(hText,	"y w")

	IniRead, bVisible, config.ini, Config, Visible, %A_Space%
	IfEqual, bVisible, , SetEnv, bVisible, 1
	if !bVisible
		HideControls(true)
	
	Gui, Show
return

F1:: HideControls(true)
F2:: HideControls(false)


HideControls(bHide) {
	global 
	if (!bHide)
	{
		WinShow, ahk_id %hText%
		WinShow, ahk_id %hEdt1%	
	} else {
		WinHide, ahk_id %hText%
		WinHide, ahk_id %hEdt1%	
	}
	Align(hGui)		;re-align (it will reset attach automatically if present among includes)
}

SaveGui() {
	global 
	b := Win_Is(hText, "visible")
	if !b
		HideControls(false)

	p := Splitter_GetPos(hSplit)
	
	Win_Recall(">", "", "config.ini")
	IniWrite, %p%, config.ini, Config, Splitter
	IniWrite, %b%, config.ini, Config, Visible
}


Esc:: 
GuiClose:
	SaveGui()
	ExitApp
return

#include Align.ahk
#include inc\Win.ahk

;sample includes
#include inc\Attach.ahk
#include inc\Splitter.ahk