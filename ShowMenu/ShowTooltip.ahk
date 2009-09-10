/*
 Function:  ShowTooltip 
            Show tooltip and automatically dismiss it. 

 Parameters: 
            Msg   - Text to show. If omited or empty, any existing tooltip will be hidden. 
            X,Y - Coordinates on which to show tooltip. Affected by CoordMode. 
            TimeIn, TimeOut   - Time in milliseconds for tooltip to show and to disappear. 

 About: 
            o v1.0 by majkinetor 
 */ 
ShowTooltip(Msg="", X="" ,Y="", TimeIn=500, TimeOut=1500){ 
   static 
   ifEqual, Msg, , goto ShowTooltipOff 

   _Msg := Msg, _X:=X, _Y:=Y 
   MouseGetPos, , , _win , _ctrl 

   t1 := -TimeIn, t2 := -TimeOut 
   SetTimer, ShowTooltipOn, %t1% 
   return 

 ShowTooltipOff: 
   Tooltip, , , , 19 
 return 

 ShowTooltipOn: 
   SetTimer, ShowTooltipOff, %t2% 
   MouseGetPos, , , win , ctrl 
   ifNotEqual, ctrl, %_ctrl%, IfNotEqual, win, %win%, return 
   Tooltip,%_Msg% , _X, _Y, 19 
 return 
}