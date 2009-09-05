#Include RaGrid.ahk 
#SingleInstance, force 

   Gui, +LastFound  
   hwnd := WinExist() 

;EDITTEXT,EDITLONG,   CHECKBOX,   COMBOBOX,   HOTKEY,   BUTTON,   IMAGE,   DATE,   TIME,   USER,   EDITBUTTON 
   hGrd := RG_Add(hwnd, 0, 30, 800, 500, "GRIDFRAME VGRIDLINES NOSEL" ) 

   RG_AddColumn(hGrd, "cap=zero" , "w=150", "ha=1", "ca=0", "type=EditText" ) 
   RG_AddColumn(hGrd, "cap=one"  , "w=150" ,"ha=1", "ca=0", "type=EditText" ) 
   RG_AddColumn(hGrd, "cap=two"  , "w=180" ,"ha=1", "ca=0", "type=EditText" ) 
   RG_AddColumn(hGrd, "cap=three", "w=150" ,"ha=1", "ca=0", "type=EditText" ) 
   RG_SetFont(hGrd, "s10 bold, Arial") 
   RG_SetHdrHeight(hGrd, 30), RG_SetRowHeight(hGrd, 22) 

  Loop, 20 
  { 
    aCol1 := aCol2 := aCol3 := aCol4 := "Row=" A_Index - 1 "  Col=" 
    aCol1 .= 0, aCol2 .= 1, aCol3 .= 2, aCol4 .= 3 
    RG_AddRow(hGrd, "aCol") 
  } 
   Gui, Show, h500 w800 
    
; -- Set events... 
; "HEADERCLICK,BUTTONCLICK,CHECKCLICK,IMAGECLICK,BEFORESELCHANGE,AFTERSELCHANGE,BEFOREEDIT 
; ,AFTEREDIT,BEFOREUPDATE,AFTERUPDATE,USERCONVERT" 
  RG_SetEvents(hGrd, "OnRgEvent", "HEADERCLICK AFTERSELCHANGE BEFOREEDIT AFTEREDIT") 


;-- Demonstrate that WM_NOTIFY events are stacked: Experiment w/ the order to see 
  Alternate_WM_NOTIFY(func, 1, 0, 0) 
  RG_SetEvents(hGrd, "OnRgEvent", "AFTERSELCHANGE AFTEREDIT") ; Change previous set event notifiers 
  Alternate_WM_NOTIFY2(func, 1, 0, 0) 


;   RG_SetEvents(hGrd, "OnRgEvent", "") ; Turn event notification off (or change) 
return 

^l::reload 

OnRgEvent: 
  ToolTip, % A_Now " - " RG_EVENT " | " RG_ROW "  " RG_COLUMN, 20, 40, 1 
;   OutputDebug % RG_EVENT " | " RG_ROW "  " RG_COLUMN 
return 


Alternate_WM_NOTIFY(wparam, lparam, msg, hwnd){ 
  static WM_NOTIFY := 0x4E, old=0, user 

  if !old { 
    old := OnMessage(WM_NOTIFY, "Alternate_WM_NOTIFY"), user := wparam 
    old := old = "Alternate_WM_NOTIFY" ? "-" : RegisterCallback(old, "", 4) 
    return 
  } 
  if old != - 
    DllCall(old, "uint", wparam, "uint", lparam, "uint", msg, "uint", hwnd) 

  ;Test message handler here .... 
  ToolTip, % A_Now " - Message stacking test notifier", 20, 20, 2 
} 
Alternate_WM_NOTIFY2(wparam, lparam, msg, hwnd){ 
  static WM_NOTIFY := 0x4E, old=0, user 

  if !old { 
    old := OnMessage(WM_NOTIFY, "Alternate_WM_NOTIFY2"), user := wparam 
    old := old = "Alternate_WM_NOTIFY2" ? "-" : RegisterCallback(old, "", 4) 
    return 
  } 
  if old != - 
    DllCall(old, "uint", wparam, "uint", lparam, "uint", msg, "uint", hwnd) 

  ;Test message handler here .... 
  ToolTip, % A_Now " - Message stacking test notifier2", 20, 60, 3 
} 


;- still used within in RaGrid.ahk.. 
InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4) 
{ 
    Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data. 
        DllCall("RtlFillMemory", "UInt", &pDest + pOffset + A_Index-1, "UInt", 1, "UChar", pInteger >> 8*(A_Index-1) & 0xFF) 
} 

ExtractInteger(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4) 
{ 
    Loop %pSize%  ; Build the integer by adding up its bytes. 
        result += *(&pSource + pOffset + A_Index-1) << 8*(A_Index-1) 
    if (!pIsSigned OR pSize > 4 OR result < 0x80000000) 
        return result  ; Signed vs. unsigned doesn't matter in these cases. 
    ; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart: 
    return -(0xFFFFFFFF - result + 1) 
}