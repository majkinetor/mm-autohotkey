


ATOU( ByRef Unicode, Ansi ) { ; Ansi to Unicode
 VarSetCapacity( Unicode, (Len:=StrLen(Ansi))*2+1, 0 )
 Return DllCall( "MultiByteToWideChar", Int,0,Int,0,Str,Ansi,UInt,Len, Str,Unicode, UInt,Len )
}

UTOA( pUnicode )  {           ; Unicode to Ansi
  VarSetCapacity( Ansi,(nSz:=DllCall( "lstrlenW", UInt,pUnicode )+1) )
  DllCall( "WideCharToMultiByte", Int,0, Int,0, UInt,pUnicode, UInt,nSz+1
                                , Str,Ansi, UInt,nSz+1, Int,0, Int,0 )
Return Ansi
}



/*
	Function:	SetEvents
			Set notification events.

	Parameters:
			Handler	- Function that handles events. If empty, any existing handler will be removed.
			Events	- White space separated list of events to monitor.

	Handler:
 >     	Result := Handler(hCtrl, Event, p1, p2, p3 )

		hCtrl	- Handle of richedit control sending the event.
		Event - Specifies event that occurred. Event must be registered to be able to monitor it.
		Col,Row - Cell coordinates.
		Data	- Numeric data of the cell. Pointer to string for textual cells and DWORD value for numeric.
		Result  - Return 1 to prevent action.

	Events:
    CHANGE - Sent when the user has taken an action that may have altered text in an edit control.
             Sent after the system updates the screen. (***)
    DRAGDROPDONE - Notifies a rich edit control's parent window that the drag-and-drop
                   operation has completed.
        - p1
        - p2

        P1 - Number of characters highlighted in drag-drop operation.
        P2 - Beginning character position of range.
        P3 - Ending character position of range.
    DROPFILES - Notifies that the user is attempting to drop files into the control.
      P1 - Number of files dropped onto rich edit control.
      P2 - Newline delimited (`n) list of files dropped onto control.
      P3 - Character position files were dropped onto within rich edit control.
    KEYEVENTS - Notification of a keyboard or mouse event in the control. To ignore the
                event, the handler function should return a nonzero value.  (*** needs redone)
      P1 - Character position files were dropped onto within rich edit control.
           258="KEYPRESS_DWN",513="MOUSE_L_DWN",514="MOUSE_L_UP",516="MOUSE_R_DWN",
           517="MOUSE_R_UP",522="SCROLL_BEGIN",277="SCROLL_END" ;,512="MOUSE_HOVER",256="KEYPRESS_UP"
    MOUSEEVENTS,SCROLLEVENTS,
    LINK - A rich edit control sends these messages when it receives various messages, when the
           user clicks the mouse or when the mouse pointer is over text that has the LINK effect.
          (*** expand usefulness)
    PROTECTED - User is taking an action that would change a protected range of text.  To ignore
                the event, the handler function should return a nonzero value.
    REQUESTRESIZE - This message notifies a rich edit control's parent window that the control's
                    contents are either smaller or larger than the control's window size.
      P1 - Requested new size.
    SELCHANGE - The current selection has changed.
      P1 - Beginning character position of range.
      P2 - Ending character position of range.

 Returns:
			The previous event mask (number).
 */
RichEdit_SetEvents(hCtrl, Handler="", Events="selchange"){
  static ENM_CHANGE=0x1,ENM_DRAGDROPDONE=0x10,ENM_DROPFILES:=0x100000,ENM_KEYEVENTS=0x10000,ENM_LINK=0x4000000,ENM_MOUSEEVENTS=0x20000,ENM_PROTECTED=0x200000,ENM_REQUESTRESIZE=0x40000,ENM_SCROLLEVENTS=0x8,ENM_SELCHANGE=0x80000 ;ENM_OBJECTPOSITIONS=0x2000000,ENM_SCROLL=0x4,ENM_UPDATE=0x2   ***
       , sEvents="CHANGE,DRAGDROPDONE,DROPFILES,KEYEVENTS,LINK,MOUSEEVENTS,PROTECTED,REQUESTRESIZE,SCROLLEVENTS,SELCHANGE,SCROLL"
  static WM_NOTIFY=0x4E,WM_COMMAND=0x111,EM_SETEVENTMASK=69,WM_USER=0x400, oldNotify, oldCOMMAND

	if (Handler = "")
		return OnMessage(WM_NOTIFY, old != "RichEdit_onNotify" ? old : ""), old := ""

	if !IsFunc(Handler)
		return A_ThisFunc "> Invalid handler: " Handler

  StringUpper, Events,Events
	hMask := 0
	loop, parse, Events, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField,,continue
		if A_LoopField not in %sEvents%
			return A_ThisFunc "> Invalid event: " A_LoopField
		hMask |= ENM_%A_LOOPFIELD%
    If (A_LoopField = "DROPFILES")
      DllCall("shell32.dll\DragAcceptFiles", Int,hCtrl  , Int,TRUE)
; 		if A_LoopField in CHANGE,SCROLL   ; (*** WIP)
;     	if !oldCOMMAND {
;     		oldCOMMAND := OnMessage(WM_COMMAND, "RichEdit_onNotify")
;     		if oldCOMMAND != RichEdit_onNotify
;     			RichEdit("oldCOMMAND", RegisterCallback(oldCOMMAND))
;     	}
	}
	
	if !oldNotify {
		oldNotify := OnMessage(WM_NOTIFY, "RichEdit_onNotify")
		if oldNotify != RichEdit_onNotify
			RichEdit("oldNotify", RegisterCallback(oldNotify))
	}

	RichEdit(hCtrl "Handler", Handler)
  SendMessage, WM_USER | EM_SETEVENTMASK, 0,hMask,, ahk_id %hCtrl%
  return ERRORLEVEL  ; This message returns the previous event mask
}

EM_GETEVENTMASK(hCtrl)  {
  static EM_GETEVENTMASK=59,WM_USER=0x400
  SendMessage, WM_USER | EM_GETEVENTMASK, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; This message returns the event mask for the rich edit control.
}


;========================================== PRIVATE ===============================================================

RichEdit_onNotify(wparam, lparam, msg, hwnd) {
	static MODULEID := 091009, oldNotify="*", oldCOMMAND="*"

  Critical
	if (_ := (NumGet(Lparam+4))) != MODULEID
	 ifLess _, 10000, return	;if ahk control, return asap (AHK increments control ID starting from 1. Custom controls use IDs > 10000 as its unlikely that u will use more then 10K ahk controls.
	 else {
	 
		ifEqual, oldNotify, *, SetEnv, oldNotify, % RichEdit("oldNotify")
		if oldNotify !=
			return DllCall(oldNotify, "uint", Wparam, "uint", Lparam, "uint", Msg, "uint", Hwnd)
			
; 		ifEqual, oldCOMMAND, *, SetEnv, oldCOMMAND, % RichEdit("oldCOMMAND")
; 		if oldCOMMAND !=
; 			return DllCall(oldCOMMAND, "uint", Wparam, "uint", Lparam, "uint", Msg, "uint", Hwnd)
			
	 }

	hw :=  NumGet(Lparam+0), code := NumGet(Lparam+8, 0, "UInt"),  handler := RichEdit(hw "Handler")
	ifEqual, handler,,return (code=1796) ? TRUE : FALSE  ;ENM_PROTECTED- msg returns nonzero value to prevent operation

;  msgbox, % code
; return

  If (code = 1792)       {          ; ENM_MOUSEEVENTS ENM_KEYEVENTS ENM_SCROLLEVENTS
    Umsg := NumGet(lparam+12)  ;Keyboard or mouse message identifier.
    key := ((n:=NumGet(lparam+40))>=32) ? Chr(n) : ""
    static 258="KEYPRESS_DWN",513="MOUSE_L_DWN",514="MOUSE_L_UP",516="MOUSE_R_DWN",517="MOUSE_R_UP",522="SCROLL_BEGIN",277="SCROLL_END" ;,512="MOUSE_HOVER",256="KEYPRESS_UP"
    If (%Umsg%)   ;***
      return %handler%(hw, %Umsg%, key, "", "")
  }

  Else If (code = 1793)  {          ; ENM_REQUESTRESIZE
    rc := NumGet(lparam+24) ;Requested new size.
    return %handler%(hw, "REQUESTRESIZE", rc, "", "")
  }

  Else If (code = 1794)  {          ; ENM_SELCHANGE
    cpMin := NumGet(lparam+12), cpMax := NumGet(lparam+16) ;,seltyp := NumGet(lparam+20) (***)
;     SEL_TEXT = 0x1
;     SEL_OBJECT = 0x2
;     SEL_MULTICHAR = 0x4
;     SEL_MULTIOBJECT = 0x8
    return %handler%(hw, "SELCHANGE", cpMin, cpMax, "")
  }

  Else If (code = 1795)  {          ; ENM_DROPFILES
     hDrop := NumGet(lparam+8, 4 , "UInt"), cp := NumGet(lparam+8, 8 , "Int")

    ; (thanks DerRaphael!)  http://www.autohotkey.com/forum/post-234905.html&highlight=#234905
    Loop,% file_count := DllCall("shell32.dll\DragQueryFile","uInt",hDrop,"uInt",0xFFFFFFFF,"uInt",0,"uInt",0) {
       VarSetCapacity(lpSzFile,4096,0)
       DllCall("shell32.dll\DragQueryFile","uInt",hDrop,"uInt",A_index-1,"uInt",&lpSzFile,"uInt",4096)
       VarSetCapacity(lpSzFile,-1)
       files .= ((A_Index>1) ? "`n" : "") lpSzFile
    }
    return %handler%(hw, "DROPFILES", file_count, files, cp)
  }

  Else If (code = 1804)  {          ; ENM_DRAGDROPDONE
    chars := NumGet(lparam+12), cpMax := NumGet(lparam+16)
    return %handler%(hw, "DRAGDROPDONE", chars, cpMax-chars, cpMax)
  }

  Else If (code = 1796)  {          ; ENM_PROTECTED
    cpMin := NumGet(lparam+24), cpMax := NumGet(lparam+28)
    return %handler%(hw, "PROTECTED", cpMin, cpMax, "") ; This message returns a nonzero value to prevent the operation.
  }
  
  Else If (code = 1803)  {          ; ENM_LINK
   Umsg := NumGet(lparam+12)
   If Umsg Not In 513,516
    return
   cpMin := NumGet(lparam+24), cpMax := NumGet(lparam+28)
   return %handler%(hw, "LINK", (Umsg = 513 ? "LClick" : "RClick"), cpMin, cpMax) ; This message returns a nonzero value to prevent the operation.
  }
}

;Storage
RichEdit(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") {
	static
	 _ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}



;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------

/*
--Messages--
; http://msdn.microsoft.com/en-us/library/cc656557(VS.85).aspx
EM_AUTOURLDETECT
EM_CANPASTE
EM_CANREDO
EM_DISPLAYBAND
EM_EXGETSEL
EM_EXLIMITTEXT
EM_EXLINEFROMCHAR
EM_EXSETSEL -
EM_FINDTEXT
EM_FINDTEXTEX
EM_FINDTEXTEXW
EM_FINDTEXTW
EM_FINDWORDBREAK
EM_FORMATRANGE
EM_GETAUTOURLDETECT    ;----------------- RE_Get()
EM_GETBIDIOPTIONS
EM_GETCHARFORMAT
EM_GETCTFMODEBIAS     *** ??? constant?
EM_GETCTFOPENSTATUS   *** ??? constant?
EM_GETEDITSTYLE
EM_GETEVENTMASK
EM_GETHYPHENATEINFO   *** ??? constant?
EM_GETIMECOLOR
EM_GETIMECOMPMODE
EM_GETIMECOMPTEXT   *** ??? constant?
EM_GETIMEMODEBIAS
EM_GETIMEOPTIONS
EM_GETIMEPROPERTY   *** ??? constant?
EM_GETLANGOPTIONS
EM_GETOLEINTERFACE
EM_GETOPTIONS
EM_GETPAGEROTATE   *** ??? constant?
EM_GETPARAFORMAT
EM_GETPUNCTUATION
EM_GETREDONAME
EM_GETSCROLLPOS
EM_GETSELTEXT
EM_GETTEXTEX
EM_GETTEXTLENGTHEX
EM_GETTEXTMODE
EM_GETTEXTRANGE
EM_GETTYPOGRAPHYOPTIONS
EM_GETUNDONAME
EM_GETWORDBREAKPROCEX
EM_GETWORDWRAPMODE
EM_GETZOOM      ;----------------- end RE_Get()

EM_HIDESELECTION
EM_ISIME     
EM_PASTESPECIAL
EM_RECONVERSION
EM_REDO
EM_REQUESTRESIZE

EM_SELECTIONTYPE    ;----------------- RE_Set()
EM_SETBIDIOPTIONS
EM_SETBKGNDCOLOR
EM_SETCHARFORMAT
EM_SETCTFMODEBIAS     *** ??? constant?
EM_SETCTFOPENSTATUS   *** ??? constant?
EM_SETEDITSTYLE
EM_SETEVENTMASK
EM_SETFONTSIZE
EM_SETHYPHENATEINFO   *** ??? constant?
EM_SETIMECOLOR
EM_SETIMEMODEBIAS
EM_SETIMEOPTIONS
EM_SETLANGOPTIONS
EM_SETOLECALLBACK
EM_SETOPTIONS
EM_SETPAGEROTATE   *** ??? constant?
EM_SETPALETTE
EM_SETPARAFORMAT
EM_SETPUNCTUATION
EM_SETSCROLLPOS
EM_SETTARGETDEVICE
EM_SETTEXTEX
EM_SETTEXTMODE
EM_SETTYPOGRAPHYOPTIONS
EM_SETUNDOLIMIT
EM_SETWORDBREAKPROCEX
EM_SETWORDWRAPMODE
EM_SETZOOM
EM_SHOWSCROLLBAR
EM_STOPGROUPTYPING    ;----------------- end RE_Set()
EM_STREAMIN
EM_STREAMOUT

RE_ReplaceSel ??
*/

/*

http://msdn.microsoft.com/en-us/library/cc656458(VS.85).aspx

EM_CANUNDO
EM_CHARFROMPOS
EM_EMPTYUNDOBUFFER
EM_FMTLINES
EM_GETCUEBANNER
EM_GETFIRSTVISIBLELINE
EM_GETHANDLE
EM_GETHILITE
EM_GETIMESTATUS
EM_GETLIMITTEXT
EM_GETLINE
EM_GETLINECOUNT
EM_GETMARGINS
EM_GETMODIFY
EM_GETPASSWORDCHAR
EM_GETRECT
EM_GETSEL
EM_GETTHUMB
EM_GETWORDBREAKPROC
EM_HIDEBALLOONTIP
EM_LIMITTEXT
EM_LINEFROMCHAR
EM_LINEINDEX
EM_LINELENGTH
EM_LINESCROLL
EM_POSFROMCHAR
EM_REPLACESEL
EM_SCROLL
EM_SCROLLCARET
EM_SETCUEBANNER
EM_SETHANDLE
EM_SETHILITE
EM_SETIMESTATUS
EM_SETLIMITTEXT
EM_SETMARGINS
EM_SETMODIFY
EM_SETPASSWORDCHAR
EM_SETREADONLY
EM_SETRECT
EM_SETRECTNP
EM_SETSEL
EM_SETTABSTOPS
EM_SETWORDBREAKPROC
EM_SHOWBALLOONTIP
EM_UNDO
WM_UNDO
*/


; The EM_CANPASTE message determines whether a rich edit control can paste a specified clipboard format.
; http://msdn.microsoft.com/en-us/library/bb787993(VS.85).aspx
EM_CANPASTE(hCtrl)  {

;   static EM_CANPASTE=50,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_CANPASTE, 0,&@??,, ahk_id %hCtrl%


;   wParam
;   Specifies the Clipboard Formats to try. To try any format currently on the clipboard, set this parameter to zero.
;   lParam
;   This parameter is not used; it must be zero.
;   Return Value
;
;   Return Value
;   If the clipboard format can be pasted, the return value is a nonzero value.
;   If the clipboard format cannot be pasted, the return value is zero.

}




EM_DISPLAYBAND(hCtrl)  {
  static EM_DISPLAYBAND=51,WM_USER=0x400

  VarSetCapacity(RECT, 16, 0)
  left := 10, top := 10, right := 70, bottom := 100
    NumPut(left, RECT, 0, "Int")
    NumPut(top, RECT, 4, "Int")
    NumPut(right, RECT, 8, "Int")
    NumPut(bottom, RECT, 12, "Int")

  SendMessage, WM_USER | EM_DISPLAYBAND, 0,&RECT,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If the operation succeeds, the return value is TRUE.
}



; EM_FINDTEXT(hCtrl, lpstrText)  {
EM_FINDTEXT(hCtrl, Flags="D", FindWhat="", ReplaceWith="")  {
  static EM_FINDTEXT=56,WM_USER=0x400
	static FR_DOWN=1, FR_MATCHCASE=4, FR_WHOLEWORD=2    ;,FR_HIDEMATCHCASE=0x8000, FR_HIDEWHOLEWORD=0x10000, FR_HIDEUPDOWN=0x4000
	static buf, FR, len := 256
	hexFlags := 0
	hexFlags |= InStr(flags, "d") ? FR_DOWN      : 0
	hexFlags |= InStr(flags, "c") ? FR_MATCHCASE : 0
	hexFlags |= InStr(flags, "w") ? FR_WHOLEWORD : 0
; 	f |= InStr(flags, "-d") ? FR_HIDEUPDOWN : 0
; 	f |= InStr(flags, "-w") ? FR_HIDEWHOLEWORD :0
; 	f |= InStr(flags, "-c") ? FR_HIDEMATCHCASE :0

;   FINDTEXT_CHARRANGE := NumGet(FINDTEXT, 0, "UInt")
;   FINDTEXT_lpstrText := NumGet(FINDTEXT, 8, "UInt")
;   ;--
;   NumPut(FINDTEXT_CHARRANGE, FINDTEXT, 0, "UInt")
; 	VarSetCapacity(CHARRANGE, 8, 0)
; NumPut(cpMin, CHARRANGE, 0, "Int"), NumPut(cpMax ? cpMax : cpMin, CHARRANGE, 4, "Int")
  VarSetCapacity(FINDTEXT, 12, 0)
  NumPut(0, FINDTEXT, 0, "Int")
  NumPut(100, FINDTEXT, 4, "Int")
  NumPut(&lpstrText, FINDTEXT, 8, "UInt")
  SendMessage, WM_USER | EM_FINDTEXT, hexFlags,&FINDTEXT,, ahk_id %hCtrl%
  MsgBox, % ERRORLEVEL  "`n`n"  
;   MsgBox, % NumGet(FINDTEXT, 0, "UInt")
  ;------------------------
  ; typedef struct _findtext {
  ;     CHARRANGE chrg;
  ;     LPCTSTR lpstrText;
  ; } FINDTEXT;
}
EM_FINDTEXTEX(hCtrl, lpstrText)  {
  static EM_FINDTEXTEX=79,WM_USER=0x400
  VarSetCapacity(FINDTEXTEX, 20, 0)
;   FINDTEXTEX_chrg := NumGet(FINDTEXTEX, 0, "UInt")
;   FINDTEXTEX_lpstrText := NumGet(FINDTEXTEX, 8, "UInt")
;   FINDTEXTEX_chrgText := NumGet(FINDTEXTEX, 12, "UInt")
  ;--
;   NumPut(FINDTEXTEX_chrg, FINDTEXTEX, 0, "UInt")
  NumPut(lpstrText, FINDTEXTEX, 8, "UInt")
;   NumPut(FINDTEXTEX_chrgText, FINDTEXTEX, 12, "UInt")

  SendMessage, WM_USER | EM_FINDTEXTEX, 1,&FINDTEXTEX,, ahk_id %hCtrl%
  MsgBox, % NumGet(FINDTEXTEX, 12, "UInt") " | " NumGet(FINDTEXTEX, 16, "UInt")
;   MSGBOX, % ERRORLEVEL
}
EM_FINDTEXTEXW(hCtrl)  {
;   static EM_FINDTEXTEXW=124,WM_USER=0x400
;   SendMessage, WM_USER | EM_FINDTEXTEXW, 0,&@??,, ahk_id %hCtrl%
}
EM_FINDTEXTW(hCtrl)  {
;   static EM_FINDTEXTW=123,WM_USER=0x400
;   SendMessage, WM_USER | EM_FINDTEXTW, 0,&@??,, ahk_id %hCtrl%
}


EM_FINDWORDBREAK(hCtrl)  {
;   static EM_FINDWORDBREAK=76,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_FINDWORDBREAK, 0,&@??,, ahk_id %hCtrl%

}


EM_FORMATRANGE(hCtrl)  {
  static EM_FORMATRANGE=57,WM_USER=0x400
  VarSetCapacity(FORMATRANGE, 48, 0)
    NumPut(hDC, FORMATRANGE, 0, "UInt") ;FORMATRANGE_hdc
    NumPut(hDCTarget, FORMATRANGE, 4, "UInt") ;FORMATRANGE_hdcTarget (use EM_SETTARGETDEVICE() )
    NumPut(0, FORMATRANGE, 8, "Int") ;FORMATRANGE_rc_left
    NumPut(0, FORMATRANGE, 12, "Int") ;FORMATRANGE_rc_top
    NumPut(200, FORMATRANGE, 16, "Int") ; FORMATRANGE_rc_right
    NumPut(300, FORMATRANGE, 20, "Int") ; FORMATRANGE_rc_bottom
    NumPut(0, FORMATRANGE, 24, "Int") ; FORMATRANGE_rcPage_left
    NumPut(0, FORMATRANGE, 28, "Int") ; FORMATRANGE_rcPage_top
    NumPut(200, FORMATRANGE, 32, "Int") ; FORMATRANGE_rcPage_right
    NumPut(300, FORMATRANGE, 36, "Int") ; FORMATRANGE_rcPage_bottom
    NumPut(0, FORMATRANGE, 40, "UInt") ; CHARRANGE-min
    NumPut(200, FORMATRANGE, 40, "UInt") ; ; CHARRANGE-max
  SendMessage, WM_USER | EM_FORMATRANGE, 1,&FORMATRANGE,, ahk_id %hCtrl%
  MsgBox, % "EM_FORMATRANGE: " errorlevel  ;This message returns the index of the last character that fits in the region, plus 1.

;-- CLEANUP

  ; It is very important to free cached information after the last time you use this message by
  ; specifying NULL in lParam. In addition, after using this message for one device, you must free
  ; cached information before using it again for a different device.
  SendMessage, WM_USER | EM_FORMATRANGE, 0,0,, ahk_id %hCtrl%
;   DllCall("DeleteDC","uint",hDC)
}


EM_GETBIDIOPTIONS(hCtrl)  {
  static EM_GETBIDIOPTIONS=201,WM_USER=0x400

  VarSetCapacity(BIDIOPTIONS, 8, 0), cbSize := 8

  ; typedef struct _bidioptions {
     NumPut(cbSize, BIDIOPTIONS, 0, "UInt")
  ;   NumPut(BIDIOPTIONS_wMask, BIDIOPTIONS, 4, "UShort")
  ;   NumPut(BIDIOPTIONS_wEffects, BIDIOPTIONS, 6, "UShort")
  ; }

  SendMessage, WM_USER | EM_GETBIDIOPTIONS, 0,&BIDIOPTIONS,, ahk_id %hCtrl%
;   MsgBox, % errorlevel    ; This message does not return a value.

  ; typedef struct _bidioptions {
  ;   BIDIOPTIONS_cbSize := NumGet(BIDIOPTIONS, 0, "UInt")
  ;   BIDIOPTIONS_wMask := NumGet(BIDIOPTIONS, 4, "UShort")
  MsgBox, % wEffects := NumGet(BIDIOPTIONS, 6, "UShort")
  ; }

  static BOE_RTLDIR=0x1,BOE_PLAINTEXT=0x2,BOE_NEUTRALOVERRIDE=0x4,BOE_CONTEXTREADING=0x8,BOE_CONTEXTALIGNMENT=0x10,BOE_LEGACYBIDICLASS=0x00000040
; RTLDIR - Default paragraph direction—implies alignment (obsolete).
; PLAINTEXT - Uses plain text layout (obsolete).
; NEUTRALOVERRIDE - Overrides neutral layout.
; CONTEXTREADING - Context reading order.
; CONTEXTALIGNMENT - Context alignment.
; LEGACYBIDICLASS - Causes the plus and minus characters to be treated as neutral characters with no implied direction. Also causes the slash character to be treated as a common separator.
}
EM_SETBIDIOPTIONS(hCtrl)  {
  static EM_SETBIDIOPTIONS=200,WM_USER=0x400
  static BOM_DEFPARADIR=0x1,BOM_PLAINTEXT=0x2,BOM_NEUTRALOVERRIDE=0x4,BOM_CONTEXTREADING=0x8,BOM_CONTEXTALIGNMENT=0x10,BOM_LEGACYBIDICLASS=0x0040
  static BOE_RTLDIR=0x1,BOE_PLAINTEXT=0x2,BOE_NEUTRALOVERRIDE=0x4,BOE_CONTEXTREADING=0x8,BOE_CONTEXTALIGNMENT=0x10,BOE_LEGACYBIDICLASS=0x00000040

  VarSetCapacity(BIDIOPTIONS, 8, 0), cbSize := 8
  wMask := wEffects := 0
  ;   Loop, Parse, effects,
  ;     If A_LoopField In PLAINTEXT,NEUTRALOVERRIDE,CONTEXTREADING,CONTEXTALIGNMENT
  ;       wMask := wEffects |= BOE_%A_LoopField%

  wMask := wEffects |= BOE_RTLDIR
  ; typedef struct _bidioptions {
     NumPut(cbSize, BIDIOPTIONS, 0, "UInt")
     NumPut(wMask, BIDIOPTIONS, 4, "UShort")
     NumPut(wEffects, BIDIOPTIONS, 6, "UShort")
  ; }1
  SendMessage, WM_USER | EM_SETBIDIOPTIONS, 0,&BIDIOPTIONS,, ahk_id %hCtrl%
;   MsgBox, % errorlevel    ; This message does not return a value.
}



EM_GETCTFMODEBIAS(hCtrl)  {
  static EM_GETCTFMODEBIAS=237,WM_USER=0x400
  SendMessage, WM_USER | EM_GETCHARFORMAT, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; The current Text Services Framework mode bias value.
}

EM_GETCTFOPENSTATUS(hCtrl)  {
  static EM_GETCTFOPENSTATUS=240,WM_USER=0x400
  SendMessage, WM_USER | EM_GETCTFOPENSTATUS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; If the TSF keyboard is open, the return value is TRUE. Otherwise, it is FALSE.
}

EM_GETEDITSTYLE(hCtrl)  {
  static EM_GETEDITSTYLE=205,WM_USER=0x400
  SendMessage, WM_USER | EM_GETEDITSTYLE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; The return value can be one or more of the following values...
}


EM_GETHYPHENATEINFO(hCtrl)  {   ; richedit 4.1 only (msftedit.dll)
  static EM_GETHYPHENATEINFO=230,WM_USER=0x400

  pfnHyphenate := RegisterCallback( "RichEdit_hyphenateProc" )
  VarSetCapacity(HYPHENATEINFO, 12, 0), cbSize := 12

  ; typedef struct tagHyphenateInfo {
  ;   HYPHENATEINFO_cbSize := NumGet(HYPHENATEINFO, 0, "Short")
  ;   HYPHENATEINFO_dxHyphenateZone := NumGet(HYPHENATEINFO, 2, "Short")
  ;   HYPHENATEINFO_pfnHyphenate := NumGet(HYPHENATEINFO, 4, "UInt")
  ; }

  ; typedef struct tagHyphenateInfo {
     NumPut(cbSize, HYPHENATEINFO, 0, "Short")
  ;   NumPut(HYPHENATEINFO_dxHyphenateZone, HYPHENATEINFO, 2, "Short")
     NumPut(pfnHyphenate, HYPHENATEINFO, 4, "UInt")
  ; }
  SendMessage, WM_USER | EM_GETHYPHENATEINFO, &HYPHENATEINFO,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; There is no return value.
}
EM_SETHYPHENATEINFO(hCtrl)  {
  static EM_SETHYPHENATEINFO=231,WM_USER=0x400

  pfnHyphenate := RegisterCallback( "RichEdit_hyphenateProc" )
  VarSetCapacity(HYPHENATEINFO, 12, 0), cbSize := 12

  ; typedef struct tagHyphenateInfo {
  ;   HYPHENATEINFO_cbSize := NumGet(HYPHENATEINFO, 0, "Short")
  ;   HYPHENATEINFO_dxHyphenateZone := NumGet(HYPHENATEINFO, 2, "Short")
  ;   HYPHENATEINFO_pfnHyphenate := NumGet(HYPHENATEINFO, 4, "UInt")
  ; }

  ; typedef struct tagHyphenateInfo {
     NumPut(cbSize, HYPHENATEINFO, 0, "Short")
  ;   NumPut(HYPHENATEINFO_dxHyphenateZone, HYPHENATEINFO, 2, "Short")
     NumPut(pfnHyphenate, HYPHENATEINFO, 4, "UInt")
  ; }
  SendMessage, WM_USER | EM_SETHYPHENATEINFO, &HYPHENATEINFO,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; There is no return value.

  ;To enable hyphenation, the client must call EM_SETTYPOGRAPHYOPTIONS, specifying TO_ADVANCEDTYPOGRAPHY
}
RichEdit_hyphenateProc( pszWord, langid, ichExceed, phyphresult )  {
  ToolTip, pszWord = %pszWord% `nlangid = %langid% `nichExceed = %ichExceed% `nphyphresult = %phyphresult%
}





EM_GETIMECOMPMODE(hCtrl)  {
  static EM_GETIMECOMPMODE=122,WM_USER=0x400
  SendMessage, WM_USER | EM_GETIMECOMPMODE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; The return value is one of the following values...

  static ICM_NOTOPEN=0x0,ICM_LEVEL3=0x1,ICM_LEVEL2=0x2,ICM_LEVEL2_5=0x3,ICM_LEVEL2_SUI=0x4
; ICM_NOTOPEN	- Input Method Editor (IME) is not open.
; ICM_LEVEL3 - 	True inline mode.
; ICM_LEVEL2 - 	Level 2.
; ICM_LEVEL2_5 - 	Level 2.5
; ICM_LEVEL2_SUI - Special user interface (UI).
}


EM_GETIMECOMPTEXT(hCtrl)  {
  static EM_GETIMECOMPTEXT=242,WM_USER=0x400

  VarSetCapacity(IMECOMPTEXT, 8, 0)

  ; typedef struct _imecomptext {
  ;   IMECOMPTEXT_cb := NumGet(IMECOMPTEXT, 0, "Int")
  ;   IMECOMPTEXT_flags := NumGet(IMECOMPTEXT, 4, "UInt")
  ; }

  ; typedef struct _imecomptext {
  ;   NumPut(IMECOMPTEXT_cb, IMECOMPTEXT, 0, "Int")
  ;   NumPut(IMECOMPTEXT_flags, IMECOMPTEXT, 4, "UInt")
  ; }
  SendMessage, WM_USER | EM_GETIMECOMPTEXT, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If successful, # of Unicode characters copied to the buffer. Otherwise, zero.
}

EM_GETIMEMODEBIAS(hCtrl)  {
  static EM_GETIMEMODEBIAS=127,WM_USER=0x400
  SendMessage, WM_USER | EM_GETIMEMODEBIAS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; This message returns the current IME mode bias setting.
}

EM_GETIMEOPTIONS(hCtrl)  {
  static EM_GETIMEOPTIONS=107,WM_USER=0x400
  SendMessage, WM_USER | EM_GETIMEOPTIONS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; This message returns one or more of the IME option flag values described in the EM_SETIMEOPTIONS message..
}

EM_GETIMEPROPERTY(hCtrl)  {
  static EM_GETIMEPROPERTY=244,WM_USER=0x400
  static IGP_PROPERTY=0x4,IGP_CONVERSION=0x8,IGP_SENTENCE=0xC,IGP_UI=0x10,IGP_SETCOMPSTR=0x14,IGP_SELECT=0x18,IGP_GETIMEVERSION=-4

  type := IGP_PROPERTY  ;one of the following values..
  ; IGP_PROPERTY - Property information.
  ; IGP_CONVERSION - Conversion capabilities.
  ; IGP_SENTENCE - Sentence mode capabilities.
  ; IGP_UI - User interface capabilities.
  ; IGP_SETCOMPSTR - Composition string capabilities.
  ; IGP_SELECT - Selection inheritance capabilities.
  ; IGP_GETIMEVERSION - Retrieves the system version number for which the specified IME was created.

  SendMessage, WM_USER | EM_GETIMEPROPERTY, type,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; Returns the property or capability value, depending on the value of the lParam
}

EM_GETLANGOPTIONS(hCtrl)  {
  static EM_GETLANGOPTIONS=121,WM_USER=0x400
  SendMessage, WM_USER | EM_GETLANGOPTIONS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; one or more of the following values, which indicate the current language option settings.
  
  static IMF_AUTOFONT=0x2,IMF_AUTOFONTSIZEADJUST=0x10,IMF_AUTOKEYBOARD=0x1,IMF_DUALFONT=0x80,IMF_IMEALWAYSSENDNOTIFY=0x8,IMF_IMECANCELCOMPLETE=0x4,IMF_UIFONTS=0x20
}


EM_GETOPTIONS(hCtrl)  {
  static EM_GETOPTIONS=78,WM_USER=0x400
  SendMessage, WM_USER | EM_GETOPTIONS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; This message returns a combination of the current option flag values described in the EM_SETOPTIONS message
}
EM_SETOPTIONS(hCtrl)  {
  static EM_SETOPTIONS=77,WM_USER=0x400

  static ECOOP_SET=0x1,ECOOP_OR=0x2,ECOOP_AND=0x3,ECOOP_XOR=0x4
; ECOOP_SET - Sets the options to those specified by lParam.
; ECOOP_OR - Combines the specified options with the current options.
; ECOOP_AND - Retains only those current options that are also specified by lParam.
; ECOOP_XOR - Logically exclusive OR the current options with those specified by lParam.
  operation := ECOOP_SET

  static ECO_AUTOWORDSELECTION=0x1,ECO_AUTOVSCROLL=0x40,ECO_AUTOHSCROLL=0x80,ECO_NOHIDESEL=0x100,ECO_READONLY=0x800,ECO_WANTRETURN=0x1000,ECO_SELECTIONBAR=0x1000000,ECO_VERTICAL=0x400000
; ECO_AUTOWORDSELECTION - Automatic selection of word on double-click.
; ECO_AUTOVSCROLL - Same as ES_AUTOVSCROLL style.
; ECO_AUTOHSCROLL - Same as ES_AUTOHSCROLL style.
; ECO_NOHIDESEL - Same as ES_NOHIDESEL style.
; ECO_READONLY - Same as ES_READONLY style.
; ECO_WANTRETURN - Same as ES_WANTRETURN style.
; ECO_SELECTIONBAR - Same as ES_SELECTIONBAR style.
; ECO_VERTICAL - Same as ES_VERTICAL style. Available in Asian-language versions only.
  flags=0
  flags |= ECO_READONLY
  flags |= ECO_SELECTIONBAR
  SendMessage, WM_USER | EM_SETOPTIONS, operation,flags,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; This message returns the current options of the edit control.
}


EM_GETPAGEROTATE(hCtrl)  {

; EPR_0 - Text flows from left to right and from top to bottom.
; EPR_90 - Text flows from left to right and from bottom to top.
; EPR_180 - Reserved.
; EPR_270 - Reserved.

  static EM_GETPAGEROTATE=235,WM_USER=0x400
  SendMessage, WM_USER | EM_GETPAGEROTATE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; Gets the current text layout.
}

EM_GETPARAFORMAT(hCtrl)  {
;   static EM_GETPARAFORMAT=61,WM_USER=0x400
;   SendMessage, WM_USER | EM_GETPARAFORMAT, 0,&PARAFORMAT,, ahk_id %hCtrl%
;   MsgBox, % errorlevel  ; If the operation succeeds, the return value is a nonzero value.
}



EM_GETPUNCTUATION(hCtrl)  {
  static EM_GETPUNCTUATION=101,WM_USER=0x400
  static PC_LEADING=2,PC_FOLLOWING=1,PC_DELIMITER=4,PC_OVERFLOW=3

;This structure is used only in Asian-language versions of the operating system.
    nType:=PC_FOLLOWING
  VarSetCapacity(PUNCTUATION, 8, 0)
  NumPut(4, PUNCTUATION, 0, "UInt") ; PUNCTUATION_iSize
  NumPut(&szPunctuation, PUNCTUATION, 4, "UInt")
  SendMessage, WM_USER | EM_GETPUNCTUATION, nType,&PUNCTUATION,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If the operation succeeds, the return value is a nonzero value.
  PUNCTUATION_iSize := NumGet(PUNCTUATION, 0, "UInt")
  szPunctuation:=NumGet(PUNCTUATION, 4, "UInt")
  msgbox, % DllCall("MulDiv", "Int",szPunctuation, "Int",1, "Int",1, "str")
}
EM_SETPUNCTUATION(hCtrl)  {
  static EM_SETPUNCTUATION=100,WM_USER=0x400
  static PC_LEADING=2,PC_FOLLOWING=1,PC_DELIMITER=4,PC_OVERFLOW=3
;This structure is used only in Asian-language versions of the operating system.
    nType:=PC_LEADING
  VarSetCapacity(PUNCTUATION, 8, 0)
  NumPut(PUNCTUATION_iSize, PUNCTUATION, 0, "UInt")
  NumPut(PUNCTUATION_szPunctuation, PUNCTUATION, 4, "UInt")
  SendMessage, WM_USER | EM_SETPUNCTUATION, nType,&PUNCTUATION,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If the operation succeeds, the return value is a nonzero value.
}








EM_GETTYPOGRAPHYOPTIONS(hCtrl)  {   ; Rich Edit 3.0
  static EM_GETTYPOGRAPHYOPTIONS=203,WM_USER=0x400
  SendMessage, WM_USER | EM_GETTYPOGRAPHYOPTIONS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; The return value can be one of the following values.
  
  static TO_ADVANCEDTYPOGRAPHY=1,TO_SIMPLELINEBREAK=2
}

EM_GETWORDBREAKPROCEX(hCtrl)  {
  static EM_GETWORDBREAKPROCEX=80,WM_USER=0x400
  SendMessage, WM_USER | EM_GETWORDBREAKPROCEX, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; The message returns the address of the current procedure.
}

EM_HIDESELECTION(hCtrl, value=true)  {
  static EM_HIDESELECTION=63,WM_USER=0x400
  SendMessage, WM_USER | EM_HIDESELECTION, (value ? true : false),0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; This message does not return a value.
}


EM_ISIME(hCtrl)  {  ; richedit 4.1 only (msftedit.dll)
  static EM_ISIME=243,WM_USER=0x400
  SendMessage, WM_USER | EM_ISIME, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; Returns TRUE if it is an East Asian locale. Otherwise, it returns FALSE.
}

EM_PASTESPECIAL(hCtrl)  {
  static EM_PASTESPECIAL=64,WM_USER=0x400

  ;Standard Clipboard Formats
  static CF_BITMAP=2,CF_DIB=8,CF_DIBV5=17,CF_DIF=5,CF_DSPBITMAP=0x82,CF_DSPENHMETAFILE=0x8E,CF_DSPMETAFILEPICT=0x83
        ,CF_DSPTEXT=0x81,CF_ENHMETAFILE=14,CF_GDIOBJFIRST=0x300,CF_GDIOBJLAST=0x3FF,CF_HDROP=15,CF_LOCALE=16
        ,CF_METAFILEPICT=3,CF_OEMTEXT=7,CF_OWNERDISPLAY=0x80,CF_PALETTE=9,CF_PENDATA=10,CF_PRIVATEFIRST=0x200
        ,CF_PRIVATELAST=0x2FF,CF_RIFF=11,CF_SYLK=4,CF_TEXT=1,CF_WAVE=12,CF_TIFF=6,CF_UNICODETEXT=13

  cbFormat := CF_BITMAP
  SendMessage, WM_USER | EM_PASTESPECIAL, cbFormat,&REPASTESPECIAL,, ahk_id %hCtrl%
;   MsgBox, % errorlevel  ; This message does not return a value.
}

EM_RECONVERSION(hCtrl)  {
  static EM_RECONVERSION=125,WM_USER=0x400
  SendMessage, WM_USER | EM_RECONVERSION, 0,0,, ahk_id %hCtrl%
;   MsgBox, % errorlevel  ; This message always returns zero.
}

EM_REQUESTRESIZE(hCtrl)  {
  static EM_REQUESTRESIZE=65,WM_USER=0x400
;This message is useful during WM_SIZE processing for the parent of a bottomless rich edit control.

  SendMessage, WM_USER | EM_REQUESTRESIZE, 0,0,, ahk_id %hCtrl%
;   MsgBox, % errorlevel  ; This message does not return a value.
}

EM_SELECTIONTYPE(hCtrl)  {
  static EM_SELECTIONTYPE=66,WM_USER=0x400
;This message is useful during WM_SIZE processing for the parent of a bottomless rich edit control.

  SendMessage, WM_USER | EM_SELECTIONTYPE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If the selection is empty, the return value is SEL_EMPTY.
          ; If not empty, the return value isset of flags containing one or more of the following values.
          
  static SEL_TEXT=0x1,SEL_OBJECT=0x2,SEL_MULTICHAR=0x4,SEL_MULTIOBJECT=0x8
}

EM_SETCTFMODEBIAS(hCtrl, mode)  {
  static EM_SETCTFMODEBIAS=238,WM_USER=0x400

  ;set the Text Services Framework (TSF) mode bias
  static CTFMODEBIAS_DEFAULT=0x0000,CTFMODEBIAS_FILENAME=0x0001,CTFMODEBIAS_NAME=0x0002,CTFMODEBIAS_READING=0x0003
        ,CTFMODEBIAS_DATETIME=0x0004,CTFMODEBIAS_CONVERSATION=0x0005,CTFMODEBIAS_NUMERIC=0x0006
        ,CTFMODEBIAS_HIRAGANA=0x0007,CTFMODEBIAS_KATAKANA=0x0008,CTFMODEBIAS_HANGUL=0x0009
        ,CTFMODEBIAS_HALFWIDTHKATAKANA=0x000A,CTFMODEBIAS_FULLWIDTHALPHANUMERIC=0x000B,CTFMODEBIAS_HALFWIDTHALPHANUMERIC=0x000C
  mode := CTFMODEBIAS_FILENAME    ; one of the following values.
  ; CTFMODEBIAS_DEFAULT -There is no mode bias.
  ; CTFMODEBIAS_FILENAME - The bias is to a filename.
  ; CTFMODEBIAS_NAME - The bias is to a name.
  ; CTFMODEBIAS_READING - The bias is to the reading.
  ; CTFMODEBIAS_DATETIME - The bias is to a date or time.
  ; CTFMODEBIAS_CONVERSATION - The bias is to a conversation.
  ; CTFMODEBIAS_NUMERIC - The bias is to a number.
  ; CTFMODEBIAS_HIRAGANA - The bias is to hiragana strings.
  ; CTFMODEBIAS_KATAKANA - The bias is to katakana strings.
  ; CTFMODEBIAS_HANGUL - The bias is to Hangul characters.
  ; CTFMODEBIAS_HALFWIDTHKATAKANA - The bias is to half-width katakana strings.
  ; CTFMODEBIAS_FULLWIDTHALPHANUMERIC - The bias is to full-width alphanumeric characters.
  ; CTFMODEBIAS_HALFWIDTHALPHANUMERIC - The bias is to half-width alphanumeric characters.

  SendMessage, EM_SETCTFMODEBIAS | WM_USER, mode,0,, ahk_id %hCtrl%
  MsgBox, % ERRORLEVEL ; If successful, the return value is the new TSF mode bias value. If unsuccessful, the return value is the old TSF mode bias value.
}

EM_SETCTFOPENSTATUS(hCtrl)  {
;Text Services Framework (TSF)
  static EM_SETCTFOPENSTATUS=241,WM_USER=0x400
  tsfKeyboard := true
  SendMessage, EM_SETCTFMODEBIAS | WM_USER, (tsfKeyboard ? true : false),0,, ahk_id %hCtrl%
  MsgBox, % ERRORLEVEL ; If successful, this message returns TRUE.
}

EM_SETEDITSTYLE(hCtrl)  {
;   static EM_SETEDITSTYLE=204,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETEDITSTYLE, 0,&@??,, ahk_id %hCtrl%

}


EM_SETIMEMODEBIAS(hCtrl)  {
;   static EM_SETIMEMODEBIAS=126,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETIMEMODEBIAS, 0,&@??,, ahk_id %hCtrl%

}

EM_SETIMEOPTIONS(hCtrl)  {
;   static EM_SETIMEOPTIONS=106,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETIMEOPTIONS, 0,&@??,, ahk_id %hCtrl%

}

EM_SETLANGOPTIONS(hCtrl)  {
;   static EM_SETLANGOPTIONS=120,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETLANGOPTIONS, 0,&@??,, ahk_id %hCtrl%

}

EM_SETPAGEROTATE(hCtrl)  {


  static EM_GETPAGEROTATE=236,WM_USER=0x400
  SendMessage, WM_USER | EM_GETPAGEROTATE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; Gets the current text layout.
}
EM_SETPALETTE(hCtrl)  {
;   static EM_SETPALETTE=93,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETPALETTE, 0,&@??,, ahk_id %hCtrl%

}
EM_SETPARAFORMAT(hCtrl)  {
;   static EM_SETPARAFORMAT=71,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETPARAFORMAT, 0,&@??,, ahk_id %hCtrl%

}

EM_SETTARGETDEVICE(hCtrl, width)  {

  ; http://www.codeproject.com/KB/printing/richeditprint.aspx?display=Print
  ; http://msdn.microsoft.com/en-us/library/ms646940(VS.85).aspx
  
  static hModule,PD_RETURNDC=0x100,PD_RETURNDEFAULT=0x400
  static EM_SETTARGETDEVICE=72,WM_USER=0x400

  If !hModule
    hModule := DllCall("LoadLibrary","str","comdlg32.dll")
  VarSetCapacity(PRINTDIALOG_STRUCT,66,0), NumPut(66,PRINTDIALOG_STRUCT)
  NumPut( PD_RETURNDC | PD_RETURNDEFAULT, PRINTDIALOG_STRUCT,20)
  If !DllCall("comdlg32\PrintDlgA","uint",&PRINTDIALOG_STRUCT)  {
    DllCall("FreeLibrary", "UInt", hModule), hModule := ""
    return false, errorlevel := "ERROR: Couldn't retrieve default printer."
  }

;   hDC := NumGet(PRINTDIALOG_STRUCT,16) ; default printers device context hwnd

  hDC := DllCall("GetDC","uint",hCtrl)
  SendMessage, WM_USER | EM_SETTARGETDEVICE, hdc,width*1440,, ahk_id %hCtrl%  ; line width in twips (1440 twips/inch)
  MsgBox, % errorlevel  ; The return value is zero if the operation fails, or nonzero if it succeeds.
;   DllCall("DeleteDC","uint",hDC)
}


EM_SETTYPOGRAPHYOPTIONS(hCtrl)  {
  static EM_SETTYPOGRAPHYOPTIONS=202,WM_USER=0x400,TO_ADVANCEDTYPOGRAPHY=1,TO_SIMPLELINEBREAK=2
  SendMessage, WM_USER | EM_SETTYPOGRAPHYOPTIONS, TO_ADVANCEDTYPOGRAPHY,TO_ADVANCEDTYPOGRAPHY,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If wParam is valid, the return value is TRUE.
}

EM_STOPGROUPTYPING(hCtrl)  {
  static EM_STOPGROUPTYPING=88,WM_USER=0x400
  SendMessage, WM_USER | EM_STOPGROUPTYPING, 0,0,, ahk_id %hCtrl%
}

EM_STREAMIN(hCtrl)  {
  static EM_STREAMIN=73,WM_USER=0x400
  static SF_RTF=0x2,SF_RTFNOOBJS=0x3,SF_TEXT=0x1,SF_TEXTIZED=0x4
  static SFF_PLAINRTF=0x4000,SFF_SELECTION=0x8000,SF_UNICODE=0x10,SF_USECODEPAGE=0x20

  wbProc := RegisterCallback("RichEdit_editStreamCallBack")
  VarSetCapacity(EDITSTREAM, 16, 0)
  NumPut(&dwCookie, EDITSTREAM, 0, "UInt") ; dwCookie
  NumPut(wbProc, EDITSTREAM, 8, "UInt")
  SendMessage, WM_USER | EM_STREAMIN, SF_TEXT,&EDITSTREAM,, ahk_id %hCtrl%
  MsgBox, % errorlevel
}
EM_STREAMOUT(hCtrl, byref out)  {
  static EM_STREAMOUT=74,WM_USER=0x400
  static SF_RTF=0x2,SF_RTFNOOBJS=0x3,SF_TEXT=0x1,SF_TEXTIZED=0x4
  static SFF_PLAINRTF=0x4000,SFF_SELECTION=0x8000,SF_UNICODE=0x10,SF_USECODEPAGE=0x20

  wbProc := RegisterCallback("RichEdit_editStreamCallBack")

  VarSetCapacity(EDITSTREAM, 16, 0)
  NumPut(&out, EDITSTREAM, 0, "UInt") ; dwCookie
  NumPut(wbProc, EDITSTREAM, 8, "UInt")

  SendMessage, WM_USER | EM_STREAMOUT, SF_RTF,&EDITSTREAM,, ahk_id %hCtrl%
  MsgBox, % DllCall("MulDiv", "Int",&out, "Int",1, "Int",1, "str")
;   MsgBox, % errorlevel
}

RichEdit_editStreamCallBack(dwCookie, pbBuff, cb, pcb) {
; ToolTip, % "1- "dwCookie "`n2- " pbBuff "`n3- " cb "`n4- " pcb "`n---`n" buffer


;   MsgBox, % buffer := DllCall("MulDiv", "Int",pbBuff, "Int",1, "Int",1, "str")

  DllCall("lstrcpy", "UInt", dwCookie1, "Str", &pbBuff)
  MsgBox, % dwCookie1
}

____Redundant____:
RETURN

EM_SETFONTSIZE(hCtrl)  {
;   static EM_SETFONTSIZE=223,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETFONTSIZE, 0,&@??,, ahk_id %hCtrl%

}


____Asian_Only____:
RETURN

EM_GETIMECOLOR(hCtrl)  {
; This message is available only in Asian-language versions of the operating system.
;   static EM_GETIMECOLOR=105,WM_USER=0x400
;   SendMessage, WM_USER | EM_GETIMECOLOR, 0,&@??,, ahk_id %hCtrl%
}

EM_SETIMECOLOR(hCtrl)  {
; This message is available only in Asian-language versions of the operating system.
;   static EM_SETIMECOLOR=104,WM_USER=0x400
;   SendMessage, WM_USER | EM_SETIMECOLOR, 0,&@??,, ahk_id %hCtrl%
}

