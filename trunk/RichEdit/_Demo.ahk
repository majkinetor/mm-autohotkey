GetText: ;Retrieves a specified range of characters from a rich edit control.

 Log("Selection: " RichEdit_GetText( hRichEdit ))
 Log("All: " RichEdit_GetText( hRichEdit, 0, -1 ))
 Log("Range: " RichEdit_GetText( hRichEdit, 4, 10 ))
return

SetParaFormat:		;ets the paragraph formatting for the current selection in a rich edit control.
	r := RichEdit_SetParaFormat(hRichEdit, "Align=CENTER", "Num=DECIMAL,10,D,1000", "Line=DOUBLE", "Space=1000,3000" )
	Log("Set Align, Num, Line & Space: " r)
;	r := RichEdit_SetParaFormat(hRichEdit, "Ident=-1000") ;,-1000, 1000" )
	r := RichEdit_SetParaFormat(hRichEdit, "Tabs=100 1000 2000 5000")
	Log("Set Tabs: " r)
return


TextMode:	;Sets text mode.
	rtf := RichEdit_Save( hRichEdit )			;get RTF
	txt := RichEdit_GetText(hRichEdit, 0, -1)	;get PLAINTEXT
	Log( "Current mode: " RichEdit_TextMode(hRichEdit) )
	Log( "Set mode to plaintext: " RichEdit_TextMode(hRichEdit, "PLAINTEXT") )
	Log( "Current mode: " RichEdit_TextMode(hRichEdit) )
	RichEdit_SetText(hRichEdit, txt)
	Msgbox Plain Text
	Log( "Restore mode to richtext: " RichEdit_TextMode(hRichEdit, "RICHTEXT") )
	RichEdit_SetText(hRichEdit, rtf)
return

SetText:			;Set text from string or file in rich edit control using either rich text or plain text.
	RichEdit_SetText(hRichEdit, "insert..", "", 150)
	RichEdit_SetText(hRichEdit, "append to end..", "SELECTION", -1 )
return

LineScroll:			;Line scroll
	RichEdit_LineScroll(hRichEdit, 100, 1)
return

PosFromChar:	   ;Gets the client area coordinates of a specified character in an Edit control.
	RichEdit_PosFromChar(hRichEdit, RichEdit_GetSel(hRichEdit), X, Y)
	Log("Pos: " X, " " Y)
return

GetLine:			;Get Line
	Log("Current Line: '" RichEdit_GetLine(hRichEdit) "'")
return

GetLineCount:		;Get Line Count
	Log("Line count: " RichEdit_GetLineCount(hRichEdit) )
return

GetModify:			;Get modification status
	Log("Modification status: " RichEdit_GetModify(hRichEdit))
return

SelectionType:		;Get selection type
	Log("Selection type: " RichEdit_SelectionType(hRichEdit))
return

GetOptions: ;Get options
	Log("Current options: " RichEdit_GetOptions(hRichEdit))
return

SetOptions:	;Set options
	r := RichEdit_SetOptions(hRichEdit, "XOR", "SELECTIONBAR READONLY")	;switch readonly
	Log("Current options: " r)
return

FindWordBreak:	;Finds the next word break before or after the specified character position or retrieves information about the character at that position.
	pos := RichEdit_FindWordBreak(hRichEdit, RichEdit_GetSel(hRichEdit), "MOVEWORDRIGHT")
	RichEdit_SetSel(hRichEdit, pos)
	Log("Next word found at: " pos)
return

Clear:	;Clear selection
	RichEdit_Clear(hRichEdit)
return


AutoUrlDetect:  ; Enable disable or toggle automatic detection of URLs by a rich edit control.

  Log("Url detect: " RichEdit_AutoUrlDetect( hRichEdit, "^" ))
return

GetSel: ;Retrieve the starting and ending character positions of the selection.

	RichEdit_GetSel( hRichEdit, min, max  )
	if !(count := max-min)
		 Log("Cursor Position: " min)
	else Log("Selected from: " min " - " max " (" count ")")
return

LineFromChar: ;Determines which line contains the specified character in a rich edit control.
	Log( "Current Line: " RichEdit_LineFromChar( hRichEdit, RichEdit_GetSel(hRichEdit)))
return

LimitText:	;Sets an upper limit to the amount of text the user can type or paste into a rich edit control
	RichEdit_LimitText( hRichEdit, 20 )  ; limit to 20 characters
return