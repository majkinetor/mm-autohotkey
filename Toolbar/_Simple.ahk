#SingleInstance, force

	Gui, +LastFound
	hGui := WinExist(), 

	Gui, Show, w300 h300 Hide		;set gui width


	h1 := Toolbar_Add(hGui, "OnToolbar", "flat nodivider", 3)

	btns = 
		(LTrim
			cut,,
			copy ,,
			paste,,
			undo,,
			redo,,
		 )
	Toolbar_Insert(h1, btns)
	Toolbar_Autosize(h2, "bl")

	Gui, Show
return

OnToolbar(h,e,p,t,i){

}

GuiClose:
	exitapp
return

#include Toolbar.ahk