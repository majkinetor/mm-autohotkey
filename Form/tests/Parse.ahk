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
		c := SubStr(LF := A_LoopField, 0), n := SubStr(LF, 1, -1), l := StrLen(n),  j := A_Index
		if c in ?,#,*
		{
			loop, %p_#%
			{
				p := p_%A_Index%
				if !(SubStr(p, 1, l) = n)
					continue
				v := SubStr(p, l+1)
				if (c="*" || c="#")	{
					if (c="#") && (v+0 = "")
						continue
					o%j% := v	
				} else ifEqual, c, ?, SetEnv, o%j%, 1			
			}
		}
		else o%j% := p_%LF%
		ifGreater, A_Index, 10, break
	}
	return no
}
