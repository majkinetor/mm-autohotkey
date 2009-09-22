; Title:	CmnDlg
;			*Common Operating System dialogs*

;----------------------------------------------------------------------------------------------
; Function:		Color
;				(See color.png)
;
; Parameters: 
;				pColor	- Initial color and output in RGB format, 
;				hGui	- Optional handle to parents HWND
;  
; Returns:	
;				False if user canceled the dialog or if error occurred	
; 
;
CmnDlg_Color(ByRef pColor, hGui=0){ 
  ;covert from rgb
    clr := ((pColor & 0xFF) << 16) + (pColor & 0xFF00) + ((pColor >> 16) & 0xFF) 

    VarSetCapacity(sCHOOSECOLOR, 0x24, 0) 
    VarSetCapacity(aChooseColor, 64, 0) 

    NumPut(0x24,		 sCHOOSECOLOR, 0)      ; DWORD lStructSize 
    NumPut(hGui,		 sCHOOSECOLOR, 4)      ; HWND hwndOwner (makes dialog "modal"). 
    NumPut(clr,			 sCHOOSECOLOR, 12)     ; clr.rgbResult 
    NumPut(&aChooseColor,sCHOOSECOLOR, 16)     ; COLORREF *lpCustColors 
    NumPut(0x00000103,	 sCHOOSECOLOR, 20)     ; Flag: CC_ANYCOLOR || CC_RGBINIT 

    nRC := DllCall("comdlg32\ChooseColorA", str, sCHOOSECOLOR)  ; Display the dialog. 
    if (errorlevel <> 0) || (nRC = 0) 
       return  false 

  
    clr := NumGet(sCHOOSECOLOR, 12) 
    
    oldFormat := A_FormatInteger 
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 

 ;convert to rgb 
    pColor := (clr & 0xff00) + ((clr & 0xff0000) >> 16) + ((clr & 0xff) << 16) 
    StringTrimLeft, pColor, pColor, 2 
    loop, % 6-strlen(pColor) 
		pColor=0%pColor% 
    pColor=0x%pColor% 
    SetFormat, integer, %oldFormat% 

	return true
}


;----------------------------------------------------------------------------------------------
;
; Function:     Find / Replace
;				(see find.png)
;				(see replace.png)
;
; Parameters: 
;               hGui    - Handle to parents HWND
;               fun     - Notification function used for communication with dialog.
;               flags   - Creation flags, see below.
;               deff    - Default text to be displayed at the start of the dialog box in find edit box
;               defr    - Default text to be displayed at the start of the dialog box in replace edit box
;
; Flags:        
;				String containing list of creation flags. You can use "-" prefix to hide that GUI field.
;
;                d - down radio button selected in Find dialog
;                w - whole word selected
;                c - match case selected
;
; Notifications:
;				Dialog box is not modal, so it communicates with the script while it is active. Both Find & Replace use 
;				the same prototype of notification function so even if you use Find only you will have to specify ReplaceWith parameter.
;
;>					OnFind(Event, Flags, FindWhat, ReplaceWith)
;
;                   Event    - "close", "find", "replace", "replace_all"
;                   Flags    - string contaning flags about user selection; each letter means user has selected that particular GUI element.
;                   FindWhat - user find text
;                ReplaceWith - user replace text
;   
; Returns:      
;               Handle of the dialog or 0 if dialog can't be created. Can also return "Invalid Label" if lbl is not valid.
; 
CmnDlg_Find( hGui, fun, flags="d", deff="") {
	static FINDMSGSTRING = "commdlg_FindReplace"
	static FR_DOWN=1, FR_MATCHCASE=4, FR_WHOLEWORD=2, FR_HIDEMATCHCASE=0x8000, FR_HIDEWHOLEWORD=0x10000, FR_HIDEUPDOWN=0x4000
	static buf, FR, len := 256

	f := 0
	f |= InStr(flags, "d")  ? FR_DOWN : 0 
	f |= InStr(flags, "c")  ? FR_MATCHCASE : 0
	f |= InStr(flags, "w")  ? FR_WHOLEWORD : 0
	f |= InStr(flags, "-d") ? FR_HIDEUPDOWN : 0
	f |= InStr(flags, "-w") ? FR_HIDEWHOLEWORD :0 
	f |= InStr(flags, "-c") ? FR_HIDEMATCHCASE :0

	if FR =						  
		VarSetCapacity(FR, 40, 0), VarSetCapacity(buf, len)
	
	if deff !=
		buf := deff
	
	NumPut( 40,		FR, 0)	;size
	NumPut( hGui,	FR, 4)	;hwndOwner
	NumPut( f,		FR, 12)	;Flags
	NumPut( &buf,	FR, 16)	;lpstrFindWhat
	NumPut( len,	FR, 24) ;wFindWhatLen


	CmnDlg_callback(fun,"","","")
	OnMessage( DllCall("RegisterWindowMessage", "str", FINDMSGSTRING), "CmnDlg_callback" )

	return DllCall("comdlg32\FindTextA", "str", FR)
}

;----------------------------------------------------------------------------------------------
; Function:  Font
;			 (see font.png)				
;
; Parameters:
;            pFace		- Initial font,  output
;            pStyle		- Initial style, output
;            pColor		- Initial text color, output
;			 pEffects   - Set to false to disable effects (strikeout, underline, color)
;            hGui		- Parent's handle, affects position
;
;  Returns:
;            False if user canceled the dialog or if error occurred
;
CmnDlg_Font(ByRef pFace, ByRef pStyle, ByRef pColor, pEffects=true, hGui=0) {

   RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels
   VarSetCapacity(SLogFont, 128, 0)

   pEffects := pEffects ? 0x100 : 0

   ;set initial name
   DllCall("RtlMoveMemory", "uint", &SLogFont+28, "Uint", &pFace, "Uint", 32)

   ;convert from rgb  
   clr := ((pColor & 0xFF) << 16) + (pColor & 0xFF00) + ((pColor >> 16) & 0xFF) 

   ;set intial data
   if InStr(pStyle, "bold")
      NumPut(700, SLogFont, 16)

   if InStr(pStyle, "italic")
      NumPut(255, SLogFont, 20, 1   )

   if InStr(pStyle, "underline")
      NumPut(1, SLogFont, 21, 1)
   
   if InStr(pStyle, "strikeout")
      NumPut(1, SLogFont, 22, 1)

   if RegExMatch( pStyle, "s[1-9][0-9]*", s){
      StringTrimLeft, s, s, 1      
      s := -DllCall("MulDiv", "int", s, "int", LogPixels, "int", 72)
      NumPut(s, SLogFont, 0)				; set size
   }
   else  NumPut(16, SLogFont, 0)         ; set default size

   VarSetCapacity(SChooseFont, 60, 0)
   NumPut(60,		SChooseFont, 0)		; DWORD lStructSize
   NumPut(hGui,      SChooseFont, 4)		; HWND hwndOwner (makes dialog "modal").
   NumPut(&SLogFont, SChooseFont, 12)	; LPLOGFONT lpLogFont
   NumPut(0x041 + pEffects,	SChooseFont, 20)	; CF_EFFECTS = 0x100, CF_SCREENFONTS = 1, CF_INITTOLOGFONTSTRUCT = 0x40
   NumPut(clr,    SChooseFont, 24)		; rgbColors

   r := DllCall("comdlg32\ChooseFontA", "uint", &SChooseFont)  ; Display the dialog.
   if !r
      return false

   ;font name
   VarSetCapacity(pFace, 32)
   DllCall("RtlMoveMemory", "str", pFace, "Uint", &SLogFont + 28, "Uint", 32)
   pStyle := "s" NumGet(SChooseFont, 16) // 10

   ;color
   old := A_FormatInteger
   SetFormat, integer, hex                      ; Show RGB color extracted below in hex format.
   pColor := NumGet(SChooseFont, 24)
   SetFormat, integer, %old%

   ;styles
   pStyle =
   VarSetCapacity(s, 3)
   DllCall("RtlMoveMemory", "str", s, "Uint", &SLogFont + 20, "Uint", 3)

   if NumGet(SLogFont, 16) >= 700
      pStyle .= "bold "

   if NumGet(SLogFont, 20, "UChar")
      pStyle .= "italic "
   
   if NumGet(SLogFont, 21, "UChar")
      pStyle .= "underline "

   if NumGet(SLogFont, 22, "UChar")
      pStyle .= "strikeout "

   s := NumGet(sLogFont, 0)
   pStyle .= "s" Abs(DllCall("MulDiv", "int", abs(s), "int", 72, "int", LogPixels))

 ;convert to rgb 
	oldFormat := A_FormatInteger 
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 

    pColor := (pColor & 0xff00) + ((pColor & 0xff0000) >> 16) + ((pColor & 0xff) << 16) 
    StringTrimLeft, pColor, pColor, 2 
    loop, % 6-strlen(pColor) 
		pColor=0%pColor% 
    pColor=0x%pColor% 
    SetFormat, integer, %oldFormat% 

   return 1
}

;-----------------------------------------------------------------------------------------------
; Function:	Icon 
;			(See icon.png)
;
; Parameters:
;			sIcon   - Default icon resource, output
;			idx     - Default index within resource, output
;			hGui	- Optional handle of the parent GUI.
;
; Returns:
;			False if user canceled the dialog or if error occurred 
;		
; Remarks:
;			This is simple and non-fleixibile dialog. If you need more flexibility, use <IconEx> instead.
;
CmnDlg_Icon(ByRef sIcon, ByRef idx, hGui=0) {      
    VarSetCapacity(wIcon, 1025, 0) 
    If sIcon   { 
        r := DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "Str", sIcon, "Int", StrLen(sIcon), "UInt", &wIcon, "Int", 1025) 
		IfEqual, r, 0, return false
    } 

	r := DllCall(DllCall("GetProcAddress", "Uint", DllCall("LoadLibrary", "str", "shell32.dll"), "Uint", 62), "uint", hGui, "uint", &wIcon, "uint", 1025, "intp", --idx)
	idx++
	IfEqual, r, 0, return false

	Len := DllCall("lstrlenW", "UInt", &wIcon) 
	VarSetCapacity(sIcon, len, 0) 
	r := DllCall("WideCharToMultiByte" , "UInt", 0, "UInt", 0, "UInt", &wIcon, "Int", len, "Str", sIcon, "Int", len, "UInt", 0, "UInt", 0) 
	IfEqual, r, 0, return false

    Return True 
}

;---------------------------------------------------------------------------------------------- 
; Function:  Open / Save 
;			 (see open.png)
;
; Parameters: 
;            hGui            - Parent's handle, positive number by default 0 (influences dialog position) 
;            Title			 - Dialog title
;            Filter          - Specify filter as with FileSelectFile. Seperate multiple filters with "|"
;            DefultFilter    - Index of default filter, by default 1
;            Root			 - Specifies startup directory and initial content of "File Name" edit. 
;							   Directory must have trailing "\".
;            DefaulltExt     - Extension to append when none given 
;            Flags           - White space separated list of flags, by default "FILEMUSTEXIST HIDEREADONLY"
;  
;  Flags:
;			allowmultiselect	- Specifies that the File Name list box allows multiple selections 
;			createprompt		- If the user specifies a file that does not exist, this flag causes the dialog box to prompt the user for permission to create the file
;			dontaddtorecent		- Prevents the system from adding a link to the selected file in the file system directory that contains the user's most recently used documents. 
;			extensiondifferent	- Specifies that the user typed a file name extension that differs from the extension specified by defaulltExt
;			filemustexist		- Specifies that the user can type only names of existing files in the File Name entry field
;			forceshowhidden		- Forces the showing of system and hidden files, thus overriding the user setting to show or not show hidden files. However, a file that is marked both system and hidden is not shown.
;			hidereadonly		- Hides the Read Only check box.
;			nochangedir			- Restores the current directory to its original value if the user changed the directory while searching for files.
;			nodereferencelinks	- Directs the dialog box to return the path and file name of the selected shortcut (.LNK) file. If this value is not specified, the dialog box returns the path and file name of the file referenced by the shortcut.
;			novalidate			- Specifies that the common dialog boxes allow invalid characters in the returned file name
;			overwriteprompt		- Causes the Save As dialog box to generate a message box if the selected file already exists. The user must confirm whether to overwrite the file.
;			pathmustexist		- Specifies that the user can type only valid paths and file names.
;			readonly			- Causes the Read Only check box to be selected initially when the dialog box is created
;			showhelp			- Causes the dialog box to display the Help button. The hGui receives the HELPMSGSTRING registered messages that the dialog box sends when the user clicks the Help button. 
;			noreadonlyreturn	- Specifies that the returned file does not have the Read Only check box selected and is not in a write-protected directory.
;			notestfilecreate	- Specifies that the file is not created before the dialog box is closed. This flag should be specified if the application saves the file on a create-nonmodify network share.
; 
;  Returns: 
;            Selected FileName or Emtpy when cancelled. If more then one file is selected they are separated by new line character.
; 	
CmnDlg_Open( hGui=0, Title="", Filter="", defaultFilter="", Root="", defaultExt="", flags="FILEMUSTEXIST HIDEREADONLY" ) { 
	static OFN_ALLOWMULTISELECT:=0x200, OFN_CREATEPROMPT:=0x2000, OFN_DONTADDTORECENT:=0x2000000, OFN_EXTENSIONDIFFERENT:=0x400, OFN_FILEMUSTEXIST:=0x1000, OFN_FORCESHOWHIDDEN:=0x10000000, OFN_HIDEREADONLY:=0x4, OFN_NOCHANGEDIR:=0x8, OFN_NODEREFERENCELINKS:=0x100000, OFN_NOVALIDATE:=0x100, OFN_OVERWRITEPROMPT:=0x2, OFN_PATHMUSTEXIST:=0x800, OFN_READONLY:=0x1, OFN_SHOWHELP:=0x10, OFN_NOREADONLYRETURN:=0x8000, OFN_NOTESTFILECREATE:=0x10000

	IfEqual, Filter, ,SetEnv, Filter, All Files (*.*)
	SplitPath, Root, RootFile, RootDir
	
	hFlags := 0x80000								;OFN_ENABLEXPLORER always set
	loop, parse, flags,%A_TAB%%A_SPACE%,%A_TAB%%A_SPACE%
		if A_LoopField !=
			hFlags |= OFN_%A_LoopField%

	VarSetCapacity( FN, 0xffff )
	VarSetCapacity( lpstrFilter, 2*StrLen(filter))
	VarSetCapacity( OFN ,90, 0)

	if RootFile !=
		  DllCall("lstrcpyn", "uint", &FN, "uint", &RootFile, "int", StrLen(RootFile)+1) 

	; Contruct FilterText seperate by \0 
	delta := 0										;Used by Loop as Offset
	loop, Parse, Filter, |                
	{ 
		desc := A_LoopField,			ext := SubStr(A_LoopField, InStr( A_LoopField,"(" )+1, -1) 
		lenD := StrLen(A_LoopField)+1,	lenE := StrLen(ext)+1				;including /0

		DllCall("lstrcpyn", "uint", &lpstrFilter + delta, "uint", &desc, "int", lenD) 
		DllCall("lstrcpyn", "uint", &lpstrFilter + delta + lenD, "uint", &ext, "int", lenE)
		delta += lenD + lenE
	} 
	NumPut(0, lpstrFilter, delta, "UChar" )  ; Double Zero Termination 

	; Contruct OPENFILENAME Structure   
	NumPut( 76,				 OFN, 0,  "UInt" )    ; Length of Structure 
	NumPut( hGui,			 OFN, 4,  "UInt" )    ; HWND 
	NumPut( &lpstrFilter,	 OFN, 12, "UInt" )    ; Pointer to FilterStruc 
	NumPut( 0,				 OFN, 16, "UInt" )    ; Pointer to CustomFilter 
	NumPut( 0,				 OFN, 20, "UInt" )	  ; MaxChars for CustomFilter 
	NumPut( defaultFilter,	 OFN, 24, "UInt" )    ; DefaultFilter Pair 
	NumPut( &FN,			 OFN, 28, "UInt" )    ; lpstrFile / InitialisationFileName 
	NumPut( 0xffff,			 OFN, 32, "UInt" )    ; MaxFile / lpstrFile length 
	NumPut( 0,				 OFN, 36, "UInt" )	  ; lpstrFileTitle 
	NumPut( 0,				 OFN, 40, "UInt" )	  ; maxFileTitle 
	NumPut( &RootDir,		 OFN, 44, "UInt" )    ; StartDir 
	NumPut( &Title,			 OFN, 48, "UInt" )	  ; DlgTitle
	NumPut( hFlags,			 OFN, 52, "UInt" )    ; Flags 
	NumPut( &defaultExt,	 OFN, 60, "UInt" )    ; DefaultExt 


	res := (*&hGui = 45) ? DllCall("comdlg32\GetSaveFileNameA", "Uint", &OFN ) : DllCall("comdlg32\GetOpenFileNameA", "Uint", &OFN ) 
	IfEqual, res, 0, return

	adr := &FN,  f := d := DllCall("MulDiv", "Int", adr, "Int",1, "Int",1, "str"), res := ""
	if StrLen(d) != 3			;windows adds \ when in root of the drive and doesn't do that otherwise
		d.="\"		
	if ms := InStr(flags, "ALLOWMULTISELECT")
		loop 
			if f := DllCall("MulDiv", "Int", adr += StrLen(f)+1, "Int",1, "Int",1, "str") 
				res .= d f "`n"
			else {
				 IfEqual, A_Index, 1, SetEnv, res, %d%		;if user selects only 1 file with multiselect flag, windows ignores this flag.... 
				 break
			}
	
	return ms ? SubStr(res, 1, -1) : SubStr(d, 1, -1)
}

CmnDlg_Replace( hGui, fun, flags="", deff="", defr="") {
	static FINDMSGSTRING = "commdlg_FindReplace"
	static FR_MATCHCASE=4, FR_WHOLEWORD=2, FR_HIDEMATCHCASE=0x8000, FR_HIDEWHOLEWORD=0x10000, FR_HIDEUPDOWN=0x4000
	static buf_s, buf_r, FR, len := 256

	f := 0
	f |= InStr(flags, "c")  ? FR_MATCHCASE : 0
	f |= InStr(flags, "w")  ? FR_WHOLEWORD : 0
	f |= InStr(flags, "-w") ? FR_HIDEWHOLEWORD :0 
	f |= InStr(flags, "-c") ? FR_HIDEMATCHCASE :0

	if FR =
		VarSetCapacity(FR, 40, 0), VarSetCapacity(buf_s, len), VarSetCapacity(buf_r, len)
	
	if deff !=
		buf_s := deff
	if defr !=
		buf_r := defr
	
	NumPut( 40,		FR, 0)	;size
	NumPut( hGui,	FR, 4)	;hwndOwner
	NumPut( f,		FR, 12)	;Flags
	NumPut( &buf_s,	FR, 16)	;lpstrFindWhat
	NumPut( &buf_r,	FR, 20) ;lpstrReplaceWith
	NumPut( len,	FR, 24) ;wFindWhatLen
	NumPut( len,	FR, 26) ;wReplaceWithLen


	CmnDlg_callback(fun,"","","")
	OnMessage( DllCall("RegisterWindowMessage", "str", FINDMSGSTRING), "CmnDlg_callback" )

	return DllCall("comdlg32\ReplaceTextA", "str", FR)
}

CmnDlg_Save( hGui=0, Title="", Filter="", defaultFilter="", Root="", defaultExt="", flags="" ) {
	return CmnDlg_Open( hGui, Title, Filter, defaultFilter, Root, defaultExt, flags )
}


;=========================================== PRIVATE ===============================================

CmnDlg_callback(wparam, lparam, msg, hwnd) {
	static FR_DIALOGTERM = 0x40, FR_DOWN=1, FR_MATCHCASE=4, FR_WHOLEWORD=2, FR_HIDEMATCHCASE=0x8000, FR_HIDEWHOLEWORD=0x10000, FR_HIDEUPDOWN=0x4000, FR_REPLACE=0x10, FR_REPLACEALL=0x20, FR_FINDNEXT=8
	static fun 
	ifEqual, hwnd, ,return fun := wparam

	flags := NumGet(lparam+0, 12)
	if (flags & FR_DIALOGTERM)
		return %fun%("close", "", "", "")

 	CmnDlg_Flags .= (Flags & FR_MATCHCASE) && !(Flags & FR_HIDEMATCHCASE)? "c" :
	CmnDlg_Flags .= (Flags & FR_WHOLEWORD) && !(Flags & FR_HIDEWHOLEWORD) ? "w" :
	CmnDlg_FindWhat := DllCall("MulDiv", "Int", NumGet(lparam+0, 16), "Int",1, "Int",1, "str") 

	if (flags & FR_FINDNEXT) {
		CmnDlg_Flags .= (Flags & FR_DOWN) && !(Flags & FR_HIDEUPDOWN) ? "d" :
		return %fun%("find", CmnDlg_Flags, CmnDlg_FindWhat, "")
	}

	if (flags & FR_REPLACE) or (flags & FR_REPLACEALL) {
		CmnDlg_Event := (flags & FR_REPLACEALL) ? "replace_all" : "replace"
		CmnDlg_ReplaceWith := DllCall("MulDiv", "Int", NumGet(lparam+0, 20), "Int",1, "Int",1, "str") 
		return %fun%(CmnDlg_Event, CmnDlg_Flags, CmnDlg_FindWhat, CmnDlg_ReplaceWith)
	}
}

;-------------------------------------------------------------------------------------------------------------------
;Group: Examples
;
;Example1: 
;
;>  ;basic usage
;>
;>  if CmnDlg_Icon(icon, idx := 4) 
;>       msgbox Icon:   %icon%`nIndex:  %idx% 
;>
;>   if CmnDlg_Color( color := 0xFF00AA ) 
;>      msgbox Color:  %color% 
;>
;>   if CmnDlg_Font( font := "Courier New", style := "s16 bold underline italic", color:=0x80) 
;>        msgbox Font:  %font%`nStyle:  %style%`nColor:  %color%
;>
;>   res := CmnDlg_Open("", "Select several files", "", "", "c:\Windows\", "", "ALLOWMULTISELECT FILEMUSTEXIST HIDEREADONLY")
;>   IfNotEqual, res, , MsgBox, %res%
;>return
;
;Example2:
;>	 ;create gui and set text color 
;>
;>   CmnDlg_Font( font := "Courier New", style := "s16 bold italic", color:=0xFF) 
;>
;>   Gui Font, %Style% c%Color%, %Font% 
;>   Gui, Add, Text, ,Hello world.....  :roll: 
;>   Gui, Show, Autosize 
;>return
;
;Group: About
;		o Ver 4.1 by majkinetor. See http://www.autohotkey.com/forum/topic17230.html
;		o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.