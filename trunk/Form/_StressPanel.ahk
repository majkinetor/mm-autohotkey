_("mo! e w")
#MaxThreads, 255

	;=======================================================
	
	siblings  = 100		;desn't make a difference.
	depthlevel = 5		;makes the difference; tests:  vista(32b, quad)=15, xppro(64b, quad)=5

	;=======================================================
	hForm1	:=	Form_New("w500 h600 +Resize")
	loop, %siblings%
	{
		hPanel	 :=	Form_Add(hForm1,  "Panel",	 "",	  "",		"Align T, 300", "Attach p")
		loop, %depthlevel%	
			hPanel	 :=	Form_Add(hPanel,  "Panel",	 "",	  "",	"Align F", "Attach p r2")

		hButton1 :=	Form_Add(hPanel,  "Button",  A_Index,	  "",	"Align T, 50",  "Attach p r2", "Cursor hand", "Tooltip I have hand cursor")
		hButton2 :=	Form_Add(hPanel,  "Button",  A_Index,"",	"Align T, 50",  "Attach p r2", "Tooltip jea baby")
		hCal1	:=  Form_Add(hPanel,  "ListView", A_Index,  "",	"Align F",		"Attach p r2")
		LV_Add("",A_TickCount)
	}
	Form_Show()
	Scroller_init()

	;mhm....
	loop, 3		
		Scroller_UpdateBars(hForm1)
return

F1:: 	Scroller_UpdateBars(hForm1)

Form1_Close:
	ExitApp
return

#include inc
#include _Forms.ahk