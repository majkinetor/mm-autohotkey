loop, parse, opt, %A_Space%
{	
	if (LF := A_LoopField) = ""	{
		if c
			p_%n% .= A_Space
		continue
	}
	lq := SubStr(LF, 1, 1) = "'", rq := SubStr(LF, 0, 1) = "'",   len=StrLen(LF),   q := lq && rq,  sq := lq AND !rq
	e := (!lq*!c) * InStr(LF, "="),  liq := e && (SubStr(LF, e+1, 1)="'"),  iq := liq && rq
	if !c
		n := (e ? SubStr(LF, 1, e-1) : (i=""? i:=1:++i)), c := (c || sq || liq) AND !iq	
	if q or iq
		p_%n% := SubStr(LF, iq ? e+2:2, len-2-(iq ? e : 0))
	else if c
		if e
			 p_%n% := SubStr(LF, e+2)
		else p_%n% .= " " SubStr(LF, sq ? 2 : 1,  rq ? len-1 : len),   c := rq ? 0 : 1
	else p_%n% := e ? SubStr(LF, e+1) : LF
}