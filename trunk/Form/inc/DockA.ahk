DockA(HHost="", HClient="", DockDef="") {
   DockA_(HHost+0, HClient+0, DockDef, "")
}

DockA_(HHost, HClient, DockDef, Hwnd) {
   static
   
   if HClient && (DockDef != 3)
   {
      If !init 
         init := OnMessage(3, A_ThisFunc) ; WM_MOVE    ;adrSetWindowPos := DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "user32"), "str", "SetWindowPos")

      HClient += 0, HHost += 0
      if (DockDef="-") 
         if InStr(%HHost%, HClient) {
            StringReplace, %HHost%, %HHost%, %A_Space%%HClient%
            DllCall("SetWindowLong", "uint", HClient, "int", -8, "uint", %HClient%_oldparent)
            return
         } else return

      if (DockDef = "") {      ;pin
         WinGetPos hX, hY,,, ahk_id %HHost%
         WinGetPos cX, cY,,, ahk_id %HClient% 
         DockDef := "x(0,0," cX - hX ")  y(0,0," cY - hY ")"
      } 

      %HClient%_x1 := %HClient%_x2 := %HClient%_y1 := %HClient%_y2 := %HClient%_h1 := %HClient%_w1 := %HClient%_x3 := %HClient%_y3 := %HClient%_h2 := %HClient%_w2 := ""
      loop, parse, DockDef, %A_Space%%A_Tab%
      {
         ifEqual, A_LoopField,,continue

         t := A_LoopField, c := SubStr(t,1,1), t := SubStr(t,3,-1)
         StringReplace, t, t,`,,|,UseErrorLevel
         t .= !ErrorLevel ? "||" : (ErrorLevel=1 ? "|" : "")
         loop, parse, t,|,%A_Space%%A_Tab% 
            %HClient%_%c%%A_Index% := A_LoopField ? A_LoopField : 0         
      }
      %HClient%_oldparent := DllCall("SetWindowLong", "uint", HClient, "int", -8, "uint", hHost)
      %HHost% .= (%HHost% = "" ? " " : "") HClient " "
   } 
   
   ifEqual, HHost, 0,SetEnv, HHost, %Hwnd%
   ifEqual, %HHost%,,return

   oldDelay := A_WinDelay, oldCritical := A_IsCritical
   SetWinDelay, -1
   critical 100
   
   WinGetPos hX, hY, hW, hH, ahk_id %HHost%
   loop, parse, %HHost%, %A_Space%
   {       
      ifEqual, A_LoopField,,continue
      else j := A_LoopField
      WinGetPos cX, cY, cW, cH, ahk_id %j% 
      w := %j%_w1*hW + %j%_w2,  h := %j%_h1*hH + %j%_h2
      , x := hX + %j%_x1*hW + %j%_x2*(w ? w : cW) + %j%_x3
      , y := hY + %j%_y1*hH + %j%_y2*(h ? h : cH) + %j%_y3
      WinMove ahk_id %j%,,x,y, w ? w : "" ,h ? h : ""         ;   DllCall(adrSetWindowPos, "uint", hwnd, "uint", 0, "uint", x ? x : cX, "uint", y ? y : cY, "uint", w ? w : cW, "uint", h ? h :cH, "uint", 1044) ;4 | 0x10 | 0x400 
   }
   SetWinDelay, %oldDelay%
   critical %oldCritical%
}