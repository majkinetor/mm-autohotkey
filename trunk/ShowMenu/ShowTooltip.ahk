/*
 Function:  ShowTooltip 
            Show the tooltip and automatically dismiss it. 

 Parameters: 
            Msg				 - Text to show. If omitted or empty, any existing tooltip will be hidden. 
            X,Y				 - Coordinates on which to show tooltip. Affected by CoordMode. Optional.
            TimeIn, TimeOut  - Time in milliseconds for tooltip to show and to disappear. 
							   If TimeOut is 0, tooltip will never be dismissed. Optional.

 About: 
            o v1.0 by majkinetor 
 */ 
ShowTooltip( Msg, X="" ,Y="", TimeIn=500, TimeOut=1500){
	static 
	_Msg := Msg, _X:=X, _Y:=Y,, _TimeOut := TimeOut
	MouseGetPos,,,_win,_ctrl
	SetTimer, ShowTooltipOn, % -TimeIn
	return
 ShowTooltipOff:
	Tooltip,,,,19
 return
 ShowTooltipOn:
	if (_TimeOut)
		SetTimer, ShowTooltipOff, % -_TimeOut
	MouseGetPos,,,win,ctrl
	if (win != _win) || (ctrl != _ctrl)
		return
	Tooltip,%_Msg% , _X, _Y, 19
 return
}