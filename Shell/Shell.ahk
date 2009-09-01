/* Title:	Shell
			*Controls the Explorer windows.*
 */

/*
  Function:		GetCount
 				Get the number of items in the view.
 
  Parameters:	
 				pHwnd	- Handle to windows explorer instance.
 				flag	- set "sel" to get number of selected items.
 
  Returns:		
 				Number of items, or -1 on failure.
 				
 */
Shell_GetCount( pHwnd, flag="") {

	ieObj := Shell_GetIEObject( pHwnd ) 
	fvObj := Shell_GetFolderView( ieObj )
	if !fvObj
		return -1

	if (flag="all") or flag = ""
		param := 0x00000002 ;SVGIO_ALLVIEW 
	else if (flag="sel")
		param := 0x00000001

	return IFolderView_ItemCount(fvobj, param)
}

/*
  Function: GetIEObject
 			Get IWebBrowser2 interface pointer from open explorer windows
 
  Parameters: 
             hwndFind - Return interface pointer for instance with given hwnd.
 
  Returns:
 			IWebBrowser2 interface pointer
 */
Shell_GetIEObject( hwndFind="" ) {
	static 	IID_IWebBrowser2  := "{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}"

	sw := ShellWindows_Create()
	loop, % ShellWindows_Count(sw)
	{
		COM_Release(dispObj)

		dispObj := ShellWindows_Item( sw, A_Index-1 )					;get Dispatcher interface
		if !(ieObj := COM_QueryInterface(dispObj, IID_IWebBrowser2))	;get IWebBrowser2 interface
			continue
		
		if WebBrowser2_HWND(ieObj) = hwndFind
			break

		COM_Release(ieObj), ieObj := 0
	}

	return ieObj
}

/*
 Function:		GetPath
				Returns the currently open file system path in the given explorer window

 Parameters:	
				pHwnd	- Handle to windows explorer instance

 Returns:
				Path of currently open folder.
 */
Shell_GetPath( pHwnd ) {
	static IID_IPersistFolder2	:= "{1AC3D9F0-175C-11d1-95BE-00609797EA4F}"

	ieObj := Shell_GetIEObject( pHwnd ) 

	;get folder view automatition object
	fvObj := Shell_GetFolderView(ieObj)

	pf2Obj := IFolderView_GetFolder(fvObj, IID_IPersistFolder2)
	pidl := IPersistFolder2_GetCurFolder(pf2Obj)

	COM_Release(pfd2Obj), COM_Release(fvObj), COM_Release(ieObj)

	if API_SHGetPathFromIDList(pidl, fpath)
		return fpath
}

/*
  Function:		GetSelection
 				Get selected item(s)
 
  Parameters:
 				hwnd	- Handle of Explorer window
  
  Returns:
 				Path of each selected item.
 */
Shell_GetSelection( pHwnd ) {
	ieObj := Shell_GetIEObject( pHwnd )
	fvObj := Shell_GetFolderView( ieObj )

	elObj := IFolderView_Items(fvObj)
	loop
	{
		pidl := IEnumIdList_Next(elObj)
		ifEqual, pidl, 0, break
		API_SHGetPathFromIDList(pidl, fpath)
		res .= fpath "`n"
	}
	COM_Release(fvObj),	 COM_Release(ieObj)
	return res
}

/*
  Function:		GetView
 				Gets the current view of desired Explorer window
 
  Parameters:	
 				pHwnd	- Handle to windows explorer instance
 
  Returns:		View mode type, see <SetView>
 */
Shell_GetView( pHwnd) {

	ieObj := Shell_GetIEObject( pHwnd ) 
	fvObj := Shell_GetFolderView( ieObj )

	r := IFolderView_GetCurrentViewMode( fvObj )
	COM_Release(fvObj), COM_Release(ieObj)

	return r
}

/*
  Function:		SelectItem
 				Select item by index
  
  Parameters:
 				hwnd	- Handle of Explorer window
 				idx1	- 0 based index of item to select
 				idx2	- All items up to the idx2 will be selected. Keep in mind that this method selects items 1 by 1 thus selecting large amount 
 						  of items isn't efficient.
 */
Shell_SelectItem(hwnd, idx1, idx2="") {
	ieObj := Shell_GetIEObject( Hwnd )
	fvObj := Shell_GetFolderView( ieObj )

	if idx2 is not Integer
		return IFolderView_SelectItem(fvObj, idx1)
	
	loop,  % idx2 - idx1 + 1
		 IFolderView_SelectItem(fvObj, idx1+A_Index)	
}

/*
	Function:	SetHook

	Parameter:
				Handler	- Name of the function to call on shell events.

	Handler:
		Reason		- Reason for which handler is called. 
		Param		- Parameter of the handler. Parameters are given bellow for each reason.

 >	OnShell(Reason, Param) {	
 >		static WINDOWCREATED=1, WINDOWDESTROYED=2, WINDOWACTIVATED=4, GETMINRECT=5, REDRAW=6, TASKMAN=7, APPCOMMAND=12
 >	} 
		
	Param:		
		WINDOWACTIVATED	-	The HWND handle of the activated window.
		WINDOWREPLACING	-	The HWND handle of the window replacing the top-level window.
		WINDOWCREATED	-	The HWND handle of the window being created.
		WINDOWDESTROYED	-	The HWND handle of the top-level window being destroyed.		
		GETMINRECT		-	A pointer to a RECT structure.
		TASKMAN			-	Can be ignored.
		REDRAW			-	The HWND handle of the window that needs to be redrawn.

	Remarks:
		Requires explorer to be set as a shell in order to work.

	Returns:
		0 on failure, name of the previous hook procedure on success.
 */
Shell_SetHook(Handler) {
	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on
	Process, Exist
	h := WinExist("ahk_pid " ErrorLevel)
	DetectHiddenWindows, %oldDetect%

	if !DllCall("RegisterShellHookWindow", "UInt", h) 
		return 0
	return OnMessage(DllCall( "RegisterWindowMessage", "str", "SHELLHOOK") , Handler)
}

/*
  Function:		SetPath
				Open the folder in given explorer window

 Parameters:	
				pHwnd	- Handle to windows explorer instance
				pPath	- path to be set or one of the tree symbols:
								o >  go forward
								o <  go back
								o |  go up
 Returns:
				True on success
 */
Shell_SetPath( pHwnd, pPath ) {
	static IID_IShellBrowser	:= "{000214E2-0000-0000-C000-000000000046}"
	static SID_STopLevelBrowser := "{4C96BE40-915C-11CF-99D3-00AA004AE837}"
	static SBSP_PARENT := 0x2000, SBSP_NAVIGATEBACK := 0x4000, SBSP_NAVIGATEFORWARD := 0x8000

	ieObj := Shell_GetIEObject( pHwnd ) 
	sbObj := COM_QueryService(ieObj, SID_STopLevelBrowser, IID_IShellBrowser)

	COM_Ansi2Unicode(pPath, wPath)

	pidl := 0
	if (pPath = "|") 
		flag := SBSP_PARENT
	else if (pPath ="<")
			flag :=	SBSP_NAVIGATEBACK	
		else if (pPath =">")
				flag :=	SBSP_NAVIGATEFORWARD	
			 else pidl := API_SHParseDisplayName( wPath ) 

	ShellBrowser_BrowseObject( sbObj, pidl, flag ) 
}

/*
  Function:		SetView
 				Sets the view in desired Explorer window
 
  Parameters:	
 				pHwnd	- Handle to windows explorer instance
 				pView	- Number, view mode type
 
  View Mode Types:
 
     ICON		- 1
     SMALLICON	- 2
     LIST		- 3
     DETAILS	- 4
     THUMBNAIL	- 5
     TILE		- 6
     THUMBSTRIP - 7
 
 */
Shell_SetView( pHwnd, pView ) {
	ieObj := Shell_GetIEObject( pHwnd ) 
	fvObj := Shell_GetFolderView( ieObj )

	r := IFolderView_SetCurrentViewMode( fvObj, pView )
	COM_Release(fvObj), COM_Release(ieObj)

	return r
}

Shell_getFolderView( ieObj ) {
	static IID_IShellBrowser	:= "{000214E2-0000-0000-C000-000000000046}"
		,  IID_IFolderView		:= "{CDE725B0-CCC9-4519-917E-325D72FAB4CE}"
		,  SID_STopLevelBrowser := "{4C96BE40-915C-11CF-99D3-00AA004AE837}"
	
	sbObj := COM_QueryService(ieObj, SID_STopLevelBrowser, IID_IShellBrowser)
	svObj := ShellBrowser_QueryActiveShellView( sbObj )
	fvObj := COM_QueryInterface(svObj, IID_IFolderView)

	COM_Release(sbObj), COM_Release(svObj)
	return fvObj
}

;============================================== PRIVATE ===================================

ShellWindows_Create(){
	static CLSID_ShellWindows := "{9BA05972-F6A8-11CF-A442-00A0C90A8F39}"
		,  IID_ShellWindows	 := "{85CB6900-4D95-11CF-960C-0080C7F4EE85}"
	

	return COM_CreateObject(CLSID_ShellWindows, IID_ShellWindows) 
}

ShellWindows_Count(obj){
	DllCall( COM_VTable(obj, 7), "Uint", obj, "intP", cnt ) 
	return cnt
}

ShellWindows_Item( obj, index=0 ) {
	DllCall( COM_VTable(obj, 8), "Uint", obj, "int64", 3, "int64", index, "UintP", ieObj)
	return ieObj
}

WebBrowser2_HWND( obj ) {
	DllCall( COM_VTable(obj, 37), "Uint", obj, "UintP", hwnd)
	return hwnd
}

ShellBrowser_BrowseObject( obj, pidl, wFlags ) {
  	DllCall( COM_VTable(obj, 11), "Uint", obj, "uint", pidl, "uint", wFlags)
}

ShellBrowser_QueryActiveShellView(obj) {
 	DllCall( COM_VTable(obj, 15), "Uint", obj, "UintP", ppshv)
	return ppshv
}

IFolderView_GetFolder(obj, riid) {
	If StrLen(riid) = 38
	   COM_GUID4String(riid, riid)

 	DllCall( COM_VTable(obj, 5), "Uint", obj, "str", riid, "UintP", ppv)
	return ppv
}

IFolderView_SetCurrentViewMode( obj, viewMode ) {
	return DllCall( COM_VTable(obj, 4), "Uint", obj, "Uint", viewMode)
}

IFolderView_SelectItem( obj, idx, flag=1) {
	return DllCall( COM_VTable(obj, 15), "Uint", obj, "Uint", idx, "Uint", flag)
}

IFolderView_Item(obj, idx) {
	DllCall( COM_VTable(obj, 6), "Uint", obj, "Uint", idx, "UintP", pidl)
	return pidl
}

IFolderView_GetCurrentViewMode( obj ) {

	r := DllCall( COM_VTable(obj, 3), "Uint", obj, "UintP", viewMode)
	if (r>0) or (viewMode > 10)
		return 0

	return viewMode
}

IFolderView_GetFocusedItem(obj) {
	r := DllCall( COM_VTable(obj, 10), "Uint", obj,  "UintP", piItem)
	if r > 0 
		return 0

	return piItem
}

IFolderView_ItemCount(obj, pFlag) {
 	r := DllCall( COM_VTable(obj, 7), "Uint", obj, "uint", pFlag, "UintP", pcItems)
	if r > 0 
		return -1

	return pcItems
}

IFolderView_Items(obj, pFlag=0x80000001) {
	guid := COM_GUID4String(IID_IEnumIDList,"{000214F2-0000-0000-C000-000000000046}")
	DllCall(COM_VTable(obj, 8), "Uint", obj, "Uint", pFlag, "Uint" ,guid, "UintP", p)
	return p
}  

IEnumIdList_Next(obj) {
     DllCall(COM_VTable(obj, 3), "Uint", obj, "Uint", 1, "UintP", pidl, "UintP", 0)
	 return pidl
}

IPersistFolder2_GetCurFolder(obj){
 	DllCall( COM_VTable(obj, 5), "Uint", obj, "UintP", ppidl)
	return ppidl
}

ShellFolder_GetDisplayNameOf(obj, pidl, uFlags) {
 	DllCall( COM_VTable(obj, 11), "Uint", obj, "UintP", ppidl, "uint", uFlags, "str", 0) ;???
	return name
}

API_SHGetPathFromIDList(pidl, ByRef pszPath ) {
	VarSetCapacity( pszPath, 255, 0 )
	return DllCall("shell32.dll\SHGetPathFromIDList", "uint", pidl, "str", pszPath)
}

API_SHParseDisplayName( ByRef path ) {
	r := DllCall( "shell32.dll\SHParseDisplayName", "uint", &path, "uint", 0, "uintP", pidl ,"uint",0, "uint", 0 )
	if r > 0 
		return 0

	return pidl
}

/* Group: Examples
 Display info about active Explorer window
 (start code)
  	    h := WinExist("ahk_class ExploreWClass")
 
 	    p := "Path: " Shell_GetPath( h )
 	    s := "Sel:`n" Shell_GetSelection( hwnd)          
 
 	    msgbox %p%`n%s%
 (end code)
 */

/*
  Group: About 
       o Ver 1.0 by majkinetor. See http://www.autohotkey.com/forum/topic19400.html
       o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
 */