; Title:	HLink
;			Custom HyperLink control
;:
; Created by majkinetor

;----------------------------------------------------------------------------------------------
; Function:		Add
;				Creates hyperlink control
;
; Parameters: 	
;				hGui	- Handle of the parent GUI
;				fun		- Notification function
;				x,y,w,h - Size & position
;				txt		- Link information. Link is specified in the form specified by Textille language. 
;						  Link is text between the ' char followd by the : char and location. Everything else 
;						  will be displayed as ordinary text.
;
; Notifications:
;>				OnLink(hwnd, pText, pLink)
;
;				hwnd	- Handle of the HLink control that generated notification
;				pText	- Text of the control
;				pLink	- Link of the control
;
; Example:
;>     hLink1 := HLink_Add(hGui, "OnLink", 10, 10, 200, 20, "Click 'here':www.Google.com to go to Google")
;
HLink_Add(hGui, fun, x, y, w, h, txt="'HLink Control':"){
	local old, hwnd, ICC
	static ICC_LINK_CLASS=0x8000, WS_CHILD=0x40000000, WS_VISIBLE=0x10000000, WS_TABSTOP=0x10000
	static init, id=1

	ifEqual, fun, ,	return "Err: Invalid function"

	if !init { 
		HLink_MODULEID := 170608
		old := OnMessage(0x4E, "HLink_onNotify")
		if old != HLink_onNotify
			HLink_oldNotify := RegisterCallback(old)

		VarSetCapacity(ICC, 8, 0), NumPut(8, ICC, 0)
		DllCall("comctl32.dll\InitCommonControlsEx", "uint", &ICC)
		init := true
	}
	
	txt := RegExReplace(txt, "'(.+?)'\:([^ ]*)", "<a href=""$2"">$1</a>")
	hWnd := DllCall("CreateWindowEx"
                  ,"Uint", 0
                  ,"str",  "SysLink"
                  ,"str",  txt
                  ,"Uint", WS_CHILD | WS_VISIBLE | WS_TABSTOP
                  ,"int",  x, "int", y, "int", w, "int", h
                  ,"Uint", hGui
                  ,"Uint", HLink_MODULEID
                  ,"Uint", 0
                  ,"Uint", 0)

	HLink_%hwnd%_fun := fun

	return hWnd
}

HLink_Add2Panel(hPanel, Txt, Opt) {
	f := "Panel_Parse",  %f%(Opt, "x y w h f", x, y, w, h, f)
	return HLink_Add(hPanel, f, x, y, w, h, Txt)
}

;----------------------------------------------------------------------------------------------

HLink_OnNotify(wparam, lparam, msg, hwnd){
    local idFrom, txt, code, out, out1, out2, res, fun, _hwnd
	static NM_CLICK = -2, NM_ENTER = -4
	
  ;forwarding
	idFrom := NumGet(lparam+4)
	if (idFrom != HLink_MODULEID){
		if HLink_oldNotify {
			res := DllCall(HLink_oldNotify, "uint", wparam, "uint", lparam, "uint", msg, "uint", hwnd)
			return res ? res : ""		;!!! without this AHK TreView doesn't work
		}
		return
	}

  ;handle HLink messages
	code := NumGet(lparam+8) - 4294967296
	if code not in %NM_CLICK%,%NM_ENTER%	
		return
   
	_hwnd := NumGet(lparam+0), 	fun := HLink_%_hwnd%_fun
	ControlGetText, txt, ,ahk_id %_hwnd%
	RegExmatch(txt, "\Q<a href=""\E(.*?)"">(.+?)</a>", out)
	StringReplace, txt, txt, %out%, %out2%
	
	%fun%(_hwnd, txt, out1)
}


;-------------------------------------------------------------------------------------------------------------------
;Group: Example
;>#SingleInstance force
;>#NoEnv
;>   Gui, +LastFound
;>   hGui := WinExist() +0
;>
;>   HLink_Add(hGui, "OnLink", 10,  10,  200, 20, "Click 'here':www.Google.com to go to Google" )
;>   HLink_Add(hGui, "OnLink", 10,  40,  250, 20, "Click 'on this link':www.Yahoo.com to go to Yahoo")
;>   HLink_Add(hGui, "OnLink", 10,  170, 100, 20, "'About HLink':About")
;>   HLink_Add(hGui, "OnLink", 110, 170, 100, 20, "'Forum':http://www.autohotkey.com/forum/topic19508.html")
;>   HLink_Add(hGui, "OnLink", 10, 60, 100, 20)
;>   Gui, Show, w300 h200
;>return
;>
;>OnLink(hwnd, pText, pLink){
;>	if pLink = About
;>		msgbox Hlink control`nby majkinetor
;>	else Run, %pLink%
;>}


;-------------------------------------------------------------------------------------------------------------------
;Group: About
;		o Ver 1.2 by majkinetor. See http://www.autohotkey.com/forum/topic19508.html
;		o HLink Reference at MSDN: <http://msdn2.microsoft.com/en-us/library/bb760704.aspx>
;		o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.
