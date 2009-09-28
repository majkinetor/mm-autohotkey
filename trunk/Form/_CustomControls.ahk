_("e d w")

	ctrls = HiEdit HLink Toolbar QHTM Rebar Splitter
	;===============================================
	
	SetWorkingDir, inc		;required to load some dll's that are put there
	hForm  := Form_New("w500 h400")
	hInfo  := Form_Add(hForm, "Text", "Press F1 to cycle controls.`nControls: " ctrls, "", "Align T, 50")
	hTab   := Form_Add(hForm, "Panel", "", "", "Align F")
	loop, parse, ctrls, %A_Space%
	{		
		hPanel%A_Index%	 :=	Form_Add(hTab,  "Panel", "",  "hidden",	"Align " hTab )
		hCtrl := Form_Add(hPanel%A_Index%, A_LoopField,	A_LoopField, "", "Align F")
		InitControl(A_LoopField, hCtrl), ctrlNo := A_Index
	}
	
	Form_Show()
	n := 1, Win_Show(hPanel1)
return

InitControl(Name, HCtrl) {
	global

	if Name = Toolbar
		Toolbar_Insert(HCtrl, "cut`ncopy`npaste")
	else if Name = Rebar
	{
		Rebar_Insert(HCtrl, Form_Add(hForm, "Edit", Name, "w100 h100"))
		Rebar_Insert(HCtrl, Form_Add(hForm, "ComboBox", Name, "w100 h100"))
	}
	else if Name = Splitter
	{
		hp1 := Form_Add(hPanel%A_Index%	, "Panel", "Panel 1", "style='center sunken'", "Align T, 200")
		Align(hCtrl, "T", 30)
		hp2 := Form_Add(hPanel%A_Index%	, "Panel", "Panel 2", "style='center sunken'", "Align F")
		Splitter_Set(hCtrl, hp1 " - " hp2)
	}
	else if Name= QHTM
		QHTM_AddHtml(HCtrl, "<BR><b><font size=4>Remove flux capacitor?</font></b><p>Removing the flux capacitor during flight might lead to <b>overheating</b>,<br> <font color=""red"">toxi gas</font> exhaust, and some really unhappy passengers<p><b>Are you sure you wish to remove flux capacitor?</b><p>")
}

F1::
	Win_Show(hPanel%n%, false), n++
	ifGreater, n, %ctrlNo%, SetEnv, n, 1
	Win_Show(hPanel%n%)
return

#include inc
#include _Forms.ahk