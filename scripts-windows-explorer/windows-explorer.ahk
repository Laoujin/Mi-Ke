; Dependencies: vendor/windows-explorer-util.ahk, utilities/ini-reader.ahk, notify.ahk

; Control + Shift + N: New directory (builtin)
; Control + Shift + F: New file
ExplorerNewFile:
	DeselectSelectedFiles()
	Send {Appskey}
	Send w
	Send t
	Send ^a
Return


; Control + Shift + T: New txt file
ExplorerNewTextFile:
	DeselectSelectedFiles()
	Send {Appskey}
	Send w
	Send t
Return

DeselectSelectedFiles()
{
	selectedFiles := Explorer_GetSelected()
	if selectedFiles
	{
		; If no file is selected, ^Space may actually select it
		; after which {AppsKey} will open the wrong ContextMenu
		Send ^{Space}
	}
}



; Control + Alt + D: Open last downloaded file
ExplorerLastDownloadedFile:
	Loop, Files, %DOWNLOAD_FOLDER%\*, DF
	{
		FileGetTime, Time, %A_LoopFileFullPath%, C
		If (Time > Time_Orig)
		{
			Time_Orig := Time
			File := A_LoopFileFullPath
		}
	}
	Run, explorer.exe /select`,"%File%"
Return



; 2x Capslock: put path of selected file to clipboard
ExplorerSelectedFileDirToClipboard:
	If (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 500)
	{
		curPath := Explorer_GetPath()
		ToClipboardAndNotify(curPath)
	}
Return


; 2x Shift+Capslock: put path + filename to clipboard
ExplorerSelectedFilePathToClipboard:
	If (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 500)
	{
		SelectedFiles := Explorer_GetSelected()
		StringSplit, selectedFile, SelectedFiles, `n
		SplitPath, selectedFile1, name, dir, ext, name_no_ext, drive
		ToClipboardAndNotify(selectedFile1)
	}
Return


ToClipboardAndNotify(toClipboard)
{
	clipboard := toClipboard
	Notify("Path Copied", toClipboard)
}



; Control+Capslock: Open selected text clipboard in Explorer
OpenExplorerInClipboardPath:
	clipVal := CopyAndSaveClip()

	explorerCmd := "explorer /select," clipVal
	Run, %explorerCmd%
	Sleep 400
	Send {Enter}

	RestoreClip()
Return