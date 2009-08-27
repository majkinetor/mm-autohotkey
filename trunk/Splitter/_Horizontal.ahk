;_("e")
;#SingleInstance, force

	;=========== SETUP ========
		w := 600
		h := 500
		ssize := 30
		spos  := 35
	
	;==========================

	h1 := h*spos//100 - ssize//2,	 h2 := h-h1
	gui, margin, 0, 0
	Gui +Resize +LastFound
	hGui := WinExist()

	gui, add, edit, HWNDhc1 w%w% h%h1%, Press ESC to exit.`n
	hSep := Splitter_Add( "h" ssize " w" w, "grayrect")
	gui, add, monthcal, HWNDhc2 w%w% h%h2%

	Splitter_Set( hSep, hc1 " - " hc2 )
	
	Attach( hc1,  "w h r2")
	Attach( hSep, "y w r2")
	Attach( hc2,  "y w r2")
;	Gui, show, autosize
	Gui, Show, % Win_Pos("<", "autosize")
return

F1::
return


Esc:: 
GuiClose:
	Win_Pos(">")
	exitapp
	h1 := Win_Get(hGui, "Lh")
	h11 := Win_GetRect(hSep, "*y")	
	spos1 := (h11 + ssize//2)*100//h1

	FileRead, txt, %A_ScriptFullPath%
	txt := RegExReplace(txt, "`aim)(^\s+spos\s+:= )\d+[ \t]*$", "$1" spos1)
	FileDelete, %A_ScriptFullPath%
	FileAppend, %txt%, %A_ScriptFullPath%
	ExitApp
return

Win_Pos( Default, Options="" ){
	static key="Software\AutoHotkey\Win"
	op := SubStr(Default, 1, 1)

	if op = <		;load
	{
		RegRead, pos, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%
		if ErrorLevel
			return Options
		return pos
	} else {		;save
		Gui, +LastFound
		Win_Get(WinExist(), "Lxywh", x,y,w,h)
		pos := "x" x " y" y " w"w " h" h
		RegWrite, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%, %pos%
	}
}

#include Splitter.ahk
#include Attach.ahk
#include Win.ahk