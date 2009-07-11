/* Title:	HLink
			*Custom HyperLink control.*
*/

/*
  Function:		Add
 				Creates hyperlink control.
 
  Parameters: 	
 				hGui	- Handle of the parent GUI.
 				X..H	- Size & position.
				Handler	- Notification handler. If you omit handler, link will be opened in default browser when clicked.
 				Text	- Link text. Link is text between the ' char followd by the : char and location (as Textille mark-up).
 						  Everything else  will be displayed as ordinary text.
 
  Notifications:
 >				Result := OnLink(hWnd, Text, Link)
 
 				hWnd	- Handle of the HLink control that generated notification.
 				Text	- Text of the control.
 				Link	- Link of the control.
 
  Example:
 >				hLink := HLink_Add(hGui, "OnLink", 10, 10, 200, 20, "Click 'here':www.Google.com to go to Google")
 */
HLink_Add(hGui, X, Y, W, H, Handler="", Text="'HLink Control':"){
	static MODULEID
	static ICC_LINK_CLASS=0x8000, WS_CHILD=0x40000000, WS_VISIBLE=0x10000000, WS_TABSTOP=0x10000
	static id=1

	if MODULEID =
	{ 
		old := OnMessage(0x4E, "HLink_onNotify"), MODULEID := 170608
		if old != HLink_onNotify
			HLink("oldNotify", RegisterCallback(old))

		VarSetCapacity(ICC, 8, 0), NumPut(8, ICC, 0)
		DllCall("comctl32.dll\InitCommonControlsEx", "uint", &ICC)
	}
	
	Text := RegExReplace(Text, "'(.+?)'\:([^ ]*)", "<a href=""$2"">$1</a>")
	hCtrl := DllCall("CreateWindowEx"
                  ,"Uint", 0
                  ,"str",  "SysLink"
                  ,"str",  Text
                  ,"Uint", WS_CHILD | WS_VISIBLE | WS_TABSTOP
                  ,"int",  X, "int", Y, "int", W, "int", H
                  ,"Uint", hGui
                  ,"Uint", MODULEID
                  ,"Uint", 0
                  ,"Uint", 0, "Uint")

	if IsFunc(Handler)
		HLink(hCtrl "handler", Handler)

	return hCtrl
}

;----------------------------------------------------------------------------------------------

HLink_OnNotify(Wparam, Lparam, Msg, Hwnd){
	static MODULEID := 170608, oldNotify="*"
	static NM_CLICK = -2, NM_ENTER = -4

	if ((NumGet(Lparam+4)) != MODULEID){
		ifEqual, oldNotify, *, SetEnv, oldNotify, % HLink("OldNotify")		
		ifNotEqual, oldNotify,,return DllCall(oldNotify, "uint", Wparam, "uint", Lparam, "uint", Msg, "uint", Hwnd)		
		return
	}

	hw := NumGet(Lparam+0),  code := NumGet(Lparam+8, 0, "Int")

	if code not in %NM_CLICK%,%NM_ENTER%
		return
   
	ControlGetText, txt, ,ahk_id %hw%
	RegExmatch(txt, "\Q<a href=""\E(.*?)"">(.+?)</a>", out)
	StringReplace, txt, txt, %out%, %out2%

	handler := HLink(hw "Handler")
	if (handler = "")
		Run, %out1%
	else if ( %handler%(hw, txt, out1) )
		Run, %out1%
}

;Mini storage function
HLink(var="", value="~`a") { 
	static
	_ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}




/* Group: Example
	(start code)
	#SingleInstance force

	   Gui, +LastFound
	   hGui := WinExist() +0

	   HLink_Add(hGui, 10,  10,  250, 20, "OnLink", "Click 'here':www.Google.com to go to Google" )
	   HLink_Add(hGui, 10,  40,  250, 20, "OnLink", "Click 'this link':www.Yahoo.com to go to Yahoo")
	   HLink_Add(hGui, 10,  170, 100, 20, "OnLink", "'About HLink':About")
	   HLink_Add(hGui, 110, 170, 100, 20, "OnLink", "'Forum':http://www.autohotkey.com/forum/topic19508.html")
	   HLink_Add(hGui, 10,	60,  100, 20, "", "'Google':www.Google.com) ;without handler
	   Gui, Show, w300 h200
	return

	OnLink(hCtrl, Text, Link){
		if Link = About
			msgbox Hlink control`nby majkinetor
		else return 1

	}
	(end code)
 */

/* Group: About
		o Ver 2.0 by majkinetor. See http://www.autohotkey.com/forum/topic19508.html
		o HLink Reference at MSDN: <http://msdn2.microsoft.com/en-us/library/bb760704.aspx>
		o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/> 
 */