Extension_Image(HBtn, Parameters){ 
    static BM_SETIMAGE=247, IMAGE_ICON=2, BS_ICON=0x40 
	static param_1 := "Image", param_2 := "Size"
	loop, parse, Parameters, `n
		_ := param_%A_Index%, %_% := A_LoopField

	WinGetClass, cls, ahk_id %HBtn%
	ifNotEqual, cls, Button, return 0
		

	if Image is not integer 
    { 
        j := InStr(Image, ":", 0, 0), idx := 1 
        if j > 2  
            idx := Substr( Image, j+1), pPath := SubStr( Image, 1, j-1) 
        DllCall("PrivateExtractIcons","str",pPath,"int",idx-1,"int",Size,"int",Size,"uint*",hIco,"uint*",0,"uint",1,"uint",0,"int") 
        ifEqual, hIco, 0, return A_ThisFunc ">   Can't load image: " Image 

	} else hIco := Image 
    
    WinSet, Style, +%BS_ICON%, ahk_id %hBtn%
    SendMessage, BM_SETIMAGE, IMAGE_ICON, hIco, , ahk_id %hBtn% 
    if ErrorLevel 
        DllCall("DeleteObject", "UInt", ErrorLevel) 
		
    return hIco 
}
