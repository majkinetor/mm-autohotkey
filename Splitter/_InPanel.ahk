;_("mo! e")
#NoEnv
#SIngleInstance, force
	
	w := 500
	h := 500
	sep := 30
	;=========================

	Gui, +LastFound +Resize
	hGui := WinExist()+0
	Gui, Margin, 0, 0

	w1 := w2 := w//2
	hP := Panel_Add(hGui, 50, 50, w, h)
	
	gui, add, edit, HWNDhc1 w%w1% h%h%
	hSep := Splitter_Add( "x+0 h" h " w" sep)
	gui, add, monthcal, HWNDhc2 w%w2% h%h% x+0

	Win_SetParent(hc1, hp)
	Win_SetParent(hc2, hp)
	Win_SetParent(hSep, hp)
	
	Splitter_Set( hSep, hc1 " | " hc2 )

	Attach(hc1, "h")
	Attach(hc2, "w h")
	Attach(hSep,"h")
	Attach(hP, "p")

	w += 100, h+=100
	gui, show, w%w% h%h%
		
#include Splitter.ahk

#include inc
#include Attach.ahk
#include Win.ahk
#include Panel.ahk