/*
 Function:  SetFont
			Sets the control font.

 Parameters:
			hCtrl	  - Handle of the control.
			FontStyle - Font style or font handle.
			FontFace  - Font face, if omitted "Ms Sans Serif".	

 Returns:	
			Font handle.
 */
Ext_Font(hCtrl, FontStyle="", FontFace="") { 
	static WM_SETFONT := 0x30

	if FontStyle is not integer
	{
	  ;parse font 
		italic      := InStr(FontStyle, "italic")    ?  1    :  0 
		underline   := InStr(FontStyle, "underline") ?  1    :  0 
		strikeout   := InStr(FontStyle, "strikeout") ?  1    :  0 
		weight      := InStr(FontStyle, "bold")      ? 700   : 400 

	  ;height 
		RegExMatch(Font, "(?<=[S|s])(\d{1,2})(?=[ ,])", height) 
		if (height = "") 
		  height := 10 
		RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels 
		height := -DllCall("MulDiv", "int", Height, "int", LogPixels, "int", 72) 
	
		IfEqual, FontFace,,SetEnv FontFace, MS Sans Serif
	 ;create font 
	   hFont   := DllCall("CreateFont", "int",  height, "int",  0, "int",  0, "int", 0 
						  ,"int",  weight,   "Uint", italic,   "Uint", underline 
						  ,"uint", strikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", FontFace, "Uint")
	} else hFont := FontStyle
	SendMessage,WM_SETFONT,hFont,TRUE,,ahk_id %hCtrl%
	return hFont
}
