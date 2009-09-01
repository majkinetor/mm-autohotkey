#SingleInstance, Force 
#Persistent 
#NoEnv 
SetBatchLines, -1 
Return 

F12:: 
{ 
    If( TaskbarToggle = "" ) 
    { 
        VarSetCapacity( APPBARDATA, 36, 0 ) 
        NumPut( 36, APPBARDATA, 0, "UInt" ) ; cbSize 
        NumPut( WinExist( "ahk_class Shell_TrayWnd" ), APPBARDATA, 4, "UInt" ) ; hWnd 
        TaskbarToggle := 0 
    } 
    If( TaskbarToggle = 0 ) 
    { 
        NumPut( ( ABS_ALWAYSONTOP := 0x2 )|( ABS_AUTOHIDE := 0x1 ), APPBARDATA, 32, "UInt" ) ; lParam 
        TaskbarToggle := 1 
    } 
    Else 
    { 
        NumPut( ( ABS_ALWAYSONTOP := 0x2 ), APPBARDATA, 32, "UInt" ) ; lParam 
        TaskbarToggle := 0 
    } 
    DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA ) 
    Return 
}