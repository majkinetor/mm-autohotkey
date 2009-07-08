#SingleInstance, force
SetBatchLines, -1

	Gui, +LastFound
	hGui := WinExist(), 
	Gui, Show , w410 h160 Hide		;set gui width & height (mandatory)

	hToolbar := Toolbar_Add(hGui, "OnToolbar", "ADJUSTABLE FLAT LIST TOOLTIPS", 1)

	FileRead, btns, *t toolbar.cfg
	if btns =
		btns = 
		(LTrim
			cut
			copy 
			paste
			-
			undo
			redo
			-
			delete
			new
			open
			save
			-
			print preview
			properties
			-----
			help

			*find
			*find next
			*print
		)
	
	Toolbar_AddButtons(hToolbar, btns)
	Gui, Add, Text, y50, Customize the toolbar and reload application.`nDouble click the empty toolbar space or press F1`n`nYou can also SHIFT + drag buttons.
	Gui, Add, Button, y+30 w100 gOnBtn, Reload
	Gui, Add, Button, x+10 gOnBtn, Reset Toolbar and Reload
	Gui, Add, Text, x+20 yp+5 w150
	Gui, Show, ,Customization Test
return

F1::Toolbar_Customize(hToolbar)

OnToolbar(hToolbar, pEvent, pPos, pTxt, pID){
	static no=0

	if pEvent in change,adjust
	{
		FileDelete, toolbar.cfg
		btns := Toolbar_Define(hToolbar)
		FileAppend, %btns%, toolbar.cfg
		
		no++
		ControlSetText, Static2, Times saved: %no%
	}

	if pEvent = click
		ControlSetText, Static2, Clicked: %pTxt% (%pPos%)
}

GuiClose:
	ExitApp
return

OnBtn:
	if A_GuiControl != Reload
		FileDelete, toolbar.cfg
	Reload
return

#include Toolbar.ahk