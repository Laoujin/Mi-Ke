isExplorerLike() {
	; Windows Explorer or Desktop
	return Explorer_GetWindow()
}

; OpenSaveFileDialogActive()

; -------------------------------------------------------------------- GETTING SELECTED FILE(S)/PATH IN WINDOWS EXPLORER


ActiveFolderPath()
{
	return PathCreateFromURL(ExplorerPath(WinExist("A")))
}

ExplorerPath(_hwnd)
{
	for Item in ComObjCreate("Shell.Application").Windows
		if (Item.hwnd = _hwnd)
			return, Item.LocationURL
}

PathCreateFromURL(URL)
{
	VarSetCapacity(fPath, Sz := 2084, 0)
	DllCall("shlwapi\PathCreateFromUrl" (A_IsUnicode ? "W" : "A" ), Str, URL, Str, fPath, UIntP,Sz, UInt, 0)
	return fPath
}

/*
	Library for getting info from a specific explorer window (if window handle not specified, the currently active
	window will be used).  Requires AHK_L or similar.  Works with the desktop.  Does not currently work with save
	dialogs and such.


	Explorer_GetSelected(hwnd="")   - paths of target window's selected items
	Explorer_GetAll(hwnd="")		- paths of all items in the target window's folder
	Explorer_GetPath(hwnd="")	   - path of target window's folder

	example:
		F1::
			path := Explorer_GetPath()
			all := Explorer_GetAll()
			sel := Explorer_GetSelected()
			MsgBox % path
			MsgBox % all
			MsgBox % sel
		return

	Joshua A. Kinnison
	2011-04-27, 16:12
*/

Explorer_GetPath(hwnd="")
{
	if !(window := Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"

	if (window="desktop")
		return A_Desktop

	path := window.LocationURL
	path := RegExReplace(path, "ftp://.*@","ftp://")
	StringReplace, path, path, file:///
	StringReplace, path, path, /, \, All

	; thanks to polyethene
	Loop
		If RegExMatch(path, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, path, path, `%%hex%, % Chr("0x" . hex), All
		Else Break
	return path
}

; Gets all files in selected folder?
; Explorer_GetAll(hwnd="") ; not in use atm
; {
; 	return Explorer_Get(hwnd)
; }

Explorer_GetSelectedArray(hwnd="")
{
	return Explorer_Get(hwnd,true)
}

; Gets selected file
Explorer_GetSelected(hwnd="",separator="`n")
{
	Array := Explorer_Get(hwnd,true)
	for index, element in Array
	{
		result .= element separator
	}
	return Trim(result, separator)
}

Explorer_GetWindow(hwnd="")
{
	; thanks to jethrow for some pointers here
	WinGet, process, processName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
	WinGetClass class, ahk_id %hwnd%

	if (process!="explorer.exe")
		return

	if (class ~= "(Cabinet|Explore)WClass")
	{
		for window in ComObjCreate("Shell.Application").Windows
			if (window.hwnd==hwnd)
				return window
	}
	else if (class ~= "Progman|WorkerW")
		return "desktop" ; desktop found
}

Explorer_Get(hwnd="",selection=false)
{
	Array := []

	if !(window := Explorer_GetWindow(hwnd))
		; return ErrorLevel := "ERROR"
		return %Array%

	if (window="desktop")
	{
		ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
		if !hwWindow ; #D mode
			ControlGet, hwWindow, HWND,, SysListView321, A
		ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
		base := SubStr(A_Desktop,0,1)=="\" ? SubStr(A_Desktop,1,-1) : A_Desktop
		Loop, Parse, files, `n, `r
		{
			path := base "\" A_LoopField
			IfExist %path% ; ignore special icons like Computer (at least for now)
				Array.Push(path)
		}
	}
	else
	{
		if selection
			collection := window.document.SelectedItems
		else
			collection := window.document.Folder.Items
		for item in collection {
			Array.Push(item.path)
		}
	}
	return %Array%
}



; --------------------------------------------------------------------------------------------- IS OPEN/SAVE FILE DIALOG
; https://autohotkey.com/board/topic/9362-detect-opensave-dialog/
; Doesn't seem to working in all (or many?) programs (unfortunately)

OpenSaveFileDialogActive()
{
	WinGet, active_hwnd, ID, A
	{
		if ( IsDialog( active_hwnd ) )
			return 1
		else
			return 0
	}

	return 0
}


IsDialog(dlg)
{

	local toolbar, edit, combo, button

	toolbar := FindWindowExID(dlg, "ToolbarWindow32", "0x440")	  ;windows XP
	if (toolbar = "0")
		toolbar := FindWindowExID(dlg, "ToolbarWindow32", "0x001")  ;windows 2k

	edit   := FindWindowExID(dlg, "Edit", "0x480")			; edit field
	combo  := FindWindowExID(dlg, "ComboBoxEx32", "0x47C")	; comboboxex field
	button := FindWindowExID(dlg, "Button", "0x001")		; second button


	if (toolbar && (combo || edit) && button)
		return 1
	else
		return 0
}


;------------------------------------------------------------------------------------------------
; Iterate through controls with the same class, find the one with ctrlID and return its handle
; Used for finding a specific control on a dialog

FindWindowExID(dlg, className, ctrlId)
{
	local ctrl, id

	ctrl = 0
	Loop
	{
		ctrl := DllCall("FindWindowEx", "uint", dlg, "uint", ctrl, "str", className, "uint", 0 )
		if (ctrlId = "0")
		{
			return ctrl
		}

		if (ctrl != "0")
		{
			id := DllCall( "GetDlgCtrlID", "uint", ctrl )
			if (id = ctrlId)
				return ctrl
		}
		else
			return 0
	}
}
