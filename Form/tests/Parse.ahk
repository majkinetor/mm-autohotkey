Parse(O, pQ, ByRef o1="",ByRef o2="",ByRef o3="",ByRef o4="",ByRef o5="",ByRef o6="",ByRef o7="",ByRef o8="", ByRef o9="", ByRef o10=""){
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
		else 
		{	
			l := StrLen(n)
			loop, %p__0%			;	o = AlwaysOnTop Resize T50 TCFFFFFF 'asfdasf asfd asf' style=' ja `'mislim`' da je to ok  ' x567
			{					;	Parse(o, "OnTop? 3 style x#")
				p := p__%A_Index%
				if (!cC && !(SubStr(p, 1, l) = n)) || (cC & !(SubStr(p, 1, l) == n))
					continue				
				o := v := SubStr(p,l+1,1) = cA  ? SubStr(p,l+2) : SubStr(p, l+1),  p__%A_Index% := ""
				ifEqual, c, ?, SetEnv, o, 1
				if (c="#") && (v+0 = "")
					continue
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
