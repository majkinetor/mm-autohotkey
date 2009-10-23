/*
 Function:		Add
				Create control.
 
 Parameters:
				HParent	- Handle of the parent of the control.
				X..H	- Position.
				Style	- White space separated list of control styles. Any integer style or one of the style keywords (see below).
						  Invalid styles are skipped.

 Styles:
     DISABLENOSCROLL - Disables scroll bars instead of hiding them when they are not needed.
     BORDER			- Displays the control with a sunken border style so that the rich edit control appears recessed into its parent window.
	 HIDDEN			- Don't show the control.

     AUTOHSCROLL	- Automatically scrolls text to the right by 10 characters when the user types a character at the end of the line. When the user presses the ENTER key, the control scrolls all text back to position zero.
     AUTOVSCROLL	- Automatically scrolls text up one page when the user presses the ENTER key on the last line.
     CENTER			- Centers text in a single-line or multiline edit control.
     LEFT			- Left aligns text.
     MULTILINE		- Designates a multiline edit control. The default is single-line edit control.
     NOHIDESEL		- Negates the default behavior for an edit control. The default behavior hides the selection when the control loses the input focus and inverts the selection when the control receives the input focus. If you specify ES_NOHIDESEL, the selected text is inverted, even if the control does not have the focus.
     NUMBER			- Allows only digits to be entered into the edit control.
     PASSWORD		- Displays an asterisk (*) for each character typed into the edit control. This style is valid only for single-line edit controls.
     READONLY		- Prevents the user from typing or editing text in the edit control.
     RIGHT			- Right aligns text in a single-line or multiline edit control.
     WANTRETURN		- Specifies that a carriage return be inserted when the user presses the ENTER key while entering text into a multiline edit control in a dialog box. If you do not specify this style, pressing the ENTER key has the same effect as pressing the dialog box's default push button. This style has no effect on a single-line edit control.			

 Returns:
	Control's handle or 0. Error message on problem.
 */
RichEdit_Add(HParent, X="", Y="", W="", H="", Style="")  {
  static WS_CLIPCHILDREN=0x2000000, WS_VISIBLE=0x10000000, WS_CHILD=0x40000000
		,ES_DISABLENOSCROLL=0x2000, EX_BORDER=0x200
		,ES_LEFT=0, ES_CENTER=1, ES_RIGHT=2, ES_MULTILINE=4, ES_AUTOVSCROLL=0x40, ES_AUTOHSCROLL=0x80, ES_NOHIDESEL=0x100, ES_NUMBER=0x2000, ES_PASSWORD=0x20,ES_READONLY=0x800,ES_WANTRETURN=0x1000
		,ES_HSCROLL=0x100000, ES_VSCROLL=0x200000, ES_SCROLL=0x300000 
		,MODULEID

	if !MODULEID
		init := DllCall("LoadLibrary", "Str", "Msftedit.dll", "Uint"), MODULEID := 091009

	hStyle := InStr(" " Style " ", " hidden ") ? 0 : WS_VISIBLE,  hExStyle := 0
	Loop, parse, Style, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, ,continue
		else if A_LoopField is integer
			 hStyle |= A_LoopField
		else if (v := ES_%A_LOOPFIELD%)
			 hStyle |= v
		else if (v := EX_%A_LOOPFIELD%)
			 hExStyle |= v
		else continue
	}
	/*
		class   := A_OSVersion = "WIN_95" ? "RICHEDIT" : "RichEdit20A"
		hModule := DllCall("LoadLibrary", "str",  (class="RichEdit20A" ? "riched20.dll" : "riched32.dll")  )

		http://www.soulfree.net/tag/391
		RE version - DLL (hModule)- class
		1.0	       - Riched32.dll - RichEdit
		2.0	       - Riched20.dll - RichEdit20A or RichEdit20W (ANSI or Unicode window classes)
		3.0	       - Riched20.dll - ?
		4.1	       - Msftedit.dll - RICHEDIT50W

		2.0 not compatible w/ EM_CONVPOSITION, EM_GETIMECOLOR, EM_GETIMEOPTIONS, EM_GETPUNCTUATION,
		  EM_GETWORDWRAPMODE, EM_SETIMECOLOR, EM_SETIMEOPTIONS, EM_SETPUNCTUATION, EM_SETWORDWRAPMODE

		Windows XP SP1	Includes Rich Edit 4.1, Rich Edit 3.0, and a Rich Edit 1.0 emulator.
		Windows XP	Includes Rich Edit 3.0 with a Rich Edit 1.0 emulator.
		Windows Me	Includes Rich Edit 1.0 and 3.0.
		Windows 2000	Includes Rich Edit 3.0 with a Rich Edit 1.0 emulator.
		Windows NT 4.0	Includes Rich Edit 1.0 and 2.0.
		Windows 98	Includes Rich Edit 1.0 and 2.0.
		Windows 95	Includes only Rich Edit 1.0. However, Riched20.dll is compatible with Windows 95 and may be installed by an application that requires it.
     */
	
	hCtrl := DllCall("CreateWindowEx"
                  , "Uint", hExStyle			; ExStyle
                  , "str" , "RICHEDIT50W"		; ClassName
                  , "str" , ""					; WindowName
                  , "Uint", WS_CHILD | hStyle	; Edit Style
                  , "int" , X					; Left
                  , "int" , Y					; Top
                  , "int" , W					; Width
                  , "int" , H					; Height
                  , "Uint", HParent				; hWndParent
                  , "Uint", MODULEID			; hMenu 
                  , "Uint", 0					; hInstance
                  , "Uint", 0, "Uint")			; must return uint.
	return hCtrl
}

/*
  Function:  AutoUrlDetect
 			Enable, disable, or toggle automatic detection of URLs by a rich edit control.
 
  Parameters:
 			flag - Specify *TRUE* to enable automatic URL detection or *FALSE* to disable it. Specify
             *"Toggle"* to toggle its current state. Leave flag parameter blank to not make any
             changes, but instead only return its current state.
 
  Returns:
 			If auto-URL detection is active, the return value is 1.
 			If auto-URL detection is inactive, the return value is 0.
 
  Example:
 > MsgBox, % RichEdit_AutoUrlDetect( hRichEdit, true )
 > MsgBox, % RichEdit_AutoUrlDetect( hRichEdit, "Toggle" )
 > MsgBox, % "Current state: " RichEdit_AutoUrlDetect( hRichEdit )
 */
RichEdit_AutoUrlDetect( hCtrl, flag="-" )  {
  static EM_AUTOURLDETECT=91,EM_GETAUTOURLDETECT=92,WM_USER=0x400
  If flag in -,Toggle
  {
    SendMessage, WM_USER | EM_GETAUTOURLDETECT, 0,0,, ahk_id %hCtrl%
    flag := flag="Toggle" ? !ERRORLEVEL : ERRORLEVEL
  }
  If flag in 0,1,Toggle
    SendMessage, WM_USER | EM_AUTOURLDETECT, %flag%,0,, ahk_id %hCtrl%
  return flag
}

/*
  Function: GetRedo
 			Determine whether there are any actions in the control redo queue, and
      optionally retrieve the type of the next redo action.
 
  Parameters:
 			name - This optional parameter is the name of the variable in which to store the
             type of redo action, if any.
 
  Name Types:
      UNKNOWN - The type of undo action is unknown.
      TYPING - Typing operation.
      DELETE - Delete operation.
      DRAGDROP - Drag-and-drop operation.
      CUT - Cut operation.
      PASTE - Paste operation.
 
  Returns:
 			If there are actions in the control redo queue, the return value is a nonzero value.
 			If the redo queue is empty, the return value is zero.
 
  Related:
      <Redo>, <GetUndo>, <Undo>, <SetUndoLimit>
 
  Example:
 > If RichEdit_GetRedo( hRichEdit, name )
 >   MsgBox, The next redo is a %name% type
 > Else
 >   MsgBox, Nothing left to redo.
 */
RichEdit_GetRedo(hCtrl, ByRef name="-")  {
  static EM_CANREDO=85,EM_GETREDONAME=87,WM_USER=0x400
        ,UIDs="UNKNOWN,TYPING,DELETE,DRAGDROP,CUT,PASTE"
  SendMessage, WM_USER | EM_CANREDO, 0,0,, ahk_id %hCtrl%
  nRedo := ERRORLEVEL
  
  If ( nRedo && name != "-" )  {
    SendMessage, WM_USER | EM_GETREDONAME, 0,0,, ahk_id %hCtrl%
    Loop, Parse, UIDs, `,
      If (A_Index - 1 = errorlevel)  {
        name := A_LoopField
        break
      }
  }
  return nRedo
}

/*
  Function: GetSel
 			Retrieve the starting and ending character positions of the selection in a rich edit control.
 
  Parameters:
 			cpMin -	The optional name of the variable in which to store the character position index immediately
              preceding the first character in the range.
 			cpMin -	The optional name of the variable in which to store the character position index immediately
              following the last character in the range.
 
  Returns:
 			Returns the number of characters selected, not including the terminating null character.
 
  Related:
      <GetText>, <GetTextLength>, <SetSel>, <SetText>, <LineFromChar>
 
  Example:
 > If !RichEdit_GetSel( hRichEdit ) {
 >   MsgBox, No characters selected.
 >   return
 > }
 > count := RichEdit_GetSel( hRichEdit, min, max )
 > MsgBox,,%count% char's selected, Selected from: %min%-%max%
 */
RichEdit_GetSel(hCtrl, ByRef cpMin="", ByRef cpMax="" )  {
  static WM_USER=0x400,EM_EXGETSEL=52
  VarSetCapacity(CHARRANGE, 8, 0)
  SendMessage, WM_USER | EM_EXGETSEL, 0,&CHARRANGE,, ahk_id %hCtrl%
  cpMin := NumGet(CHARRANGE, 0, "Int"), cpMax := NumGet(CHARRANGE, 4, "Int")
  return cpMax - cpMin
}

/*
 Function: GetText
			Retrieves a specified range of characters from a rich edit control.

 Parameters:
			cpMin -	Beginning of range of characters to retrieve.
			cpMax -	End of range of characters to retrieve
			codepage - If *UNICODE* or *U*, this optional parameter will use unicode code page
                in the translation. Otherwise it will default to using ansi.

 Note:
     If the *cpMin* and *cpMax* are omitted, the current selection is retrieved.
     The range includes everything if *cpMin* is 0 and *cpMax* is –1.

 Returns:
			Returns the retrieved text.

 Related:
     <GetSel>, <SetText>, <SetSel>, <GetTextLength>

 Example:
 > RichEdit_GetText( hRichEdit ) ; get current selection
 > RichEdit_GetText( hRichEdit, 0, -1 ) ; get all
 > RichEdit_GetText( hRichEdit, 4, 10 ) ; get range
 */
RichEdit_GetText(hCtrl, cpMin="-", cpMax="-", codepage="")  {
  static WM_USER=0x400,EM_EXGETSEL=52,EM_GETTEXTEX=94,EM_GETTEXTRANGE=75,GT_SELECTION=2
  ; GT_ALL=0,CP_ACP=0
  bufferLength := RichEdit_GetTextLength(hCtrl, "CLOSE", "UNICODE" )
  If (cpMin="-" && cpMax="-")
    MODE := GT_SELECTION, cpMin:=cpMax:=""

  Else If (cpMin=0 && cpMax=-1)
    MODE := GT_ALL      , cpMin:=cpMax:=""

  Else If cpMin is integer
  {
    If cpMax is integer
    {
      VarSetCapacity(lpwstr,bufferLength,0), VarSetCapacity(TEXTRANGE, 12, 0)
      NumPut(cpMin, TEXTRANGE, 0, "UInt")
      NumPut(cpMax, TEXTRANGE, 4, "UInt"), NumPut(&lpwstr, TEXTRANGE, 8, "UInt")
      SendMessage, WM_USER | EM_GETTEXTRANGE, 0,&TEXTRANGE,, ahk_id %hCtrl%

      ; If not unicode, return ansi from string pointer..
      If !DllCall("IsWindowUnicode", "UInt", hCtrl)
        return DllCall("MulDiv", "Int",&lpwstr, "Int",1, "Int",1, "str")

      ;..else, convert Unicode to Ansi..
      nSz:=DllCall("lstrlenW","UInt",&lpwstr) + 1, VarSetCapacity( Ansi,nSz )
      DllCall("WideCharToMultiByte" , "Int",0       , "Int",0
                                    ,"UInt",&LPWSTR ,"UInt",nSz+1
                                    , "Str",ansi    ,"UInt",nSz+1
                                    , "Int",0       , "Int",0 )
      return ansi
    }
  }
  Else
    return "", errorlevel := "ERROR: Invalid use of cpMin or cpMax parameter."

  VarSetCapacity(GETTEXTEX, 20, 0)          , VarSetCapacity(BUFFER, bufferLength, 0)
  NumPut(bufferLength, GETTEXTEX, 0, "UInt"), NumPut(MODE, GETTEXTEX, 4, "UInt")
  NumPut( (codepage="unicode"||codepage="u") ? 1200 : 0  , GETTEXTEX, 8, "UInt")
  SendMessage, WM_USER | EM_GETTEXTEX, &GETTEXTEX,&BUFFER,, ahk_id %hCtrl%
  VarSetCapacity(BUFFER, -1)
  return BUFFER
}

/*
 Function:	GetTextLength
			Calculates text length in various ways.

 Parameters:
			flag     - Space separated list of one or more options.  See below list.
			codepage - If *UNICODE* or *U*, this optional parameter will use unicode code page
                in the translation. Otherwise it will default to using ansi.

 Flag Options:
     DEFAULT  - Returns the number of characters. This is the default.
     USECRLF  - Computes the answer by using CR/LFs at the end of paragraphs.
     PRECISE  - Computes a precise answer. This approach could necessitate a conversion
                and thereby take longer. This flag cannot be used with the *CLOSE* flag.
     CLOSE    - Computes an approximate (close) answer. It is obtained quickly and can
                be used to set the buffer size. This flag cannot be used with the *PRECISE*
                flag.
     NUMCHARS - Returns the number of characters. This flag cannot be used with the
                *NUMBYTES* flag.
     NUMBYTES - Returns the number of bytes. This flag cannot be used with the *NUMCHARS*
                flag.

 Returns:
     If the operation succeeds, the return value is the number of TCHARs in the edit
     control, depending on the setting of the flags.
     If the operation fails, the return value is blank.

 Remarks:
     This message is a fast and easy way to determine the number of characters in the
     Unicode version of the rich edit control. However, for a non-Unicode target code
     page you will potentially be converting to a combination of single-byte and double-byte
     characters.

 Related:
     <LimitText>, <GetSel>

 Example:
 > MsgBox, % "DEFAULT  = " RichEdit_GetTextLength(hRichEdit, "DEFAULT" )  "`n"
 >         . "USECRLF  = " RichEdit_GetTextLength(hRichEdit, "USECRLF" )  "`n"
 >         . "PRECISE  = " RichEdit_GetTextLength(hRichEdit, "PRECISE" )  "`n"
 >         . "CLOSE    = " RichEdit_GetTextLength(hRichEdit, "CLOSE" )    "`n"
 >         . "NUMCHARS = " RichEdit_GetTextLength(hRichEdit, "NUMCHARS" ) "`n"
 >         . "NUMBYTES = " RichEdit_GetTextLength(hRichEdit, "NUMBYTES" ) "`n"
 */
RichEdit_GetTextLength(hCtrl, flags=0, codepage="")  {
  static EM_GETTEXTLENGTHEX=95,WM_USER=0x400
  static GTL_DEFAULT=0,GTL_USECRLF=1,GTL_PRECISE=2,GTL_CLOSE=4,GTL_NUMCHARS=8,GTL_NUMBYTES=16

  hexFlags:=0
	Loop, parse, flags, %A_Tab%%A_Space%
		hexFlags |= GTL_%A_LOOPFIELD%

  VarSetCapacity(GETTEXTLENGTHEX, 4, 0)
  NumPut(hexFlags, GETTEXTLENGTHEX, 0), NumPut((codepage="unicode"||codepage="u") ? 1200 : 1252, GETTEXTLENGTHEX, 4)
  SendMessage, EM_GETTEXTLENGTHEX | WM_USER, &GETTEXTLENGTHEX,0,, ahk_id %hCtrl%
  IfEqual, ERRORLEVEL,0x80070057, return "", errorlevel := "ERROR: Invalid combination of parameters."
  IfEqual, ERRORLEVEL,FAIL      , return "", errorlevel := "ERROR: Invalid control handle."
  return ERRORLEVEL
}

/*
 Function: GetUndo
			Determine whether there are any actions in the control undo queue, and optionally retrieve
     the type of the next undo action.

 Parameters:
			name - Optional byref parameter will contain the type of undo action, if any.

 Types:
     UNKNOWN - The type of undo action is unknown.
     TYPING - Typing operation.
     DELETE - Delete operation.
     DRAGDROP - Drag-and-drop operation.
     CUT - Cut operation.
     PASTE - Paste operation.

 Returns:
			If there are actions in the control undo queue, the return value is a nonzero value.
			If the undo queue is empty, the return value is zero.

 Related:
     <Undo>, <SetUndoLimit>, <GetRedo>, <Redo>

 Example:
 > If RichEdit_GetRedo( hRichEdit, name )
 >   MsgBox, The next redo is a %name% type
 > Else
 >   MsgBox, Nothing left to redo.
 */
RichEdit_GetUndo(hCtrl, ByRef name="-")  {
  static EM_CANUNDO=0xC6,EM_GETUNDONAME=86,WM_USER=0x400
        ,UIDs="UNKNOWN,TYPING,DELETE,DRAGDROP,CUT,PASTE"
  SendMessage, EM_CANUNDO, 0,0,, ahk_id %hCtrl%
  nUndo := ERRORLEVEL

  If ( nUndo && name != "-" )  {
    SendMessage, WM_USER | EM_GETUNDONAME, 0,0,, ahk_id %hCtrl%
    Loop, Parse, UIDs, `,
      If (A_Index - 1 = errorlevel)  {
        name := A_LoopField
        break
      }
  }
  return nUndo
}

/*
 Function: LineFromChar
			Determines which line contains the specified character in a rich edit control.

 Parameters:
			idxChar -	Zero-based integer index of the character.

 Returns:
			Returns the zero-based index of the line *idxChar* is on.

 Related:
     <GetSel>, <SetSel>

 Example:
 > msgbox, % RichEdit_LineFromChar( hRichEdit, 5 )
 */
RichEdit_LineFromChar(hCtrl, idxChar)  {
  static EM_EXLINEFROMCHAR=54,WM_USER=0x400
  SendMessage, WM_USER | EM_EXLINEFROMCHAR, 0,%idxChar%,, ahk_id %hCtrl%
  return ERRORLEVEL
}

/*
 Function: LimitText
			Sets an upper limit to the amount of text the user can type or paste into a rich edit control.

 Parameters:
			txtSize -	Specifies the maximum amount of text that can be entered. If this parameter is zero,
               the default maximum is used, which is 64K characters. A Component Object Model (COM)
               object counts as a single character.

 Returns:
			This function does not return a value.

 Remarks:
     Before LimitText is called, the default limit to the amount of text a user can enter is
     32,767 characters.

 Related:
     <LimitText>

 Example:
 > RichEdit_LimitText( hRichEdit, 20 )  ; limit to 20 characters
 */
RichEdit_LimitText(hCtrl,txtSize=0)  {
  static EM_EXLIMITTEXT=53,WM_USER=0x400
  SendMessage, WM_USER | EM_EXLIMITTEXT, 0,%txtSize%,, ahk_id %hCtrl%
}

/*
 Function: Redo
			Send message to rich edit control to redo the next action in the control's redo queue.

 Returns:
			If the Redo operation succeeds, the return value is a nonzero value.
			If the Redo operation fails, the return value is zero.

 Related:
     <GetRedo>, <Undo>, <GetUndo>, <SetUndoLimit>

 Example:
 > RichEdit_Redo( hRichEdit )
 */
RichEdit_Redo(hCtrl)  {
  static EM_REDO=84,WM_USER=0x400
  SendMessage, WM_USER | EM_REDO, 0,0,, ahk_id %hCtrl%
  return ERRORLEVEL
}

/*
 Function: ScrollPos
			Obtain the current scroll position, or tell the rich edit control to scroll to a particular point.

 Parameters:
			posString - String specifying the x/y point in the virtual text space of the document, expressed
                 in pixels. (See example)

 Returns:
     If *posString* is omitted, the return value is the current scroll position.

 Related:
     <ShowScrollBar>, <GetSel>, <LineFromChar>, <SetSel>

 Example:
 > Msgbox, % "scroll pos = " RichEdit_ScrollPos( hRichEdit )
 > RichEdit_ScrollPos( hRichEdit , "7/22" )
 */
RichEdit_ScrollPos(hCtrl, posString="" )  {
  static EM_GETSCROLLPOS=221,EM_SETSCROLLPOS=222,WM_USER=0x400

  VarSetCapacity(POINT, 8, 0)
  If (!posString)  {
    SendMessage, WM_USER | EM_GETSCROLLPOS, 0,&POINT,, ahk_id %hCtrl%
    return NumGet(POINT, 0, "Int") . "/" . NumGet(POINT, 4, "Int")  ; returns posString
  }

  If RegExMatch( posString, "^(?<X>\d*)/(?<Y>\d*)$", m )  {
    NumPut(mX, POINT, 0, "Int"), NumPut(mY, POINT, 4, "Int")
    SendMessage, WM_USER | EM_SETSCROLLPOS, 0,&POINT,, ahk_id %hCtrl%
  }
  Else
    return false, errorlevel := "ERROR: '" posString "' isn't a valid posString."
}

/*
 Function: SetBgColor
			Sets the background color for a rich edit control.

 Parameters:
			color -	Color in RGB format (0xRRGGBB)

 Returns:
			Returns the previous background color in RGB format.

 Related:
     <SetCharFormat>, <GetCharFormat>

 Example:
 > CmnDlg_Color( color, hRichEdit )
 > RichEdit_SetBgColor( hRichEdit, color )
 >
 > RichEdit_SetBgColor( hRichEdit, 0xa9f874 )
 */
RichEdit_SetBgColor(hCtrl, color)  {
  static EM_SETBKGNDCOLOR=67,WM_USER=0x400

  old := A_FormatInteger
  SetFormat, integer, hex
  RegExMatch( color, "0x(?P<R>..)(?P<G>..)(?P<B>..)$", _ ) ; RGB2BGR
  color := "0x00" _B _G _R        ; 0x00bbggrr
  SendMessage, WM_USER | EM_SETBKGNDCOLOR, 0, % color,, ahk_id %hCtrl%
  RegExMatch( ERRORLEVEL + 0x1000000, "(?P<B>..)(?P<G>..)(?P<R>..)$", _ ) ; RGB2BGR
  pColor := "0x" _R _G _B
  SetFormat, integer, %old%

  return pColor
}

/*
 Function: SetSel
			Selects a range of characters or Component Object Model (COM) objects in a Rich Edit control.

 Parameters:
			cpMin -	Beginning of range of characters to select.
			cpMax -	End of range of characters to select.

 Note:
     If the *cpMin* and *cpMax* members are equal, or *cpMax* is omitted, the cursor will be moved to
     *cpMin*'s position.
     The range includes everything if *cpMin* is 0 and *cpMax* is –1.

 Returns:
			Returns true if character range was set.

 Related:
     <SetText>, <GetSel>, <GetText>, <GetTextLength>

 Example:
 > RichEdit_SetSel( hRichEdit, 4, 10 ) ; select range
 > RichEdit_SetSel( hRichEdit, 2 )     ; move cursor to right of 2nd character
 > RichEdit_SetSel( hRichEdit, 0, -1 ) ; select all
 */
RichEdit_SetSel(hCtrl, cpMin=0, cpMax=0)  {
  static EM_EXSETSEL=55,WM_USER=0x400
  
  If cpMin is not integer
    return false
  If cpMax is not integer
    return false
  VarSetCapacity(CHARRANGE, 8, 0)
  NumPut(cpMin, CHARRANGE, 0, "Int"), NumPut(cpMax ? cpMax : cpMin, CHARRANGE, 4, "Int")
  SendMessage, WM_USER | EM_EXSETSEL, 0,&CHARRANGE,, ahk_id %hCtrl%
  return true
}

/*
 Function: SetText
			Set text from string or file in rich edit control using either rich text or plain text.

 Parameters:
			txt -	The text string to set within control.
			flag - Space separated list of options.  See below list.
			pos - When using *SELECTION* flag, this optional parameter allows you to specify a character
           position you want text inserted to, rather than replacing current selection. To append to
           end, use -1.

 Flag Options:
     DEFAULT - Deletes the undo stack, discards rich-text formatting, & replaces all text.
     KEEPUNDO - Keeps the undo stack.
     SELECTION - Replaces selection and keeps rich-text formatting.
     FROMFILE - Load a file into control.  If used, this option expects the *txt* parameter to be
                a filename. If there is a problem loading the file, *ErrorLevel* will contain message.

 Returns:
     If the operation is setting all of the text and succeeds, the return value is 1.
     If the operation fails, the return value is zero.

 Related:
     <SetSel>, <GetText>, <GetSel>, <TextMode>

 Example:
 > FileSelectFile, file,,, Select file, RTF(*.rtf; *.txt)
 > RichEdit_SetText(hRichEdit, file, "FROMFILE KEEPUNDO")
 >
 > RichEdit_SetText(hRichEdit, "insert..", "SELECTION")
 >
 > RichEdit_SetText(hRichEdit, "replace all..")
 >
 > RichEdit_SetText(hRichEdit, "append to end..", "SELECTION", -1 )
 */
RichEdit_SetText(hCtrl, txt="", flag=0, pos="" )  {
  static EM_SETTEXTEX=97,WM_USER=0x400
        ,ST_DEFAULT=0,ST_KEEPUNDO=1,ST_SELECTION=2
  hexFlag=0
  If flag
  	Loop, parse, flag, %A_Tab%%A_Space%
      If (A_LoopField = "FROMFILE") {
        FileRead, file, %txt%
        If errorlevel
          return false, errorlevel := "ERROR: Couldn't open file '" txt "'"
      }
      Else If A_LoopField in DEFAULT,KEEPUNDO,SELECTION
    	 hexFlag |= ST_%A_LoopField%
  VarSetCapacity(SETTEXTEX, 8, 0), NumPut(hexFlag, SETTEXTEX, 0, "UInt")

  ; The code page is used to translate the text to Unicode. If codepage is 1200 (Unicode code page),
  ; no translation is done. If codepage is CP_ACP (0), the system code page is used. 
  NumPut(0, SETTEXTEX, 4, "UInt")

  ; If specifying a pos, calculate new range for restoring original selection
  If (pos && (hexFlag >= 2) )
    RichEdit_GetSel(hCtrl,min,max), prevPos:=RichEdit_SetSel(hCtrl,pos)
    , pos>-1 && pos<=min  ?   (min+=len:=StrLen((file ? file : txt)) , max+=len)   :   ""
    
  ; Setting text
  SendMessage, WM_USER | EM_SETTEXTEX, &SETTEXTEX, (file ? &file : &txt),, ahk_id %hCtrl%
  err := ERRORLEVEL
  return err, prevPos ? RichEdit_SetSel(hCtrl,min,max)
}

/*
 Function: SetUndoLimit
			Set the maximum number of actions that can stored in the undo queue.

 Parameters:
			nMax - The maximum number of actions that can be stored in the undo queue.

 Returns:
       The return value is the new maximum number of undo actions for the rich edit control.

 Remarks:
       By default, the maximum number of actions in the undo queue is 100. If you increase
       this number, there must be enough available memory to accommodate the new number.
       For better performance, set the limit to the smallest possible value needed.

 Related:
     <Undo>, <GetUndo>, <Redo>, <GetRedo>

 Example:
 > MsgBox, % RichEdit_SetUndoLimit( hRichEdit, 5 )
 */
RichEdit_SetUndoLimit(hCtrl, nMax)  {
  static EM_SETUNDOLIMIT=82,WM_USER=0x400
  if nMax is not integer
    return false
  SendMessage, WM_USER | EM_SETUNDOLIMIT, %nMax%,0,, ahk_id %hCtrl%
  return ERRORLEVEL
}

/*
 Function: ShowScrollBar
			Shows or hides scroll bars for rich edit control.

 Parameters:
			bar - Identifies which scroll bar to display: horizontal or vertical. This parameter must be
           "*V*", "*H*", or a combination of the two.

			state - *TRUE* or *FALSE*.

 Returns:
     This function does not return a value.

 Remarks:
     This method is only valid when the control is in-place active. Calls made while the control
     is inactive may fail.

 Related:
     <ScrollPos>

 Example:
 > RichEdit_ShowScrollBar( hRichEdit, "VH", false )
 > Sleep, 3000
 >
 > RichEdit_ShowScrollBar( hRichEdit, "V", true )
 */
RichEdit_ShowScrollBar(hCtrl, bar, state=true)  {
  static EM_SHOWSCROLLBAR=96,WM_USER=0x400,SB_HORZ=0,SB_VERT=1

  If ( StrLen(bar) <= 2)  {
    If InStr( bar, "H" )
      SendMessage, WM_USER | EM_SHOWSCROLLBAR, SB_HORZ, state,, ahk_id %hCtrl%
    If InStr( bar, "V" )
      SendMessage, WM_USER | EM_SHOWSCROLLBAR, SB_VERT, state,, ahk_id %hCtrl%
  }
}

/*
 Function: TextMode
			Get or set the current text mode of a rich edit control.

 Parameters:
			textMode - Space separated list of options (see below list). If omitted, current text
                mode is returned.

 textMode Options:
     PLAINTEXT - Indicates plain-text mode, in which the control is similar to a standard
                 edit control. For more information about plain-text mode:
                 <http://msdn.microsoft.com/en-us/library/bb774286(VS.85).aspx>
     RICHTEXT - Indicates rich-text mode (default text mode)
     SINGLELEVELUNDO - The control allows the user to undo only the last action in the undo queue.
     MULTILEVELUNDO - The control supports multiple undo actions (default undo mode).
                      Use <SetUndoLimit> to set the maximum number of undo actions.
     SINGLECODEPAGE - The control only allows the English keyboard and a keyboard corresponding
                      to the default character set. For example, you could have Greek and
                      English. Note that this prevents Unicode text from entering the control.
                      For example, use this value if a rich edit control must be
                      restricted to ANSI text.
     MULTICODEPAGE - The control allows multiple code pages and Unicode text into the control
                     (default code page mode)

 Returns:
     If *textMode* is omitted, the return value is the current text mode settings.
     When *textMode* is given, function will return *TRUE* or *FALSE*.

 Remarks:
     The control must not contain text when calling this function, or it will return *FALSE*.
     To ensure there is no text, use <SetText> with an empty string.
 >     RichEdit_SetText(hRichEdit, "")
     If you simply want to determine whether a rich edit control is Unicode, use *IsWindowUnicode* dllcall as demonstrated below:
 > If DllCall("IsWindowUnicode", "UInt", hCtrl)
 >   MsgBox, Control is unicode.
 > Else
 >   MsgBox, Control is ansi.

 Related:
     <SetUndoLimit>

 Example:
 > MsgBox, % "mode= " RichEdit_TextMode(hRichEdit)
 >
 > If RichEdit_TextMode( hRichEdit, "PLAINTEXT SINGLELEVELUNDO" )
 >   MsgBox, % "new mode= " RichEdit_TextMode(hRichEdit)
 > Else
 >   MsgBox, % errorlevel
 */
RichEdit_TextMode(hCtrl, textMode="")  {
  static EM_SETTEXTMODE=89,EM_GETTEXTMODE=90,WM_USER=0x400
  static TM_PLAINTEXT=1,TM_RICHTEXT=2,TM_SINGLELEVELUNDO=4,TM_MULTILEVELUNDO=8,TM_SINGLECODEPAGE=16,TM_MULTICODEPAGE=32

  If (textMode)  {    ; Setting text mode
    txtMode := undoMode := codepgMode := 0
    Loop, parse, textMode, %A_Tab%%A_Space%
    {
      If A_LoopField in RICHTEXT,PLAINTEXT
    	 txtMode    := TM_%A_LoopField%
      Else If A_LoopField in MULTILEVELUNDO,SINGLELEVELUNDO
    	 undoMode   := TM_%A_LoopField%
      Else If A_LoopField in MULTICODEPAGE,SINGLECODEPAGE
    	 codepgMode := TM_%A_LoopField%
      Else
        return false, errorlevel := "ERROR: '" A_LoopField "' isn't a valid textmode."
    }
    SendMessage, WM_USER | EM_SETTEXTMODE, % txtMode | undoMode | codepgMode,0,, ahk_id %hCtrl%
    return !errorlevel ? true : false, errorlevel := "ERROR: Unable to change text mode. Make sure control is empty first."
  }
  Else  {     ; Getting current text mode
    SendMessage, WM_USER | EM_GETTEXTMODE, 0,0,, ahk_id %hCtrl%
    If errorlevel is not integer
      return false, errorlevel := "ERROR: Failed to retrieve controls text mode. Check to make sure you are specifying correct hwnd to control."
    tm := errorlevel
    TEXTMODES=MULTICODEPAGE,SINGLECODEPAGE,MULTILEVELUNDO,SINGLELEVELUNDO,RICHTEXT,PLAINTEXT
    Loop, parse, TEXTMODES,`,
      tm >= TM_%a_loopfield%  ?  (tmDesc.=(tmDesc ? " " a_loopfield : a_loopfield), tm-=TM_%a_loopfield%)  :  ""
    return tmDesc
  }
}

/*
 Function: Undo
			Send message to rich edit control to undo the next action in the control's undo queue &
     optionally empty the undo buffer by resetting the undo flag.

 Parameters:
			reset - To clear undo buffer rather than send undo command, set this to *true*, "*T*", or "*reset*".

 Returns:
     For a single-line edit control, the return value is always TRUE.
     For a multiline edit control, the return value is *TRUE* if the undo operation is
     successful, or *FALSE* if the undo operation fails, or your resetting undo queue.

 Related:
     <GetUndo>, <SetUndoLimit>, <Redo>, <GetRedo>

 Example:
 > RichEdit_Undo( hRichEdit )       ; undo
 > RichEdit_Undo( hRichEdit, true ) ; reset undo queue
 */
RichEdit_Undo(hCtrl, reset=false)  {
  static EM_UNDO=0xC7,EM_EMPTYUNDOBUFFER=0xCD
  If (!reset)  {
    SendMessage, EM_UNDO, 0,0,, ahk_id %hCtrl%
    return ERRORLEVEL
  }
  If reset in 1,t,true,reset
    SendMessage, EM_EMPTYUNDOBUFFER, 0,0,, ahk_id %hCtrl%
}

/*
 Function: Zoom
			Sets the zoom ratio anywhere between 1/64 and 64.

 Parameters:
			zoom - Integer amount to increase or decrease zoom with *+* or *-* infront of it (see examples).

 Returns:
       If the new zoom setting is accepted, the return value is *TRUE*.
       If the new zoom setting is not accepted, the return value is *FALSE*.
       If *zoom* param is omitted, current numerator/denominator ratio is returned.

 Examples:
 > Msgbox, % "zoom ratio: " RichEdit_Zoom( hRichEdit )
 >
 > #MaxHotkeysPerInterval 200
 > #IfWinActive ahk_group RichEditGrp
 > ^WheelUp::   RichEdit_Zoom( hRichEdit, +1 )
 > ^WheelDown:: RichEdit_Zoom( hRichEdit, -1 )
 > #IfWinActive
 */
Richedit_Zoom(hCtrl, zoom=0)  {
  static EM_SETZOOM=225,EM_GETZOOM=224,WM_USER=0x400

  ; Get the current zoom ratio
  VarSetCapacity(numer, 4)  ;, VarSetCapacity(denom, 4)
  SendMessage, WM_USER | EM_GETZOOM, &numer,&denom,, ahk_id %hCtrl%
  numerator := NumGet(numer, 0, "UShort") ;, denominator := NumGet(denom, 0, "UShort")

  If zoom is not integer
    return false, errorlevel := "ERROR: '" zoom "' is not an integer, stupid"
  If (!zoom)
    return numerator "/" denominator

  ; Calculate new numerator value (denominator not currently changed)
  InStr(zoom,"-") ?  numerator-=SubStr(zoom,2)  :  numerator+=zoom
    
  ; Set the zoom ratio
  SendMessage, WM_USER | EM_SETZOOM, %numerator%, 1,, ahk_id %hCtrl%
  return ERRORLEVEL
}





 ; ///////////////////////////////  UNDER CONSTRUCTION  //////////////////////////////////////////////

/*
 Function: GetCharFormat
			Get or set the current text mode of a rich edit control.

 Parameters:
			font - Optional byref parameter will contain the name of the font.
			style - Optional byref parameter will contain a space separated list
             of styles. See below list.
			colors - Optional byref parameter will contain the RGB color for font.
			mode - If *DEFAULT* or *D*, this optional parameter retrieves the formatting to all text in the
            control. Otherwise it applies the formatting to the current selection. If the selection
            is empty, the character formatting is applied to the insertion point, and the new
            character format is in effect only until the insertion point changes.

 Style Options:
     AUTOCOLOR - The text color is the current color of the text in windows.
     BOLD - Characters are bold.
     DISABLED - RichEdit 2.0 and later: Characters are displayed with a shadow that is offset by 3/4 point or one pixel, whichever is larger.
     ITALIC - Characters are italic.
     STRIKEOUT - Characters are struck.
     UNDERLINE - Characters are underlined.
     PROTECTED - Characters are protected. an attempt to modify them will cause an EN_PROTECTED notification message.

 Returns:
			This function does not return a value.

 Remarks:
     The control must not contain text when calling this function, or it will return *FALSE*.
     To ensure there is no text, use <SetText> with an empty string.

 >     RichEdit_SetText(hRichEdit, "")

 Related:
     <SetCharFormat>, <SetBgColor>

 Example:
 > RichEdit_GetCharFormat(hRichEdit, face, style, color)
 > MsgBox, Face = %Face% `nstyle = %style%  `ncolor = %color%
 */
RichEdit_GetCharFormat(hCtrl, ByRef font="", ByRef style="", ByRef color="", mode="SELECTION")  {
  static EM_GETCHARFORMAT=58,WM_USER=0x400
  static SCF_SELECTION=0x1,SCF_DEFAULT=0x0

  mode := (mode="default"||mode="d")  ?   SCF_DEFAULT : SCF_SELECTION
  VarSetCapacity(CHARFORMAT, 60, 0), NumPut(60, CHARFORMAT)
  SendMessage, WM_USER | EM_GETCHARFORMAT, mode,&CHARFORMAT,, ahk_id %hCtrl%

  ; dwEffects - Character effects. This member can be a combination of the following values.
  static CFE_AUTOCOLOR=0x40000000,CFE_BOLD=0x1,CFE_ITALIC=0x2,CFE_STRIKEOUT=0x8,CFE_UNDERLINE=0x4,CFE_PROTECTED=0x10
  cfe := NumGet(CHARFORMAT, 8, "UInt")
  dwEffects=PROTECTED,UNDERLINE,STRIKEOUT,ITALIC,BOLD,AUTOCOLOR
  Loop, parse, dwEffects,`,
    cfe >= CFE_%a_loopfield%  ?  (style.=(style ? " " a_loopfield : a_loopfield), cfe-=CFE_%a_loopfield%)  :  ""

  ; color (crTextColor)
  old := A_FormatInteger
  SetFormat, integer, hex
  RegExMatch( NumGet(CHARFORMAT,20,"UInt")+0x1000000, "(?P<R>..)(?P<G>..)(?P<B>..)$", _ ) ; RGB2BGR
  color := "0x" _B _G _R

  ; font size (cfeDesc)
  SetFormat, float, 1.0
  style .= (style ? " s" : "s") . NumGet(CHARFORMAT,12,"Int")/20
  SetFormat, integer, %old%

  ; face (szFaceName)
  VarSetCapacity(font, 32)
  DllCall("RtlMoveMemory", "str", font, "Uint", &CHARFORMAT + 26, "Uint", 32)
}

EM_GETCHARFORMAT222(hCtrl, ByRef face="", ByRef style="", ByRef color="")  {
  static EM_GETCHARFORMAT=58,WM_USER=0x400
  static SCF_DEFAULT=0x0,SCF_SELECTION=0x1

  VarSetCapacity(CHARFORMAT, 60, 0), NumPut(60, CHARFORMAT)
  SendMessage, WM_USER | EM_GETCHARFORMAT, SCF_SELECTION,&CHARFORMAT,, ahk_id %hCtrl%

  ; dwMask - Members containing valid information or attributes to set. This member can be zero, one, or more than one of the following values.
   static CFM_BOLD=0x1,CFM_CHARSET=0x8000000,CFM_COLOR=0x40000000,CFM_FACE=0x20000000,CFM_ITALIC=0x2,CFM_OFFSET=0x10000000,CFM_PROTECTED=0x10,CFM_SIZE=0x80000000,CFM_STRIKEOUT=0x8,CFM_UNDERLINE=0x4

  ; dwEffects - Character effects. This member can be a combination of the following values.
  static CFE_AUTOCOLOR=0x40000000,CFE_BOLD=0x1,CFE_ITALIC=0x2,CFE_STRIKEOUT=0x8,CFE_UNDERLINE=0x4,CFE_PROTECTED=0x10
  cfe := NumGet(CHARFORMAT, 8, "UInt")
  dwEffects=PROTECTED,UNDERLINE,STRIKEOUT,ITALIC,BOLD,AUTOCOLOR
  Loop, parse, dwEffects,`,
    cfe >= CFE_%a_loopfield%  ?  (style.=(style ? " " a_loopfield : a_loopfield), cfe-=CFE_%a_loopfield%)  :  ""
     cfe >= CFE_%a_loopfield%  ?  (cfeDesc.=(cfeDesc ? " " a_loopfield : a_loopfield), cfe-=CFE_%a_loopfield%)  :  ""

  ; color
  old := A_FormatInteger
  SetFormat, integer, hex
  RegExMatch( NumGet(CHARFORMAT,20,"UInt")+0x1000000, "(?P<R>..)(?P<G>..)(?P<B>..)$", _ ) ; BGR2RGB
  crTextColor := "0x" _B _G _R

  ; font size
  SetFormat, float, 1.0
  style .= (style ? " s" : "s") . NumGet(CHARFORMAT,12,"Int")/20
   cfeDesc .= (cfeDesc ? " s" : "s") . NumGet(CHARFORMAT,12,"Int")/20
  SetFormat, integer, %old%

  ; face
  VarSetCapacity(szFaceName, 32)
  DllCall("RtlMoveMemory", "str", szFaceName, "Uint", &CHARFORMAT + 26, "Uint", 32)
  ;-
   face:=szFaceName, style:=cfeDesc, color:=crTextColor
}

/*
 Function: SetCharFormat
			Set character formatting in a rich edit control.

 Parameters:
			face - Name of font.
			style -	Space separated list of optional character effects. See below list.
			color -	RGB color for font.
			mode - If *ALL* or *A*, this optional parameter applies the formatting to all text in the
            control. Otherwise it applies the formatting to the current selection. If the selection
            is empty, the character formatting is applied to the insertion point, and the new
            character format is in effect only until the insertion point changes.

 Style Options:
     AUTOCOLOR - The text color is the current color of the text in windows.
     BOLD - Characters are bold.
     DISABLED - RichEdit 2.0 and later: Characters are displayed with a shadow that is offset by 3/4 point or one pixel, whichever is larger.
     ITALIC - Characters are italic.
     STRIKEOUT - Characters are struck.
     UNDERLINE - Characters are underlined.
     PROTECTED - Characters are protected.

 Returns:
     If the operation is setting all of the text and succeeds, the return value is 1.
     If the operation fails, the return value is zero.

 Related:
     <GetCharFormat>, <SetBgColor>

 Example:
 > CmnDlg_Font( Face, Style, Color, true, hwnd )
 > RichEdit_SetCharFormat( hCtrl, Face, Style, Color )
 */
RichEdit_SetCharFormat(hCtrl, face="", style="", color="-", mode="SELECTION")  {
  static EM_SETCHARFORMAT=68,WM_USER=0x400
  static SCF_ALL=0x4,SCF_SELECTION=0x1  ;,SCF_WORD=0x2
  If mode in A,ALL
    mode := SCF_ALL
 ;   Else If mode in W,WORD
 ;     mode := SCF_SELECTION | SCF_WORD
  Else
    mode := SCF_SELECTION

  ;To turn off a formatting attribute, set the appropriate value in dwMask but do not set the corresponding value in dwEffects
  static CFM_BOLD:=0x1,CFM_CHARSET:=0x8000000,CFM_COLOR:=0x40000000,CFM_FACE:=0x20000000,CFM_ITALIC:=0x2,CFM_OFFSET:=0x10000000,CFM_PROTECTED:=0x10,CFM_SIZE:=0x80000000,CFM_STRIKEOUT:=0x8,CFM_UNDERLINE:=0x4
  static dwMask_default=0
  dwMask_default |= !dwMask_default ? CFM_BOLD|CFM_CHARSET|CFM_ITALIC|CFM_OFFSET|CFM_PROTECTED|CFM_STRIKEOUT|CFM_UNDERLINE : 0

  ; Character effects. This member can be a combination of the following values.
  static CFE_AUTOCOLOR=0x40000000,CFE_BOLD=0x1,CFE_ITALIC=0x2,CFE_STRIKEOUT=0x8,CFE_UNDERLINE=0x4,CFE_PROTECTED=0x10
  dwMask:=dwMask_default  , dwEffects:=0
  StringUpper, style,style
  If style
  	Loop, parse, style, %A_Tab%%A_Space%
      If A_LoopField in AUTOCOLOR,BOLD,ITALIC,STRIKEOUT,UNDERLINE,PROTECTED
    	 dwEffects |= CFE_%A_LoopField%

  If RegExMatch( color, "0x(?P<R>..)(?P<G>..)(?P<B>..)", _ ) ; RGB2BGR
    color:= "0x" _B _G _R

  VarSetCapacity(CHARFORMAT, 60, 0), NumPut(60, CHARFORMAT)
  dwMask |= RegExMatch(style " ","U)S([0-9]+) ", m) ?  (CFM_SIZE , NumPut(m1*20,CHARFORMAT,12,"Int"))   :  0
  dwMask |= color!="-"                          ?  (CFM_COLOR, NumPut(color,CHARFORMAT,20,"UInt"))  :  0
  dwMask |= face && StrLen(face)<33             ?  (CFM_FACE , VarSetCapacity(szFaceName,33,0), szFaceName:=face) : 0

  NumPut(dwMask, CHARFORMAT, 4, "UInt"), NumPut(dwEffects, CHARFORMAT, 8, "UInt")
  If szFaceName
    DllCall("lstrcpy", "UInt", &CHARFORMAT + 26, "Str", szFaceName)
  SendMessage, WM_USER | EM_SETCHARFORMAT, mode,&CHARFORMAT,, ahk_id %hCtrl%
  return ERRORLEVEL ; value of the dwMask member of the CHARFORMAT structure
}


 ; EM_SETEVENTMASK(hCtrl)  {
 ;   static EM_SETEVENTMASK=69,WM_USER=0x400
 ;
 ; ENM_CHANGE=0x1  ; notification message through a WM_COMMAND message.
 ; ENM_CORRECTTEXT=0x400000
 ; ENM_DRAGDROPDONE=0x10
 ;   ENM_DROPFILES:=0x100000,DllCall( "shell32.dll\DragAcceptFiles", Int,hCtrl  , Int,TRUE )
 ; ENM_IMECHANGE=0x800000
 ;   ENM_KEYEVENTS=0x10000
 ; ENM_LINK=0x4000000
 ;   ENM_MOUSEEVENTS=0x20000
 ; ENM_OBJECTPOSITIONS=0x2000000
 ;   ENM_PROTECTED=0x200000
 ;   ENM_REQUESTRESIZE=0x40000
 ; ENM_SCROLL=0x4  ;  notification message through a WM_COMMAND message
 ;   ENM_SCROLLEVENTS=0x8
 ;   ENM_SELCHANGE=0x80000
 ; ENM_UPDATE=0x2
 ;
 ;   lParam := ENM_KEYEVENTS | ENM_SCROLLEVENTS | ENM_MOUSEEVENTS
 ;   SendMessage, WM_USER | EM_SETEVENTMASK, 0,lParam,, ahk_id %hCtrl%
 ; ;   return ERRORLEVEL  ; This message returns the previous event mask
 ;
 ;
 ; }

RichEdit_GETWORDWRAPMODE(hCtrl)  {
  static EM_GETWORDWRAPMODE=103,WM_USER=0x400

  SendMessage, WM_USER | EM_GETWORDWRAPMODE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel
}

RichEdit_SETWORDWRAPMODE(hCtrl)  {
	static EM_SETWORDWRAPMODE=102,WM_USER=0x400
	static WBF_WORDWRAP = 0x10
		,EM_SETTARGETDEVICE = 72
		,state=0
	a=0
	state:=!state

 ; DllCall("SendMessage", "UInt", _ctrlID, "UInt", 0x448, "UInt", "0", "Int", !(opt1)) ; EM_SETTARGETDEVICE

 ;   SendMessage, 0x448,0,true,, ahk_id %hCtrl%
 ;   SendMessage, WM_USER | EM_SETWORDWRAPMODE, %WBF_WORDWRAP%,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel
}

EM_SETWORDBREAKPROC(hCtrl)  {
  static EM_SETWORDBREAKPROC=0xD0
        ,wbProc

    if !wbProc
      wbProc := RegisterCallback("RichEdit_wordBreakProc")
 ;       DllCall("GlobalFree", "UInt", wbProc)
  SendMessage, 208, 0,wbProc,, ahk_id %hCtrl%
 ;   SendMessage, EM_SETWORDBREAKPROC, 0,wbProc,, ahk_id %hCtrl%
  MsgBox, % errorlevel " - " wbProc . " - " . hCtrl
 ; Return Value - This message does not return a value.
 ;   msgbox, hold..
 ;       DllCall("GlobalFree", "UInt", wbProc)
}

RichEdit_wordBreakProc(lpch, ichCurrent, cch, code) {
  ;   LPTSTR lpch    - A pointer to the text of the edit control.
  ;   int ichCurrent - An index to a character position in the buffer of text that identifies the point
  ;                    at which the function should begin checking for a word break.
  ;   int cch        - An index to a character position in the buffer of text that identifies the point
  ;                    at which the function should begin checking for a word break.
  ;   int code       - The action to be taken by the callback function. This parameter can be one of the
  ;                    following values:
  ;                   WB_CLASSIFY      - Retrieves the character class and word break flags of the
  ;                                      character at the specified position. This value is for use with
  ;                                      rich edit controls.
  ;                   WB_ISDELIMITER   - Checks whether the character at the specified position is a
  ;                                      delimiter.
  ;                   WB_LEFT          - Finds the beginning of a word to the left of the specified
  ;                                      position.
  ;                   WB_LEFTBREAK     - Finds the end-of-word delimiter to the left of the specified
  ;                                      position. This value is for use with rich edit controls.
  ;                   WB_MOVEWORDLEFT  - Finds the beginning of a word to the left of the specified
  ;                                      position. This value is used during CTRL+LEFT key processing.
  ;                                      This value is for use with rich edit controls.
  ;                   WB_MOVEWORDRIGHT - Finds the beginning of a word to the right of the specified
  ;                                      position. This value is used during CTRL+RIGHT key processing.
  ;                                      This value is for use with rich edit controls.
  ;                   WB_RIGHT         - Finds the beginning of a word to the right of the specified
  ;                                      position. This is useful in right-aligned edit controls.
  ;                   WB_RIGHTBREAK    - Finds the end-of-word delimiter to the right of the specified
  ;                                      position. This is useful in right-aligned edit controls. This
  ;                                      value is for use with rich edit controls.
  static WB_CLASSIFY=3,WB_ISDELIMITER=2,WB_LEFT=0,WB_LEFTBREAK=6,WB_MOVEWORDLEFT=4,WB_MOVEWORDRIGHT=5,WB_RIGHT=1,WB_RIGHTBREAK=7

	exp=(s|c| )
   Loop, % cch * 2 ; build the string:
      str .= Chr(*(lpch - 1 + A_Index))
      
 ;       StringReplace, str,str, %a_space%,_,A
 ;   str := DllCall("MulDiv", "Int",lpch, "Int",1, "Int",1, "str")
	tooltip, lpch=%lpch% `nichCurrent=%ichCurrent% `ncch=%cch% `ncode=%code% `nstr=%str%
 ; If (code = WB_LEFT)
 ;   return RegExMatch( str, "s[^s]*\Z.*s.*" )
	If (code = WB_MOVEWORDLEFT)
      Return, RegExMatch(   SubStr(str, 1, ichCurrent = cch ? cch : ichCurrent - (ichCurrent > 1))
                          , exp . "[^" . exp . "]*\Z")
	If (code = WB_MOVEWORDRIGHT)
     Return, ichCurrent = cch or !(z := RegExMatch(str, exp, "", ichCurrent + 1)+1) ? cch : z - 1


 ;   str= especially
 ; msgbox, %  RegExMatch( str, "s[^s]*\Z.*s.*" )
 ;    static exp = "\W" ; treat any non alphanumeric character as a delimiter with this regex
 ;    Loop, % cch * 2 ; build the string:
 ;       str .= Chr(*(lpch - 1 + A_Index))
 ;    If code = 0 ; WB_LEFT
 ;       Return, RegExMatch(SubStr(str, 1, ichCurrent = cch
 ;          ? cch : ichCurrent - (ichCurrent > 1)), exp . "[^" . exp . "]*\Z")
 ;    Else If code = 1 ; WB_RIGHT
 ;     ToolTip, right
 ; ;       Return, ichCurrent = cch or !(z := RegExMatch(str, exp, "", ichCurrent + 1)) ? cch : z - 1
 ;    Else If code = 2 ; WB_ISDELIMITER
 ;       Return, RegExMatch(SubStr(str, ichCurrent + 1, 1), exp)
}

; EM_GETWORDBREAKPROC
EM_SETWORDBREAKPROCEX(hCtrl)  {     ; *** no longer used after re2.0.  use  EM_SETWORDBREAKPROC to set EditWordBreakProc instead
 ;   static EM_SETWORDBREAKPROCEX=81,WM_USER=0x400
 ;
 ;   SendMessage, WM_USER | EM_SETWORDBREAKPROCEX, 0,&@??,, ahk_id %hCtrl%

}








 ; *** WIP-  http://msdn.microsoft.com/en-us/library/bb774252(VS.85).aspx
__RichEdit_OleInterface(hCtrl)  {
  static EM_GETOLEINTERFACE:=60,EM_SETOLECALLBACK:=70,WM_USER:=0x400

  ; Retrieve an IRichEditOle object to access a rich edit control's COM functionality.
  VarSetCapacity(pointer, 4)
  SendMessage, WM_USER | EM_GETOLEINTERFACE, 0,&pointer,, ahk_id %hCtrl%
  If !pointer := NumGet(pointer, 0)
    return "ERROR:  Couldn't retrieve an IRichEditOle object for control."
 ; COM methods: http://msdn.microsoft.com/en-us/library/bb774306(VS.85).aspx


  ; gives a rich edit control an IRichEditOleCallback object that the control uses to
  ; get OLE-related resources and information from the client.
  SendMessage, WM_USER | EM_SETOLECALLBACK, 0,pointer,, ahk_id %hCtrl%

 ;   com_init()
 ;   msgbox, % pipa := COM_QueryInterface(pointer)
 ;   msgbox, % COM_Invoke(pipa, "GetClipboardData")
  ;   msgbox, KEEP GOING: "%pointer%"
}
