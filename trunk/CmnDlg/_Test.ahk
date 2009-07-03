 ;basic usage

  CmnDlg_Icon(icon, idx := 4)
    msgbox Icon:   %icon%`nIndex:  %idx%

   if CmnDlg_Color( color := 0xFF00AA )
      msgbox Color:  %color%

   if CmnDlg_Font( font := "Courier New", style := "s16 bold underline italic", color:=0x80)
        msgbox Font:  %font%`nStyle:  %style%`nColor:  %color%

   res := CmnDlg_Open("", "Select several files", "", "", "c:\Windows\", "", "ALLOWMULTISELECT FILEMUSTEXIST HIDEREADONLY")
   IfNotEqual, res, , MsgBox, %res%
return