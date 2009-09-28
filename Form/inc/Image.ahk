/*
 Group: Image
		Adds image to the Button control.

 Parameters:
		Image	- Path to the .BMP file or image handle. First pixel signifies transparency color.
		Width	- Width of the image, if omitted, current control width will be used.
		Height	- Height of the image, if omitted, current control height will be used.
 
 */
Ext_Image(hButton, Image, Width="", Height=""){ 
    static BM_SETIMAGE=247, IMAGE_ICON=2, BS_BITMAP=0x80, IMAGE_BITMAP=0, LR_LOADFROMFILE=16, LR_LOADTRANSPARENT=0x20

	if (Width = "" || Height = "") {
		ControlGetPos, , ,W,H, ,ahk_id %hButton%
		ifEqual, Width,, SetEnv, Width, % W-8
		ifEqual, Height,,SetEnv, Height, % H-8
	}

	if Image is not integer 
	{
		if (!hBitmap := DllCall("LoadImage", "UInt", 0, "Str", Image, "UInt", 0, "Int", Width, "Int", Height, "UInt", LR_LOADFROMFILE, "UInt"))
			return 0
	} else hBitmap := Image 
    
    WinSet, Style, +%BS_BITMAP%, ahk_id %hButton% 
    SendMessage, BM_SETIMAGE, IMAGE_BITMAP, hBitmap, , ahk_id %hButton% 
    ifNotEqual, ErrorLevel, 0, DllCall("DeleteObject", "UInt", ErrorLevel)	;remove old bitmap if exists
      
    return hBitmap 
}
