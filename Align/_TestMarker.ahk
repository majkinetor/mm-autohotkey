;_("mo w e d")
#SingleInstance, force
SetWinDelay, -1

	;===============================

	Gui, +LastFounds +Resize
	hGui := WinExist()

	Gui, Show, w500 h500 Hide

	Gui, Add, ListView,	HWNDhList x100 y100 w300 h300, 

	Gui, Add, Button, HWNDhb1, B1
	Gui, Add, Button, HWNDhb2, B2
	Gui, Add, Button, HWNDhb3, B3
	Gui, Add, Button, HWNDhb4, B4

	Align(hb1, "T", 60, hList)
	Align(hb2, "B", 20, hList)
	Align(hb3, "L", 90, hList)	
	Align(hb4, "R", 50, hList)	

	Gui, SHow,
return



#include Align.ahk
#include inc\Win.ahk