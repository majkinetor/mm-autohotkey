;_("mo! e2")
#SingleInstance, force
	ssize := 10, _ := " "
	
	pos := Win_Pos("<", x,y,w,h) 
	if pos =
		w := 600,  h := 500

	spos := 215
	h1 := spos,	 h2 := h-h1-ssize
	gui, margin, 0, 0
	Gui +Resize +LastFound ;-caption
	hGui := WinExist()

	gui, add, edit, HWNDhc1 w%w% h%h1%, Press ESC to exit.`n
	hSep := Splitter_Add("h" ssize "y+10 w" w , "sunken", "Mover")

	w := w//2
	gui, add, monthcal, HWNDhc2 w%w% h%h2%
	gui, add, monthcal, HWNDhc3 x+0 w%w% h%h2%

	Splitter_Set( hSep, hc1 " - " hc2 " " hc3)
	Attach( hc1,  "w h r2")
	Attach( hSep, "y w r2")
	Attach( hc2,  "y w.5 r2")
	Attach( hc3,  "x.5 y w.5 r2")

	Gui, show, %pos%
return

F1::
return

GuiClose:
	Win_Pos(">")
	s := Win_GetRect(hSep, "*y")
	
	FileRead, txt, %A_ScriptFullPath%
	txt := RegExReplace(txt, "`aim)(^\s+spos\s+:= ).+[ \t]*$", "$1" s)
	FileDelete, %A_ScriptFullPath%
	FileAppend, %txt%, %A_ScriptFullPath%
	ExitApp
return

Win_Pos( Options, ByRef x="",ByRef y="",ByRef w="",ByRef h="" ){
	static key="Software\AutoHotkey\Win"
	op := SubStr(Options, 1, 1)

	if op = <		;load
	{
		RegRead, pos, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%
		ifEqual, ErrorLevel,1, return
		StringSplit, p, pos, %A_Space%
		loop, %p0%
			f := SubStr(p%A_Index%,1,1), %f% := SubStr(p%A_Index%,2)
		return pos
	} else {		;save
		Gui, +LastFound
		Win_Get(WinExist(), "RxyLwh", x,y,w,h)
		pos := "x" x " y" y " w"w " h" h
		RegWrite, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%, %pos%
		return pos
	}
}

#include Splitter.ahk
#include Attach.ahk
#include Win.ahk