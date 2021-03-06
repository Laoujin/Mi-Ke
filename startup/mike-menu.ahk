; Config: mike.ini [tray-menu]
; https://autohotkey.com/docs/commands/Menu.htm

Menu, Tray, NoStandard

; ------------------------------------------------------------------------------------------------------------ TRAY ICON
SetTrayIcon() {
	iconKey := A_IsSuspended ? "icon-inverted" : "icon"
	trayIconPath := ReadMikeIni("tray-menu", iconKey, true)
	IfNotExist, %trayIconPath%
		trayIconPath := "<A_ScriptDir>\resources\iseedeadcode" (A_IsSuspended ? "-inverted" : "") ".ico"

	trayIconPath := PathReplacements(trayIconPath)
	Menu, Tray, Icon, %trayIconPath%,, 1
}

SetTrayIcon()

; --------------------------------------------------------------------------------------------------------- TRAY TOOLTIP
; https://autohotkey.com/docs/commands/OnMessage.htm
; https://autohotkey.com/docs/misc/SendMessageList.htm
OnMessage(0x404, "AHK_NOTIFYICON")
AHK_NOTIFYICON(wParam, lParam)
{
	if (lParam = 0x200) ; WM_MOUSEMOVE
	{
		SetTimer, MikeTrayTooltip, -1
		return 0
	}
}


; ------------------------------------------------------------------------------------------------------------ TRAY MENU

Menu, Tray, MainWindow


CreateQuickStartersMenu("ScriptControl", "Tray")
Menu, Tray, Add

; Start Mi-Ke when windows starts
; Startup path = %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
startupItem = Start Mi-Ke when computer starts
startupLink := A_Startup "\mike.ahk.lnk"
Menu, Tray, Add, %startupItem%, MikeToggleStartupShortcut
IfExist %startupLink%
{
	Menu, Tray, ToggleCheck, %startupItem%
}
Menu, Tray, Add, Choose tray icons, MikeChooseTrayIcon



CreateQuickStartersMenuItem("OpenConsoleLogWindow", "Tray")


Menu, Tray, Add

; More icons?
; https://www.digitalcitizen.life/where-find-most-windows-10s-native-icons
; http://www.glennslayden.com/code/shell32_icons.jpg

Menu, Tray, Add, View source (Explorer), MiKeTraySource
Menu, Tray, Icon, View source (Explorer), %A_WINDIR%\explorer.exe
Menu, Tray, Add, View source (IDE), MiKeTraySourceEditor
editorIcon := GetMenuIcon(EDITOR)
if (editorIcon) {
	Menu, Tray, Icon, View source (IDE), %editorIcon%
}
Menu, Tray, Add, View source (Github), MiKeTraySourceGithub
Menu, Tray, Add


CreateQuickStartersMenu("Autohotkey")
CreateQuickStartersMenu("Browsers")
CreateQuickStartersMenu("Consoles")
CreateQuickStartersMenu("Editors")
CreateQuickStartersMenu("Programs")
CreateQuickStartersMenu("Windows")

Menu, Tray, Add

Menu, Tray, Add, E&xit, MiKeTrayExit

; 1=For one click to activate default (2=double click=default)
;Menu, Tray, Click, 1
;Menu, Tray, Default, Open UI

; Code if we want to do different things for tray single/double click
; OnMessage(0x404, "AHK_NOTIFYICON")
; AHK_NotifyIcon(wParam, lParam) {
; 	static Delay := 300, TimeSinceLastClick := A_TickCount
; 	if (lParam = 0x202 && A_TickCount - TimeSinceLastClick > Delay) { ; WM_LBUTTONUP
; 		TimeSinceLastClick := A_TickCount
; 		Menu, Tray, Show   ; Show the menu
; 	}
; }




Goto, MiKeContinue



; ----------------------------------------------------------------------------------------------------- Tray Subroutines


MikeTrayTooltip:
	inputStr := ReadMikeIni("tray-menu", "tooltip")
	inputStr := ReplaceSystemInfo(inputStr)
	Menu, Tray, Tip, %inputStr%
return


MikeChooseTrayIcon:
	FileSelectFile, trayIconPath, 3, , Pick new tray icon, Icons (*.ico)
	if trayIconPath {
		customTrayIconPath = %A_ScriptDir%\resources\mike.ico
		FileCopy, %trayIconPath%, %customTrayIconPath%, 1
		WriteMikeIni("<A_ScriptDir>\resources\mike.ico", "tray-menu", "icon")
	}

	FileSelectFile, trayIconPath, 3, , Pick new tray icon used while Mi-Ke is suspended, Icons (*.ico)
	if trayIconPath {
		customTrayIconPath = %A_ScriptDir%\resources\mike-inverted.ico
		FileCopy, %trayIconPath%, %customTrayIconPath%, 1
		WriteMikeIni("<A_ScriptDir>\resources\mike-inverted.ico", "tray-menu", "icon-inverted")
	}

	SetTrayIcon()
	return

MiKeTrayExit:
ExitApp

MiKeTraySource:
	Run, explore %A_ScriptDir%
return

MiKeTraySourceEditor:
	path := EDITOR.path
	Run, "%path%" %A_ScriptDir%
return

MikeToggleStartupShortcut:
	IfNotExist %startupLink%
	{
		FileCreateShortcut, %A_ScriptFullPath%, %startupLink%
	}
	else
	{
		FileDelete, %startupLink%
	}
	Menu, Tray, ToggleCheck, %startupItem%
return

MiKeContinue:
