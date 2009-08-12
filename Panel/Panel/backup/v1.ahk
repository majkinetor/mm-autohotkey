#Singleinstance, force
#NoEnv
SetBatchLines, -1

opt := "'opt1' opt2 'hah hah' 'c:\12bmp'  123 size=13 'style=s1       s2  s3'  style2='13' "
;opt := "'hah hah' 'c:\1\2.bmp'  123 size=13 'style=s1       s2  s3'  'style2=13' "
;opt := "'style2=13 asdf fs'"

t1 := A_TickCount

c := 0, i := 1
loop, 1000
loop, parse, opt, %A_Space%
{
	if (A_loopField = "") 
	{
		if c 
			p_%n% .= A_Space
		continue
	}
		
	e := InStr(A_LoopField, "="), lq := SubStr(A_LoopField, 1, 1) = "'", rq := SubStr(A_LoopField, 0, 1) = "'",   len=StrLen(A_LoopField)
	q := lq AND rq,  sq := lq AND !rq,  eq := !lq AND rq,   c := c || sq
	if !c or sq
		n := e ? SubStr(A_LoopField, (lq ? 2 : 1), e-(lq ? 2 :1)) : i++

;	msgbox %c% %n%
	if q
		if e
			 p_%n% := SubStr(A_LoopField, e+1, len-e-1)
		else p_%n% := SubStr(A_LoopField, 2, len-2)
	else if c
		if e
			 p_%n% := SubStr(A_LoopField, e+1)
		else p_%n% .= " " SubStr(A_LoopField, sq ? 2 : 1,  rq ? len-1 : len),   c := rq ? 0 : 1

	else p_%n% := e ? SubStr(A_LoopField, e+1) : A_LoopField

}
t2 := A_TickCount
msgbox % t2-t1