#SingleInstance, force
	Gui, +LastFound
	hGui := WinExist(), 
	Gui, Show , w410 h360 Hide		;set gui width & height (mandatory)

	h1 := Toolbar_Add(hGui, "OnToolbar", "flat bottom nodivider", 1)
	h2 := Toolbar_Add(hGui, "OnToolbar", "flat", 2)
	h3 := Toolbar_Add(hGui, "OnToolbar", "vertical wrapable nodivider", 3, "x100 y120 w200 h150")

	btns = 
		(LTrim
			cut
			copy
			paste
			---
			undo
			redo
		 )
	Toolbar_AddButtons(h1, btns)
	Toolbar_AddButtons(h2, btns)
	Toolbar_AddButtons(h3, btns)
	Toolbar_SetButtonSize(h3, 60)

	Gui, Show
return

OnToolbar(h,e,p,t,i){

}

GuiClose:
	exitapp
return

#include Toolbar.ahk