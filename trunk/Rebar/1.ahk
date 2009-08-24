#NoEnv 
#SingleInstance, force 
SetBatchLines, -1 

   Gui, +LastFound +Resize 
   hGui := WinExist() 
   Gui, Show, w600 h300 hide 

  ;create edit 
   Gui, Add, Edit, HWNDhLog w400 h100, F1 - Maximize band 1`nF2 - Maximize band 2`nF3 - Toggle titles`n`nClick band title or separator to animate 

  ;create combo 
   ;Gui, Add, ComboBox, gOnCombo HWNDhCombo w0, item 1 |item 2|item 3 

   hMenu := Toolbar_Add(hGui, "OnToolbar", "menu", 0, "x0") 
   Toolbar_Insert(hMenu, "File,`nEdit`nView`nFavorites`nTools`nHelp") 
   Toolbar_AutoSize(hMenu, "fit") 

   hRebar := Rebar_Add(hGui, "fixedorder", "", "", "OnRebar")    
   ReBar_AddBand(hRebar, hMenu, "mW 0", "S usechevron break") 
   ReBar_AddBand(hRebar, hLog, "S gripperalways", "T log") 
    

   Gui, Add, ListView, x0 y120 gOnList, 1|2|3 
   loop, 10 
      LV_Add("", A_Index) 

   gui, show, 
return 

OnList: 
   MsgBox %A_GuiEvent%    
return 

OnCombo: 
  msgbox Combo Event 
return 

F3:: 
   titlesOff := !titlesOff 
   loop, % Rebar_Count(hRebar) 
      Rebar_SetBandStyle(hRebar, A_Index, (titlesOff ? "" : "-") "hidetitle") 



GuiClose: 
   ExitApp 
return 


#include Rebar.ahk 
#include Toolbar.ahk