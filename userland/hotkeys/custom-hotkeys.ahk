; Don't go into metro mode when I accidently
; press the left Windows button

; TODO: This should only be active in Windows 8
~LWin Up::
If (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 500) {
	; Press again to still go into metro mode
	Send {RWIN}
}
return





PinToTaskbar(FilePath)
{
    SplitPath,FilePath,File,Dir
    For w in ComObjCreate("Shell.Application").Namespace(Dir).ParseName(File).Verbs()
        if (w.Name = "Pin to Tas&kbar")
            return w.DoIt()
}

UnPinToTaskbar(FilePath)
{
    SplitPath,FilePath,File,Dir
    For i in ComObjCreate("Shell.Application").Namespace(Dir).ParseName(File).Verbs()
        if (i.Name = "Unpin from Tas&kbar")
            return i.DoIt()
}