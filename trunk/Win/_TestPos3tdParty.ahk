#singleinstance, force
	hwnd := WinExist("Total Commander")
return

ESC::ExitApp
F1::Win_Recall(">", hwnd, "config.ini")
F2::Win_Recall("<", hwnd, "config.ini")

#include Win.ahk