_()
	Shell_ABSetState("")
return

/*	Function: ABSetState
			  Set state of the AppBar.

	Parameters:
			State - "autohide", "ontop" or "all". To disable state add "-" as prefix. To toggle it, add "^". Omit to disable all states.
			Hwnd  - Hwnd of the AppBar, by default TaskBar.
*/
Shell_ABSetState(State="", Hwnd=""){
	static ABM_SETSTATE=0xA, ABM_GETSTATE=4, AUTOHIDE=1, ONTOP=2, ALL=3

	c := SubStr(State, 1, 1), VarSetCapacity(ABD,36,0), NumPut(36, ABD, 0, "Uint")
	curState := DllCall("Shell32.dll\SHAppBarMessage", "UInt", ABM_GETSTATE, "UInt", &ABD )
	if (bToggle :=  c = "^") || (bDisable := c = "-")
		State := SubStr(State, 2)

	ifEqual, State, ,SetEnv, State, 0
	else State := %State%

	sd := curState & ~State, sa := curState | State
	if State
		State := bToggle ? (curState & State ? sd : sa) : bDisable ? sd : sa

	NumPut(State, ABD, 32), DllCall("Shell32.dll\SHAppBarMessage", "UInt", ABM_SETSTATE, "UInt", &ABD)
}