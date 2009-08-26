;_("mo! e2")
#SingleInstance, force
	goto MakeGui
return

MakeGui:
	no++

	Gui, %no%:+Resize +LastFound
	hGui := WinExist(),  %hGui% := no

	Gui, %no%:Add, Edit, HWNDhe1%no% w150 h100 -tabstop, F1 - new Gui `nF4 - move left `nF5 - move right `nESC - exit script
	Gui, %no%:Add, Picture, HWNDhe2%no% w100 x+5 h100, pic.bmp 

	Gui, %no%:Add, Edit, HWNDhe3%no% w100 xm h100
	Gui, %no%:Add, Edit, HWNDhe4%no% w100 x+5 h100
	Gui, %no%:Add, Edit, HWNDhe5%no% w100 yp x+5 h100
	
	gosub SetAttach
	Gui, %no%:Show, Autosize

	Randomize(no)
return


SetAttach:
	Attach(he1%no%, "w.5 h")
	Attach(he2%no%, "x.5 w.5 h r")
	Attach(he3%no%, "y w1/3")
	Attach(he4%no%, "y x1/3 w1/3")
	Attach(he5%no%, "y x2/3 w1/3")
return

F1::
	gosub MakeGui
return

F4::
	h := WinExist("A"), n := %h%
	Win_MoveDelta(he1%n%, "", "", -50)
	Win_MoveDelta(he2%n%, -50, "", 50)
	Win_Redraw(he2%n%)
	Attach(h)   ;reset Gui with handle h, use Attach() if you have only 1 Gui
return

F5::
	h := WinExist("A"), n := %h%
	Win_MoveDelta(he1%n%, "", "", 50)
	Win_MoveDelta(he2%n%, 50, "", -50)
	Win_Redraw(he2%n%)
	Attach(h)   ;reset
return

Randomize(no){
	ifEqual, no, 1, return

	Random, w, 0, 500
	Random, h, 0, 500
	Random, x, 0, A_ScreenWidth - w - 10
	Random, y, 0, A_ScreenHeight - h - 10
	Gui, %no%:Show, x%x% y%y% w%w% h%h%, No: %no%
}

ESC::
	ExitApp
return

#include Win.ahk
#include Attach.ahk