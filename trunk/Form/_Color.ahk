_("mo! w d e")

	hForm1	:=	Form_New("w400 e3 h300 +Resize Font='bold s12, Courier'")
	h1 := Form_Add(hForm1, "Edit", "w100 h100")
	h2 := Form_Add(hForm1, "Edit", "w100 h100")
	h3 := Form_Add(hForm1, "Text", "w100 h100")

	CColor(h1, "", "White")
	CColor(h2, "Lime", "Blue")
	CColor(h3, "Red", "White")
	Form_Show()
return


Form1_Close:
	exitapp
return


#include inc
#include _Forms.ahk
#include CColor.ahk