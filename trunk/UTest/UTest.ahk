#SingleInstance, force

UTest_Start()	;execute tests

Assert_True( bExp, Name="") {
	if !bExp
		UTest_SetFail( Name )
}

Assert_False( bExp, Name="" ) {
	if bExp
		UTest_SetFail( Name )
}

Assert_Empty( Var, Name="" ){
	if (Var != "")
		UTest_SetFail( Name )
}

Assert_NotEmpty( Var, Name="" ){
	if (Var = "")
		UTest_SetFail( Name )
}

Assert_Contains(Var, String, Name=""){
	if !InStr(Var, String)
		UTest_SetFail( Name )
}

Assert_StartsWith(Var, String, Name=""){
	if SubStr(Var, 1, Strlen(String)) != String
		UTest_SetFail( Name )
}

Assert_EndsWith(Var, String, Name=""){
	ifEqual, String,,return
	if SubStr(Var, -1*Strlen(String)+1) != String
		UTest_SetFail( Name )
}

Assert_Match(Var, RegEx, Name=""){
	if !RegExMatch(Var, RegEx) 
		UTest_SetFail( Name )
}

UTest_SetFail(Name) {
	UTest("Name", Name), UTest("F", 1 )
}

UTest_RunTests(){
	tests := UTest_GetTests(), bNoGui := UTest("NoGui")
	
	bTestsFail := 0
	loop, parse, tests, `n
	{
		StringSplit, f, A_LoopField, %A_Space%
		%f1%()		
		bFail := UTest("F"), Name := UTest("Name"), fName := SubStr(f1,6)
		ifEqual, bFail, 1, SetEnv, bTestsFail, 1

		s .= (bFail ? "FAIL" : "OK") "," fName "," f2 "," Name "`n"
		UTest("F", 0),	UTest("Name", "")

		if !bNoGui
			LV_Add("", bFail ? "FAIL" : "OK", fName, f2, Name)
	}
	if !bNoGui
		LV_ModifyCol(), LV_ModifyCol(1, 100), LV_ModifyCol(3, 50), LV_ModifyCol(4, 150)

	UTest("TestsFail", bTestsFail)
	return SubStr(s, 1, -1)
}

UTest_GetTests() {
	s := UTest_GetFunctions()
	loop, parse, s, `n
	{
		if SubStr(A_LoopField, 1, 5)="Test_"
			t .= A_LoopField "`n"
	}
	return SubStr(t, 1, -1)
}

UTest_GetFunctions() {
	LowLevel_init()
	func_ptr := __getFirstFunc()
	loop{			
		line_ptr :=	NumGet(func_ptr+4, 0, "Uint"), lineno := NumGet(line_ptr+8, 0, "Uint")
		fNames .= DllCall("MulDiv", "Int", NumGet(func_ptr+0, 0, "UInt"), "Int",1, "Int",1, "str") " " lineno "`n"
		func_ptr := NumGet(func_ptr+44, 0, "UInt")
		ifEqual, func_ptr, 0, break
	}
	return SubStr(fNames, 1, -1)
}

UTest_getFreeGuiNum(){
	loop, 99  {
		Gui %A_Index%:+LastFoundExist
		IfWinNotExist
			return A_Index
	}
	return 0
}

UTest_Start( bNoGui = false) {
	UTest("NoGui", bNoGui)
	if !bNoGui
		hGui := UTest_CreateGui()
	s := UTest_RunTests()
	
	if hGui
	{
		Result := UTest("TestsFail") ? "FAIL" : "OK"
		ControlSetText,Static1, %Result%, ahk_id %hGui%
	}

	return s
}

UTest_CreateGui() {
	w := 400, h := 400
	n := UTest_getFreeGuiNum() 

	Gui, %n%: +LastFound +LabelUTest_
	hGui := WinExist()
	Gui, %n%: Add, ListView, w%w% h%h%, Result|Function|Line|Name
	Gui, %n%: Font, s10 bold, Courier New
	Gui, %n%: Add, Text, w%w% h40
	Gui, %n%: Show,autosize, UTest
	UTest("GUINO", n)

	Hotkey, ifWinActive, ahk_id %hGui%
	Hotkey, ESC, UTest_Close
	Hotkey, ifWinActive
	return hGui

 UTest_Close:
 	ExitApp
 return
}

UTest(var="", value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	_ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
return
}

#include LowLevel.ahk