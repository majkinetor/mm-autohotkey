#SingleInstance, force
SetBatchLines, -1
	Gui, +LastFound
	hGui := WinExist()
	w := 330,  h := 400

	Gui, Add, Button, gBtn w100, Save
	Gui, Add, Button, gBtn w100 x+10, Reload

	hCtrl := Property_Add( hGui, 0, 40, w, h-40, "", "Handler")
	Property_SetColors(hCtrl, "pbAAEEAA sbaaeeaa sffff")
	Property_SetFont(hCtrl, "Separator", "bold s9, verdana")

	If !FileExist("properties")
	{
	  p = 
		(LTrim
		Name=My Separator
		Type=Separator
		Value=25
		
		Name=My Button
		Type=Button
		Value=click me

		Name=My Text
		Type=Text
		Value=default text

		Name=Some longer fat separator
		Type=Separator
		Value=55
	
		Name=My Checkbox
		Type=CheckBox
		Value=is that ok ?
		Param=0

 		Name=My HyperLink
		Type=HyperLink
		Value=www.autohotkey.com

		Name=My WideButton
		Type=WideButton
		Value=click me

 		Name=Digit
		Type=Integer
		Value=3

		Name=My ComboBox
		Type=ComboBox
)
		Property_Insert(hCtrl, p)
	}
	else Property_AddFromFile(hCtrl, "properties")

	Property_SetRowHeight(hCtrl, 25)
	Gui, show, w%w% h%h%
return

Stress(p, k=7){
	loop, %k%
		p .= "`n`n" p
	return p
}


~ESC:: 
	ControlGetFocus, out, A
	if !InStr(out, "Edit")
		Exitapp
return

F1::
	msgbox % Property_Count(hctrl)
return

GuiClose:
	ExitApp
return

Btn:
	if A_GuiControl = Reload
		Reload

	if A_GuiControl = Save
		msgbox % Property_Save(hCtrl, "Properties")
return

Handler(hCtrl, event, name, value, param){
	tooltip %event% %name% %value% %param%, 0, 0
	if event in EB,S
		return

	;do some stupid checks
	if (name="My Button") 
		if (Value = "") {
			MsgBox Stupid check: can't be empty
			return 1
		}			

	if (name="My Checkbox") 
		if (Param = 1) {
			MsgBox Stupid check: can't be 1, only 0 atm.
			return 1
		}			

	if (name="My WideButton") 
		if (Value = "click me") && event != "C"
			MsgBox Stupid check: Change the value, please :S

	if (name="Digit") 
		if Value not between 0 and 9
		{
			MsgBox Stupid check:   %value% is not a digit
			return 1
		}

}


/*
  Title:		Properties GUI
			Settings/Properties control editor/viewer.
 */

/*

 Function:		Add
				Creates property window.

 Parameters:
				hGui	- Handle of the parent
				x-h		- Control coordinates
				style   - White space separated list of style names.
				handler - Notification handler
 
 Handler:

 Retunrs:
				Control handle

 */
Property_Add(hGui, x=0, y=0, w=200, h=100, style="", Handler="") {
	hCtrl := SS_Add(hGui, x, y, w, h, "GRIDMODE CELLEDIT COLSIZE ROWSELECT " style, "Property_Handler")
	Property_initSheet(hCtrl)
	if IsFunc(Handler)
		Property(hCtrl "_handler", Handler)
	return hCtrl
}

/*
 Function:		AddFromFile
				Add properties from file

 Parameters:
				FileName - File from which to import properties. The file contains property definition list
				ParseIni - Set to TRUE if file is Ini file.

 Remarks:
				<Insert> function doesn't tolerate `r symbol. If you are manually loading text from a file, make sure you replace `r`n with `n
				or use *t option with FileRead

 */
Property_AddFromFile( hCtrl, FileName, ParseIni = false ) {
	FileRead, txt, *t %FileName%

	ifEqual, ParseIni, 0, return Property_Insert( hCtrl, txt )

	oldTrim := A_AutoTrim
	AutoTrim, on

	loop, parse, ini, `r`n, `r`n
	{
		ifEqual, A_LoopField, , continue
		line = %A_LoopField%
		c := SubStr(A_LoopField,1,1)

		if (c=";")
			continue
			
		if (c = "[")
			s .= "Type=Separator`nText=" line
		else	{
			j := InStr(line, "="), v := SubStr(line, j+1)

			if v is integer
				 Type := "Integer"
			else Type := "Text"

			s .= "Name=" SubStr(line, 1, j-1) "`nType=" Type "`nText=" v
		}
		s .= "`n`n"
	}

	AutoTrim, %oldTrim%
	return Property_Insert(hctrl, SubStr(s,1,-2))
}

/*
 Function:		Clear
				Clear Property window
 */
Property_Clear(hCtrl){
	SS_NewSheet(hCtrl), Property_initSheet(hCtrl), 	SS_Focus(hCtrl)
}

Property_Count(hCtrl) {
	return SS_GetRowCount(hCtrl)
}

/*
 Function:		Define
				Export the propety definition list from the control

 */
Property_Define(hCtrl) {
	n := SS_GetRowCount(hCtrl)
	loop, %n%
	{
		type := SS_GetCellType(hCtrl, 2, A_Index) 
		p := SS_GetCellText(hCtrl, 1, A_Index) 
		v := SS_GetCellText(hCtrl, 2, A_Index) 
		
		s = %s%Name=%p%`nType=
		if type=EXPANDED
			s .= "Separator"
		else if type contains WIDEBUTTON
			s .= "WideButton"
		else if type contains INTEGER
			s .= "Integer"
		else if type contains HYPERLINK
			s .= "HyperLink"
		else if type contains CHECKBOX,COMBOBOX
		{
			s .= InStr(type, "CHECKBOX") ? "CheckBox" : "ComboBox"
			s .= "`nParam=" SS_GetCellData(hCtrl, 2, A_Index) 

		}
		else if type contains COMBOBOX
			s .= "ComboBox"
		else s .= "Text"

		if type != EXPANDED
			s .= "`nValue=" v 

		s .= "`n`n"
	}
	return SubStr(s, 1, -2)
}

/*
	Returns row of the given property
 */
Property_Find(hCtrl, Name, StartAt=0) {

	cnt := SS_GetRowCount(hCtrl)
	loop, % cnt - StartAt
		if SS_GetCellText(hCtrl, 1, startAt + A_Index) = Name
			return A_Index
	return 0
}

/*
 Function:		GetValue
				Get property value

 Parameters:
				Name	- Property name for which to get value

 Returns:
				Value
 */
Property_GetValue( hCtrl, Name ) {
	ifEqual Name,,return	
	return SS_GetCellText(hCtrl, 2, Property_Find( hCtrl, Name))
}


/*
  Function:		Insert
				Insert property in the list on a given postion

  Parameters:
				Properties	- Property Defintion List. Definition is a multiline string containing 1 property attribute per line.
							  Definition List is the list of such definitions, separated by one blank line.
				Position	- Position in the list (1 based) at which to insert properties from the Definition List. 
							  0 (default) means that properties will be appended to the list. Insertion is very slow operation compared to appending.

  Definition:
				Name		- Name of the property to be displayed in first column
				Type		- Type of the property. Currently supported types are:
							  Text, Button, WideButton, CheckBox, ComboBox, Integer, Hyperlink, Separator. If not specified, Text is used by default.
				Value		- Value of the property. For ComboBox item this contains pipe delimited list of items.
				Param		- Parameter. Index of selected item for ComboBox, 1|0 for Checkbox.

  Remarks:
				The fastest way to add properties into the list is to craft property definition list and append it into the control with one call to this function.
				Using this function in a loop in many iterations will lead to seriously degraded performance (especially with Position option) with very large number of properties ( around 1K  )
 */
Property_Insert(hCtrl, Properties, Position=0){


	StringReplace, Properties, Properties, `n`n, `a, A
	StringSplit, a, Properties, `a
	
	nrows := SS_GetRowCount(hCtrl)
	if (Position > nrows+1)
		Position := 0

	if (Position != 0)
	{
		Loop, %a0%
			if (a%A_Index% != "")
				SS_InsertRow(hCtrl, Position)
	}
	else if (a0 = 1)
		 SS_InsertRow(hCtrl, -1)		
	else SS_SetGlobalFields(hCtrl, "nrows", nrows+a0)
	Property("", hCtrl ")pb pf vb vf sb sf", _pb, _pf, _vb, _vf, _sb, _sf),  k:=1

	Position--
	loop, %a0%
	{
		p := a%A_Index%
		ifEqual, p,, continue

		if Position != -1
			 i := Position + k++
		else i := nrows + k++
		
	 ;initialize
		Name := Value := Param := "", Type := "Text"
		state:="Default", fnt1=0, fnt2=1, txtal:="RIGHT MIDDLE", imgal="MIDDLE RIGHT", txtal2="MIDDLE LEFT"
		PB := _PB,  PF := _PF  ,VF := _VF,  VB := _VB

	 ;parse property into local variables

		loop, parse, p, `n
		{
			ifEqual, A_LoopField,, continue
			j := InStr(A_LoopField, "="),    desc := SubStr(A_LoopField, 1, j-1)
			%desc% := SubStr(A_LoopField, j+1, StrLen(A_LoopField))
		}

	 ;set SpreadSheet options
		if (bSeparator := (Type="Separator") ) 
			tpe:= "FORCETEXT", state := "Locked", fnt1 := 2,  PB := _SB, PF :=_SF, 	txtal := "CENTER MIDDLE"
		
		tpe := type " FORCETYPE"

		if (Type="HyperLink")
			tpe := "HYPERLINK", fnt2 := 3

		if (type="ComboBox")
	 		tpe := "COMBOBOX FIXEDSIZE", Value := SS_CreateCombo(hCtrl, Value), Data := Param
		
		if (Type="Button")		
			 tpe := "BUTTON FORCETEXT FIXEDSIZE"

		if (Type="WideButton")	
			 tpe := "WIDEBUTTON FORCETEXT", txtal2="CENTER MIDDLE"
		
		if (Type="CheckBox")
			tpe := "CHECKBOX FIXEDSIZE"

	 ;set row
		SS_SetCell(	hCtrl, 1, i
					,"type=TEXT", "txt=" Name
					,"bg=" PB, "fg=" PF
					,"state=LOCKED", "txtal=" txtal, "fnt=" fnt1, bSeparator ? "h=" Value : "")

		if (bSeparator)
			SS_ExpandCell( hCtrl, 1, i, 2, i )
		else
			SS_SetCell( hCtrl, 2, i
				,"type=" Tpe 
				,"txt="  Value
				,"bg=" VB, "fg=" VF
				,"txtal=" txtal2, "imgal=" imgal
				,"fnt=" fnt2, "state=" state, InStr("CheckBox,Combobox", type) ? "data=" Param : "")

	}

	sleep, -1
}

/*
 Function:		Save
				Save content of the control to the file.

 Parameters:
				FileName	- File to save to. If exists, it will be deleted first without confirmation.
 
 Returns:
				FALSE if there was a problem saving file, TRUE otherwise

 */
Property_Save(hCtrl, FileName) {
	FileDelete, %FileName%
	FileAppend, % Property_Define(hCtrl) , %FileName%
	return ErrorLevel
}

/*
 Function:		SetColors
				Set colors for any subset of property elements

 Parameters:
				colors	- String containing white space separated colors of property elements

 Colors:		
				PB PF - property bg & fg 
				VB VF - value bg & fg
				SB SF - separator bg & fg

 Example:
>				Property_SetColors("pbAAEEAA sbBFFFFF")   ;set property and separator background color
 */
Property_SetColors(hCtrl, colors){
	Loop, parse, colors, %A_Space%%A_Tab%,%A_Space%%A_Tab%
	{
		ifEqual, A_LoopField,,continue
		StringLeft c, A_LoopField, 2
		%c% := "0x" SubStr(A_LoopField, 3)
		Property(hCtrl c, %c%)
	}
}

/*
  Function:		SetFont
 				Set font for Propety element

  Parameters:
				Element	- One of the four available elements: Property, Value, Separator, Hyperlink
				Font	- Font description in AHK format
*/

Property_SetFont(hCtrl, Element, Font) {

	if (element="Property")
		idx := 0
	if (element="Value")
		idx := 1
	if (element="Separator")
		idx := 2
	if (element="HyperLink")
		idx := 3

	return SS_SetFont(hCtrl, idx, font)
}

Property_SetRowHeight(hCtrl, val) {
    c := Property_Count(hCtrl)
	SS_SetGlobalFields(hCtrl, "gcellht", val)
	if !c
		SS_DeleteRow(hCtrl, 1)
	SS_SetRowHeight(hCtrl, 0, 0)
}

Property_handler(hCtrl, event, earg, col, row){
	static last

	handler := Property(hctrl "_handler")
	ifEqual, handler, ,return

	if (event = "S") and col=1 
		SetTimer, Property_Timer, -1					;if user selects first column, switch to 2nd so he can use shortcuts on combobox, checkbox etc...	


	t := SS_GetCellType(hCtrl, col, row, 2)				;return base type of the cell
	if t in 11,12										;checkbox, combobox
		param := SS_GetCellData(hCtrl, col, row)		; get their data
	
	name  := SS_GetCellText(hCtrl, 1, row)
	value := event = "EA" ? earg : SS_GetCellText(hCtrl, 2, row)

	if event in UB,UA
	{	
		if t not in 11,12
			return

		if (event="UB")
			last := param

		StringReplace, event, event, U, E
	}

	;tooltip %etype% %event%,300, 300, 4
	r := %handler%(hCtrl, event, name, value, param)
	if (r && event="EA" && param != "")	; checkbox & combobox don't have EDIT, but only UPDATE notification and in that case you can't prevent change.
		SS_SetCellData(hCtrl, last, col, row)
	return r
}

Property_Timer:
	SS_SetCurrentCell(hCtrl, 2, SS_GetCurrentRow(hCtrl))
return

Property_initSheet(hCtrl){
	static b
	ControlGetPos, ,,w,h,,ahk_id %hCtrl%

	if !b
		SysGet, b, 46

	SS_SetColWidth(hCtrl, 1, 100)
	SS_SetColWidth(hCtrl, 2, w-100-2*b)
	SS_SetColCount(hCtrl, 2)
	SS_SetRowCount(hCtrl, 0)
	SS_SetRowHeight(hCtrl, 0, 0)
}

/*
	Storage function
			  
	
	Parameters:
			  var		- Variable name to retreive. To get up to 5 variables at once, omit this parameter
			  value		- Optional variable value to set. If var is empty value contains list of vars to retreive with optional prefix
			  o1 .. o5	- If present, reference to variables to receive values.
	
	Returns:
			  o	if _value_ is omited, function returns the current value of _var_
			  o	if _value_ is set, function sets the _var_ to _value_ and returns previous value of the _var_
			  o if _var_ is empty, function accepts list of variables in _value_ and returns values of those varaiables in o1 .. o5

	Examples:
			
 >			v(x)	 - return value of x
 >			v(x, v)  - set value of x to v and return previous value
 >			v("", "x y z", x, y, z)  - get values of x, y and z into x, y and z
 >			v("", "preffix_)x y z", x, y, z) - get values of preffix_x, preffix_y and preffix_z into x, y and z
			
*/
Property(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	if (var = "" ){
		if ( _ := InStr(value, ")") )
			__ := SubStr(value, 1, _-1), value := SubStr(value, _+1)
		loop, parse, value, %A_Space%
			_ := %__%%A_LoopField%,  o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	} else _ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}

#include ..\SpreadSheet\SpreadSheet.ahk