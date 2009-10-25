/*
 Function: Copy
		   Copy.
 */ 
Edit_Copy(hEdit) { 
    Static WM_COPY:=0x301 
    SendMessage WM_COPY,0,0,,ahk_id %hEdit% 
} 

/*
 Function: Cut
		   Cut.
 */ 
Edit_Cut(hEdit) { 
    Static WM_CUT:=0x300 
    SendMessage WM_CUT,,,,ahk_id %hEdit% 
} 

/*
 Function: Paste
		   Paste.
 */ 
Edit_Paste(hEdit) { 
    Static WM_PASTE:=0x302 
    SendMessage WM_PASTE,0,0,,ahk_id %hEdit% 
} 

/*
 Function:	Undo
			Do undo operation

 Returns:
			TRUE if the Undo operation succeeds, FALSE otherwise
 */
Edit_Undo(hEdit) { 
	static WM_UNDO := 772 
	SendMessage, WM_UNDO,,,, ahk_id %hEdit% 
	return ErrorLevel
}

/*
 Function:	Redo
			Do redo operation

 Returns:
			TRUE if the Redo operation succeeds, FALSE otherwise
 */
Edit_Redo(hEdit) { 
	static EM_REDO := 1108 
	SendMessage, EM_REDO,,,, ahk_id %hEdit%    
	return ErrorLevel
}