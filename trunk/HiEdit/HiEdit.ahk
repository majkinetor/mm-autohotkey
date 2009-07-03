; Title:	HiEdit
;			HiEdit is a multitabbed, ultra fast, large file edit control consuming very little memory. 
;			It can display non-printable characters in a readable format and can be used for any general 
;			purpose editing of text and birary files.
;--------------------------------------------------------------------------------------------
; Function: Add
;			Add control to the GUI.
;
; Parameters:
;			x,y,w,h	- Position of the control
;			style	- Space separated list of control styles, by default both scroll bars are visible. You can use numbers or style strings.
;			dllPath	- Path of the control dll, by default control is searched in the current folder.
;
; Styles:
;			HSCROLL, VSCROLL, TABBED, HILIGHT, TABBEDBTOP, TABBEDHRZSB, TABBEDBOTTOM
;
HE_Add(hwnd, x, y, w, h, style="HSCROLL VSCROLL", dllPath="HiEdit.dll"){
	global HE_MODULEID
	static WS_CLIPCHILDREN=0x2000000, WS_VISIBLE=0x10000000, WS_CHILD=0x40000000
	static HSCROLL=0x8 ,VSCROLL=0x10, TABBED=4, HILIGHT=0x20, TABBEDBTOP=0x1, TABBEDHRZSB=0x2 ,TABBEDBOTTOM=0x4, SINGLELINE=0x40, FILECHANGEALERT=0x80

	hStyle := 0
	loop, parse, style, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, , continue
		hStyle |= %A_LOOPFIELD%
	}

	if !init {
		HE_MODULEID := 1020
		DllCall("LoadLibrary", "str", dllPath)
		init := true 
	}

	hCtrl := DllCall("CreateWindowEx"
      , "Uint", 0x200            ; WS_EX_CLIENTEDGE
      , "str",  "HiEdit"         ; ClassName
      , "str",  szAppName      ; WindowName
      , "Uint", WS_CLIPCHILDREN | WS_CHILD | WS_VISIBLE | hStyle
      , "int",  x            ; Left
      , "int",  y            ; Top
      , "int",  w            ; Width
      , "int",  h            ; Height
      , "Uint", hwnd         ; hWndParent
      , "Uint", HE_MODULEID  ; hMenu
      , "Uint", 0            ; hInstance
      , "Uint", 0)
	HE_SetTabsImageList(hCtrl)
	return hCtrl
}

;----------------------------------------------------------------------------------------------------
; Function: AutoIndent
;			Sets the autoindent state
;
; Parameters:
;			pState	- TRUE or FALSE
;
HE_AutoIndent(hEdit, pState ) {
	static HEM_AUTOINDENT := 2042		;wParam=0,	lParam=fAutoIndent:TRUE/FALSE	
	SendMessage, HEM_AUTOINDENT, 0, pState,, ahk_id %hEdit%
	return errorlevel
}

;----------------------------------------------------------------------------------------------------
; Function:	CloseFile
;			Close file or all files
;
; Parameters: 
;			idx	- Index of the file to close. -2 to close ALL opened files, -1 to close current file (default)
;
HE_CloseFile(hEdit, idx=-1){
	static HEM_CLOSEFILE	:= 2026		;wParam=0,			
	SendMessage, HEM_CLOSEFILE, 0, idx,, ahk_id %hEdit%
	return errorlevel
}

;----------------------------------------------------------------------------------------------------
; Function:	ConvertCase  
;			Convert case of selected text
;
; Parameters:
;			case - can be "upper", "lower", "toggle" (default), "capitalize". 
;
; Returns:
;			Returns TRUE if successful, FALSE otherwise
;
HE_ConvertCase(hEdit, case="toggle") {
	static HEM_CONVERTCASE=2046		;EQU WM_USER+1022	;wParam=CC_UPPERCASE/CC_LOWERCASE/CC_TOGGLECASE,lParam = -1	 :Returns TRUE if successful/FALSE otherwise
	static cc_upper=0, cc_lower=1, cc_toggle=2, cc_capitalize=3
	SendMessage, HEM_CONVERTCASE, cc_%case%, -1,, ahk_id %hEdit% 
	Return ErrorLevel
}

;----------------------------------------------------------------------------------------------------
; Function:	FindText
;			Find desired text in the control
; 
; Parameters:
;			sText	- Text to be searched for.
;			cpMin	- Start searching at this character position. By default 0.
;			cpMax	- End searching at this character position. By default -1. 
;					  When searching backward, cpMin must be equal to or greater than cpMax. 
;					  When searching forward, a value of –1 in cpMax extends the search range to the end of the text.
;			flags	- Space separated combination of search flags: "WHOLEWORD" (or "w") "MATCHCASE" (or "c")
;
; Returns:	
;			The zero-based character position of the next match, or -1 if there are no more matches.
;	
HE_FindText(hEdit, sText, cpMin=0, cpMax=-1, flags="") { 
	static EM_FINDTEXT=1080,WHOLEWORD=2,MATCHCASE=4, c=4, w=2		 ;WM_USER + 56
	hFlags := 0
	loop, parse, flags, %A_Tab%%A_Space%,%A_Space%%A_Tab%
		if (A_LoopField != "")
			hFlags |= %A_LOOPFIELD%

	VarSetCapacity(FT, 12)
	NumPut(cpMin,  FT, 0)
	NumPut(cpMax,  FT, 4)
	NumPut(&sText, FT, 8)
	SendMessage, EM_FINDTEXT, hFlags, &FT,, ahk_id %hEdit% 
	
	Return (ErrorLevel = 4294967295) ? -1 : ErrorLevel 
}

;--------------------------------------------------------------------------------------------
; Function: GetColors
;			Get the control colors
;
; Parameters:
;			colors	- Set to the color name to return its value. Omit to return all colors in INI format
;
; Returns:
;			Color(s) or FAIL if unsuccessful. See <SetColors> for details about available colors
;
HE_GetColors(hEdit, color=""){
	static HEM_GETCOLORS := 2038
	static names := "Text,Back,SelText,ActSelBack,InSelBack,LineNumber,SelBarBack,NonPrintableBack,Number"
	
	VarSetCapacity(COLORS, 48, 0)
	SendMessage,HEM_GETCOLORS,0,&COLORS,,ahk_id %hEdit%
	ifEqual,ErrorLevel,FAIL, return FAIL

	fmt := A_FormatInteger
	SetFormat, integer, hex
	Loop, Parse, names, `,
		res .= A_LoopField "=" NumGet(COLORS, 4*(A_Index-1)) "`n"
	SetFormat,  integer, %fmt%
	return SubStr(res, 1, -1)
}

;----------------------------------------------------------------------------------------------------
; Function: GetCurrentFile
;			Get the index of the current file
;
HE_GetCurrentFile(hEdit){
	static HEM_GETCURRENTFILE	:= 2032	;wParam=0,			lParam = 0
	SendMessage, HEM_GETCURRENTFILE, 0, 0,, ahk_id %hEdit%
	return errorlevel
}

;----------------------------------------------------------------------------------------------------
; Function: GetFileCount
;			Returns count of open files.
;
HE_GetFileCount(hEdit){
	static HEM_GETFILECOUNT	:= 2029			;wParam=0,	lParam=0
	SendMessage, HEM_GETFILECOUNT, 0, 0,, ahk_id %hEdit%
	return errorlevel
}

;----------------------------------------------------------------------------------------------------
; Function: GetFileName
;			Get the file path.
;
; Parameters: 
;			idx	- Index of the file. -1 to get file path of the current file (default)
;
; Returns:
;			TRUE if successful, FALSE otherwise
;
HE_GetFileName(hEdit, idx=-1){
	static HEM_GETFILENAME		:= 2030		;wParam = lpszFileName, lParam = -1 for current file or dwFileIndex	:Returns TRUE if successful/FALSE otherwise
	VarSetCapacity(fileName, 512)
	SendMessage, HEM_GETFILENAME, &fileName, idx,, ahk_id %hEdit%
	return fileName
}

;----------------------------------------------------------------------------------------------------
; Function:	GetFirstVisibleLine  
;			Returns the zero-based index of the uppermost visible line.
;
HE_GetFirstVisibleLine(hEdit){
	static EM_GETFIRSTVISIBLELINE=206
	SendMessage, EM_GETFIRSTVISIBLELINE, 0, 0,, ahk_id %hEdit% 
	Return ErrorLevel 	
}

;----------------------------------------------------------------------------------------------------
; Function:	GetLine
;			Get the text of the desired line from the control
; 
; Parameters:
;			idx	- Zero-based index of the line. -1 means current line.
;
; Returns:	
;			The return value is the number of characters copied. 
;			The return value is empty string if the line number specified by the line parameter is greater than the number of lines in the HiEdit control
;
HE_GetLine(hEdit, idx=-1){
	static EM_GETLINE=196	  ;The return value is the number of characters copied. The return value is zero if the line number specified by the line parameter is greater than the number of lines in the HiEdit control
	if (idx = -1) 
		idx := HE_LineFromChar(hEdit, HE_LineIndex(hEdit))
	len := HE_LineLength(hEdit, idx)
	VarSetCapacity(txt, len), NumPut(len, txt)
	SendMessage, EM_GETLINE, idx, &txt,, ahk_id %hEdit% 
	if ErrorLevel = 0
		return
	VarSetCapacity(txt, -1)
	Return SubStr(txt, 1, ErrorLevel)
}

;----------------------------------------------------------------------------------------------------
; Function:	GetLineCount
;			Returns an integer specifying the number of lines in the HiEdit control. 
;			If no text is in the HiEdit control, the return value is 1. 
;
HE_GetLineCount(hEdit){
	static EM_GETLINECOUNT=186
   	SendMessage, EM_GETLINECOUNT, 0, 0,, ahk_id %hEdit%
	Return ErrorLevel
}

;--------------------------------------------------------------------------------------------------
; Function:	GetRedoData
;			Returns redo type and/or data for desired redo level. The same rules as in <GetUndoData>
;
HE_GetRedoData(hEdit, level){
	static HEM_GETREDODATA=2040		;wParam=Undo level (1 based),	lParam=lpUNDODATA	:Returns type of undo (UNDONAMEID)
	static UID_0="UNKNOWN",UID_1="TYPING",UID_2="DELETE",UID_3="DRAGDROP",UID_4="CUT",UID_5="PASTE",UID_6="SETTEXT",UID_7="REPLACESEL",UID_8="CLEAR",UID_9="BACKSPACE",UID_10="INDENT",UID_11="OUTDENT",UID_12="CODEPAGE",UID_13="CASE"
	static size = 128
	VarSetCapacity( RD, 8, 0), VarSetCapacity( buf, size ), NumPut(&buf, RD), NumPut(size, RD, 4)
	SendMessage, HEM_GETREDODATA, level, &RD,, ahk_id %hEdit%
	VarSetCapacity(buf, -1)
;	Return % buf
	Return % UID_%ErrorLevel%
}

;----------------------------------------------------------------------------------------------------
; Function:	GetSel
;			Get letfmost and/or rightmost character positions of the selection
; 
; Parameters:
;			info - "L" (default) means that function will return leftmost position.
;				   Set to "R" to get rightmost position. Set to "" to return both separated by dot,
;				   for instance, "12.195". To obtain L and R you can use for instance
;> 				     	s := floor(sel), e := SubStr(sel, strlen(s)+2)
;
; Returns:	
;			Depends on info parameter
;		
HE_GetSel(hEdit, info="L"){
	static EM_GETSEL=176
	
	VarSetCapacity(s, 4), VarSetCapacity(e, 4)
	SendMessage, EM_GETSEL, &s, &e,, ahk_id %hEdit% 
	l := NumGet(s), r := NumGet(e)
	ifEqual, info, L, return l
	ifEqual, info, R, return r
	Return l "." r
}

;----------------------------------------------------------------------------------------------------
; Function:	GetSelText
;			Returns selected text 
; 
HE_GetSelText(hEdit){
	static EM_GETSELTEXT = 1086		;Returns: the number of characters copied, not including the terminating null character.
	e := HE_GetSel(hEdit, "")
	s := floor(sel), e := SubStr(sel, strlen(s)+2)

	VarSetCapacity(buf, e-s+2)
	SendMessage, EM_GETSELTEXT, 0, &buf,, ahk_id %hEdit% 
	VarSetCapacity(buf, -1)
	Return buf
}

;----------------------------------------------------------------------------------------------------
; Function:	GetTextLength  
;			Returns the length of text, in characters.
;
HE_GetTextLength(hEdit) {
	static WM_GETTEXTLENGTH=14
	SendMessage, WM_GETTEXTLENGTH, 0, 0,, ahk_id %hEdit% 
	Return ErrorLevel 	
}

;----------------------------------------------------------------------------------------------------
; Function:	GetTextRange
;			Get range of characters from the control
;
; Parameters:
;			min	- Index of leftmost characther of the range. By default 0.
;			max - Index of rightmost characther of the range. -1 means last character in the control.
;
HE_GetTextRange(hEdit, min=0, max=-1){
	static EM_GETTEXTRANGE=1099			;Returns: The number of characters copied, not including the terminating null character.
	if (max=-1)
		max := HE_GetTextLength(hEdit)
	VarSetCapacity(buf, max-min+2)
	VarSetCapacity(RNG, 12), NumPut(min, RNG), NumPut(max, RNG, 4), NumPut(&buf, RNG, 8)
	SendMessage, EM_GETTEXTRANGE, 0, &RNG,, ahk_id %hEdit% 
	VarSetCapacity(buf, -1)
	Return buf
}

;---------------------------------------------------------------------------
; Function:	GetUndoData
;			Returns undo type and/or data for desired undo level.
;
; Parameters:
;			level - Undo level
;
; Types:
;			UNKNOWN		-		The type of undo action is unknown.
;			TYPING		-		Typing operation.
;			DELETE		-		Delete operation.
;			DRAGDROP	-		Drag-and-drop operation.
;			CUT			-		Cut operation.
;			PASTE		-		Paste operation.
;			SETTEXT		-		WM_SETTEXT message was used to set the control text
;			REPLACESEL	-		EM_REPLACESEL message was used to insert text
;			CLEAR		-		Delete selected text
;			BACKSPACE	-		Back Space Operation
;			INDENT		-		Increase Indent
;			OUTDENT		-		Decrease Indent
;			CODEPAGE	-		Convert codepage
;			CASE		-		Convert case
;
HE_GetUndoData(hEdit, level){
	static HEM_GETUNDODATA=2039		;wParam=Undo level (1 based),	lParam=lpUNDODATA	:Returns type of undo (UNDONAMEID)
	static UID_0="UNKNOWN",UID_1="TYPING",UID_2="DELETE",UID_3="DRAGDROP",UID_4="CUT",UID_5="PASTE",UID_6="SETTEXT",UID_7="REPLACESEL",UID_8="CLEAR",UID_9="BACKSPACE",UID_10="INDENT",UID_11="OUTDENT",UID_12="CODEPAGE",UID_13="CASE"
	static size = 128
	VarSetCapacity( UD, 8, 0), VarSetCapacity( buf, size ), NumPut(&buf, UD), NumPut(size, UD, 4)
	SendMessage, HEM_GETUNDODATA, level, &UD,, ahk_id %hEdit%
	VarSetCapacity(buf, -1)
	Return % UID_%ErrorLevel%
}



;----------------------------------------------------------------------------------------------------
; Function:	LineFromChar
;			Returns line number of the line containing specific character index.
;
; Parameters:
;			ich	- The character index of the character contained in the line whose number is to be retrieved. If the ich parameter is -1, either the line number of the current line (the line containing the caret) is retrieved or, if there is a selection, the line number of the line containing the beginning of the selection is retrieved. 
;	
; Returns:
;			The zero-based line number of the line containing the character index specified by ich. 
;
HE_LineFromChar(hEdit, ich) {
	static EM_LINEFROMCHAR=201
   	SendMessage, EM_LINEFROMCHAR, ich, 0,, ahk_id %hEdit%
	Return ErrorLevel
}

;----------------------------------------------------------------------------------------------------
; Function:	LineIndex
;			Returns the character index of the line.
;
; Parameters:
;			idx	- Line number for which to retreive character index. -1 (default) means current line.
;	
; Returns:
;			The character index of the line specified in the idx parameter, or -1 if the specified line number is greater than the number of lines.
HE_LineIndex(hedit, idx=-1) {
	static EM_LINEINDEX=187
 	SendMessage, EM_LINEINDEX, idx, 0,, ahk_id %hEdit% 
	Return ErrorLevel
}

;----------------------------------------------------------------------------------------------------
; Function:	LineLength
;			Returns the lenght of the line.
;
; Parameters:
;			idx	- Line number for which to retreive line length. -1 (default) means current line.
;	
; Returns:
;			the length, in characters, of the line
;
HE_LineLength(hEdit, idx=-1) {
	static EM_LINELENGTH=193
	SendMessage, EM_LINELENGTH, He_LineIndex(hEdit, idx) , 0,, ahk_id %hEdit% 
	Return ErrorLevel
}

;--------------------------------------------------------------------------------------------
; Function: LineNumbersBar
;			Sets the line numbers bar state and looks.
;
; Parameters:
;			state	- Can be "show", "hide", "automaxsize", "autosize"
;			linw	- Line numbers width (by default 40)
;			selw	- Selection bar width (by default 10)
;
HE_LineNumbersBar( hEdit, state="show", linw=40, selw=10 ) {
	static HEM_LINENUMBERSBAR := 2036		;EQU WM_USER+1012		;wParam=LNB_HIDE/LNB_SHOW/LNB_AUTOSIZE,			lParam=HIWORD:Selection bar width , LOWWORD:Line numbers width
	static LNB_HIDE=0, LNB_SHOW=1, LNB_AUTOMAXSIZE=2, LNB_AUTOSIZE=4
	
	if state is not Integer
		state := LNB_%state%
	SendMessage, HEM_LINENUMBERSBAR,state,selw<<16 | linw,,ahk_id %hEdit%
	return errorlevel
}

;----------------------------------------------------------------------------------------------------
; Function:	NewFile
;			Opens new tab.
HE_NewFile(hEdit){
	static HEM_NEWFILE	:= 2024		;wParam=0,	lParam=0
	SendMessage, HEM_NEWFILE, 0, 0,, ahk_id %hEdit%
	return errorlevel
}

;----------------------------------------------------------------------------------------------------
; Function:	OpenFile
;			Open file in new tab
;
; Parameters: 
;			pFileName	- Path of the file to be opened
;			flag		- Set to TRUE to create new file if pFileName doesn't exist. 
;						  If set to FALSE, function fails if the file doesn't exist (default).
; Returns:
;			TRUE if successful/FALSE otherwise
;
HE_OpenFile(hEdit, pFileName, flag=0){
	static HEM_OPENFILE	:= 2025		;wParam=0,				lParam=lpszFileName	 Returns TRUE if successful/FALSE otherwise
	SendMessage, HEM_OPENFILE, flag, &pFileName,, ahk_id %hEdit%
	return errorlevel
}

;----------------------------------------------------------------------------------------------------
; Function:	Redo
;			Do redo operation
;
; Returns:
;			TRUE if the Redo operation succeeds, FALSE otherwise
HE_Redo(hEdit) { 
	static EM_REDO := 1108 
	SendMessage, EM_REDO,,,, ahk_id %hEdit%    
	return ErrorLevel
} 
;----------------------------------------------------------------------------------------------------
; Function:	ReloadFile
;			Reload file
;
; Parameters: 
;			idx	- Index of the file to reload. -1 to reload current file (default)
;
HE_ReloadFile(hEdit, idx=-1) {
	static HEM_RELOADFILE=2027	;EQU WM_USER+1003	;wParam=0,	lParam = -1 for current file
	SendMessage, HEM_RELOADFILE, 0, idx,, ahk_id %hEdit% 
	Return ErrorLevel 	
}

;----------------------------------------------------------------------------------------------------
; Function:	ReplaceSel
;			Replace selection with desired text
;
; Parameters:
;			text - Text to replace selection with.
;
HE_ReplaceSel(hEdit, text=""){
	static  EM_REPLACESEL=194
	
	SendMessage, EM_REPLACESEL, 0, &text,, ahk_id %hEdit% 
	Return ErrorLevel
}

;----------------------------------------------------------------------------------------------------
; Function: SaveFile
;			Save file to disk
;
; Parameters: 
;			pFileName	- File name.
;			idx			- Index of the file to save. -1 to save current file (default)
;
; Returns:
;			TRUE if successful, FALSE otherwise
;			
HE_SaveFile(hEdit, pFileName, idx=-1){
	static HEM_SAVEFILE	:= 2028		;wParam=lpszFileName,					lParam = -1 for current file or dwFileIndex	:Returns 
	
	SendMessage, HEM_SAVEFILE, &pFileName, idx,, ahk_id %hEdit%
	return errorlevel
}

;----------------------------------------------------------------------------------------------------
; Function:	ScrollCaret
;			Scroll content of control until caret is visible.
;
HE_ScrollCaret(hEdit){
	static EM_SCROLLCARET=183
	SendMessage, EM_SCROLLCARET, 0, 0,, ahk_id %hEdit% 
	Return ErrorLevel
}

;--------------------------------------------------------------------------------------------
; Function: SetColors
;			Set the control colors
;
; Parameters:
;			colors	- Any subset of available color options in INI format (array of NAME=COLOR lines). Skiped colors will not be changed.
;			fRdraw	- Set to TRUE to redraw control
;
; Colors:
;	Text			 - Normal Text Color
;	Back			 - Editor Back Color
;	SelText			 - Selected Text Color
;	ActSelBack		 - Active Selection Back Color
;	InSelBack		 - Inactive Selection Back Color
;	LineNumber		 - Line Numbers Color
;	SelBarBack		 - Selection Bar Back Color
;	NonPrintableBack - 0 - 31 special non printable chars
;	Number			 - Number Color	   
;
HE_SetColors(hEdit, colors, fRedraw=true){
	static HEM_SETCOLORS := 2037
	static names := "Text,Back,SelText,ActSelBack,InSelBack,LineNumber,SelBarBack,NonPrintableBack,Operator,Number,Comment,String"

 ;set colors to current value by default, so that does that are skipped remain
	current := HE_GetColors(hEdit)
	Loop, parse, current, `n
		j := InStr(A_LoopField, "="), clr := SubStr(A_LoopField, 1, j-1), val := SubStr(A_LoopField, j+1),  n%clr% := val

 ;parse new colors
	at := A_AutoTrim
	AutoTrim,  on
    Loop, parse, colors, `n, `n
	{
		color = %A_LoopField%
		ifEqual, color,,continue
		name := SubStr(color, 1, i:=InStr(color, "=")-1),  val := SubStr(color, i+2)
		name = %name%
		val = %val%
		if name not in %names%
			return "Invalid color name: '" name "'"
		if val is not Integer
			return "Invalid color value: '" val "'"
		n%name%	:= val
	}
	AutoTrim, %at%


	VarSetCapacity(COLORS, 36, 0)
	NumPut(nText			, COLORS, 0)	;NormalTextColor
	NumPut(nBack			, COLORS, 4) 	;EditorBkColor
	NumPut(nSelText			, COLORS, 8) 	;SelectionForeColor
	NumPut(nActSelBack		, COLORS, 12)	;ActiveSelectionBkColor
	NumPut(nInSelBack		, COLORS, 16)	;InactiveSelectionBkColor
	NumPut(nLineNumber		, COLORS, 20)	;LineNumberColor
	NumPut(nSelBarBack		, COLORS, 24)	;SelBarBkColor   
	NumPut(nNonPrintableBack, COLORS, 28)	;NonPrintableBackColor		   			
	NumPut(nNumber			, COLORS, 32)	;NumberColor				
	SendMessage,HEM_SETCOLORS, &COLORS, fRedraw,,ahk_id %hEdit%
	return ErrorLevel
}

;----------------------------------------------------------------------------------------------------
; Function: SetCurrentFile
;			Set the the current file
;
; Parameters:
;			idx	- New file index to set as current.
HE_SetCurrentFile(hEdit, idx){
	static HEM_SETCURRENTFILE	:= 2033		;wParam=0,	lParam = dwFileIndex
	SendMessage, HEM_SETCURRENTFILE, 0, idx,, ahk_id %hEdit%
	return errorlevel
}

;----------------------------------------------------------------------------------------------------
; Function: SetEvents
;			Set notification events
;
; Parameters:
;			func	- Subroutine that will be called on events.
;			e		- White space separated list of events to monitor (by default "selchange").
;
; Globals:
;			HE_HWND		- Control handle
;			HE_EVENT	- Specifies event that occurred. Event must be registered to be able to monitor them. Events "tabmclick" and "filechange" are registered automatically.
;			HE_INFO		- String specifying event info.	You can access individual info elements as INFO_Start
;			HE_RESULT	- Placeholder for notification result, if its needed.
;
; Events & Infos:
;			SelChange	- S<start> E<end> L<line>	[t|*] (t if tab changed, * if text changed)
;			Key			- key pressed
;			Mouse		- x<xcoord> y<ycoord> v<virtual_key>
;			Scroll		- Set HE_Result to 1 to prevent standard menu from showing
;			ContextMenu	- 			
;			FileChange	- <file_index>	(file is changed outside of the application)
;			Tabmclick	- (middle button click over tab)
;
; Returns:
;			"OK" if succesiful, error string otherwise
;
HE_SetEvents(hEdit, func, e="selchange"){
	local old, hmask
	static ENM_KEYEVENTS = 0x10000, ENM_MOUSEEVENTS = 0x20000, ENM_SCROLLEVENTS = 0x8, ENM_SELCHANGEEVENTS = 0x80000, ENM_CONTEXTMENUEVENTS=0x20
	static EM_SETEVENTMASK = 1093, events="key,mouse,scroll,selchange,contextmenu"

	if !IsLabel(func)
		return "Err: label doesn't exist`n`n" func

	hmask := 0
	loop, parse, e, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, , continue
		if A_LoopField not in %events%
			return "Err: unknown event - '" A_LoopField "'"
		hmask |= ENM_%A_LOOPFIELD%EVENTS
	}
	SendMessage, EM_SETEVENTMASK, 0, hMask,, ahk_id %hEdit%

	old := OnMessage(0x4E, "HE_onNotify")
	if (old != "HE_onNotify")
		HE_oldNotify := RegisterCallback(old)

	hEdit += 0
	HE_%hEdit%_func	 := func
	return "OK"
}


HE_onNotify(wparam, lparam, msg, hwnd) {
	local code, hw, idFrom, m, l, w
	static EN_TABMCLICK=0x1000, EN_FILECHANGE=0x1001, EN_SELCHANGE = 0x702, EN_MSGFILTER = 0x700

	idFrom :=  NumGet(lparam+4)   ; and its ID 
	if (idFrom != HE_MODULEID)
		return HE_oldNotify ? DllCall(HE_oldNotify, "uint", wparam, "uint", lparam, "uint", msg, "uint", hwnd) : ""

  ;NMHDR 
	hw	   :=  NumGet(lparam+0)   ;control sending the message - this HiEdit
	code   :=  NumGet(lparam+8)		;- 4294967296

    HE_HWND := hw
	HE_EVENT := HE_INFO := HE_Result := ""
	if (code = EN_TABMCLICK) {
		HE_EVENT := "tabmclick"
		GoSub % HE_%hw%_func
		return
	}
										
	if (code = EN_FILECHANGE) {
		HE_EVENT := "filechange", HE_INFO := NumGet(lparam+12)
		GoSub % HE_%hw%_func
		return
	}

	if (code = EN_SELCHANGE) {
		HE_EVENT := "selchange",  m := NumGet(lparam+20, 0, "Short")=16,  l := NumGet(lparam+30) && !m
		HE_INFO_Start := NumGet(lparam+12)
		HE_INFO_End  := NumGet(lparam+16)
		HE_INFO_Line := NumGet(lparam+22)
		HE_INFO_Flag := (m ? "t" : "") (l ? "*" : "")
		HE_INFO := "S" HE_INFO_Start " E" HE_INFO_End " L" HE_INFO_Line " " HE_INFO_Flag 
		GoSub % HE_%hw%_func
		return
	}

	if (code=EN_MSGFILTER) {
		m := NumGet(lparam+12), w := NumGet(lparam+16), l := NumGet(lparam+20)
		if m between 0x201 AND 0x209	;mouse messges, don't report WM_MOUSEMOVE=0x200
			 HE_EVENT := "mouse", HE_INFO := "x" l & 0xFFFF " y" (l >> 16) " v" w
		else if m = 0x102				;WM_CHAR
			 HE_EVENT := "key", HE_INFO := chr(w)
		else if m = 0x7B				; WM_CONTEXTMENU 
			 HE_EVENT := "contextmenu"
		else if m = 0x20A				 ;WM_MOUSEWHEEL
			 HE_EVENT := "scroll"

		if HE_EVENT
			GoSub % HE_%hw%_func
		return HE_Result
	}
}

;--------------------------------------------------------------------------------------------
; Function: SetFont
;			Sets the control font
;
; Parameters:
;			pFont	- AHK font definition: "Style, FontName"
;
HE_SetFont(hEdit, pFont="") { 
   local height, weight, italic, underline, strikeout , nCharSet, fontFace 
   local hFont, LogPixels
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
   SendMessage,WM_SETFONT,hFont,TRUE,,ahk_id %hEdit%
   return ErrorLevel
}

;----------------------------------------------------------------------------------------------------
; Function:	SetKeywordFile
;			Set syntax highlighting.
;
; Parameters:
;			pFile	- Path to .hes file
;
; Keyword File:
;			[ext1,ext2,...,extN] - Each keyword definiton block starts with list of extensions in angular brackets.
;			0xSSRRGGBB=word1 word2 ... wordN - Color keywords on this line with BBGGRR color. SS is 00 by default.
;			delimiters	 - High byte in the color (0x01xxxxxx) refers to delimiters. Delimiters are added from ALL sections for a file extension.
;			string chars - A & at the end of keyword specifies a string char. For ex. "& means that everything enclosed in two " is a string
;			comments keyword - A + at the end of keyword specifies a comment char/keyword. For ex. //+ means that everything that follows is a comment.
;							   Multiline comments are not supported yet. A "-" at the end of keyword specifies that ALL text up to the end of line will be painted using the color specified UNLESS a comment indicator is found.
;			;	- Line comment
;
HE_SetKeywordFile( pFile ){
	return DllCall("HiEdit.dll\SetKeywordFile", "str", pFile)
}

;----------------------------------------------------------------------------------------------------
; Function:	SetSel
;			Set the selection 
; 
; Parameters:
;			nStart	- Starting character position of the selection. Set -1 to remove current selection.
;			nEnd	- Ending character position of the selection. Set -1 to use position of the last character in the control.
;					  Omit to return cursor position
;	
HE_SetSel(hEdit, nStart=0, nEnd="") {
	static EM_SETSEL=0x0B1

	ifEqual, nEnd, -1, SetEnv, nEnd, %nStart%
	SendMessage, EM_SETSEL, nStart, nEnd,, ahk_id %hEdit% 
	Return ErrorLevel 	
}

;----------------------------------------------------------------------------------------------------
; Function: SetTabWidth
;			Sets the tab width
;
; Parameters:
;			pWidth	- Tab width in characters
;			pRedraw	- Set to true to redraw control (default)
;
HE_SetTabWidth(hEdit, pWidth, pRedraw=true){
	static HEM_SETTABWIDTH := 2041		;wParam=nChars,		lParam=fRedraw:TRUE/FALSE
	SendMessage, HEM_SETTABWIDTH, pWidth, pRedraw,, ahk_id %hEdit%
	return errorlevel
}

;--------------------------------------------------------------------------------------------
; Function: SetTabsImageList
;			Sets the image list of the tab navigation toolbar
;
; Parameters:
;			pImg	- .BMP file with image list. Omit this parameter to use default image list.
;
HE_SetTabsImageList(hEdit, pImg="") {
	static LR_LOADFROMFILE		:= 0x10
		,  LR_CREATEDIBSECTION	:= 0x2000
		,  HEM_SETTABSIMAGELIST := 2043
		,  toolbarBMP			:= "424de60000000000000076000000280000001c00000007000000010004000000000070000000000000000000000010000000000000000000000000008000008000000080800080000000800080008080000080808000c0c0c0000000ff0000ff000000ffff00ff000000ff00ff00ffff0000ffffff00fddddfdddddfdddfdddddfddddfd0000fdddffddddffdddffddddffdddfd0000fddfffdddfffdddfffdddfffddfd0000fdffffddffffdddffffddffffdfd0000fddfffdddfffdddfffdddfffddfd0000fdddffddddffdddffddddffdddfd0000fddddfdddddfdddfdddddfddddfd0000"
	if (pImg = "")	{
		deleteFile := true
		pImg := "___he_bar.bmp"
		WriteFile(pImg, toolbarBMP)
	}
	hImlTabs := DllCall("comctl32.dll\ImageList_LoadImage", "uint", 0
			, "str", pImg
			, "int", 7, "int", 4
			, "uint", 0x0FF00FF
			, "uint", IMAGE_BITMAP
			, "uint", LR_CREATEDIBSECTION | LR_LOADFROMFILE )
	if (deleteFile) 
		FileDelete, %pImg%
	SendMessage,HEM_SETTABSIMAGELIST,0,hImlTabs,,ahk_id %hEdit%
}

;----------------------------------------------------------------------------------------------------
; Function:	ShowFileList
;			Show popup menu containg list of open files.
; 
; Parameters:
;			x, y	- Position of popup window
;
HE_ShowFileList(hEdit, x=0, y=0){
	static HEM_SHOWFILELIST	:= 2044	    ;EQU WM_USER+1020		;wParam=X pos,									lParam=Y pos
	SendMessage, HEM_SHOWFILELIST, x, y,, ahk_id %hEdit%
}

;----------------------------------------------------------------------------------------------------
; Function:	Undo
;			Do undo operation
;
; Returns:
;			TRUE if the Undo operation succeeds, FALSE otherwise
HE_Undo(hEdit) { 
	static WM_UNDO := 772 
	SendMessage, WM_UNDO,,,, ahk_id %hEdit% 
	return ErrorLevel
}

;========================================== PRIVATE ===============================================================

WriteFile(file,data) { 
   Handle :=  DllCall("CreateFile","str",file,"Uint",0x40000000 ,"Uint",0,"UInt",0,"UInt",4,"Uint",0,"UInt",0) 
   Loop{ 
     if strlen(data) = 0 
        break 
     StringLeft, Hex, data, 2          
     StringTrimLeft, data, data, 2  
     Hex = 0x%Hex% 
     DllCall("WriteFile","UInt", Handle,"UChar *", Hex ,"UInt",1,"UInt *",UnusedVariable,"UInt",0) 
   } 
 
   DllCall("CloseHandle", "Uint", Handle) 
   return 
}

;--------------------------------------------------------------------------------------------
;Group: Example
;> Gui, +LastFound 
;> hwnd := WinExist() 
;> 
;> hEdit := HE_Add(hwnd,0,0,600,500) 
;> Gui, SHow, w600 h500 
;> 
;> #include HiEdit.ahk
;--------------------------------------------------------------------------------------------

;Group: About
;	o HiEdit control is copyright of Antonis Kyprianou (aka akyprian). See http://www.winasm.net
;	o AHK wrapper ver 3.0.0.1-5 is copyright of Miodrag Milic (aka majkinetor). See http://www.autohotkey.com/forum/topic17230.html
;	o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.