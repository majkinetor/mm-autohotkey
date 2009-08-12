Panel_Parse()
loop, parse, opt, %A_Space%
{
	if (LF := A_LoopField) = ""	{
		p_%n% .= c ? A_Space : ""
		continue
	}
	lq:=SubStr(LF, 1, 1)="'",rq:=SubStr(LF,0,1)="'",len=StrLen(LF),sq:=lq&&!rq,e:=(!lq*!c)*InStr(LF,"="),liq:=e&&(SubStr(LF,e+1,1)="'"),iq:=liq&&rq
	n:=!c ? (e ? SubStr(LF,1,e-1):(i="" ? i:=1:++i)):n, p_# := i
	if (lq && rq) or iq
 		 p_%n% := SubStr(LF, iq ? e+2:2, len-2-(iq ? e : 0))
	else if (c || sq || liq) && !iq
		 p_%n% .= e ? SubStr(LF, e+2) : (" " SubStr(LF, sq ? 2 : 1,  rq ? len-1 : len))	,  c := !e && rq ? 0 : 1
	else p_%n% := e ? SubStr(LF, e+1) : LF
}