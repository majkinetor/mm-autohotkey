_("mm! e2")
#SingleInstance, force

	Gui, +Resize +LastFound
	hGui := WinExist()

	Gui, Add, Edit, HWNDhe1%no% w150 h100 -tabstop, F1 - new Gui `nF2 - hide ctrl`nF3 - show ctrl`nF4 - ctrl left `nF5 - ctrl right `nESC - exit script
	Gui, Add, Picture, HWNDhe2%no% w100 x+5 h100, pic.bmp 

	Gui, Add, Edit, HWNDhe3%no% w100 xm h100
	Gui, Add, Edit, HWNDhe4%no% w100 x+5 h100
	Gui, Add, Edit, HWNDhe5%no% w100 yp x+5 h100
	
	AttachMe(hGui)
	Gui, Show, Autosize

return

AttachMe(hParent){

}



#include Win.ahk
#include Attach.ahk