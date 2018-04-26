; Improving upon things already present in Windows Explorer

#IfWinActive ahk_class CabinetWClass



; Esc twice to close open Windows Explorer
Esc::
	If (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 500)
		WinClose
	Else
		Send, {Esc}
Return



; Alt + Enter for ContextMenu.Properties does not work for a Drive
; $ so that we can still use Send !{enter}
$!enter::
selectedFiles := Explorer_GetSelected()
if (selectedFiles)
{
	Send !{enter}
}
else
{
	selectedFiles := ActiveFolderPath()
	isDrive := RegExMatch(selectedFiles, "\w:\\")
	if isDrive {
		Run, properties "%selectedFiles%"
	}
}
return



#IfWinActive



; Windows + Enter
; See image dimensions and file size
; Press again to copy dimensions to clipboard
lastImagePath :=
lastImageSize :=

#Enter::
selectedFiles := StrSplit(Explorer_GetSelected(), "`n")
selectedFile := selectedFiles[1]
if (selectedFile <> "ERROR") {
	If (lastImagePath = selectedFile and A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 2000) {
		clipboard := lastImageSize
		Notify("On Clipboard", lastImageSize)
		return
	}


	gdip1 := new Gdip()
	bitmap1 := Gdip.BitmapFromFile(selectedFile)
	if !bitmap1.Pointer
	{
		Notify("Image loading error!", selectedFile)
		return
	}


	lastImagePath := selectedFile
	lastImageSize := bitmap1.size.width "x" bitmap1.size.height

	FileGetSize, imageFileSize, %selectedFile%
	imageFileSize := "Size: " autoByteFormat(imageFileSize) "`n"

	imgInfo := lastImageSize
	Notify(imgInfo, imageFileSize "`n" selectedFile, 5)

	bitmap1 :=
	gdip1 :=
}
return




; The following hotkeys should work in both Windows Explorer and in Open/Save dialogs
; https://autohotkey.com/board/topic/9362-detect-opensave-dialog/

isExplorer() {
	return WinActive("ahk_class CabinetWClass") or DialogWindowActive()
}

; Control + Shift + 6: Switch to Details View (builtin)
; ~ = Do not block native function
; Resize first column so that filenames are completely visible
~^+6::
iniSectionName = apps-windows-explorer-open-save-dialog-size
if (isExplorer() and ReadMikeIni(iniSectionName, "active")) {
	if (DialogWindowActive()) {
		minWidth := ReadMikeIni(iniSectionName, "min-width")
		minHeight := ReadMikeIni(iniSectionName, "min-height")

		WinGetPos x, y, width, height, A
		if (width < minWidth or height < minHeight) {
			WinMove, A,, (A_ScreenWidth/2)-(minWidth/2), (A_ScreenHeight/2)-(minHeight/2), minWidth, minHeight
		}
	}


	Send {Control Down}{NumpadAdd}{Control Up}
}
return