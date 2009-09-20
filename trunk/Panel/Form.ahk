_("e")
	hForm1	:=	Form_New("w500 h400", "Resize ToolWindow")

	hPanel	:=	Form_Add(hForm1,  "Panel",	 "",	  "w250",		"Align L", "Attach p")
	hButton1 :=	Form_Add(hPanel,  "Button",  "OK",	  "gOnBtn h100","Align T", "Attach p", "Cursor hand", "Tooltip I am nasty button")
	hButton2 :=	Form_Add(hPanel,  "Button",  "Cancel","gOnBtn",		"Align F", "Attach p", "Tooltip jea baby")

	hPanel2	:=	Form_Add(hForm1,  "Panel",	 "",	  "",			"Align F", "Attach p")
	hEdit1	:=  Form_Add(hPanel2, "Edit",	 "mrlj",  "h200",		"Align T", "Attach p")
	hCal1	:=  Form_Add(hPanel2, "MonthCal","",	  "",			"Align F", "Attach p")

	Form_Show()
return

F1::
	WinMove, ahk_id %hForm1%, , , , 300, 300
return

OnBtn:
	msgbox % A_GuiCOntrol
return


Form_New(Size="", Options="") {
	static no=1

	if Name=
		Name := "Form" no++
	
	if Size=
		Size := "w400 h200"

	if !(n := Form_getFreeGuiNum())
		return A_ThisFunc "> Maximum number of windows created."

	Gui, %n%:+LastFound +Label%Name%_ %Options%
	hForm := WinExist()+0

	Form(Name, n), Form(hForm, n) 
	
	Gui, %n%:Show, %Size% Hide, %Name%
	Gui, %n%:Margin, 0, 0		;this makes Add function behave normaly i.e. if you add control on pos X,Y it will not be X+mx and Y+my. This is important for Panel.

	return hForm
}

Form_Show( Name="", Title="" ){
	if Name=
		Name := "Form1"

	n := Form(Name)
	Gui, %n%:Show, ,%Title%
}

Form_Close( Name ) {
	local g
	g := "Form_" Name, g := %g%
	Gui, %g%:Hide
}


Form_Add(HParent, Ctrl, Txt="", Opt="", E1="",E2="",E3="",E4="",E5=""){
	static integrated = "Text,Edit,UpDown,Picture,Button,Checkbox,Radio,DropDownList,ComboBox,ListBox,ListView,TreeView,Hotkey,DateTime,MonthCal,Slider,Progress,GroupBox,Tab2,StatusBar"

  ;make control with options
	if Ctrl is not Integer
	{
		if Ctrl in %integrated% 
			 hCtrl := Form_addAhkControl(HParent, Ctrl, Txt, Opt)
		else if IsFunc(f_Add := Ctrl "_Add2Form")
			 hCtrl := %f_Add%(HParent, Txt, Opt)
		else return A_ThisFunc "> Custom control doesn't have Add2Form function: " Ctrl 
	}

  ;apply extensions
	loop {
		o := E%A_Index%
		ifEqual,o,,break

		f_Extension := SubStr(o, 1, k:=InStr(o, " ")-1), k := SubStr(o, k+2)
		if IsFunc(f_Extension)
			 o := %f_Extension%(hCtrl, k)
		else if IsFunc( f_Extension := "Extension_" f_Extension )
			 o := %f_Extension%(hCtrl, k)
		else return A_ThisFunc "> Unsupported extension: " f_Extension
		ifEqual, o,0, return A_ThisFunc " >   Unsuported " Ctrl " extension: " f_Extension
	}
		
	return hCtrl
}


Panel_New(HParent, X, Y, W, H, Style="", Text="") { 
	static init=0
	static WS_VISIBLE=0x10000000, WS_CHILD=0x40000000, WS_CLIPCHILDREN=0x2000000, SS_NOTIFY=0x100
	static SS_SIMPLE = 0xB, SS_BLACKFRAME = 7, SS_BLACKRECT = 4, SS_CENTER=0x201, SS_VCENTER=0x200, SS_HCENTER = 1, SS_GRAYFRAME = 0x8, SS_GRAYRECT = 0x5, SS_RIGHT = 2, SS_SUNKEN = 0x1000, SS_WHITEFRAME = 9, SS_WHITERECT = 6

	if !init
		init := Panel_registerClass()

	hStyle := 0
	loop, parse, Style, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, , continue
		if A_LoopField is integer
			 hStyle |= A_LoopField
		else hStyle |= SS_%A_LOOPFIELD%
	}

	hCtrl := DllCall("CreateWindowEx" 
	  , "Uint",	  0
	  , "str",    "Panel"	
	  , "str",    text		
	  , "Uint",   WS_VISIBLE | WS_CHILD	| WS_CLIPCHILDREN | SS_NOTIFY | hStyle
	  , "int",    X, "int", Y, "int", W, "int",H
	  , "Uint",   HParent
	  , "Uint",   0, "Uint",0, "Uint",0, "Uint") 

	ifEqual, res, 0, return A_ThisFunc "> Failed to create control."
	return hCtrl
} 

;==================================== PRIVATE ================================================

Form_getToken(s, r=0) {
	static next=1, sep=" "

	ifEqual, r,1,SetEnv, next, 1

	j := InStr(s, sep, 0, next)
	IfEqual, j, 0, return SubStr(s, next), next := 1
	r := SubStr(s, next, j-next), next:=j+1
	return, r
}

/*
 Function:	Parse
 			Form options parser.

			o	- String with Form options.
			pQ	- Query parameter. It is space a separated list of option names you want to extract from the options string. See bellow for
				  details of extraction.  
			o1..o10 - Variables to receive requested options.

 Options string:	
			Options string is space separated list of named or unnamed options. 
			Option is simply a sentence between quote chars. 
			You don't have to use quotes when you don't have spaces in sentence.	
			Option can have a name which you can use to refer to it. Name can be anything that can pass as
			ahk variable name. The syntax is (_ denotates space):

 >			options ::= [name"="]'word1 word2 ... wordN' _ [options]

 Examples:
			First one is regular AHK GUI option string, the second one also contains named options.

 >			options =  x20 y40 w0 h0 red HWNDvar gLabel
 >			options =  w800 h600 style='Resize ToolWindow' font='s12 bold, Courier New' 'show' dummy='dummy'

			In first line there are only unnamed options. In second line, there are all possible types of options
			and you can see different styles to write them.

 Extracting:
			To extract set of options from the option string you first use query parameter to specify an option 
			then you supply variables to hold the results:

 >		    Parse(o, "x# y# h# red? HWND* style font 1 3", x, y, h, red, HWND, style, font, p1, p3)

			name	- Get the option by that name (style, font)
			N		- Get unnamed option by its position in the options string,  (1 3)
			str*	- Get unnamed option that starts with string name (HWND*)
			str#	- Get unnamed option that holds the number and have str prefix (x# y# h#)
			str?	- Boolean option, output is true if str exists in the option string or false otherwise (red?)

 Remarks:
			Entire string is parsed even if only 1 option is in the query parameter. This function is not ment to be 
			used with simple option strings, but with those that might contain large number of possible options and most of
			them are required to be extracted.

			Currently you can extract maximum 10 options at a time, but this simple restriction can be removed for up to 29 options
			(as maximum number of variables you can pass to an AHK function is 31)

 Returns:
			Number of options in the string.
 */
Form_Parse(o, pQ, ByRef o1="",ByRef o2="",ByRef o3="",ByRef o4="",ByRef o5="",ByRef o6="",ByRef o7="",ByRef o8="", ByRef o9="")
{
	loop, parse, o, %A_Space%
	{	
		if (LF := A_LoopField) = ""	{
			if c
				p_%n% .= A_Space
			continue
		}
		lq := SubStr(LF, 1, 1) = "'", rq := SubStr(LF, 0, 1) = "'",   len=StrLen(LF),   q := lq && rq,  sq := lq AND !rq
		e := (!lq*!c) * InStr(LF, "="),  liq := e && (SubStr(LF, e+1, 1)="'"),  iq := liq && rq
		if !c
			n := (e ? SubStr(LF, 1, e-1) : (i=""? i:=1:++i)), c := (c || sq || liq) AND !iq, p_# := i
		if q or iq
			p_%n% := SubStr(LF, iq ? e+2:2, len-2-(iq ? e : 0))
		else if c
			if e
				 p_%n% := SubStr(LF, e+2)
			else p_%n% .= " " SubStr(LF, sq ? 2 : 1,  rq ? len-1 : len),   c := rq ? 0 : 1
		else p_%n% := e ? SubStr(LF, e+1) : LF
	}
	loop, %p_#%
		_ := SubStr(p_%A_Index%, 1, 1), p_%_% := SubStr(p_%A_Index%, 2)		;this creates locals x, y, w, h
	
	loop, parse, pQ, %A_Space%
		if (A_Index > 9)
			break
		else _ := "p_" A_LoopField,  o%A_Index% := %_%
}

Form_addAhkControl(hParent, Ctrl, Txt, Opt ) {
	Gui, Add, %Ctrl%, HWNDhCtrl %Opt%, %Txt%
	DllCall("SetParent", "uint", hCtrl, "uint", hParent)	
	return hCtrl+0
}

Form_getFreeGuiNum(){
	loop, 99  {
		Gui %A_Index%:+LastFoundExist
		IfWinNotExist
			return A_Index
	}
	return 0
}

;storage
Form(var="", value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	if (var = "" ){
		if ( _ := InStr(value, ")") )
			__ := SubStr(value, 1, _-1), value := SubStr(value, _+1)
		loop, parse, value, %A_Space%
			_ := %__%%A_LoopField%,  o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	} else _ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
}

Panel_wndProc(Hwnd, UMsg, WParam, LParam) { 
	static WM_SIZE:=5, redirect = "32,78,273,277,279", anc, f="Attach_"		;WM_SETCURSOR,WM_COMMAND,WM_NOTIFY,WM_HSCROLL,WM_VSCROLL
	
	if UMsg in %redirect%
	{	
		anc := DllCall("GetAncestor", "uint", Hwnd, "uint",2)	;GWL_ROOT = 2
		return DllCall("SendMessage", "uint", anc, "uint", umsg, "uint", wparam, "uint", LParam)
	}
	
	if (UMsg = WM_SIZE)
		return IsFunc(f) ? %f%(Wparam, LParam, UMsg, Hwnd) : ""

	return DllCall("CallWindowProc","uint",A_EventInfo,"uint",Hwnd,"uint",UMsg,"uint",WParam,"uint",LParam)
}


Panel_registerClass() {
    static ClassAtom, ClassName="Panel"
    
	ifNotEqual, ClassAtom,, return ClassAtom
    
    VarSetCapacity(wcl,40)
    if ! DllCall("GetClassInfo","uint",0,"str","Static","uint",&wcl)
        return false
    NumPut(NumGet(wcl)|0x20000,wcl)						; wcl->style |= CS_DROPSHADOW
    NumPut(&ClassName,wcl,36)							; wcl->lpszClassName = &ClassName
    NumPut(DllCall("GetModuleHandle","uint",0),wcl,16)  ; wcl->hInstance = NULL

	; Create a callback for Form_WndProc, passing Static's WindowProc as A_EventInfo. lpfnWndProc := the callback.
    NumPut(RegisterCallback("Panel_WndProc","",4,NumGet(wcl,4)),wcl,4)    
    return DllCall("RegisterClass","uint",&wcl)
}

Panel_Add2Form(hParent, Txt, Parameters){
	Form_Parse(Parameters, "x y w h style", x, y, w, h, style)
	return Panel_New(hParent, x, y, w, h, style, Txt)	
}

#include inc
#include Align.ahk
#include Attach.ahk
#include Win.ahk
#include Extensions.ahk