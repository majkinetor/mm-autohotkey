	OnExit, OnExit
	Run, DbgView, , ,PID
	WinWait, ahk_class dbgviewClass
	hDbg := WinExist("ahk_pid " pid)
	AppBar_New(hDbg,  "Edge=Right", "AutoHide=Blend")
	Win_SetCaption(hDbg), Win_SetMenu(hDbg)
return

OnExit:
	WinClose, ahk_id %hDbg%
	ExitApp
return

#include AppBar.ahk
#include Taskbar\Win.ahk
#include Taskbar\_.ahk
