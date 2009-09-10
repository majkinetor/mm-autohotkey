/*
 Function:		ShowMenu
				Show menu from the text string
  
 Parameters: 
				MDef	- Textual menu definition.
				Mnu		- Menu to show. Label with the same name as menu will be launched on item selection.
						  "" means first menu will be shown (default)
				Sub		- Optional subroutine that will override default label (named by menu)
				Sep		- Optional separator char used for menu items in menu definition, by default new line
				
 Returns:      
				Message describing error if it ocured or new line separated list of created menus.
				If return value is blank, ShowMenu just displayed menu already created in one of previous calls.

 Remarks:
				You must have in the code label with the same name as that given to the menu, otherwise
				ShowMenu returns "No Label" error (unless you used "sub" parameter in which case the same 
				applies to that subroutine). There must be no white space between menu name and start of the line.
				Set each menu item on new line, use "-" to define separator.
				To create submenu, use "item = [submenu]" notation where submenu must exist in the textual 
				menu definition. While referencing any particular menu as submenu multiple times will work 
				correctly, circular references will produce unexpected results. 
				You can use = after item to store some custom data there. If text after = doesn't contain valid
				submenu reference, it will just be removed before item is displayed.
				To make menu definition more compact use something else then new line as item separator
				for instance "|" :
 >
 >					[Mnu1]
 >					item1|item2|item3|-|item4=[Mnu2]|item5
 >					[Mnu2]
 >					menu21 = menu21|menu22|menu23|menu24									  
 >				
				You can then use this command to show the menu
 >					ShowMenu(mDef, "", "", "|")		;use first menu found and | as item separator

 About:
				o v1.1 by majkinetor
 */
ShowMenu( MDef, Mnu="", Sub="", Sep="`n", r=0 ) {
	static p, menus
	if (!r)  {
		if (Mnu = "") and (SubStr(MDef, 1, 1) = "[")				;use first menu if Mnu = ""
			Mnu := SubStr(MDef, 2, InStr(MDef, "]")- 2)
		p := Sub="" ? Mnu : Sub, menus:=""							;set on function call (not on recursion step)
	}

	Menu, %Mnu%, UseErrorLevel, on
	Menu, %Mnu%, Color,											    ;check if menu already exists
	if !ErrorLevel
		if !r {														;if this is first call, show the menu
			Menu, %Mnu%, Show
			return 
		} else return												; otherwise this is recursion step so just return
	
	if !(r || IsLabel(p))
		return "No Label"

	if !(s := SubStr(MDef, 1, StrLen(Mnu)+2) = "[" Mnu "]" )		;start index
		s := InStr(MDef, "`n[" Mnu "]")
	IfEqual, s, 0, Return "Menu not found"
	
	if !(e := InStr(MDef, "`n[",false, s+1))						;end index
		e := StrLen(MDef)		

 	if *(&MDef+s-1) = 10											;skip `n if on start
		s++
	s += Strlen(Mnu)+3, this := SubStr(MDef, s, e-s+1)				;extract menu def

	menus .= Mnu "`n"
	Loop, parse, this, %Sep%, `n`r
	{
		s := A_LoopField
		IfEqual, s, ,continue
		IfEqual, s,-,SetEnv,s,										;separator
		if j := RegExMatch(s, "S)(?<=\[).+?(?=\])", out)			;check for submenu	
			 s := SubStr(s, 1, InStr(s,"=")-1),   ShowMenu( MDef, out, sub, Sep, 1)
		else if k := InStr(s,"=")									;if it has = after it remove it
			s := SubStr(s, 1, k-1)
		Menu, %Mnu%, Add, %s%, % j ? ":" out : p
	}

	IfEqual, r, 0 , Menu, %Mnu%, Show								;if not in recursion, show
	return menus
}