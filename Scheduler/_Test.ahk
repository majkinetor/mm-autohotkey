	
	v_Name  = My Task 2
	v_Run	= Notepad.exe
	v_Args  = test.txt
	v_Type	= HOURLY

	v_User = Administrator
	v_Password = kljun7


;	msgbox % Scheduler_Query("Blah")
	msgbox % Scheduler_Create("v")
return

F12:: Scheduler_Open()

#include Scheduler.ahk

