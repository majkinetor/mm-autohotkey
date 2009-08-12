SetBatchLines, -1
#SingleInstance, force 
		
		gui, +lastfound	+Resize
		hGui := winexist()

		width := 500, 	height := 400
		hkCtrl	:= "hParent"	;hotkey control			

		hParent := Panel_New(hGui, 0, 0, width, height, "0")	;this is the same as GUI, as it covers entire gui

		hP2		:= Panel_Add(hParent,	"Panel",	"800000 h180 Lbottom Ayw"	,"P2")
		hP1		:= Panel_Add(hParent,	"Panel",	"w200 Lleft Ah"				,"P1")
		hButton	:= Panel_Add(hP1,		"Button",	"gOnCtrl Ltop Aw"			,"OK")
		hEdit	:= Panel_Add(hP1,		"Edit",		"gOnCtrl Awh Lclient"		,"Memo`n")
		hPic	:= Panel_Add(hParent,	"MonthCal", "Lclient Awh")
		hPic	:= Panel_Add(hP2,		"Picture",   "Lclient Awhr2", "c:\windows\Soap Bubbles.bmp")

		
		hkCtrl := %hkCtrl%
		Gui, show, w%width% h%height%
return

GuiSize:
	Panel_GuiSize(A_GuiWidth, A_GuiHeight, A_EventInfo, hParent)
return



F11::
F12::		
	sign := A_ThisHotKey = "F11" ? "-" : "+"
	ControlGetPos, , ,hkW, hkH, , ahk_id %hkCtrl%

	if GetKeyState("1") {
		delta := sign 50
		ControlMove, ,,,hkW+delta,hkH+delta,ahk_id %hkCtrl%
	}
	else
		loop 25 {
			delta := sign A_Index*2
			ControlMove, ,,,hkW+delta,hkH+delta,ahk_id %hkCtrl%
			sleep, -1
		}
return

GuiEscape:
GuiCLose:
	exitapp
return

OnCtrl:
	tooltip %A_Gui% %A_GuiControL%
return


#include Panel.ahk
