; Copy two blocks of text and compare them in a diff program
; Select a file/folder in Explorer to compare the contents

; Control + Windows + Alt + Left Arrow: Copy selected text and put in %A_Desktop%\left.txt
; Control + Windows + Alt + Down Arrow: Copy selected text in %A_Desktop%\right.txt and open diff program
; Control + Windows + Alt + Right Arrow: open diff program with left vs right
; Control + Windows + Alt + Up: show current clipboard content
; Control + Windows + Alt + 0: select a file with Dropbox conflict to compare it with the original file


GetLeft()
{
	return ReadMikeIni("memory-diff", "leftFile", true)
}

GetRight()
{
	return ReadMikeIni("memory-diff", "rightFile", true)
}

PasteClipboardToFile(file, clipContent)
{
	IfExist, %clipContent%
	{
		If (InStr(FileExist(clipContent), "D"))
		{
			return "DIRECTORY-COMPARE"
		}
		fileName := clipContent
		FileRead, clipContent, %clipContent%
		clipContent = %fileName%`n%clipContent%
	}

	; MsgBox %clipboard%
	FileDelete, %file%
	FileAppend, %clipContent%, %file%
}

DiffMergeOpenAppl(left := "", right := "")
{
	if (!left and !right) {
		left := GetLeft()
		right := GetRight()
	}

	mergeTool := ReadMikeIni("memory-diff", "merge-tool", true)
	mergeTool := GetQuickStarterInfoByName(mergeTool)
	exePath := PathReplacements(mergeTool.path)
	exePath .= mergeTool.mergePathArgs

	StringReplace, exePath, exePath, <left>, %left%
	StringReplace, exePath, exePath, <right>, %right%
	Run %exePath%
}

; Control + Win + Left: Clipboard to left.txt
MemoryDiffSaveLeft:
clipVal := CopyAndSaveClip()
PasteClipboardToFile(GetLeft(), clipVal)
diffMergeContentLeftFile := clipVal

trimmedContent := TrimContent(diffMergeContentLeftFile)
Notify("left.txt", trimmedContent)

RestoreClip()
return


; Control + Win + Alt + Down: Clipboard to right.txt and open diff tool
MemoryDiffSaveRightAndOpen:
clipVal := CopyAndSaveClip()
doCompare = false
if (clipVal = diffMergeContentLeftFile)
{
	MsgBox, 4, Identical, Clipboards are identical. Do you want to open diff anyway?, 1
	IfMsgBox, Yes
		doCompare = true
}
else
	doCompare = true

if doCompare = true
{
	result := PasteClipboardToFile(GetRight(), clipVal)
	if (result = "DIRECTORY-COMPARE" and InStr(FileExist(diffMergeContentLeftFile), "D")) {
		DiffMergeOpenAppl(diffMergeContentLeftFile, clipVal)
	} else {
		DiffMergeOpenAppl()
	}
}
RestoreClip()
return


; Control + Win + Alt + Right: Open diff tool
MemoryDiffOpen:
DiffMergeOpenAppl()
return


; Control + Win + Alt + 0: Compare with Dropbox unconflicted file
; In Windows Explorer, compare original file against "someFile (Bert's conflicted copy 2017-07-07).ext"
MemoryDiffDropboxOpen:
clipVal := CopyAndSaveClip()
IfExist, %clipVal%
{
	fileConflictRegex := ReadMikeIni("memory-diff", "dropbox-conflict-regex")
	isConflictFile := RegExMatch(clipVal, fileConflictRegex)
	if isConflictFile
	{
		PasteClipboardToFile(GetRight(), clipVal)

		originalFileName := RegExReplace(clipVal, fileConflictRegex, "")
		PasteClipboardToFile(GetLeft(), originalFileName)

		DiffMergeOpenAppl()
	}
}
RestoreClip()
return


; Control + Win + Alt + Up: See clipboard
MemoryDiffSee:
trimmedContent := TrimContent(Clipboard)
Notify("Clipboard contents", trimmedContent)
return
