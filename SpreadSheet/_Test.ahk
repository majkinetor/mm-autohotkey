/*
	Function: S
			  Get struct data
	
	Define:
			  S - Dummy, not used but must be set.
			  pQ - Struct definition. First word is struct name followed by : and a space, then comes the space separted list of field definitions.
				   Field definiton consist of field name, = sign, and decimal represinting offset and type description. For instance, "left=4.1" means that field name 
				   is "left", field offset is 4 bytes and field type is 1 (UChar). You can omit field decimal in which case "Uint" is used for type
				   and offset is calculated from previous one (or it defaults to 0 if it is first field in the list).
				   Presed type number with 0 to make it without "U" or with 00 to make it Float/Double. For instance, .01 is "Char" and .004 is Float. 
				   Struct name can also be followed by = and size, or just = in which case function will try to automatically calculate the struct size based on input fields.
				   Later, you can pass ! in Put mode to make the function initialize the structure for you.
	Syntax:
 >			pQ :: StructName[=[Size]]: field1 field2 ... fieldN	
 >			fieldN :: name[=[offset[=.type]]]
 >			type :: offset.[0][0]size
 >			size  :: [0]1 | [0]2 | [0]4 | [0]8 | 004 | 008

	Get and Put:
			  S		 - Reference to struct data.
			  pQ	 - Query parameter. First word is struct name followed by : and a space, then comes the space separated list of field names.
					   If the first char after struct name is "<" function will work in Put mode, if char is ">" it works in "Get" mode.
					   If char is "!" function works in IPut mode (Initialize & Put), but only if struct is defined so that its size is known.
			  o1..o8 - Reference to output variables (Get) or input variables (Put)

	Syntax:
 >			pQ :: StructName[>|<|!]: FieldName1 FieldName2 ... FieldNameN

	Returns:
			 o In Define mode, function returns struct size for automatically calculated size, or nothing
			 o In Get/Put function returns o1.

			 Otherwise the result contains description of the error.
	
	Examples:
	(start code)
	Define Examples
			S(s, "RECT=16: left=0.4 top=0.4 right=0.4 bottom=0.4")			;Define RECT explicitelly.
			S(s, "RECT=: left top right bottom")	;Define RECT struct with auto struct size and auto offset increment. Returns 16. The same as above
			S(s, "RECT: right=8 bottom")			;Define only 2 fields of RECT struct. Returns nothing. RECT must be initialized before accessing it.
			S(s, "R: x=.1 y=.02 k z=28.004")		;Define R size don't care. R.x is UChar at 0, r.y is Short at 1, R.k is Uint at 3 and  R.z is Float at 28.
			S(s, "R=: x=.1 y=.02 k z=28.004")		;The same but calculate struct size. Returns 32.

	Get & Put Examples
			S(b, "RECT< left right", x, y)			;b.left := x, b.right := y
			S(b, "RECT> left, right")				;x := b.left, y := b.right
			S(b, "RECT> right")						;Returns b.right
			S(b, "RECT! left right")				;VarSetCapacity(b, SizeOf(RECT)), b.left = x, b.right=y
	(end code)
 */
S(ByRef S, pQ="",ByRef o1="~`a ",ByRef o2="",ByRef o3="",ByRef  o4="",ByRef o5="",ByRef  o6="",ByRef o7="",ByRef  o8=""){
	static
	static 1="UChar", 2="UShort", 4="Uint", 004="Float", 8="Uint64", 008="Double", 01="Char", 02="Short", 04="Int", 08="Int64"
	local last_offset:=-4, last_type := 4, i, j, R

	if (o1="~`a ")
	{
		j := InStr(pQ, ":"), R := SubStr(pQ, 1, j-1), pQ := SubStr(pQ, j+2)
		if i := InStr(R, "=")
			_ := SubStr(R, 1, i-1), _%_% := SubStr(R, i+1, j-i), R:=_		

		IfEqual, R,, return A_ThisFunc "> Struct name can't be empty"
		loop, parse, pQ, %A_Space%, %A_Space%
		{
			j := InStr(A_LoopField, "=")
			If j
				 field := SubStr(A_LoopField, 1, j-1), offset := SubStr(A_LoopField, j+1)
			else field := A_LoopField, offset := last_offset + last_type 

			d := InStr(offset, ".")
			if d
				 type := SubStr(offset, d+1), offset := SubStr(offset, 1, d-1)
			else type := 4
			IfEqual, offset, , SetEnv, offset, % last_offset + last_type

			%R%_%field% := offset "." type,  last_offset := offset,  last_type := type
		}
		return i && _%_%="" ? _%_% := last_offset + last_type : ""
	}
	;"STRi field
	j := InStr(pQ, A_Space)-1,  i := SubStr(pQ, j, 1), R := SubStr(pQ, 1, j-1), pQ := SubStr(pQ, j+2)
	IfEqual, R,, return A_ThisFunc "> Struct name can't be empty"
	if (i = "!") 
		if j := _%R%
			 VarSetCapacity(s, j)
		else return  A_ThisFunc "> In order to use !, define struct with size"	
	loop, parse, pQ, %A_Space%, %A_Space%
	{	
		field := A_LoopField, data := %R%_%field%, offset := floor(data), type := SubStr(data, StrLen(offset)+2), type := %type%
		ifEqual, data, , return A_ThisFunc "> Field or struct isn't recognised :  " R "." field 
		if (i = ">")
			  o%A_Index% := NumGet(S, offset, type)
		else  NumPut(o%A_Index%, S, offset, type)
	}
	return o1	
}

version = 2.1
#singleinstance, force
#MaxThreads, 255
SetBatchLines, -1
CoordMode, tooltip, screen

	Gui, +LastFound +Resize
	hwnd := WinExist()
	Gui, Font, s11, Courier
	w := 650, h := 500, hdr:=40

;	Gui, Add, Text, y10 x5, Choose Action
;	Gui, Add, DDL,  x+10 w200 y5 0x8000 vC gOnChange, Load|Save| |New Sheet|Blank Cell|Delete Cell|Current Cell| |Delete Col|Delete Row|Insert Col|Insert Row| |Get Multisel|Set Multisel|Expand cell| |Set Global| |No Row Header|No Col Header|Scroll Lock|Get Cell Rect| |Split Ver|Split Hor|Split Close|Split Sync|Get Cell||Get Cell Text|Get Cell Data| |Set Cell String|Set Cell Data to 0
;	Gui, Add, Button,x+10 h25 0x8000 gOnButton, exec   F1
;	Gui, Add, Button,x+10 yp hp 0x8000 gOnReload, reload
;	Gui, Add, Button,x+10 yp hp 0x8000 gOnAbout, ?
	
;	OnMessage(WM_DRAWITEM := 0x02B, "MyFun")

	hCtrl := SS_Add(hwnd, 0, 100, w, h-hdr, "WINSIZE VSCROLL HSCROLL CELLEDIT ROWSIZE COLSIZE STATUS MULTISELECT", "Handler")
	loop, 1
		SS_SetCell(hCtrl, A_Index, 2, "type=OWNERDRAWINTEGER", "txt=" A_Index, "state=LOCKED")

	SS_SetRowHeight(hCtrl, 2, 100)
	gui, show, w500 h600
	SS_Focus(hCtrl)
	return		

	SS_SetCell(hCtrl, 1, 1, "type=FLOAT", "txt=14.123456", "txtal=4 RIGHT", "state=LOCKED")

	SS_SetCell(hCtrl, 1, 0, "txt=hello", "")
	SS_SetCell(hCtrl, 0, 1, "txtal=BOTTOM RIGHT")


	SS_SetDateFormat(hCtrl, "dd.MM.yyyy")
	SS_SetCell(hCtrl, 3, 1, "type=INTEGER DATE", "txt=" i := SS_ConvertDate(hCtrl, "10.11.1976"), "w=100")
	SS_SetCell(hCtrl, 4, 1, "type=INTEGER", "txt=" i)	
	SS_SetCell(hCtrl, 2, 1, "type=TEXTMULTILINE FORCETYPE", "txt=Some`nMultiline Text", "fnt=1")


	SS_SetCell(hCtrl, 1, 2, "type=TEXT", "txt=Style", "bg=0xFF", "fg=0xFFFFFF", "state=LOCKED")
		
	SS_SetCell(hCtrl, 1, 3, "type=TEXT", "txt=Anchor", "bg=0xFF", "fg=0xFFFFFF", "state=LOCKED")
	SS_SetCell(hCtrl, 2, 3, "type=BUTTON FORCETEXT FIXEDSIZE", "txt=w0.5 h", "imgal=MIDDLE RIGHT", "fnt=1")

	SS_SetCell(hCtrl, 1, 4, "type=TEXT", "txt=Visible", "bg=0xFF", "fg=0xFFFFFF")


	SS_SetCell(hCtrl, 1, 6, "type=TEXT", "txt=Help", "bg=0xFFFF", "fg=-1")
	SS_SetCell(hCtrl, 2, 6, "type=HYPERLINK", "txt=autohotkey.com", "w=150", "fnt=2")

	SS_SetCell(hCtrl, 1, 8, "type=WIDEBUTTON TEXT", "Txt=My Button","txtal=CENTER MIDDLE", "w=100", "state=LOCKED")

	SS_SetRowHeight(hCtrl, 1, 50)

	SS_SetFont(hCtrl, 0, "s10, Arial")
	SS_SetFont(hCtrl, 1, "s9, Courier")
	SS_SetFont(hCtrl, 2, "s8 italic bold, Verdana")

	;formula
	SS_SetCell(hCTrl, 1, 10, "txt= x  =", "type=TEXT", "txtal=CENTER", "fnt=1")
	SS_SetCell(hCTrl, 1, 11, "txt= y  =", "type=TEXT", "txtal=CENTER", "fnt=1")
	SS_SetCell(hCTrl, 1, 12, "txt=x+y =", "type=TEXT", "txtal=CENTER", "fnt=1")

	SS_SetCell(hCtrl, 2, 10, "type=INTEGER FORCETYPE", "txt=90", "fnt=1", "txtal=LEFT")
	SS_SetCell(hCtrl, 2, 11, "type=INTEGER FORCETYPE", "txt=20", "fnt=1", "txtal=LEFT" )
	SS_SetCell(hCtrl, 2, 12, "type=FORMULA", "txt=AB10+AB11", "txtal=LEFT")
	
	graph = Grp(T(-1,0,0,Rgb(0,0,0),"Graph Demo"),X(0,PI()*4,0,1,Rgb(0,0,255),"x-axis"),Y(-1.1,1.1,0,0.5,Rgb(255,0,0),"y-axis"),gx(AJ1:AJ13,Rgb(0,0,0),"Cell values"),fx(Sin(x()),0.1,Rgb(255,0,255),"Sin(x)"),fx(x()^3-x()^2-x(),0.1,Rgb(0,128,0),"x^3-x^2-x"))

	SS_SetCell(hCtrl, 1, 14, "type=GRAPH", "txt=" graph, "bg=0x0D0FFFF")
	SS_ExpandCell(hCtrl, 1, 14, 4, 20)
	SS_ReCalc(hCtrl)

	SS_SetGlobalFields(hCtrl, "cell_txtal", "RIGHT MIDDLE")
	Gui, Show, w%w% h%h%, SpreadSheet
	SS_Focus(hCtrl)		;refresh
return


Handler(hwnd, Event, EArg, Col, Row) {
	static hIcon, s
	if !hIcon
		hIcon := LoadIcon("home.ico", 64), s:=2

	if Event=D
	{
		critical, 100
		outputdebug ej
		lparam := EArg, 
		lpspri := NumGet(lparam+44)
;		t := NumGet(lpspri+27,0, "UChar")
		
		hdc := NumGet(lparam+24)
		, left	:= NumGet(lparam+28)
		, top	:= NumGet(lparam+32)
;		right	:= NumGet(lparam+36)
;		bottom	:= NumGet(lparam+40)

	
;		int	:= NumGet(lpspri+36)
;		int := NumGet(int+0)
	;	s := SS_strAtAdr(NumGet(lpspri+36))
		int := SS_GetCellData(hwnd, col, row)
		DllCall("TextOut", "uint", hDC, "uint", left, "uint", top, "str", int, "uint", StrLen(int))
		API_DrawIconEx( hDC, left, top+25, hIcon, int*2, int*2, 0, 0, 3)
		sleep, -1
;		API_DestroyIcon(hIcon)
	}

;	text := SS_GetCellText(hwnd, Col, Row)
;	StringReplace, text, text, `n, \n, A
;	s .= "cell: " col "," row "," SS_GetCellType(hwnd,col,row)  "    event: " event " (earg: " earg ")  Text: " text "`n" 
;	tooltip, %s%, 0, 0
;	if StrLen(s) > 500 
;		s =
}


SetGlobalSettings(){
	global

	;header and cell defaults	
	h_bg := c_bg := 0xAAAAAA
	h_txtal := c_txtal := "CENTER MIDDLE"
	h_fg := 0xFF0000
	h_fnt := 2
	c_fg := 0xFFFFFF
	
	g_colhdrbtn := 0			;button sytle col hdr
	g_rowhdrbtn := 0			;button style row hdr
	g_winhdrbtn := 0			;button style win hdr
	g_lockcol   := 0xAAAAAA		;Back color of locked cell              
	g_hdrgrdcol := 0xFF00FF		;Header grid color                      
	g_grdcol    := 0xFFFFFF		;Cell grid color                        
	g_bcknfcol  := 0xCCCCCC		;Back color of active cell, lost focus  
	g_txtnfcol  := 1			;Text color of active cell, lost focus  
	g_bckfocol  := 0xFFFF	    ;Back color of active cell, has focus   
	g_txtfocol  := 0			;Text color of active cell, has focus   

	g_ghdrwt    := 25			;header width
	g_ghdrht    := 25			;header height
	g_gcellw    := 50			;cell width
	g_gcellht   := 20			;cell height

	SS_SetGlobal(hCtrl, "g", "c", "h", "h", "h")
}

OnChange:
	Gui, Submit, NoHide
	ifEqual, c,, return
	
	if c=Load 
	{
		FileSelectFile, fn,3,, Open a file, SpreadSheet (*.spr)
		if Errorlevel
			return
		SS_LoadFile(hCtrl, fn)
	}
	
	if c=Save
	{
		FileSelectFile, fn,S, ,Save a file, SpreadSheet (*.spr)
		if Errorlevel
			return
		SS_SaveFile(hCtrl, fn)
	}

	if c=New Sheet
		SS_NewSheet(hCtrl)
	
	if c=Blank Cell
		SS_BlankCell(hCtrl)

	if c=Delete Cell
		SS_DeleteCell(hCtrl)

	if c=Current Cell
		msgbox %col% %row%

	if c=Delete Col
		SS_DeleteCol(hCtrl)
	if c=Delete Row
		SS_DeleteRow(hCtrl)
	if c=Insert Col
		SS_InsertCol(hCtrl, SS_GetCurrentCol(hCtrl))
	if c=Insert Row
		SS_InsertRow(hCtrl, SS_GetCurrentRow(hCtrl))
	if c=Get Multisel
	{
		SS_GetMultiSel(hCtrl, top, left, right,bottom)
		msgbox %left% %top% %right% %bottom%
	}
	if c=Set Multisel
		SS_SetMultiSel(hCtrl, 2, 1, 4, 8), 	SS_Focus(hCtrl)

	if c=Set Global
		SetGlobalSettings()

	if c=Expand Cell
		SS_GetMultiSel(hCtrl,  top,  left,  right,  bottom),  SS_ExpandCell(hCtrl, left, top, right, bottom )

	if c=No Row Header
		SS_SetColWidth(hCtrl,0,0)

	if c=No Col Header
		SS_SetRowHeight(hCtrl,0,0)
	
	if c=Scroll Lock
		SS_SetLockRow(hCtrl, 3)

	if c=Get Cell Rect
	{
		SS_GetCellRect(hCtrl,  top,  left,  right,  bottom)
		msgbox %top% %left% %right% %bottom%
	}

	if c=Split Ver
		SS_SplittVer(hCtrl) 
	if c=Split Hor
		SS_SplittHor(hCtrl)

	if c=Split Close
		SS_SplittClose(hCtrl)

	if c=SPlit Sync
		SS_SplittSync(hCtrl, 1)

	if c=Get Cell
	{
		SS_GetCellArray(hCtrl, "i")
		msg = 
		(LTrim
			Type = %i_type%
			Text = %i_txt%
			Data = %i_data%

			state = %i_state%         
			bg = %i_bg%
			fg = %i_fg%
			txtal = %i_txtal%
		    imgal = %i_imgal%
			fnt = %i_fnt%
		)
	
		msgbox %msg%
	}

	if c=Get Cell Text
		msgbox % SS_GetCellText(hCtrl)
	
	if c=Set Cell String
		SS_SetCellString(hCtrl, "TEST")

	if c=Get Cell Data
		msgbox % SS_GetCellData(hCtrl)

	if c=Set Cell Data to 0
		SS_SetCellData(hCtrl, 0)

	SS_Focus(hCtrl)
return

Anchor(c, a = "", r = false) { ; v3.6 - Titan
	static d
	GuiControlGet, p, Pos, %c%
	If ex := ErrorLevel {
		Gui, %A_Gui%:+LastFound
		ControlGetPos, px, py, pw, ph, %c%
	}
	If !(A_Gui or px) and a
		Return
	i = x.w.y.h./.7.%A_GuiWidth%.%A_GuiHeight%.`n%A_Gui%:%c%=
	StringSplit, i, i, .
	d := a ? d . ((n := !InStr(d, i9)) ? i9 : "")
		: RegExReplace(d, "\n\d+:" . c . "=[\-\.\d\/]+")
	Loop, 4
		x := A_Index, j := i%x%, i6 += x = 3
		, k := !RegExMatch(a, j . "([\d.]+)", v) + (v1 ? v1 : 0)
		, e := p%j% - i%i6% * k, d .= n ? e . i5 : ""
		, RegExMatch(d, "\Q" . i9 . "\E(?:([\d.\-]+)/){" . x . "}", v)
		, l .= p%j% := InStr(a, j) ? (ex ? "" : j) . v1 + i%i6% * k : ""
	If r
		rx = Draw
	If ex
		ControlMove, %c%, px, py, pw, ph
	Else GuiControl, Move%rx%, %c%, %l%
}

OnButton:
	goto OnChange
return
F1:: goto OnChange

~ESC::
	ControlGetFocus, out, A
	ifEqual,out,Edit1, return
	
	IfWinActive SpreadSheet
		ExitApp
return

GuiClose:
	Exitapp
return

OnReload:
	Reload
return

GuiSize:
	Anchor("SPREAD_SHEET1", "wh")
return

OnAbout:
	msg =
	(Ltrim
	SpreadSheet control by KetilO 
	http://www.radasm.com/
	
	SpreedSheet AHK wrapper
	by majkinetor

	Version: %version%
	)
	msgbox %msg%
return

#include SpreadSheet.ahk


API_DrawIcon( hDC, xLeft, yTop, hIcon)
{
    return DllCall("DrawIcon"
            ,"uint", hDC
            ,"uint", xLeft
            ,"uint", yTop
            ,"uint", hIcon)
}

API_DrawIconEx( hDC, xLeft, yTop, hIcon, cxWidth, cyWidth, istepIfAniCur, hbrFlickerFreeDraw, diFlags)
{
    return DllCall("DrawIconEx"
            ,"uint", hDC
            ,"uint", xLeft
            ,"uint", yTop
            ,"uint", hIcon
            ,"int",  cxWidth
            ,"int",  cyWidth
            ,"uint", istepIfAniCur
            ,"uint", hbrFlickerFreeDraw
            ,"uint", diFlags )
}
LoadIcon(pPath, pSize=32){
	j := InStr(pPath, ":", 0, 0), idx := 1
	if j > 2 
		 idx := Substr( pPath, j+1), pPath := SubStr( pPath, 1, j-1)

	DllCall("PrivateExtractIcons"
            ,"str",pPath,"int",idx-1,"int",pSize,"int", pSize
            ,"uint*",hIcon,"uint*",0,"uint",1,"uint",0,"int")

	return hIcon
}
API_DestroyIcon(hIcon) {
	return,	DllCall("DestroyIcon", "uint", hIcon)
}


