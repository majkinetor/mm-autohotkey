/*
	Function:	CColor
				Set text and background color for some Gui controls. 
				Supported types: Edit, Text, ListBox, ComboBox, DropDownList, CheckBox, RadioButton 
   
	Parameters:   
		Hwnd		-  Handle of the control.
		Background  -  Background color. HTML color name or 6-digit RGB value or TRANSPARENT. Optional.
		Foreground  -  Foreground color. HTML color name or 6-digit RGB value. Optional.
	  
	Remarks:
		On tha first call for a specific control class the function registers itself as message handler for WM_CTLCOLOR
		message of appropriate class.
   
	About:
		o Version 1.0 by majkinetor.
		o Original code by (de)nick, See: <http://www.autohotkey.com/forum/topic238864.html>.
		o Licenced under BSD <http://creativecommons.org/licenses/BSD/>.
 */
CColor(Hwnd, Background="", Foreground="") {
	return CColor_(Background, Foreground, "", Hwnd+0)
}

CColor_(Wp, Lp, Msg, Hwnd) { 
	static 
	static WM_CTLCOLOREDIT := 0x0133, WM_CTLCOLORLISTBOX := 0x134, WM_CTLCOLORSTATIC := 0x0138 
		  ,BS_CHECKBOX := 0x2 ,BS_RADIOBUTTON := 0x8 ,ES_READONLY := 0x800
		  ,CBLACK=0, CSILVER=0xC0C0C0, CGRAY=0x808080, CWHITE=0xFFFFFF, CMAROON=0x80, CRED=0x0FF, CPURPLE=0x800080, CFUCHSIA=0xFF00FF, CGREEN=0x8000, CLIME=0xFF00, COLIVE=0x8080, CYELLOW=0xFFFF, CNAVY=0x800000, CBLUE=0xFF0000, CTEAL=0x808000, CAQUA=0xFFFF00
 		  ,CLASSES := "Button,ComboBox,Edit,ListBox,Static"
	
	If (Msg = "") {      
		if !adrSetTextColor
			adrSetTextColor	:= DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "Gdi32.dll"), "str", "SetTextColor")
		   ,adrSetBkColor	:= DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "Gdi32.dll"), "str", "SetBkColor")
		   ,adrSetBkMode	:= DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "Gdi32.dll"), "str", "SetBkMode")
	
      ;Set the colors (RGB -> BGR)
		BG := !Wp ? "" : C%Wp% != "" ? C%Wp% : "0x" SubStr(WP,5,2) SubStr(WP,3,2) SubStr(WP,1,2) 
		FG := !Lp ? "" : C%Lp% != "" ? C%Lp% : "0x" SubStr(LP,5,2) SubStr(LP,3,2) SubStr(LP,1,2) 

	  ;Activate message handling with OnMessage() on the first call for a class 
		WinGetClass, class, ahk_id %Hwnd% 
		If class not in %CLASSES% 
			return A_ThisFunc "> Unsupported control class: " class

		ControlGet, style, Style, , , ahk_id %Hwnd% 
		if (class = "Edit") && (Style & ES_READONLY) 
			class := "Static"
			
		if (class = "Button")
			if (style & BS_RADIOBUTTON) || (style & BS_CHECKBOX) 
				 class := "Static" 
			else return A_ThisFunc "> Unsupported control class: " class
		
		if (class = "ComboBox") { 
			VarSetCapacity(CBBINFO, 52, 0), NumPut(52, CBBINFO), DllCall("GetComboBoxInfo", "UInt", Hwnd, "UInt", &CBBINFO) 
			hwnd1 := NumGet(CBBINFO, 48)		;hwndList
			%hwnd1%BG := BG, %hwnd1%FG := FG

			IfEqual, CTLCOLORLISTBOX,,SetEnv, CTLCOLORLISTBOX, % OnMessage(WM_CTLCOLORLISTBOX, A_ThisFunc) 

			If (NumGet(CBBINFO,44) != hwnd1)	;hwndEdit
				Hwnd :=  Numget(CBBINFO,44)

			class := "Edit" 
		} 

		if (!CTLCOLOR%Class%)
			CTLCOLOR%Class% := OnMessage(WM_CTLCOLOR%Class%, A_ThisFunc) 
		return %Hwnd%BG := BG, %Hwnd%FG := FG, %Hwnd% := DllCall("CreateSolidBrush", "UInt", %Hwnd%BG)
   } 
 
 ; Message handler 
	critical					;its OK, always in new thread.

	hParent := Hwnd, Hwnd := Lp + 0, hDC := Wp + 0
	if !init && (init := 1)
		SetTimer, %A_ThisFunc%, -10

	If (%Hwnd%) { 
		DllCall(adrSetBkMode, "uint", hDC, "int", 1)
		if (%Hwnd%FG)
			DllCall(adrSetTextColor, "UInt", hDC, "UInt", %Hwnd%FG)
		if (%Hwnd%BG)
			DllCall(adrSetBkColor, "UInt", hDC, "UInt", %Hwnd%BG)
		return (%Hwnd%)
	}

 CColor_:
	WinSet, Redraw, ,ahk_id %hParent%	
 return
}