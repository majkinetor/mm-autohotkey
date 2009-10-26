LineScroll:			;Line scroll
	RichEdit_LineScroll(hRichEdit, 100, 1)
return

PosFromChar:	   ;Pos from char
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
	Log("Modificatin status: " RichEdit_GetModify(hRichEdit))
return

SelectionType:		;Get selection type
	Log("Selection type: " RichEdit_SelectionType(hRichEdit))
return

GetOptions: ;Get options
	Log("Current options: " RichEdit_GetOptions(hRichEdit))
return

SetOptions:	;Finds the next word break before or after the specified character position or retrieves information about the character at that position.
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

GetText: ;Retrieves a specified range of characters from a rich edit control.

 Log("Selection: " RichEdit_GetText( hRichEdit ))
 Log("All: " RichEdit_GetText( hRichEdit, 0, -1 ))
 Log("Range: " RichEdit_GetText( hRichEdit, 4, 10 ))
return

LineFromChar: ;Determines which line contains the specified character in a rich edit control.
	Log( "Current Line: " RichEdit_LineFromChar( hRichEdit, RichEdit_GetSel(hRichEdit)))
return

LimitText:	;Sets an upper limit to the amount of text the user can type or paste into a rich edit control
	RichEdit_LimitText( hRichEdit, 20 )  ; limit to 20 characters
return

TextMode:	;Sets text mode.
	txt := RichEdit_GetText( hRichEdit, 0, -1 )
	RichEdit_SetText(hRichEdit)
	RichEdit_TextMode(hRichEdit, "RICHTEXT") 
	RichEdit_SetText(hRichEdit, txt)
return