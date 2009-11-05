_("mo!")
	w := 550, h := 650
	hForm1 := Form_New("+Resize w" w " h" h)

	Form_Add(hForm1, "Text", "This is widget test")
	txt =
	(LTrim
		Some testing text goes here...

		Ha ha hahah ahaha
	)
	hWritter := Writer_Add(hForm1, 50, 60, 400, 300, "", txt)


	Form_Show()
return


#include ..\inc
#include ..\widgets\Writer.ahk