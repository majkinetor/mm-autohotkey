;_("e")
	goto MakeGui
return

MakeGui:
	n++
	Gui, %n%:+Resize +LastFound
	hGui := WinExist()
	pos := Win_Pos("w300 h100 <" n)
	Gui, %n%:Show, %pos%, %pos% %hGui%
return


F1:: goto MakeGui

ESC::
	pos := Win_Pos(">> !")
	Exitapp
return

#include Win.ahk