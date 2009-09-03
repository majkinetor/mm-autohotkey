_()
	Shell_GetQuickLaunch()

	n := Shell_ABNew(32)
	Gui, %n%:+LastFound
	hGui := WinExist()

	Gui, %n%:Add, Text, HWNDhDummy
	Gui, %n%:Add, Button, HWNDhStart gOnStart 0x8000 x4 w50 y2, Start
	hRebar := Rebar_Add(hGui, "fixedorder", "", "x60 h32 w" A_ScreenWidth-50)	
	
	hQuickLaunch := MakeQuickLaunch(hGui, w)	

	hTaskBar := Toolbar_Add(hGui, "OnToolbar", "FLAT TOOLTIPS LIST", "1L", "x0")
	ReBar_Insert(hRebar, hDummy)	;put this dummy one so next one can be moved.
	ReBar_Insert(hRebar, hQuickLaunch, "L " w+20 , "S usechevron")
	ReBar_Insert(hRebar, hTaskBar)
return

OnQuickLaunch(hCtrl, Event, Txt, Pos, Id)){
	if event != click
		return
	Run, % v("ql" id)
}

MakeQuickLaunch( hGui, ByRef w ) {
	hT:= Toolbar_Add(hGui, "OnQuickLaunch", "FLAT TOOLTIPS LIST", hIL := IL_Create(10, 10, 0), "x0")
	files := Shell_GetQuickLaunch()
	loop, parse, files, `n
	{
		FileGetShortcut, %A_LoopFIeld%, target, , , , icon, iconno
		if (icon iconno = "") 
			 IL_Add(hIL, target)
		else IL_Add(hIl, icon, iconno)
		
		SplitPath, A_LoopFIeld, , , , name
		btns .= name "`n"
		v( "ql" A_Index+10000, target)
	}
	Toolbar_Insert(hT, btns)
	
	Toolbar_GetMaxSize(hT, w, h)			;adjust size so chevron works. Chevron will show if width is lesser then ideal 
	ControlMove,,,,%w%,, ahk_id %hT%		; (which is taken as size of the control on insert by Rebar)
											; AUtosize() doesn't work as it sets h too, and that fucks up...	
	return hT
}

OnStart:
	WinGetPos, , , , h, ahk_id %hGui%
	Shell_SMShow(5, h)
return

#include AppBar.ahk
#include Rebar.ahk
#include Toolbar.ahk
#include Shell.ahk