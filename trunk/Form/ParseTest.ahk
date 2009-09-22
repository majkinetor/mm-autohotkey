	o = x20 y40 w0 h0 red HWNDvar gLabel                                                     
	Parse(o, "x# y# w# h# red? HWND* g*", x, y, w, h, red, hwnd, g)	
	m(x,y,w,h,red, hwnd, g)

	o = w800 h600 style='Resize ToolWindow' font='s12 bold, Courier New' HWND12 'show' dummy=red
	Parse(o, "w# h# red? HWND# style font dummy show?", w, h, bRed, HWND, style, font, d, show)
	m(w,h, bRed, hwnd, style, font, d, show)
	
	o = 'mika je car' 'pera je car' laza='laza je car'
	m := Parse(o, "laza 1 2", p1, p2, p3)
	m(m, p1, p2, p3)
return

/*
 Function:	Parse
 			Form options parser.

			o	- String with Form options.
			pQ	- Query parameter. It is space a separated list of option names you want to extract from the options string. See bellow for
				  details of extraction.  
			o1..o10 - Variables to receive requested options.

 Options string:	
			Options string is space separated list of named or unnamed options. 
			The syntax is:

 >			Options :: [Name=]Value {Options}
 >			Value   :: SentenceWithoutSpace | 'SentenceWithSpace'

 Examples:
			First one is regular AHK GUI option string, the second one also contains named options.

 >			options =  x20 y40 w0 h0 red HWNDvar gLabel
 >			options =  w800 h600 style='Resize ToolWindow' font='s12 bold, Courier New' 'show' dummy=dummy=5

			In first line there are only unnamed options. 
			In second line, there are all possible types of options	and you can see different styles to write them.

 Extracting:
			To extract set of options from the option string you first use query parameter to specify an option 
			then you supply variables to hold the results:

 >		    Parse(O, "x# y# h# red? HWND* style font 1 3", x, y, h, bRed, HWND, style, font, p1, p3)

			name	- Get the option by that name (style, font)
			N		- Get unnamed option by its position in the options string,  (1 3)
			str*	- Get unnamed option that starts with string name (HWND*)
			str#	- Get unnamed option that holds the number and have str prefix (x# y# h#)
			str?	- Boolean option, output is true if str exists in the option string or false otherwise (red?)

 Remarks:
			Entire string is parsed even if only 1 option is in the query parameter.
			Currently you can extract maximum 10 options at a time, but this restriction can be removed for up to 29 options.

 Returns:
			Number of options in the string.
 */
Parse(O, pQ, ByRef o1="",ByRef o2="",ByRef o3="",ByRef o4="",ByRef o5="",ByRef o6="",ByRef o7="",ByRef o8="", ByRef o9="", ByRef o10=""){
	sep := A_Space, no := 0
	loop, parse, O, %sep%
	{	
		if (LF := A_LoopField) = ""	{
			if c
				p_%n% .= A_Space
			continue
		}
		lq := SubStr(LF, 1, 1) = "'", rq := SubStr(LF, 0, 1) = "'",   len=StrLen(LF),   q := lq && rq,  sq := lq AND !rq
		,e := (!lq * !c) * InStr(LF, "="),  liq := e && (SubStr(LF, e+1, 1)="'"),  iq := liq && rq

		if !c
			n := (e ? SubStr(LF, 1, e-1) : (i="" ? i:=1 : ++i)),  c := (c || sq || liq) AND !iq, p_# := i
		if q or iq
			p_%n% := SubStr(LF, iq ? e+2:2, len-2-(iq ? e : 0)), no++
		else if c
			if e
				 p_%n% := SubStr(LF, e+2)
			else p_%n% .= (p_%n% = "" ? "" : " ") SubStr(LF, sq ? 2 : 1,  rq ? len-1 : len),   c := rq ? (0,no++) : 1
		else p_%n% := e ? SubStr(LF, e+1) : LF, no++
	}
	loop, parse, pQ, %A_Space%
	{
		c := SubStr(LF := A_LoopField, 0), n := SubStr(LF, 1, -1), l := StrLen(n)
		if c in ?,#,*
			loop, %p_#%
			{
				p := p_%A_Index%
				if !(SubStr(p, 1, l) = n)
					continue
				v := SubStr(p, l+1)
				if (c="*" || c="#")	{
					if (c="#") && (v+0 = "")
						continue
					o%A_Index% := v	
				} else ifEqual, c, ?, SetEnv, o%A_Index%, 1
				break
			}
		else o%A_Index% := p_%LF%
		ifGreater, A_Index, 10, break
	}
	return no
}