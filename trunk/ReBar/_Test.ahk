#Singleinstance, force 
#NoEnv

	Gui, +LastFound +Resize 
	hGui := WinExist() 
	Gui, Show, w600 h300 hide

	Gui, Font, s11, Courier New

  ;create combo
	Gui, Add, ComboBox, HWNDhCombo gOnCombo, item 1|item 2|item 3


  ;create rebar	
	hRebar := Rebar_Add(hGui, "", hIL, "", "OnRebar")	
	ReBar_AddBand(hRebar, hCombo)

	Gui, Show

return 

OnRebar(hCtrl, e){
}

#IfWinActive, _Test
F1::
;	layout := "10001 120 1|10003 243 0|10002 370 1|10004 230 1"
	layout := "10002 356 0|10003 214 0|10001 400 1|10004 290 1"
	Rebar_SetLayout(hRebar, layout)
return

F2::
	Rebar_Lock(hRebar, "~")
return

F3::
	Log(Rebar_GetLayout(hRebar))
return

F4::
	ControlGetText, layout, ,ahk_id %hLog%
	Rebar_SetLayout(hRebar, layout)
return


OnToolbar(hToolbar, Event, Text, Position, Id){
	global hMenu
	ifEqual, event, hot, return
	
	if (hToolbar != hMenu)
		return Log(Event " " Text)
	
	if Text = Reload
		Reload
	
	if Text = Exit
		ExitApp
	
	if Text = Help
		Run, Rebar.html
} 

GuiClose:
	WinClose, ahk_id %hNotepad%
	ExitApp
return


OnCombo:
	
return



#include Rebar.ahk
