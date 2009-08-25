#SingleInstance, force
	Gui, +Resize
	Gui, Add, Edit, HWNDhe1 w150 h100 -tabstop, F3=left`nF4=right
	Gui, Add, Picture, HWNDhe2 w100 x+5 h100, pic.bmp 

	Gui, Add, Edit, HWNDhe3 w100 xm h100
	Gui, Add, Edit, HWNDhe4 w100 x+5 h100
	Gui, Add, Edit, HWNDhe5 w100 yp x+5 h100
	
	gosub SetAnchor
	Gui, Show, autosize
return

SetAnchor:
	Anchor(he1, "w.5 h")
	Anchor(he2, "x.5 w.5 h r")
	Anchor(he3, "y w1/3")
	Anchor(he4, "y x1/3 w1/3")
	Anchor(he5, "y x2/3 w1/3")
return


F4::
	Win_MoveDelta(he1, "", "", -50)
	Win_MoveDelta(he2, -50, "", 50)
	Win_Redraw(he2)
	Anchor()   ;reset
return

F5::
	Win_MoveDelta(he1, "", "", 50)
	Win_MoveDelta(he2, 50, "", -50)
	Win_Redraw(he2)
	Anchor()   ;reset
return


#include Win.ahk
#include Anchor.ahk