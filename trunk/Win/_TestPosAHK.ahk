;_()
	goto MakeGui
return

MakeGui:
	n++
	pos := Win_Pos("w300 h100 <" n)
	
	Gui, %n%:+Resize +LastFound
	hGui := WinExist()
	Gui, %n%:Add, Text, ,F1 - create new Gui
	Gui, %n%:Add, Text, y+50,%pos%
	Gui, %n%:Show, %pos%, %no%
return


F1:: goto MakeGui

ESC::
	pos := Win_Pos(">> !")
	Exitapp
return

#include Win.ahk