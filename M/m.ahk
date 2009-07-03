/* Title:	M
			Set of useful stdlib functions. m
 */

/*	
	Function: m
			  MsgBox function
	
	Paramters:
			  o1..o8	- Arguments to display. Use this function without any arguments to load library.

	Returns: 
			  o1.

	Examples:
	>		 m()				; Load library so you can use other functions defined in m.ahk
	>		 if (x - m(y) = z)	; Use m inside expressions for debugging.
*/
m(o1="~`a", o2="~`a", o3="~`a", o4="~`a", o5="~`a", o6="~`a", o7="~`a", o8="~`a") {
	loop, 8
		ifEqual, o%A_Index%,~`a,break
		else s .= "'" o%A_Index% "'`n"
	ifNotEqual, o%A_Index%,~`a,	msgbox %s%
	return o1
}

/*
	Function: S
			  Struct function
	
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

/*
	Function:	v
				Storage function
			  	
	Parameters:
			  var		- Variable name to retreive. To get up to 5 variables at once, omit this parameter.
			  value		- Optional variable value to set. If var is empty value contains list of vars to retreive with optional prefix
			  o1 .. o5	- If present, reference to variables to receive values.
	
	Returns:
			  o	if _value_ is omited, function returns the current value of _var_
			  o	if _value_ is set, function sets the _var_ to _value_ and returns previous value of the _var_
			  o if _var_ is empty, function accepts list of variables in _value_ and returns values of those varaiables in o1 .. o5

	Examples:
	(start code)			
 			v(x)	 - return value of x
 			v(x, v)  - set value of x to v and return previous value
 			v("", "x y z", x, y, z)  - get values of x, y and z into x, y and z
 			v("", "preffix_)x y z", x, y, z) - get values of preffix_x, preffix_y and preffix_z into x, y and z
	(end code)
			
*/
v(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	if (var = "" ){
		if ( _ := InStr(value, ")") )
			__ := SubStr(value, 1, _-1), value := SubStr(value, _+1)
		loop, parse, value, %A_Space%
			_ := %__%%A_LoopField%,  o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	} else _ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}
