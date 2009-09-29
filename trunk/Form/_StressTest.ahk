_("mo e w")
#MaxThreads, 255

	;=======================================================
	
	siblings  = 5		;desn't make a difference, except for update speed
	nestlevel = 5		;makes the difference; tests:  vista(32b, quad)=15, xppro(64b, quad)=5

	;=======================================================
	hForm1	:=	Form_New("w500 h900 Resize")
	loop, %siblings%
	{
		hPanel	 :=	Form_Add(hForm1,  "Panel",	 "",	  "",			"Align T, 300", "Attach p")
		loop, %nestlevel%	
			hPanel	 :=	Form_Add(hPanel,  "Panel",	 "",	  "",		"Align F", "Attach p r2")

		hButton1 :=	Form_Add(hPanel,  "Button",  "OK",	  "gOnControl",	"Align T, 50",  "Attach p r2", "Cursor hand", "Tooltip I have hand cursor")
		hButton2 :=	Form_Add(hPanel,  "Button",  "Cancel","gOnControl",	"Align T, 50",  "Attach p r2", "Tooltip jea baby")
		hCal1	:=  Form_Add(hPanel,  "ListView", "col",  "gOnControl",	"Align F",		"Attach p r2")
		LV_Add("",A_TickCount)
	}

	Form_Show()
return

F1::
	WinMove, ahk_id %hForm1%, , , , 300, 300
return

F2::
	if toggled
	{
		WinHide, ahk_id %hPanel3%
		WinShow, ahk_id %hPanel2%
		toggled := 0
	}
	else {
		WinHide, ahk_id %hPanel2%
		WinShow, ahk_id %hPanel3%
		toggled := 1
	}
return

OnControl:
	msgbox % A_GuiCOntrol
return

#include inc
#include _Forms.ahk