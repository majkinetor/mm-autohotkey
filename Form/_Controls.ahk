_("m! e d w")
#SingleInstance, force
#NoEnv

	custom	= HiEdit HLink Toolbar QHTM Rebar SpreadSheet Splitter 
	ahk		= Text Edit Picture Button Checkbox Radio DropDownList ComboBox ListBox ListView TreeView Hotkey DateTime MonthCal Slider Progress GroupBox StatusBar Tab2 UpDown
	init    = HiEdit
	;===============================================
	
	ctrls := custom " " ahk

	SetWorkingDir, inc		;required to load some dll's that are put there
	hForm  := Form_New("w700 h400 Resize")

	htmlCtrls := RegExReplace(custom, "\w+", "<a href=$0 id=$0>$0</a><a href='" A_ScriptDir "\_doc\files\inc\$0-ahk.html'>&nbsp;+</a>&nbsp;&nbsp;")
			   . "<br><br>" RegExReplace(ahk, "\w+", "<a href=$0 id=$0>$0</a>&nbsp;&nbsp;")

	infoText=
	(LTrim Join
		<b>Press F1 to cycle controls. Click + to see docs.
		Click control name to switch to its tab page. Press & hold F1 and resize window as experiment.</b><br><br>
		%htmlCtrls%
	)
	hInfo  := Form_Add(hForm, "QHTM", infoText, "gOnQHTM", "Align T, 150", "Attach p r2")
	hTab   := Form_Add(hForm, "Panel", "", "", "Align F", "Attach p r2")
	loop, parse, ctrls, %A_Space%
	{		
		hPanel%A_Index%	:=	Form_Add(hTab,  "Panel", "", "w100 h100 style=hidden", "Align F,,*" hTab, "Attach p -")		;create hidden attach-disabled panel.
		hCtrl := Form_Add(hPanel%A_Index%, A_LoopField,	A_LoopField, MakeOptions(A_LoopField), "Align F", "Attach p")
		InitControl(A_LoopField, hCtrl), ctrlNo := %A_LoopField% := A_Index
	}	
	Form_Show(), OnQHTM("", "", init )
return


MakeOptions(Name) {
	if Name not in Splitter,Progress,GroupBox
		return "gHandler"
}

Handler:
	Tooltip % A_GuiControl " " A_GuiEvent
	SetTimer, Tooltip, -4000
return

Handler(p1, p2, p3) {
	Tooltip, %p1%  %p2%  %p3%
	SetTimer, Tooltip, -4000
}

Tooltip:
	Tooltip
return

OnQHTM(Hwnd, Link, Id) {
	local n
	if (id)
		n := %Id%, Win_Show(hPanel%gCur%, false), Win_Show(hPanel%n%), gCur := n
	else return 1
}

InitControl(Name, HCtrl) {
	global

	if Name = TreeView
		TV_Add(":>", TV_Add(":)"))

	if Name = HiEdit
	{
		WinSet, Style, +1, ahk_id %Hctrl%
		HE_SetEvents(HCtrl, "Handler")
	}

	if Name = HLink
	{
		ControlSetText, ,Click <a href="www.autohotkey.com">here</a> to go to AutoHotKey site, ahk_id %HCtrl%
		Attach(HCTRL, "y")
	}
	if Name = Toolbar
		Toolbar_Insert(HCtrl, "cut`ncopy`npaste")
	else if Name = Rebar
	{
		Rebar_Insert(HCtrl, Form_Add(hForm, "Edit", Name, "w100 h100"))
		Rebar_Insert(HCtrl, Form_Add(hForm, "ComboBox", Name, "w100 h100"))
	}
	else if Name = Splitter
	{		
		hp1 := Form_Add(hPanel%A_Index%	, "Panel", "Panel 1", "style='center sunken'", "Align T, 200", "Attach w r")
		Align(hCtrl, "T", 30), Attach(hCtrl, "w r")
		hp2 := Form_Add(hPanel%A_Index%	, "Panel", "Panel 2", "style='center sunken'", "Align F", "Attach w h r")
		Splitter_Set(hCtrl, hp1 " - " hp2)
	}
	else if Name= QHTM
		QHTM_AddHtml(HCtrl, "<BR><b><font size=4>Remove flux capacitor?</font></b><p>Removing the flux capacitor during flight might lead to <b>overheating</b>,<br> <font color=""red"">toxi gas</font> exhaust, and some really unhappy passengers<p><b>Are you sure you wish to remove flux capacitor?</b><p>")
}

F2::
	WinMove, ahk_id %hForm%, , , , 300, 300
return

F1::
	Win_Show(hPanel%gCur%, false), gCur++
	if (gCur > ctrlNo)
		gCur := 1
	Win_Show(hPanel%gCur%)
return

#include inc
#include _Forms.ahk