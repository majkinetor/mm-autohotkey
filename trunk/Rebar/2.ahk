  Gui, +LastFound +Resize -MaximizeBox 
   $hGUI_Main := WinExist() 
   Gui, Show , w800 h600 
   ;====== Tab ====== 
   Gui, Add, Tab2, x0 y200 w400 h200 +Theme AltSubmit hwnd$hTab v_Tab, 1|2 
   Gui,  Tab, 1 
      Gui,  Add, Edit, w200 h100, 1 
   Gui,  Tab, 2 
      Gui,  Add, Button, w200 h100 
   Gui,  Tab 

   Btns = 
   (LTrim 
      1, 1, , showtext, 1 
      2, 2, , showtext, 2 
   ) 
   $hToolbar := Toolbar_Add($hGUI_Main, "Toolbar_OnEvent", "FLAT TOOLTIPS", "1L") 
   Toolbar_Insert($hToolbar, Btns) 
   Toolbar_SetButtonWidth($hToolbar, 52) 
    
   ;====== Rebar ====== 
   Gui, Add, Edit, hwnd$hEdit w200 h50 
   $hRebar := Rebar_Add($hGUI_Main, "", "", "x0 y80") 
   ReBar_AddBand($hRebar, $hEdit, "mw 300", "L400", "T Edit") 

Return 

GuiClose: 
GuiEscape: 
ExitApp 

Toolbar_OnEvent($hToolbar, pEvent, pPos, pTxt, pId){ 
   global 
    
   if (pEvent = "click") 
      MsgBox % pEvent 
}
#include Toolbar.ahk
#include Rebar.ahk