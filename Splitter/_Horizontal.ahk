_()
#SingleInstance, force

	;=========== SETUP ========
		w := 600
		h := 500
		sep := 30
	;==========================

	h1 := h//3, h2 := h-h1
	gui, margin, 0, 0
	gui, -caption
	gui, add, edit, HWNDhc1 w%w% h%h1%, Press ESC to exit.`n
	hSep := Splitter_Add( "h" sep " w" w, "grayrect")
	gui, add, monthcal, HWNDhc2 w%w% h%h2%

	Splitter_Set( hSep, hc1 " - " hc2 )

	gui, show, w%w% h%h%
		
return

Esc:: 
GuiClose:
	ExitApp
return

#include Splitter.ahk
