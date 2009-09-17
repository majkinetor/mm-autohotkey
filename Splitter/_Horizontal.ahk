#SingleInstance, force
	spos := 159
	ssize := 30

	pos := Win_Recall("<", 0, "config.ini")
	if (pos != "") {	
			StringSplit, p, pos, %A_Space%
			x:= p1, y:=p2,  w:=p6,  h:=p7
	} else 	x:=y:="Center", w:=600, h:=500

	h1 := spos,	 h2 := h-h1-ssize
	gui, margin, 0, 0
	Gui +Resize +LastFound -caption
	hGui := WinExist()

	gui, add, edit, HWNDhc1 w%w% h%h1%, Press ESC to exit.`n
	hSep := Splitter_Add("h" ssize " w" w " sunken", "drag me")
	w1 := w//2
	gui, add, monthcal, HWNDhc2 w%w1% h%h2%
	gui, add, monthcal, HWNDhc3 x+0 w%w1% h%h2%

	Splitter_Set( hSep, hc1 " - " hc2 " " hc3 )
	Attach( hc1,  "w h r2")
	Attach( hSep, "y w r2")
	Attach( hc2,  "y w.5 r2")
	Attach( hc3,  "y x.5 w.5 r2")

	Gui, show, x%x% y%y% w%w% h%h%
return

F1::
return


Esc:: 
GuiClose:
	Win_Recall(">", "", "config.ini")
	s := Win_GetRect(hSep, "*y")
	
	FileRead, txt, %A_ScriptFullPath%
	txt := RegExReplace(txt, "`aim)(^\s+spos\s+:= ).+[ \t]*$", "$1" s)
	FileDelete, %A_ScriptFullPath%
	FileAppend, %txt%, %A_ScriptFullPath%
	ExitApp
return

;Win_Pos( Options, ByRef x="",ByRef y="",ByRef w="",ByRef h="" ){
;	static key="Software\AutoHotkey\Win"
;	op := SubStr(Options, 1, 1)
;
;	if op = <		;load
;	{
;		RegRead, pos, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%
;		ifEqual, ErrorLevel,1, return
;		StringSplit, p, pos, %A_Space%
;		loop, %p0%
;			f := SubStr(p%A_Index%,1,1), %f% := SubStr(p%A_Index%,2)
;		return pos
;	} else {		;save
;		Gui, +LastFound
;		Win_Get(WinExist(), "RxyLwh", x,y,w,h)
;		pos := "x" x " y" y " w"w " h" h
;		RegWrite, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%, %pos%
;		return pos
;	}
;}

#include Splitter.ahk
#include Attach.ahk
#include Win.ahk