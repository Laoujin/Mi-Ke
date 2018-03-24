; Stuff to help during doing Autohotkey :)


DevReloadScript:
;^#r::
; Double click tray icon to reload also
Notify("Script Reloaded")
Reload
return


DevListVars:
;!F11::
ListVars
return

DevKeyHistory:
;!F10::
KeyHistory
return

; Control + S: Auto-reload script when it's saved.
; (we assume the file path is in the Window title)
DevReloadScriptWhenSaved:
if (!WinActive(EDITOR_TITLEMATCHER))
	return

WinGetActiveTitle, winTitle
if (InStr(winTitle, A_Scriptdir))
	Goto DevReloadScript
return


; Capslock & A: Copy and google Autohotkey
BrowserSearchAutohotkey:
clipboard =
Send, ^c
ClipWait, 2
Run, http://www.google.com/search?q=autohotkey+%clipboard%
return
