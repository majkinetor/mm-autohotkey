;_("e")
#SingleInstance, off
	goto MakeGui
return

MakeGui:
	n++
	Gui, %n%:+Resize +LastFound
	hGui := WinExist()
	pos := Win_Pos("w300 h100 <" n)
	Gui, %n%:Show, %pos%, %pos% %hGui%
return


F1:: goto MakeGui
	

ESC::
	pos := Win_Pos(">>")
	exitapp
return


/* 
  Function:	Pos
			Store/Get window's position, size and maximize state.


  Parameters:

		Options		 - White space separated list of options. 		
		X-H, MinMax  - Reference to otput variables, if needed. Optional.

  Options:
		operation -	">" (store) or "<"(get). This is mandatory option.
					It can otpionaly be followed by the string representing the name of the window for which to do operation.
					">" is a special name that can be used to save all AHK Guis.
		Hwnd	  - Hwnd of the window for which to store data or Gui number (if AHK window). Valid only for ">" operation. 
					If omited, function will use Hwnd of the default AHK Gui. You can also use AHK Gui number or use Gui, N:Default 
					prior to calling the function. 
					For 3td party windows this option must be set.

  Returns:
		Position string in AHK form which can be used for AHK Gui's.	
 */
Win_Po1( Options, ByRef X="",ByRef Y="",ByRef W="",ByRef H="", ByRef MinMax="" ){
	static key="Software\AutoHotkey\Win"

	loop, parse, Options, %A_Space%%A_Tab%, %A_Space%%A_Tab%
	{
		ifEqual, A_LoopField, , continue
		f := SubStr(A_LoopField, 1, 1),  p := SubStr(A_LoopField, 2)

		if (f = ">")
			 op := ">", name := p
		else if (f = "<")
			 op := "<", name := p
		else if InStr(A_LoopField, "Hwnd")
			 hwnd := SubStr(A_LoopField, 5)
		else def .= A_LoopField " "	
	}

	if (op = "<") {
		RegRead, pos, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%!%name%
		ifEqual, ErrorLevel, 1, SetEnv, pos, %def%
	
		StringSplit, p, pos, %A_Space%
		loop, %p0%
			f := SubStr(p%A_Index%,1,1), %f% := SubStr(p%A_Index%,2)
		return pos
	} 
	else if (op = ">") {
		if (name = ">") {		;save all guis
			Loop, 99
			{
				Gui, %A_Index%:+LastFoundExist
				ifWinExist
					Win_Pos(">" A_Index " hwnd" A_Index)
			}
			return
		}
	
		if (hwnd = "") || (hwnd <= 99) {
			ifEqual, hwnd,, Gui, +LastFound
			else Gui, %hwnd%:+LastFound
			hwnd := WinExist()
		}
		WinGet, mm, MinMax, ahk_id %hwnd%
		ifNotEqual, mm, 0,  WinRestore, ahk_id %hwnd%
		Win_Get(Hwnd, "RxyLwh", x,y,w,h)

		mm := mm=-1 ? "minimized" : mm ? "maximize" : ""
		pos := "x" x " y" y " w" w " h" h " " mm

		RegWrite, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%!%name%, %pos%
		return pos
	}
}

Win_Pos( Options, ByRef X="",ByRef Y="",ByRef W="",ByRef H="", ByRef MinMax="" ){
	static key="Software\AutoHotkey\Win"
	
	oldDetect := A_DetectHiddenWindows
	loop, parse, Options, %A_Space%%A_Tab%, %A_Space%%A_Tab%
	{
		ifEqual, A_LoopField, , continue
		f := SubStr(A_LoopField, 1, 1),  p := SubStr(A_LoopField, 2)

		if (f = ">")
			 op := ">", name := p
		else if (f = "<")
			 op := "<", name := p
		else if InStr(A_LoopField, "Hwnd")
			 hwnd := SubStr(A_LoopField, 5)
		else def .= A_LoopField " "	
	}

	if (op = "<") {
		RegRead, pos, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%!%name%
		ifEqual, ErrorLevel, 1, SetEnv, pos, %def%
	
		StringSplit, p, pos, %A_Space%
		loop, %p0%
			f := SubStr(p%A_Index%,1,1), %f% := SubStr(p%A_Index%,2)
		MinMax := m != "" ? "m" m : ""
	} 
	else if (op = ">") {
		if (name = ">") {		;save all guis
			Loop, 99
			{
				Gui, %A_Index%:+LastFoundExist
				ifWinExist
					Win_Pos(">" A_Index " hwnd" A_Index)
			}
			DetectHiddenWindows, %oldDetect%
			return
		}
	
		if (hwnd = "") || (hwnd <= 99) {
			ifEqual, hwnd,, Gui, +LastFound
			else Gui, %hwnd%:+LastFound
			hwnd := WinExist()
		}
		WinGet, mm0, MinMax, ahk_id %hwnd%				;do it twice, window can be maximized then minimized.
		ifNotEqual, mm0, 0,  WinRestore, ahk_id %hwnd%
		WinGet, mm1, MinMax, ahk_id %hwnd%
		ifNotEqual, mm1, 0,  WinRestore, ahk_id %hwnd%

		WinGetClass, class, ahk_id %hwnd%
		if (class = "AutoHotkeyGUI")
			  Win_Get(Hwnd, "RxyLwh", x,y,w,h)
		else  WinGetPos, x, y, w, h, ahk_id %hwnd%

		m := mm0=-1 ? "minimized" : mm0 ? "maximize" : ""
		pos := "x" x " y" y " w" w " h" h " " m

		ifEqual, mm0, -1, WinMinimize, ahk_id %hwnd%
		else ifEqual, mm0, 1, WinMaximize, ahk_id %hwnd%

		RegWrite, REG_SZ,  HKEY_CURRENT_USER, %key%, %A_ScriptFullPath%!%name%, %pos%
	}
	DetectHiddenWindows, %oldDetect%
	return pos
}

#include Win.ahk