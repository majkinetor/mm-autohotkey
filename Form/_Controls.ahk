_("mm! e d c w")
#SingleInstance, force
#MaxThreads, 255		;Required for this sample with cursor/tooltip extensions.
#NoEnv

	custom	= HiEdit HLink Toolbar QHTM Rebar SpreadSheet RaGrid Splitter 
	ahk		= Text Edit Picture Button Checkbox Radio DropDownList ComboBox ListBox ListView TreeView Hotkey DateTime MonthCal Slider Progress GroupBox StatusBar Tab2 UpDown
	init    = HiEdit
	;===============================================
	
	ctrls := custom " " ahk

	SetWorkingDir, inc		;required to load some dll's that are put there
	hForm  := Form_New("w700 h620 Resize")

	htmlCtrls := RegExReplace(custom, "\w+", "<a href=$0 id=$0>$0</a><a href='" A_ScriptDir "\_doc\files\inc\$0-ahk.html'>&nbsp;+</a>&nbsp;&nbsp;")
			   . "<br><br>" RegExReplace(ahk, "\w+", "<a href=$0 id=$0>$0</a>&nbsp;&nbsp;")

	infoText=
	(LTrim Join
		<b>Press F1 to cycle controls. Click + to see docs.
		Click control name to switch to its tab page. Press & hold F1 and resize window as experiment.
		%htmlCtrls%
	)
	hInfo  := Form_Add(hForm, "QHTM", infoText, "gOnQHTM", "Align T, 200", "Attach w")
	hLog   := Form_Add(hForm, "ListBox", "", "hscroll", "Align R, 300", "Attach x h")
	hSep   := Form_Add(hForm, "Splitter", "", "", "Align R, 6", "Attach x h" )
	hTab   := Form_Add(hForm, "Panel", "", "", "Align F", "Attach w h")
	Splitter_Set( hSep, hTab " | " hLog)

	loop, parse, ctrls, %A_Space%
	{		
		hPanel%A_Index%	:=	Form_Add(hTab,  "Panel", "", "w100 h100 style='hidden sunken'", "Align F,,*" hTab, "Attach p -")		;create hidden attach-disabled panel.
		hCtrl := Form_Add(hPanel%A_Index%, A_LoopField,	A_LoopField, MakeOptions(A_LoopField), "Align F", "Attach p", "Cursor HAND", "Tooltip " A_LoopField), ctrl%hCtrl% := A_LoopField
		InitControl(A_LoopField, hCtrl), %A_LoopField% := ctrlNo := A_Index
		if !hFont ;create font only once, then use it for every control.
			 hFont := Ext_Font(hCtrl, "S9", "Courier New")
		else Ext_Font(hCtrl, hFont)
	}	
	QHTM_AddHtml(hInfo, "<br><h6>Total: " ctrlNo)
	Form_Show(), OnQHTM("", "", init )
	SB_SetText("Forms test")
return

/* Could be used to stretch button image on resizing
OnAttach(Hwnd) {
	global
	if (Hwnd = hButtonPanel)
		Ext_Image(hButton, "..\res\test.bmp")
}
*/

MakeOptions(Name) {

	if Name=RaGrid
		return "style='GRIDLINES NOSEL' gHandler"

	if Name=SpreadSheet
		return "style='WINSIZE VSCROLL HSCROLL CELLEDIT ROWSIZE COLSIZE MULTISELECT' gHandler"

	if Name not in Splitter,Progress,GroupBox
		return "gHandler"
}

Log(t1="", t2="", t3="", t4="", t5="") {
	global hLog
	txt = %t1% %t2% %t3% %t4% %t5%
	Control,Add,%txt%,, ahk_id %hLog%
	ControlSend, ,{End},ahk_id %hLog%
}

Handler:
	Log(A_GuiControl,A_GuiEvent)
return

Handler(HCtrl, p2="", p3="",p4="") {
	global
	Log(ctrl%hCtrl% ":   ",p2,p3,p4)
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

	if Name = Button
		Ext_Image(HCtrl, "..\res\test.bmp")

	if Name = TreeView
		TV_Add(":>", TV_Add(":)"))

	if Name = HiEdit
	{
		WinSet, Style, +1, ahk_id %Hctrl%
		HE_SetEvents(HCtrl, "Handler")
	}

	if Name = RaGrid
	{
		RG_SetHdrHeight(HCtrl, 25), RG_SetRowHeight(HCtrl, 22)
		RG_AddColumn(HCtrl, "txt=EditText", "w=150", "hdral=1",	"txtal=1", "type=EditText")
		RG_AddColumn(HCtrl, "txt=Check",	"w=80",  "hdral=1", "txtal=1", "type=CheckBox")
		RG_AddColumn(HCtrl, "txt=Button",	"w=80",  "hdral=1", "txtal=1", "type=Button")
		RG_AddRow(HCtrl, 0, Name, 1), 		RG_AddRow(HCtrl, 0, Name, 0, ":)")
	}

	if Name = HLink
		ControlSetText, ,Click <a href="www.autohotkey.com">here</a> to go to AutoHotKey site, ahk_id %HCtrl%

	if Name = Toolbar
		Toolbar_Insert(HCtrl, "cut`ncopy`npaste")

	if Name = SpreadSheet
	{
		SS_SetRowHeight(hCtrl, 0, 20), SS_SetColWidth(hCtrl, 1, 150), 
		SS_SetCell(HCtrl, 1,1, "Type=Text", "Txt=" Name), 
		SS_SetGlobalFields(HCtrl,  "gcellw gcellht cell_txtal rowhdr_txtal", 50, 30, "CENTER MIDDLE", "CENTER MIDDLE")
	}
	else if Name = Rebar
	{
		Rebar_Insert(HCtrl, Form_Add(hForm, "Edit", Name, "w100 h100"))
		Rebar_Insert(HCtrl, Form_Add(hForm, "ComboBox", Name, "w100 h100"))
	}
	else if Name = Splitter
	{		
		hp1 := Form_Add(hPanel%A_Index%	, "Panel", "Panel 1", "style='center sunken'", "Align T, 130", "Attach w r")
		Align(hCtrl, "T", 30), Attach(hCtrl, "w r")
		hp2 := Form_Add(hPanel%A_Index%	, "Panel", "Panel 2", "style='center sunken'", "Align F", "Attach w h r")
		Splitter_Set(hCtrl, hp1 " - " hp2)
	}
	else if Name=QHTM
	{
		html := "<BR><b><font size=4>Flux capacitor.</font></b><p>Removing the flux capacitor during flight might lead to <font size=6>overheating</font> <font color=""red"">toxi gas</font> exhaust, and some really unhappy passengers<p></b><img src='" A_ScriptDir "/res/test.bmp'></img><p>"
		ControlSetText, ,%html%, ahk_id %HCtrl%
	}
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