#SingleInstance, force

	;=========== SETUP ========
		w := 800
		h := 600
		sep := 5
	;==========================

	w1 := w//3, w2 := w-w1 , h1 := h // 2, h2 := h // 3
	gui, margin, 0, 0

	gui, add, edit, HWNDc11 w%w1% h%h1%
	hSepH := Splitter_Add( "x y w" w1 " h10" )
	h1-=10
	gui, add, edit, HWNDc12 w%w1% h%h1%


	hSepV := Splitter_Add( "x+0 y0 h" h " w" sep )
	gui, add, monthcal, HWNDc21 w%w2% h%h2% x+0
	gui, add, ListView, HWNDc22 w%w2% h%h2%, c1|c2|c3
	gui, add, ListBox, HWNDc23 w%w2% h%h2% , 1|2|3

	sdef = %c11% %hSepH% %c12% | %c21% %c22% %c23%
	Splitter_Set( hSepV, sdef )

	;sdef2 = %c11% - %c12%
	;Splitter_Set( hSepH, sdef2 )


	gui, show, w%w% h%h%
		
return

Esc:: 
GuiClose:
	ExitApp
return

#include Splitter.ahk