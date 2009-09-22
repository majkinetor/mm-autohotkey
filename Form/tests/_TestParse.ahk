#include UTest.ahk
return

Test_String() {
	o = 48 53.66 tooltip='some =tooltip' show=1 input='2' 101
	no := Parse(o, "tooltip show input 1 2 3", p1, p2,p3, p4, p5, p6)
	Assert_True(p1="some =tooltip", p2=1, p3=2, p4=48, p5=53.66, p6=101, no=6)

	o = '  bleh '
	no := Parse(o, "1", p1)
	Assert_True(no=1, p1="  bleh ")
}

Test_Custom() {
	o = w800 h600 style='Resize ToolWindow' font='s12 bold, Courier New' HWND12 show dummy=red
	no := Parse(o, "w# h# red? HWND# style font dummy show?", w, h, bRed, HWND, style, font, d, bShow)
	Assert_True(w=800, h=600, bRed="", hwnd=12, style="Resize ToolWindow", font="s12 bold, Courier New", d="red", bShow, no=7)
}

Test_AHKGuiLike() {
	o = x20 y40 w0 h0 red HWNDvar gLabel                                                     
	no := Parse(o, "x# y# w# h# red? HWND* g*", x, y, w, h, red, hwnd, g)	
	Assert_True(x=20, y=40, w=0, h=0, red=1, hwnd="var", g="Label", no=7)
}

Test_ByPosition(){ 
	o = 'mika je car' 'pera je car' laza='laza je car'
	no := Parse(o, "laza 1 2", p1, p2, p3)
	Assert_True(no=3, p1="laza je car", p2="mika je car", p3="pera je car")
}

#include Parse.ahk