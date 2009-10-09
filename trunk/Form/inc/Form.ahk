/*
	Title:	Form

	Form module presents alternative way of creating AHK windows. It can be used alone or as a part of the Forms framework.
	Some of the main differences between normal GUI creation and the way it is done using the module are:

	o Bigger cohesion - one function call can set most of the creation features for any control thus making changes, maintenance and bug testing much easier.
	o Custom controls without any syntax differences. The end effect is the same as if you were using integrated AHK control.
	o Control extensions provide way to implement any behavior that you may want for control.
	o Provides elements for standardization of Gui/control creation process, option specification and module design.
 */

/*
 Function:  Add
 			Add control to the parent.
 
 Parameters: 
 			HParent	- Handle of the parent. This can be top level window or container control.
 			Ctrl	- Control name or handle. All AHK controls are supported by default. Custom controls must be included if needed. See below for details.
 			Txt		- Text of the new control (optional).
			Opt		- Space separated list of control options (optional).
			E1..E5  - Control extensions (optional). Extension function must exist in the script in order to use it. Option string may preceed 
					  extension name in the RegEx manner. See below for details.
 
 Adding Controls:
 			Form can make any internal AHK control and any custom control.
			Making internal control is similar to using native command Gui, Add :
 
 > 			Gui, Add,		   CtrlName,  Options, Text
 > 			Form_Add(hParent, "CtrlName", "Text", "Options")
 
 			To make custom control, you must include appropriate module. If the module contains *Add2Form* function you can create it the same
			way as internal control, by specifying its textual name in Ctrl parameter. Otherwise, after creating the control the way described in the
			module documentation and obtaining its handle, you can specify the handle as Ctrl parameter. In that case Txt and Opt parameters are ignored
			but extensions will still work.

			Implementing Add2Form function is the best way to use custom control as it makes you forget about difference between custom and integrated controls.
		    The following is implementation of Add2Form for Panel control.
		
			(start code) 
			Panel_Add2Form(hParent, Txt, Opt){
				static parse = "Form_Parse"
				%parse%(Opt, "x# y# w# h# style", x, y, w, h, style)
				hCtrl := Panel_Add(hParent, x, y, w, h, style, Txt)	
				return hCtrl
			}

			;with above in place you can use:
			hPanel := Form_Add(hForm, "Panel", "Panel1", "w100 h200 hidden")
			(end code)
	
			When executing Add function, Form will check if there is Panel_add2Form function and if that's true, it will call it with 
			adequate parameters. If not, function will return the error message. 

			Controls can use Form_Parse function to extract individual options from the Opt string. It should be called using dynamic function calls so
			that control can work even when included in scripts that don't use Form module (without it, compiler would generate missing include error).

 Using Extensions:
			Extension is any AHK function that accepts handle of the control as its first parameter. It can have any number of of additional parameters.
			You can quickly write new extension when you need it and it will instantly become available, or you can include 3thd party extensions.
			Extensions are used similarly to AHK commands - you specify extension name followed by a space (not comma !) and list of its parameters between commas.
		
		>	hButton :=	Form_Add(hForm1, "Button", "Cancel", "gOnButton", "Align F, 250", "Attach p r", "Tooltip I pwn")
		    
			In this example Add function has 3 extensions: Align with 2 parameters and Attach & Tooltip with 1 parameter.
			The above code is equivalent to:

		>	hButton :=	Form_Add(hForm1, "Button", "Cancel", "gOnButton")	;make button without extensions:
		>	Align(hButton, "F", 250), Attach(hButton, "p r"), Ext_Tooltip(hButton, "I pwn")

			Notice that Tooltip extension uses "Ext_" prefix. Add function will first check for the function name that matches extension name and if
			doesn't exist, it will try with "Ext_" prefix.

			The order of extensions may be important. In above case Attach extension will not produce intented results if control doesn't have dimensions already
			set, so Align extension is placed before it (in this case, the same could be achieved without Align extension by specifying x..w options). 
			Tooltip extension, however, doesn't depend on anything so it can be put anywhere in extension list. 

			You can customize parameter extraction with 2 chars that can optionally preceed the extension name. For instance "Font s18, Courier New" will 
			use Font extension with 2 parameters "s18" and " Courier New". Since Font extension accepts comma in input this is wrong interpretation.
			To specify that sentence containing comma is part of the argument itself, set "*|)Font s18, Courier New". First parameter sets the mode. * is
			normal mode, "!" is trimmed mode. Second option sets separator char, by default comma. In this case its changed to | so Font extension will be called
			with single argument "s18, Courier New".
			
 Returns:
 			Control's handle if successful. 0 or error mesage if control can't be created. Error message on invalid usage.
 */
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
	} else 	DllCall("SetParent", "uint", hCtrl := Ctrl, "uint", HParent)
	
  ;apply extensions
	loop {
		o := E%A_Index%
		ifEqual,o,,break
		f_Extension := SubStr(o, 1, k:=InStr(o, " ")-1), k := SubStr(o, k+2), iOpt := InStr(f_Extension, ")")
		opt := iOpt ? (SubStr(f_Extension, 1, iOpt-1), f_Extension := SubStr(f_Extension, iOpt+1)) : ""
		Form_split(opt, k, p1, p2, p3, p4, p5)
		if !(IsFunc(f_Extension) || IsFunc( f_Extension := "Ext_" f_Extension ))
			return A_ThisFunc "> Unsupported extension: " f_Extension
		%f_Extension%(hCtrl, p1, p2, p3, p4, p5)
	}

	return hCtrl
}

/*  
 Function:	AutoSize
 			Resize the window so all controls fit. 

 Dependencies:
			Win <1.22>
 */
Form_AutoSize( Hwnd ) {
    width := height := 0
	Win_Get(Hwnd, "NhBxy", th, bx, by)
	children := Win_GetChildren(Hwnd)
    Loop, Parse, children, `n
    { 
		ifEqual, A_LoopField,, continue
		Win_GetRect(A_LoopField, "*xywh", cx, cy, cw, ch),   w := cx+cw,   h := cy+ch
		ifGreater, w, %width%,  SetEnv, width, %w%
		ifGreater, h, %height%, SetEnv, height, %h%
    }
	width +=2*bx, height += th + 2*by
	Win_Move(Hwnd, "", "", width, height)
}

Form_Close( Name ) {
	local g
	g := "Form_" Name, g := %g%
	Gui, %g%:Hide
}

/*
 Function:	New
			Creates new form.
 
 Parameters:
			Options	- Form options. Any AHK Gui option can be set plus extensions listed bellow:

 Extensions:
			a#		- Alpha. Range from 0% - 100%
			c*		- Gui color. Hexadecimal or integer value.
			Font	- Gui font (style, face).
			Name	- Name of the form, by default FormN where N is the number of the forms created.
			T		- Transparent window.
			  
 Returns:
			Form handle.

 Remarks:
			Margin for the form is set to 0,0 always.
 */
Form_New(Options="") {
	static no=1

	Form_Parse(Options, "x# y# w# h# a# c* Font Label* t?", x, y, w, h, a, c, font, name, t, extra)

	ifEqual, name,,SetEnv, Name, % "Form" no++
	pos := (x!="" ? " x" x : "") (y!="" ? " y" y : "") (w!="" ? " w" w : "") (h!="" ? " h" h : "")
	ifEqual, pos,, SetEnv, pos, w400 h200

	if !(n := Form_getFreeGuiNum())
		return A_ThisFunc "> Maximum number of windows created."

	Gui, %n%:+LastFound +Label%Name%_ %extra%
	hForm := WinExist()+0

	ifNotEqual, a,,WinSet, Transparent, % a*2.5
	ifNotEqual, c,,Gui, %n%:Color, %c%
	if (t) {
		Gui, Color, 12345
		WinSet, TransColor, 12345
		;w1 := w-5, h1 := h-5
		;WinSet, Region, 5-5 w%w1% h%h1%	;remove border on some systems...
	}
		
	if (font != "") {
		StringSplit, font, font, %A_Space%
		Gui, %n%:Font, %font1%, %font2%
	}
	
	Gui, %n%:Show, %pos% Hide, %Name%
	Gui, %n%:Margin, 0, 0		;this makes Add function behave normaly i.e. if you add control on pos X,Y it will not be X+mx and Y+my. This is important for Panel.

	Form(Name, n), Form(hForm, n)
	return hForm
}

/*
 Function:	Parse
 			Form options parser.

			O	- String with Form options.
			pQ	- Query parameter. It is space a separated list of option names you want to extract from the options string. See bellow for
				  details of extraction.  
			o1..o10 - Variables to receive requested options. Their number should match the number of variables you want to extract from the option string plus
					  1 more if you want to get non-consumed options.

 Query:
			Query is space separated list of variables you want to extract with optional settings prefix .
			The query syntax is:

 >			Query :: [Settings)][Name=]Value {Query}
 >			Settings :: sC|aC|qC|eC|c01{Settings}
 >			Value   :: SentenceWithoutSpace | 'SentenceWithSpace'


 Examples:
 >			options =  x20 y40 w0 h0 red HWNDvar gLabel
 >			options =  w800 h600 style='Resize ToolWindow' font='s12 bold, Courier New' 'show' dummy=dummy=5

 Extracting:
			To extract variables from the option string you first use query parameter to specify how to do extraction
			then you supply variables to hold the results:

 >		    Parse(O, "x# y# h# red? HWND* style font 1 3", x, y, h, bRed, HWND, style, font, p1, p3)

			name	- Get the option by the name (style, font). In option string, option must be followed by assignment char (= by default).
			N		- Get option by its position in the options string, (1 3).
			str*	- Get option that has str prefix (HWND*). 
			str#	- Get option that holds the number and have str prefix (x# y# h#).
			str?	- Boolean option, output is true if str exists in the option string or false otherwise (red?).

 Settings:
			You can change separator(s), assignment(a), escape(e) and quote(q) character and case sensitivity (c) using syntax similar to RegExMatch.
			Option value follows the option name without any separator character.

 >			Parse("x25|y27|Style:FLAT TOOLTIP", "s|a:c1)x# y# style", x, y, style)
			
			In above example, | is used as separator, : is used as assignment char and case sensitivity is turned on (style wont be found as it starts with S in options string).

			sC	- Set separator char to C (default is space)
			aC  - Set assignment char to C (default is =)
			qE	- Set quote char to C	(default is ')
			eE	- Set escape char to C  (default is	`)

 Remarks:
			Currently you can extract maximum 10 options at a time, but this restriction can be removed for up to 29 options.
			You can specify one more reference variable in addition to those you want to extract to get all extra options in the option string.

 Returns:
			Number of options in the string.
 */
Form_Parse(O, pQ, ByRef o1="",ByRef o2="",ByRef o3="",ByRef o4="",ByRef o5="",ByRef o6="",ByRef o7="",ByRef o8="", ByRef o9="", ByRef o10=""){
	cS := " ", cA := "=", cQ := "'", cE := "``", cC := 0
	if (j := InStr(pQ, ")")) && (opts := SubStr(pQ, 1, j-1), pQ := SubStr(pQ, j+1))
		Loop, parse, opts
			  mod(A_Index, 2) ? f:=A_LoopField : c%f%:=A_LoopField

	p__0 := 0, st := "n"
	loop, parse, O						;  states: normal(n), separator(s), quote(q), escape(e)
	{
		c := A_LoopField
		if (c = cS) {
			if !InStr("qs", st)	
				p__0++,  p__%p__0% := token,  token := "",  st := "s"			
		}
		else if (c = cE)
			st := "e"
		else if (c = cQ) && (st != "e") 
			 ifNotEqual, st, q, SetEnv, st, q				 
			else st := "n"		
		else ifNotEqual, st, q, SetEnv, st, n
		if st not in s,e
			 token .= c		
	}
	if (token != "")
		p__0++, p__%p__0% := token
	
	loop, parse, pQ, %A_Space%
	{
		c := SubStr(f := A_LoopField, 0),  n := InStr("?#*", c) ? SubStr(f, 1, -1) : f,  j := A_Index, o := ""
		if n is integer
			o := p__%n%,  p__%n% := ""
		else  {	
			l := StrLen(n)
			loop, %p__0% {
				p := p__%A_Index%
				if (!cC && !(SubStr(p, 1, l) = n)) || (cC & !(SubStr(p, 1, l) == n))
					continue				
				v := SubStr(p,l+1,1) = cA  ? SubStr(p,l+2) : SubStr(p, l+1)
				ifEqual, c, ?, SetEnv, v, 1
				if (c="#") && (v+0 = "")
					continue
				o := v,  p__%A_Index% := ""
				break
			}
		}
		o%j% := SubStr(o, 1, 1) = cQ ? SubStr(o, 2, -1) : o
	}
	j++
	loop, %p__0%
		o%j% .= p__%A_Index% != "" ? p__%A_Index% cS : ""
	o%j% := SubStr(o%j%, 1, -1)
	return p__0
}

Form_Show( Name="", Title="" ){
	if Name=
		Name := "Form1"

	n := Form(Name)
	Gui, %n%:Show, ,%Title%
}

/*
 Function:	Subclass 
			Subclass child window (control)
 
 Parameters: 
			hCtrl   - Handle to the child window to be subclassed.
			Fun		- New window procedure. You can also pass function address here in order to subclass child window.
					  with previously created window procedure.
			Opt		- Optional callback options for Fun, by default "" .
		   $WndProc - Optional reference to the ouptut variable that will receive address of the new window procedure.

 Returns:
			The addresss of to the previous window procedure or 0 on error.	

 Remarks:
			Should be used by extensions if needed.
			Works only for controls created in the autohotkey process.

 Example:
	(start code)
  	if !Form_SubClass(hwndList, "MyWindowProc") 
  	     MsgBox, Subclassing failed. 
  	... 
  	MyWindowProc(hwnd, uMsg, wParam, lParam){ 
  
  	   if (uMsg = .....)  
            ; my message handling here 
  
  	   return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam) 
  	}
	(end code)
 */
Form_Subclass(hCtrl, Fun, Opt="", ByRef $WndProc="") { 
	if Fun is not integer
	{
		 oldProc := DllCall("GetWindowLong", "uint", hCtrl, "uint", -4) 
		 ifEqual, oldProc, 0, return 0 
		 $WndProc := RegisterCallback(Fun, Opt, 4, oldProc) 
		 ifEqual, $WndProc, , return 0
	}
	else $WndProc := Fun
	   
    return DllCall("SetWindowLong", "UInt", hCtrl, "Int", -4, "Int", $WndProc, "UInt")
}

/*
	Function:	Form
				Storage.
			  	
	Parameters:
			  var		- Variable name to retrieve. To get up several variables at once (up to 6), omit this parameter.
			  value		- Optional variable value to set. If var is empty value contains list of vars to retrieve with optional prefix
			  o1 .. o6	- If present, reference to variables to receive values.
	
	Returns:
			  o	if _value_ is omitted, function returns the current value of _var_
			  o	if _value_ is set, function sets the _var_ to _value_ and returns previous value of the _var_
			  o if _var_ is empty, function accepts list of variables in _value_ and returns values of those variables in o1 .. o5

    Remarks:
			  Form extensions can use this function to keep its internal data. This avoid the need to polute global variable space.
			  In order to support working with or without forms, you can use dynamic function calls to invoke this function.

	Examples:
	(start code)			
 			Form(x)								; returns value of x or value of x from v.ahk inside scripts dir.
 			Form(x, v)							; set value of x to v and return previous value.
 			Form("", "x y z", x, y, z)			; get values of x, y and z into x, y and z.
 			Form("", "prefix_)x y z", x, y, z)	; get values of prefix_x, prefix_y and prefix_z into x, y and z.
	(end code)
 */
Form(Var="", Value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
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

;==================================== PRIVATE ================================================

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

Form_split(opt, s, ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="") {
	o1 := o2 := o3 := o4 := o5 := "", sep := (mode := SubStr(opt, 1, 1)) ? SubStr(opt, 2,1) : ",", omit := mode = "!" ? A_Space A_Tab : ""
	ifEqual, sep,,SetEnv, sep, `,
	StringSplit, o, s, %sep%, %omit%
	return o0
}

/*
Group: About
	o v0.6 by majkinetor.
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/> 
/*
