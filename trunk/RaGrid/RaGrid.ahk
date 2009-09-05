/*
	Title:	RaGrid
			
 */

RG_ScrollCell(hGrd){
	static GM_SCROLLCELL=0x413	;wParam=0, lParam=0
	SendMessage,GM_SCROLLCELL,,,, ahk_id %hGrd% 
	return ErrorLevel
}

RG_ResetColumns(hGrd){
	static GM_RESETCOLUMNS=0x429	;wParam=0, lParam=0
	SendMessage,GM_RESETCOLUMNS,,,, ahk_id %hGrd% 
	return ErrorLevel
}

RG_GetHdrText(hGrd, nCol){
	static GM_GETHDRTEXT=0x424	;wParam=nCol, lParam=lpBuffer

	VarSetCapacity(txt, 128)
	SendMessage,GM_GETHDRTEXT,nCol,&txt,, ahk_id %hGrd% 
	return txt 
}

RG_SetHdrText(hGrd, nCol, txt=""){
	static GM_SETHDRTEXT=0x425	;wParam=nCol, lParam=lpBuffer

	SendMessage,GM_SETHDRTEXT,nCol,&txt,, ahk_id %hGrd% 
	return ErrorLevel
}

;wParam=nRow, lParam=lpROWDATA (can be NULL)
RG_AddRow(hGrd, aColName, nRow=""){ 
	local RAW, colCount 
	static GM_ADDROW=0x402, GM_INSROW=0x403

	colCount := RG_GetColCount(hGrd)

	VarSetCapacity(RAW, 4 * colCount, 0) 
	Loop %colCount% 
	  NumPut(&%aColName%%A_Index%, RAW, (A_Index - 1) * 4) 
	
	if (nRow = "")
			SendMessage,GM_ADDROW,0,&RAW,, ahk_id %hGrd% 
	else	SendMessage,GM_INSROW,nRow,&RAW,, ahk_id %hGrd%  
	return ErrorLevel 
}

RG_DelRow(hGrd, nRow=0) {
	static GM_DELROW=0x404		;wParam=nRow, lParam=0

	if nRow = -1
		nRow += RG_GetRowCount(hGrd)

	SendMessage,GM_DELROW,nRow,0,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_MoveRow(hGrd, pFrom, pTo ){
	static GM_MOVEROW=0x405
	SendMessage,GM_MOVEROW,pFrom,pTo,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_GetRowCount(hGrd) {
	static GM_GETROWCOUNT=0x40F		;wParam=0, lParam=0
	SendMessage,GM_GETROWCOUNT,0,0,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_GetColCount(hGrd) {
	static GM_GETCOLCOUNT=0x40E		;wParam=0, lParam=0
	SendMessage,GM_GETCOLCOUNT,0,0,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_GetColWidth(hGrd, nCol=0) {		;wParam=nCol, lParam=0
	static GM_GETCOLWIDTH=0x41C
	SendMessage,GM_GETCOLWIDTH,nCol,0,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_SetColWidth(hGrd, nCol, nWidth) {		;wParam=nCol, lParam=nWidth
	static GM_GETCOLWIDTH=0x41D
	SendMessage,GM_GETCOLWIDTH,nCol,nWidth,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_GetHdrHeight(hGrd) {		
	static GM_GETHDRHEIGHT=0x41E
	SendMessage,GM_GETHDRHEIGHT,0,0,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_SetHdrHeight(hGrd, h){
	static GM_SETHDRHEIGHT=0x41F
	SendMessage,GM_SETHDRHEIGHT,0,h,, ahk_id %hGrd%
	return ErrorLevel
}

RG_GetRowHeight(hGrd){		
	static GM_GETROWHEIGHT=0x420
	SendMessage,GM_GETROWHEIGHT,0,0,, ahk_id %hGrd%
	return ErrorLevel
}

RG_SetRowHeight(hGrd, nHeight){		
	static GM_SETROWHEIGHT=0x421
	SendMessage,GM_SETROWHEIGHT,0, nHeight,, ahk_id %hGrd%
	return ErrorLevel
}

RG_ResetContent(hGrd) {
	static GM_RESETCONTENT=0x422
	SendMessage,GM_RESETCONTENT,0,0,, ahk_id %hGrd%
	return ErrorLevel
}
	
RG_GetCurRow(hGrd) {
	static GM_GETCURROW=0x40C
	SendMessage,GM_GETCURROW,0,0,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_SetCurRow(hGrd, nRow=0) {		;wParam=nRow, lParam=0
	static GM_SETCURROW=0x40D
	SendMessage,GM_SETCURROW,nRow,0,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_EnterEdit(hGrd, nCol=0, nRow=0) {
	static GM_ENTEREDIT=0x41A	;wParam=nCol, lParam=nRow
	SendMessage, GM_ENTEREDIT,nCol,nRow,, ahk_id %hGrd% 
	return ErrorLevel 
}

RG_Sort(hGrd, col=0, type="ASC"){
	static GM_COLUMNSORT=0x423
	static ASC=0,DES=1,INVERT=2
	type := 0
	SendMessage,GM_COLUMNSORT,col,&type,,ahk_id %hGrd%
}

;-----------------------------------------------------------------------------------------------------------
;w		-colwt			;column width
;cap	-lpszhdrtext	;column captin
;ha		-halign			;Header text alignment.
;ca		-calign			;Column text alignment.
;maxt	-ctextmax		;Max text lenght for TYPE_EDITTEXT and TYPE_EDITLONG.
;type	-ctype			;type of data 
;						EDITTEXT,	EDITLONG,	CHECKBOX,	COMBOBOX,	HOTKEY,	BUTTON,	IMAGE,	DATE,	TIME,	USER,	EDITBUTTON
;sort	-hdrflag		;Header flags. Set to ZERO or if initially sorted set to initial sort direction
;						ASC, DES, INVERT
RG_AddColumn(hGrd, o1="", o2="", o3="", o4="", o5="", o6="", o7=""){
	local j, prop, COL
	
	;custom interface
	local w, cap, ha, ca, type, maxt, sort ; il
	;types
	static EDITTEXT=0,EDITLONG=1,CHECKBOX=2,COMBOBOX=3,HOTKEY=4,BUTTON=5,IMAGE=6,DATE=7,TIME=8,USER=9,EDITBUTTON=10
	;sort
	static ASC=0,DES=1,INVERT=2

	static GM_ADDCOL = 0x401

	type := "EDITTEXT"
	loop, 6 {
		if !o%A_index%
			continue

		j := InStr( o%A_index%, "=" )
		prop := SubStr(	o%A_index%, 1, j-1 )
		%prop% := SubStr( o%A_index%, j+1, 100)
	}
	
	type := %TYPE%, sort := %SORT%
	VarSetCapacity(COL, 48, 0)
	NumPut(w,		COL, 0)
	NumPut(&cap,	COL, 4)
	NumPut(ha,		COL, 8)
	NumPut(ca,		COL, 12)
	NumPut(type,	COL, 16)
	NumPut(maxt,	COL, 20)
;	NumPut(format,	COL, 24)	;not used now
;	NumPut(il,		COL, 28)	;NOT USED NOW
	NumPut(sort,	COL, 32)
	
	SendMessage,GM_ADDCOL,0, &col,, ahk_id %hGrd%
	return ErrorLevel
}

;Styles: NOSEL, NOFOCUS, HGRIDLINES, VGRIDLINES,GRIDLINES, GRIDFRAME, NOCOLSIZE
RG_Add(hwnd,x=0,y=0,w=200,h=100,style=""){
	static	WS_CLIPCHILDREN=0x2000000, WS_VISIBLE=0x10000000, WS_CHILD=0x40000000
	static	NOSEL=0x1, NOFOCUS=0x2, HGRIDLINES=0x4,VGRIDLINES=0x8,GRIDLINES=12, GRIDFRAME=0x10, NOCOLSIZE=0x20

	hexStyle := 0
	loop, parse, style, %A_Tab%%A_Space%
		hexStyle |= %A_LOOPFIELD%


	hModule := DllCall("LoadLibrary", "str", "RAGrid.dll")
	hCtrl := DllCall("CreateWindowEx"
      , "Uint", 0x200            ; WS_EX_CLIENTEDGE
      , "str",  "RAGrid"         ; ClassName
      , "str",  szAppName        ; WindowName
      , "Uint", WS_CLIPCHILDREN | WS_CHILD | WS_VISIBLE | hexStyle
      , "int",  x            ; Left
      , "int",  y            ; Top
      , "int",  w            ; Width
      , "int",  h            ; Height
      , "Uint", hwnd         ; hWndParent
      , "Uint", 0            ; hMenu
      , "Uint", 0            ; hInstance
      , "Uint", 0)


	return hCtrl
}

;--------------------------------------------------------------------------------------------
; B - back color
; G - grid color
; T - text color
RG_SetColors(hGrd, colors){
	static GM_SETBACKCOLOR=0x415, GM_SETGRIDCOLOR=0x417, GM_SETTEXTCOLOR=0x419

	Loop, Parse, colors, %A_Space%
	{
		if A_LoopField =
			continue

		StringLeft c, A_LoopField, 1
		StringTrimLeft token, A_LoopField, 1
		
		%c% := "0x" token
	}


	if (B)
		SendMessage,GM_SETBACKCOLOR,B,,, ahk_id %hGrd%
	
	if (G)
 		SendMessage,GM_SETGRIDCOLOR,G,,, ahk_id %hGrd%

	if (T)
		SendMessage,GM_SETTEXTCOLOR,T,,, ahk_id %hGrd%
	
}

RG_GetColors(hGrd){
	static GM_GETBACKCOLOR=0x414, GM_GETGRIDCOLOR=0x416, GM_GETTEXTCOLOR=0x418

	oldFormat = A_FormatInteger
	SetFormat, integer, hex

	SendMessage,GM_GETBACKCOLOR,,,, ahk_id %hGrd%
	res .= "B" ERRORLEVEL
	SendMessage,GM_GETGRIDCOLOR,,,, ahk_id %hGrd%
	res .= " G" ERRORLEVEL
	SendMessage,GM_GETTEXTCOLOR,,,, ahk_id %hGrd%
	res .= " T" ERRORLEVEL

	SetFormat, integer, %oldFormat%
	return res
}

RG_SetFont(hGrd, pFont="") { 
   local height, weight, italic, underline, strikeout , nCharSet, fontFace, LogPixels
   local hFont
   static WM_SETFONT := 0x30


 ;parse font 
   italic      := InStr(pFont, "italic")    ?  1    :  0 
   underline   := InStr(pFont, "underline") ?  1    :  0 
   strikeout   := InStr(pFont, "strikeout") ?  1    :  0 
   weight      := InStr(pFont, "bold")      ? 700   : 400 

 ;height 
   RegExMatch(pFont, "(?<=[S|s])(\d{1,2})(?=[ ,])", height) 
   if (height = "") 
      height := 10 
   RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels 
   height := -DllCall("MulDiv", "int", Height, "int", LogPixels, "int", 72) 

 ;face 
   RegExMatch(pFont, "(?<=,).+", fontFace)    
   if (fontFace != "") 
       fontFace := RegExReplace( fontFace, "(^\s*)|(\s*$)")      ;trim 
   else fontFace := "MS Sans Serif" 

 ;create font 
   hFont   := DllCall("CreateFont", "int",  height, "int",  0, "int",  0, "int", 0 
                      ,"int",  weight,   "Uint", italic,   "Uint", underline 
                      ,"uint", strikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", fontFace) 

   SendMessage,WM_SETFONT,hFont,TRUE,,ahk_id %hGrd%
   return ErrorLevel
}

RG_ComboAddString(hGrd, nCol, string) {
	static GM_COMBOADDSTRING=0x406	;wParam=nCol, lParam=lpszString

	loop, parse, string, |
	{
		s := A_LoopField
		SendMessage, GM_COMBOADDSTRING, nCol, &s,, ahk_id %hGrd%
	}
}

RG_ComboClear(hGrd, nCol) {
	static GM_COMBOCLEAR=0x407	;wParam=nCol, lParam=0

	SendMessage, GM_COMBOCLEAR, nCol,,, ahk_id %hGrd%
	return ErrorLevel
}

RG_GetCellText(hGrd, nRow=0, nCol=0) {
	static GM_GETCELLDATA=0x410		;wParam=nRowCol, lParam=lpData
	
	VarSetCapacity(buf, 256, 0)

	nRowCol := (nRow << 16) + nCol
	SendMessage, GM_GETCELLDATA, nRowCol, &buf,, ahk_id %hGrd%
	return buf
}

RG_GetCellNum(hGrd, nRow=0, nCol=0) {
	static GM_GETCELLDATA=0x410		;wParam=nRowCol, lParam=lpData
	
	VarSetCapacity(buf, 256, 0)

	nRowCol := (nRow << 16) + nCol
	SendMessage, GM_GETCELLDATA, nRowCol, &buf,, ahk_id %hGrd%
	return NumGet(buf)
}

;numeric values are for combo and checkbox (index of element)
RG_SetCellText(hGrd, nRow=0, nCol=0, data="") {
	static GM_SETCELLDATA=0x411		;wParam=nRowCol, lParam=lpData (can be NULL)
	
	if (numeric)
		num := data, VarSetCapacity(data, 4), NumPut(num, data)

	nRowCol := (nRow << 16) + nCol
	SendMessage, GM_SETCELLDATA, nRowCol, &data,, ahk_id %hGrd%
	return ERRORLEVEL
}

RG_SetCellNum(hGrd, nRow=0, nCol=0, num=0) {
	static GM_SETCELLDATA=0x411		;wParam=nRowCol, lParam=lpData (can be NULL)
	
	VarSetCapacity(data, 4), NumPut(num, data)

	nRowCol := (nRow << 16) + nCol
	SendMessage, GM_SETCELLDATA, nRowCol, &data,, ahk_id %hGrd%
	return ERRORLEVEL
}

RG_GetCurSel(hGrd, ByRef nRow, ByRef nCol) {
	static GM_GETCURSEL=0x408	

	SendMessage, GM_GETCURSEL,,,, ahk_id %hGrd%
	nRow := ErrorLevel >> 16
	nCol := ErrorLevel & 0x00001111
}

RG_SetCurSel(hGrd, nCol=0, nRow=0) {	;wParam=nCol, lParam=nRow
	static GM_SETCURSEL=0x409

	SendMessage, GM_SETCURSEL,nCol,nRow,, ahk_id %hGrd%
	return ERRORLEVEL
}

RG_GetCurCol(hGrd) {	
	static GM_GETCURCOL=0x40A

	SendMessage, GM_GETCURCOL,,,, ahk_id %hGrd%
	return ERRORLEVEL
}

RG_SetCurCol(hGrd, nCol=0) {				;wParam=nCol, lParam=0
	static GM_SETCURCOL=0x40B

	SendMessage, GM_SETCURCOL,nCol,,,ahk_id %hGrd%
	return ERRORLEVEL
}

RG_SetRowColor(hGrd, back, text, nRow=0) {				;wParam=nRow, lParam=lpROWCOLOR
	static GM_SETROWCOLOR=0x42B

	VarSetCapacity(RC, 8), NumPut(back, RC), NumPut(text, RC, 4)	
	SendMessage, GM_SETROWCOLOR, nRow, &RC,,ahk_id %hGrd%
	return ERRORLEVEL
}

RG_GetRowColor(hGrd, back, text, nRow=0) {				;wParam=nRow, lParam=lpROWCOLOR
	static GM_GETROWCOLOR=0x42C

	VarSetCapacity(RC, 8)
	SendMessage, GM_GETROWCOLOR, nRow, &RC,,ahk_id %hGrd%
	return "not wrapped"	
}

;---------------------------------------------------------------------------------------------------- 
; Function: SetEvents 
;         Set notification events 
; 
; Parameters: 
;         func   - Subroutine that will be called on events. 
;         e      - White space separated list of events to monitor (by default, null). 
; 
; Globals: 
;         RG_EVENT   - Specifies event that occurred. Event must be registered to be able to monitor them. 
;     RG_ROW    - String containing zero based row number. 
;     RG_COLUMN - String containing zero based column number. 

; Events & Infos: 
;         HEADERCLICK   - Sent when user clicks header. 
;         BUTTONCLICK - Sent when user clicks the button in a button cell. 
;         CHECKCLICK - Sent when user double clicks the checkbox in a checkbox cell. 
;         IMAGECLICK - Sent when user double clicks the image in an image cell. 
;         BEFORESELCHANGE - (not implemented) Sent when user request a selection change. 
;         AFTERSELCHANGE - Sent after a selection change. 
;         BEFOREEDIT - Sent before the cell edit control shows. 
;         AFTEREDIT - Sent when the cell edit control is about to close. 
;         BEFOREUPDATE - (not implemented) Sent before a cell updates grid data. 
;         AFTERUPDATE - (not implemented) Sent after grid data has been updated. 
;         USERCONVERT - (not implemented) Sent when user cell needs to be converted. 
; 
; Returns: 
;         "OK" if succesiful, error string otherwise 
; 
RG_SetEvents(hGrd, func, e=""){ 
   local old, hmask 
  static GN_HEADERCLICK=0x1,GN_BUTTONCLICK=0x2,GN_CHECKCLICK=0x3,GN_IMAGECLICK=0x4 
        ,GN_BEFORESELCHANGE=0x5,GN_AFTERSELCHANGE=0x6,GN_BEFOREEDIT=0x7,GN_AFTEREDIT=0x8 
        ,GN_BEFOREUPDATE=0x9,GN_AFTERUPDATE=0xa,GN_USERCONVERT=0xb, WM_NOTIFY:=0x4E 
  static events="HEADERCLICK,BUTTONCLICK,CHECKCLICK,IMAGECLICK,BEFORESELCHANGE,AFTERSELCHANGE,BEFOREEDIT,AFTEREDIT,BEFOREUPDATE,AFTERUPDATE,USERCONVERT" 

   if !IsLabel(func) 
      return "Err: label doesn't exist`n`n" func 

  RG_%hGrd%_mask := "" ; clear any previous set mask 
   loop, parse, e, %A_Tab%%A_Space% 
   { 
      IfEqual, A_LoopField, , continue 
      if A_LoopField not in %events% 
         return "Err: unknown event - '" A_LoopField "'" 
      RG_%hGrd%_mask .= RG_%hGrd%_mask ? "," . GN_%A_LOOPFIELD% : GN_%A_LOOPFIELD% 
   } 
   IfEqual, RG_%hGrd%_mask,, return   ; not monitoring any events 


   old := OnMessage(WM_NOTIFY, "RG_onNotify") ; set RaGrid msg handler and remember old one 
   if (old != "RG_onNotify") 
      RG_oldNotify := RegisterCallback(old)    ; store callable old message handler 

  hGrd += 0 
   RG_%hGrd%_func := func 
   return "OK" 
} 


RG_onNotify(wparam, lparam, msg, hwnd) { 
   local code, hw, row,col,mask 
  static pInfo 
  static GN_HEADERCLICK=0x1,GN_BUTTONCLICK=0x2,GN_CHECKCLICK=0x3,GN_IMAGECLICK=0x4 
        ,GN_BEFORESELCHANGE=0x5,GN_AFTERSELCHANGE=0x6,GN_BEFOREEDIT=0x7 
        ,GN_AFTEREDIT=0x8,GN_BEFOREUPDATE=0x9,GN_AFTERUPDATE=0xa,GN_USERCONVERT=0xb 

  ; Call previous set WM_NOTIFY 
  RG_oldNotify ? DllCall(RG_oldNotify, "uint", wparam, "uint", lparam, "uint", msg, "uint", hwnd) : "" 

   hw    := NumGet(lparam+0)   ; control sending the message - this RaGrid 
  mask := RG_%hw%_mask       ; current events monitoring for 

  SetFormat, integer, hex 
   code   :=  NumGet(lparam+8)   ;- 
  SetFormat, integer, d 

  if code not in %mask% 
    return 

  RG_ROW := NumGet(lparam+16),  RG_COLUMN := NumGet(lparam+12) 

   if (code = GN_HEADERCLICK) { 
      RG_EVENT := "HEADERCLICK", RG_ROW := "" 
      GoSub % RG_%hw%_func 
      return 
   } 

   if (code = GN_BUTTONCLICK) { 
      RG_EVENT := "BUTTONCLICK" 
      GoSub % RG_%hw%_func 
      return 
   } 

   if (code = GN_CHECKCLICK) { 
      RG_EVENT := "CHECKCLICK" 
      GoSub % RG_%hw%_func 
      return 
   } 

   if (code = GN_IMAGECLICK) { 
      RG_EVENT := "IMAGECLICK" 
      GoSub % RG_%hw%_func 
      return 
   } 

;    if (code = GN_BEFORESELCHANGE) { 
;       RG_EVENT := "BEFORESELCHANGE" 
;       GoSub % RG_%hw%_func 
;       return 
;    } 

   if (code = GN_AFTERSELCHANGE) { 
    IfEqual, pInfo, %RG_ROW%|%RG_COLUMN%, return  ; filter out mutiple dup message calls 
    pInfo = %RG_ROW%|%RG_COLUMN%                  ; store info for comparison in next iteration 
      RG_EVENT := "AFTERSELCHANGE" 
      GoSub % RG_%hw%_func 
      return 
   } 

   if (code = GN_BEFOREEDIT) { 
      RG_EVENT := "BEFOREEDIT" 
      GoSub % RG_%hw%_func 
      return 
   } 

   if (code = GN_AFTEREDIT) { 
      RG_EVENT := "AFTEREDIT" 
      GoSub % RG_%hw%_func 
      return 
   } 

;    if (code = GN_BEFOREUPDATE) { 
;       RG_EVENT := "BEFOREUPDATE" 
;       GoSub % RG_%hw%_func 
;       return 
;    } 

;    if (code = GN_AFTERUPDATE) { 
;       RG_EVENT := "AFTERUPDATE" 
;       GoSub % RG_%hw%_func 
;       return 
;    } 

}


/*
Group: About
	o RaGrid 2.0.1.5 by By KetilO 
	o Module v1.0 by majkinetor.
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
/*