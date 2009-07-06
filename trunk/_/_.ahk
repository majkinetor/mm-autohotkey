/* Title:	_
			Useful stdlib functions.
 */

/*	
	Function:	_
				StdLib loader.
	
	Parameters:
				k	- Script speed, by default -1
				h	- DetectHiddenWindows on/off, by default 0.
	
	Remarks:
				Includes #NoEnv and #SingleInstance force.
 */

_(k=-1, h=0) {
	#NoEnv
	#Singleinstance, force
	DetectHiddenWindows, % h ? "on" : "off"
	SetBatchLines, %k%
}

/*	
	Function:	d
				Delay function.

	Parameters:
				fun		- Function name
				delay	- Delay after which to execute function
				o1, o2	- Function parameters.
	
	Remarks:
				d executes functions after specified period of time (plus run time of function that were executed in the preceding chain).
				It remembers function parameters per function and delay time.

	Example:
	>			d("f1", 1000)						;execute f1 after 1s without args
	>			d("f2", 500,  "2")					; but f2 will first execute with first arg 2
	>			d("f1", 4000, "data1", "data2")		; then f1 again.
 */

d(fun, delay=1, o1="", o2="") {	
	static 
		
	dv(fun delay "o1", o1),  dv(fun delay "o2", o2)
	 ,list := dv("list", dv("list") "," delay "_" fun),
	 , t := SubStr(list, 2, InStr(list, "_")-2)

	SetTimer, d, -%t%
	return
d:	
	list := dv("list")
	, j := InStr(list, "_"),  i := InStr(list "," , ",", 0, j)
	, f := SubStr(list, j+1, i-j-1),  t := SubStr(list, 2,j-2)
	, list := SubStr(list, i),  j := InStr(list, "_"), nt := SubStr(list, 2,j-2)
	, nt -= t

	if nt < 0
		 SetTimer, d, off
	else SetTimer, d, -%nt%
	dv("list",list,0), %f%(dv(f t "o1"), dv(f t "o2"))
return
}

;d storage with autosorted list
dv(var="", value="~`a ", bSort=1) { 
	static
	_ := %var%
	if (value != "~`a "){
		 SetEnv, %var%, %value%
		 if (var = "list") && bSort
		 {
			Sort,list,N D,
			_ := list
		 }
	}
	return _
}
	
/*	
	Function: m
			  MsgBox function
	
	Parameters:
			  o1..o8	- Arguments to display.

	Returns: 
			  o1.

	Examples:
	>		 if (x - m(y) = z)	; Use m inside expressions for debugging.
*/
m(o1="~`a", o2="~`a", o3="~`a", o4="~`a", o5="~`a", o6="~`a", o7="~`a", o8="~`a") {
	loop, 8
		ifEqual, o%A_Index%,~`a,break
		else s .= "'" o%A_Index% "'`n"
	msgbox %s%
	return o1
}

/*
	Function: S
			  Struct function. With S, you define structure, then you can put or get values from it.
			  It also allows you to create your own library of structures that can be included at the start of the program.
	
	Define:
			  S	- Struct definition. First word is struct name followed by : and a space, followed by space separated list of field definitions.
				   Field definition consists of field *name*, optionally followed by = sign and decimal number representation of *offset* and *type*. 
				   For instance, "left=4.1" means that field name is "left", field offset is 4 bytes and field type is 1 (UChar). 
				   You can omit field decimal in which case "Uint" is used as default type and offset is calculated from previous one (or it defaults to 0 if it is first field in the list).
				   Precede type number with 0 to make it *signed type* or with 00 to make it *Float* or *Double*. For instance, .01 is "Char" and .004 is Float. 

				   S will calculate the size of the struct for you based on the input fields. If you don't define entire struct (its perfectly valid to declare only parts of the struct you are interested in)
				   you can still define struct size by including = and *size* after structs name. This allows you to use ! mode later.

	Define Syntax:
 >			pQ		 :: StructName[=[Size]]: FieldDef1 FieldDef2 ... FieldDefN	
 >			FieldDef :: FieldName[=[Def]
 >			Def		 :: offset.[0][0]Type
 >			Type	 :: [0]1 | [0]2 | [0]4 | [0]8 | 004 | 008

	Put & Get:
			  S		 - Pointer to struct data.
			  pQ	 - Query parameter. First word is struct name followed by the *mode char* and a space, followed by the space separated list of field names.
					   If the first char after struct name is "<" or ")" function will work in Put mode, if char is ">" or ")" it works in "Get" mode.
					   If char is "!" function works in IPut mode (Initialize & Put). For ! to work, you must define entire struct, not just part of it.
					   The difference bewteen < and ( is that < works on binary data contained in S, while ( works on binary data pointed to by S. 
					   The same difference applies to > and ) modes.

			  o1..o8 - Reference to output variables (Get) or input variables (Put)

	Put & Get Syntax:
 >			pQ :: StructName[>)<(!]: FieldName1 FieldName2 ... FieldNameN

	Returns:
			 o In Define mode function returns struct size.
			 o In Get/Put mode function returns o1.

			 Otherwise the result contains description of the error.
	
	Examples:
	(start code)
	Define Examples:
			S("RECT=16: left=0.4 top=4.4 right=8.4 bottom=12.4")		;Define RECT explicitly.
			S("RECT: left top right bottom")	; Define RECT struct with auto struct size and auto offset increment. Returns 16. The same as above.
			S("RECT: right=8 bottom")			; Define only 2 fields of RECT struct. Since the fields are last one, ! can be used afterwards. Returns 16.
			S("RECT: top=4)					    ; Defines only 1 field of the RECT. Returns 8, so ! can't be used.
			S("RECT=16: top=4)					; Defines only 1 field of the RECT and overrides size. Returns 16, so ! can be used.
			S("R: x=.1 y=.02 k z=28.004")		; Define R, size don't care. R.x is UChar at 0, R.y is Short at 1, R.k is Uint at 3 and  R.z is Float at 28.
			S("R=32: x=.1 y=.02 k z=28.004")	; The same but override struct size. Returns user size (32 in this case).
			
	Get & Put Examples:
			S(b, "RECT< left right", x,y)		; b.left := x, b.right := y (b must be initialized)
			S(b, "RECT> left right", x,y)		; x := b.left, y := b.right
			S(b, "RECT! left right", x,y)		; VarSetCapacity(b, SizeOf(RECT)), b.left = x, b.right=y
			S(b:=&buf,"RECT) left right", x,y)	; *b.left = x, *b.right=y
			S(b:=&buf,"RECT( left right", x,y)	; x := *b.left , y := *b.right
	(end code)
 */
S(ByRef S,pQ,ByRef o1="~`a ",ByRef o2="",ByRef o3="",ByRef  o4="",ByRef o5="",ByRef  o6="",ByRef o7="",ByRef  o8=""){
	static
	static 1="UChar", 2="UShort", 4="Uint", 004="Float", 8="Uint64", 008="Double", 01="Char", 02="Short", 04="Int", 08="Int64"
	local last_offset:=-4, last_type := 4, i, j, R

	if (o1 = "~`a ")
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
		return _%R%!="" ? _%R% : _%R% := last_offset + last_type
	}
	j := InStr(pQ, A_Space)-1,  i := SubStr(pQ, j, 1), R := SubStr(pQ, 1, j-1), pQ := SubStr(pQ, j+2)
	IfEqual, R,, return A_ThisFunc "> Struct name can't be empty"
	if (i = "!") 
		 VarSetCapacity(s, _%R%)
	loop, parse, pQ, %A_Space%, %A_Space%
	{	
		field := A_LoopField, data := %R%_%field%, offset := floor(data), type := SubStr(data, StrLen(offset)+2), type := %type%
		ifEqual, data, , return A_ThisFunc "> Field or struct isn't recognised :  " R "." field 
		if i in >,)
			  o%A_Index% := NumGet(i=")" ? S+0 : &S+0, offset,type)
		else  NumPut(o%A_Index%, i=")" ? S : &S+0, offset,type)
	}
	return o1	
}

/*
	Function:	v
				Storage function, designed to use as stdlib or copy and enhance.
			  	
	Parameters:
			  var		- Variable name to retrieve. To get up several variables at once (up to 6), omit this parameter.
			  value		- Optional variable value to set. If var is empty value contains list of vars to retrieve with optional prefix
			  o1 .. o6	- If present, reference to variables to receive values.
	
	Returns:
			  o	if _value_ is omitted, function returns the current value of _var_
			  o	if _value_ is set, function sets the _var_ to _value_ and returns previous value of the _var_
			  o if _var_ is empty, function accepts list of variables in _value_ and returns values of those variables in o1 .. o5

    Remarks:
			  To use multiple storages, copy *v* function and change its name. 
			  			  
			  You can choose to initialize storage from additional ahk script containing only list of assigments to storage variables,
			  to do it internaly by adding the values to the end of the your own copy of the function, or to do both, by accepting user values on startup,
			  and checking them afterwards.
  			  If you use stdlib module without including it directly, just make v.ahk script and put variable definitions there.

			  Don't use storage variables that consist only of _ character as those are used to regulate inner working of function.

	Examples:
	(start code)			
 			v(x)		; returns value of x or value of x from v.ahk inside scripts dir.
 			v(x, v)		; set value of x to v and return previous value
 			v("", "x y z", x, y, z)				; get values of x, y and z into x, y and z
 			v("", "prefix_)x y z", x, y, z)	; get values of prefix_x, prefix_y and prefix_z into x, y and z
	(end code)
 */
v(var="", value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	ifEqual,___, ,gosub %A_ThisFunc%

	if (var = "" ){
		if ( _ := InStr(value, ")") )
			__ := SubStr(value, 1, _-1), value := SubStr(value, _+1)
		loop, parse, value, %A_Space%
			_ := %__%%A_LoopField%,  o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	} else _ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
v:
	;Initialize externally, try several places
	   #include *i %A_ScriptDir%\v.ahk
	   #include *i %A_ScriptDir%\inc\v.ahk
	;   ...
	;
	;AND/OR initialize internally:
	;		var1 .= var1 != "" ? "" : 1			;if user set it externally, dont change it
	;		var2 := value						;initialize always
	___ := 1
return
}

/*
	Function:	t
				Timer
			  	
	Parameters:
				v - Reference to output variable. Omit to reset timer.
	
	Returns:
				v
	
	Example:
			(start code)
				t()
				loop, 10000
					f1()
				p := t()

				loop, 10000
					f2()
				t(k)
				m(p, k)
			(end code)
			
 */
t(ByRef v="~`a "){
	static t
	ifEqual, v, ~`a ,SetEnv, t, %A_TickCount%
	return v := A_TickCount - t
}



/* Group: About
	o 0.2 by majkinetor
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/> 
 */